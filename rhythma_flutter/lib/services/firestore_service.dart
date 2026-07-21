import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local_storage_service.dart';
import '../providers/sync_status_provider.dart';

/// Handles offline-first Firestore synchronization.
///
/// Architecture:
/// - Hive (local) is always the source of truth for reads
/// - Firestore syncs when online + cloudSyncEnabled == true
/// - Pending writes queued in Hive under 'pending_cycle_sync' box
/// - Automatic retry on connectivity restore
/// - Last-write-wins conflict resolution (server timestamp wins)
class FirestoreService {
  static FirebaseFirestore? _db;
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  static final Connectivity _connectivity = Connectivity();
  static bool _initialized = false;
  static bool _isSyncing = false;

  /// Safe wrappers: only call SyncStatusProvider if the provider exists.
  static void _updateStatus(SyncStatus status, String type, {String? error}) {
    if (SyncStatusProvider.hasInstance) {
      SyncStatusProvider.instance.updateStatus(status, type, error: error);
    }
  }

  static void _setOnline() {
    if (SyncStatusProvider.hasInstance) {
      SyncStatusProvider.instance.setOnline();
    }
  }

  static void _setOffline() {
    if (SyncStatusProvider.hasInstance) {
      SyncStatusProvider.instance.setOffline();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ────────────────────────────────────────────────────────────────────────────

  /// Initialize Firestore and start connectivity listener
  static Future<void> init() async {
    if (_initialized) return;
    
    _db = FirebaseFirestore.instance;
    _db!.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Initial connectivity check
    final results = await _connectivity.checkConnectivity();
    _onConnectivityChanged(results);

    _initialized = true;
    debugPrint('FirestoreService: initialized with offline persistence');
  }

  static void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isOnline = results.any((r) => r != ConnectivityResult.none);
    
    if (isOnline) {
      _setOnline();
      // Trigger sync for current user
      final uid = LocalStorageService.currentUserId;
      if (uid != null && LocalStorageService.cloudSyncEnabled) {
        flushPendingQueue(uid);
        syncCycleLogs(userId: uid);
        syncProfile(userId: uid);
      }
    } else {
      _setOffline();
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CYCLE LOGS SYNC
  // ────────────────────────────────────────────────────────────────────────────

  /// Push local cycle logs to Firestore (last-write-wins via server timestamp)
  static Future<void> syncCycleLogs({required String userId}) async {
    if (!LocalStorageService.cloudSyncEnabled) {
      debugPrint('FirestoreService: cloud sync disabled, skipping cycle sync');
      _updateStatus(SyncStatus.synced, 'cycle');
      return;
    }
    if (_db == null || _isSyncing) return;

    final logs = LocalStorageService.getCycleLogs();
    if (logs.isEmpty) {
      debugPrint('FirestoreService: no local cycle logs to sync');
      _updateStatus(SyncStatus.synced, 'cycle');
      return;
    }

    _isSyncing = true;
    _updateStatus(SyncStatus.syncing, 'cycle');

    try {
      final batch = _db!.batch();
      final userRef = _db!.collection('client_sync').doc(userId);

      for (final log in logs) {
        final docRef = userRef.collection('cycle_logs').doc(log['start_date'] as String);
        final data = Map<String, dynamic>.from(log);
        // Add server timestamp for conflict resolution
        data['synced_at'] = FieldValue.serverTimestamp();
        data['device_id'] = LocalStorageService.currentUserId;
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('FirestoreService: synced ${logs.length} cycle logs for $userId');

      // Read back resolved server timestamps and update Hive
      for (final log in logs) {
        final docRef = userRef.collection('cycle_logs').doc(log['start_date'] as String);
        final doc = await docRef.get();
        if (doc.exists) {
          final resolvedData = doc.data()!;
          resolvedData['start_date'] = log['start_date'];
          await LocalStorageService.saveCycleLog(resolvedData);
        }
      }

      _updateStatus(SyncStatus.synced, 'cycle');
    } catch (e) {
      debugPrint('FirestoreService: cycle sync failed: $e');
      _updateStatus(SyncStatus.error, 'cycle', error: e.toString());
      // Queue for retry
      await _queuePendingCycleLogs(userId, logs);
    } finally {
      _isSyncing = false;
    }
  }

  /// Fetch cycle logs from Firestore and merge into local Hive (last-write-wins)
  static Future<void> pullCycleLogs({required String userId, int limit = 50}) async {
    if (!LocalStorageService.cloudSyncEnabled) return;
    if (_db == null) return;

    try {
      final snapshot = await _db!.collection('client_sync')
          .doc(userId)
          .collection('cycle_logs')
          .orderBy('start_date', descending: true)
          .limit(limit)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final localLog = LocalStorageService.getCycleLogForDate(DateTime.parse(doc.id));
        
        // Last-write-wins: compare server timestamp
        final serverTime = data['synced_at'] as Timestamp?;
        final localTime = localLog?['synced_at'] as Timestamp?;
        
        if (serverTime != null && (localTime == null || serverTime.compareTo(localTime) >= 0)) {
          // Server version is newer or equal - overwrite local
          data['start_date'] = doc.id; // Ensure start_date is present
          await LocalStorageService.saveCycleLog(data);
        }
      }
      debugPrint('FirestoreService: pulled ${snapshot.docs.length} cycle logs for $userId');
      _updateStatus(SyncStatus.synced, 'cycle');
    } catch (e) {
      debugPrint('FirestoreService: pull cycle logs failed: $e');
      _updateStatus(SyncStatus.error, 'cycle', error: e.toString());
    }
  }

  /// Queue cycle logs for retry when offline
  static Future<void> _queuePendingCycleLogs(String userId, List<Map<String, dynamic>> logs) async {
    final pendingBox = await Hive.openBox<Map>('pending_cycle_sync');
    for (final log in logs) {
      final key = '${userId}::${log['start_date']}';
      await pendingBox.put(key, {
        ...log, 
        'user_id': userId, 
        'queued_at': DateTime.now().toIso8601String()
      });
    }
    _updateStatus(SyncStatus.pending, 'cycle');
  }

  /// Flush pending cycle logs queue to Firestore
  static Future<void> flushPendingQueue(String userId) async {
    if (!LocalStorageService.cloudSyncEnabled) return;
    if (_db == null) return;

    final pendingBox = await Hive.openBox<Map>('pending_cycle_sync');
    final userPrefix = '$userId::';
    final keys = pendingBox.keys
        .where((k) => k.toString().startsWith(userPrefix))
        .toList();
    
    if (keys.isEmpty) return;

    debugPrint('FirestoreService: flushing ${keys.length} pending cycle logs for $userId');
    _updateStatus(SyncStatus.syncing, 'cycle');

    try {
      final batch = _db!.batch();
      final userRef = _db!.collection('client_sync').doc(userId);

      for (final key in keys) {
        final log = pendingBox.get(key)!;
        final docRef = userRef.collection('cycle_logs').doc(log['start_date'] as String);
        final data = Map<String, dynamic>.from(log);
        data.remove('user_id');
        data.remove('queued_at');
        data['synced_at'] = FieldValue.serverTimestamp();
        data['device_id'] = LocalStorageService.currentUserId;
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      
      // Clear synced items from queue
      for (final key in keys) {
        await pendingBox.delete(key);
      }
      
      debugPrint('FirestoreService: flushed ${keys.length} pending cycle logs for $userId');
      _updateStatus(SyncStatus.synced, 'cycle');
    } catch (e) {
      debugPrint('FirestoreService: flush pending queue failed: $e');
      _updateStatus(SyncStatus.error, 'cycle', error: e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PROFILE SYNC
  // ────────────────────────────────────────────────────────────────────────────

  /// Push local profile to Firestore
  static Future<void> syncProfile({required String userId}) async {
    if (!LocalStorageService.cloudSyncEnabled) return;
    if (_db == null) return;

    final profile = LocalStorageService.getProfile();
    if (profile == null) return;

    _updateStatus(SyncStatus.syncing, 'profile');

    try {
      final userRef = _db!.collection('client_sync').doc(userId);
      final data = Map<String, dynamic>.from(profile);
      data['synced_at'] = FieldValue.serverTimestamp();
      data['device_id'] = LocalStorageService.currentUserId;
      
      await userRef.set(data, SetOptions(merge: true));
      debugPrint('FirestoreService: synced profile for $userId');

      // Read back resolved server timestamp and update Hive
      final resolvedDoc = await userRef.get();
      if (resolvedDoc.exists) {
        final resolved = resolvedDoc.data()!;
        final merged = {...profile, ...resolved};
        await LocalStorageService.saveProfile(merged);
      }

      _updateStatus(SyncStatus.synced, 'profile');
    } catch (e) {
      debugPrint('FirestoreService: profile sync failed: $e');
      _updateStatus(SyncStatus.error, 'profile', error: e.toString());
    }
  }

  /// Fetch profile from Firestore and merge into local Hive
  static Future<void> pullProfile({required String userId}) async {
    if (!LocalStorageService.cloudSyncEnabled) return;
    if (_db == null) return;

    try {
      final doc = await _db!.collection('client_sync').doc(userId).get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final localProfile = LocalStorageService.getProfile() ?? {};
      
      // Last-write-wins based on synced_at timestamp
      final serverTime = data['synced_at'] as Timestamp?;
      final localTime = localProfile['synced_at'] as Timestamp?;
      
      if (serverTime != null && (localTime == null || serverTime.compareTo(localTime) >= 0)) {
        // Server is newer - merge server data into local (preserve local-only fields)
        final merged = {...localProfile, ...data};
        await LocalStorageService.saveProfile(merged);
      }
      
      debugPrint('FirestoreService: pulled profile for $userId');
      _updateStatus(SyncStatus.synced, 'profile');
    } catch (e) {
      debugPrint('FirestoreService: pull profile failed: $e');
      _updateStatus(SyncStatus.error, 'profile', error: e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // REAL-TIME LISTENERS (optional - for live sync indicator)
  // ────────────────────────────────────────────────────────────────────────────

  /// Stream of cycle logs from Firestore for real-time updates
  static Stream<QuerySnapshot<Map<String, dynamic>>> cycleLogsStream(String userId) {
    return _db!.collection('client_sync')
        .doc(userId)
        .collection('cycle_logs')
        .orderBy('start_date', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Stream of profile from Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream(String userId) {
    return _db!.collection('client_sync').doc(userId).snapshots();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CLEANUP
  // ────────────────────────────────────────────────────────────────────────────

  static void dispose() {
    _connectivitySubscription?.cancel();
  }
}