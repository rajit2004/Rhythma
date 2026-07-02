import 'package:flutter/material.dart';
import '../../components/shared.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  String _userName = 'Aarya';
  int _userAge = 28;
  int _cycleLength = 28;
  final int _mhsAverage = 85;
  final int _cycleDay = 12;

  List<Map<String, String>> _emergencyContacts = [];

  late final AnimationController _controller;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _statsFade;
  late final Animation<Offset> _statsSlide;
  late final Animation<double> _menuFade;
  late final Animation<Offset> _menuSlide;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadEmergencyContacts();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _statsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
    _statsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _menuFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );
    _menuSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final profile = LocalStorageService.getProfile();
    if (profile != null) {
      _userName = profile['name'] as String? ?? 'Aarya';
      _userAge = profile['age'] as int? ?? 28;
      _cycleLength = profile['cycle_length'] as int? ?? 28;
    }
  }

  void _loadEmergencyContacts() {
    _emergencyContacts = LocalStorageService.getEmergencyContacts();
  }

  String _getCyclePhase(int day) {
    if (day <= 5) return 'Menstrual Phase';
    if (day <= 13) return 'Follicular Phase';
    if (day == 14) return 'Ovulation Phase';
    return 'Luteal Phase';
  }

  void _showEditProfileSheet() {
    final nameController = TextEditingController(text: _userName);
    final ageController = TextEditingController(text: _userAge.toString());
    final cycleController = TextEditingController(text: _cycleLength.toString());

    String? nameError;
    String? ageError;
    String? cycleError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: RhythmaColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Edit Profile'),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: nameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    errorText: ageError,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cycleController,
                  decoration: InputDecoration(
                    labelText: 'Average Cycle Length (Days)',
                    errorText: cycleError,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    setSheetState(() {
                      nameError = null;
                      ageError = null;
                      cycleError = null;
                    });

                    final name = nameController.text.trim();
                    final ageVal = int.tryParse(ageController.text);
                    final cycleVal = int.tryParse(cycleController.text);

                    bool isValid = true;

                    if (name.isEmpty) {
                      setSheetState(() => nameError = 'Name cannot be empty');
                      isValid = false;
                    }

                    if (ageVal == null || ageVal < 10 || ageVal > 120) {
                      setSheetState(() => ageError = 'Age must be between 10 and 120');
                      isValid = false;
                    }

                    if (cycleVal == null || cycleVal < 15 || cycleVal > 45) {
                      setSheetState(() => cycleError = 'Cycle length must be between 15 and 45 days');
                      isValid = false;
                    }

                    if (isValid) {
                      setState(() {
                        _userName = name;
                        _userAge = ageVal!;
                        _cycleLength = cycleVal!;
                      });
                      
                      await LocalStorageService.saveProfile({
                        'name': name,
                        'age': ageVal!,
                        'cycle_length': cycleVal!,
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddEditContactDialog(int? editIndex, StateSetter setSheetState) {
    final contact = editIndex != null ? _emergencyContacts[editIndex] : null;
    final nameController = TextEditingController(text: contact?['name']);
    final phoneController = TextEditingController(text: contact?['phone']);
    
    String? nameError;
    String? phoneError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(editIndex == null ? 'Add Contact' : 'Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: nameError,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  errorText: phoneError,
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setDialogState(() {
                  nameError = null;
                  phoneError = null;
                });

                final name = nameController.text.trim();
                final phone = phoneController.text.trim();

                bool isValid = true;
                if (name.isEmpty) {
                  setDialogState(() => nameError = 'Name is required');
                  isValid = false;
                }
                if (phone.isEmpty || phone.length < 8 || !RegExp(r'^\+?[0-9\s\-]+$').hasMatch(phone)) {
                  setDialogState(() => phoneError = 'Enter a valid phone number (min 8 digits)');
                  isValid = false;
                }

                if (isValid) {
                  setSheetState(() {
                    if (editIndex == null) {
                      _emergencyContacts.add({'name': name, 'phone': phone});
                    } else {
                      _emergencyContacts[editIndex] = {'name': name, 'phone': phone};
                    }
                  });
                  await LocalStorageService.saveEmergencyContacts(_emergencyContacts);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyContactsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final contacts = _emergencyContacts;
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: RhythmaColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: 'Emergency Contacts',
                    action: 'Add New',
                    onAction: () {
                      _showAddEditContactDialog(null, setSheetState);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (contacts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'No emergency contacts set up yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: RhythmaColors.mutedFg),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: RhythmaColors.border,
                        ),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const TintedIcon(
                              icon: Icons.contact_phone_rounded,
                              color: RhythmaColors.rose,
                              size: 36,
                            ),
                            title: Text(
                              contact['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              contact['phone'] ?? '',
                              style: TextStyle(color: RhythmaColors.mutedFg),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, size: 20),
                                  onPressed: () {
                                    _showAddEditContactDialog(index, setSheetState);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: RhythmaColors.coral, size: 20),
                                  onPressed: () async {
                                    setSheetState(() {
                                      _emergencyContacts.removeAt(index);
                                    });
                                    await LocalStorageService.saveEmergencyContacts(_emergencyContacts);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RhythmaGradients.primary,
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: RhythmaColors.background,
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: RhythmaColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: RhythmaColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userName,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          '$_userAge years old',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: RhythmaColors.mutedFg,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: RhythmaColors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: RhythmaColors.teal.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, color: RhythmaColors.teal, size: 16),
              const SizedBox(width: 4),
              Text(
                'Cycle Day $_cycleDay • ${_getCyclePhase(_cycleDay)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: RhythmaColors.teal,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TintedIcon(icon: icon, color: color, size: 28),
              Icon(
                Icons.trending_flat_rounded,
                color: color.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: RhythmaColors.foreground,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: RhythmaColors.mutedFg,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_month_rounded,
                color: RhythmaColors.rose,
                value: '$_cycleLength days',
                label: 'Avg Cycle Length',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.psychology_rounded,
                color: RhythmaColors.teal,
                value: '$_mhsAverage',
                label: 'Avg Mental Health',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.insights_rounded,
                color: RhythmaColors.coral,
                value: '±1.2 days',
                label: 'Cycle Variability',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.history_toggle_off_rounded,
                color: RhythmaColors.primary,
                value: '27 days',
                label: 'Last Cycle Length',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionMenu() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit_rounded,
            color: RhythmaColors.primary,
            title: 'Edit Profile Information',
            onTap: _showEditProfileSheet,
          ),
          const Divider(height: 1, color: RhythmaColors.border),
          _buildActionTile(
            icon: Icons.emergency_rounded,
            color: RhythmaColors.rose,
            title: 'Medical Emergency Contact',
            onTap: _showEmergencyContactsSheet,
          ),
          const Divider(height: 1, color: RhythmaColors.border),
          _buildActionTile(
            icon: Icons.settings_rounded,
            color: RhythmaColors.foreground,
            title: 'App Settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) {
                setState(() {
                  _loadProfile();
                });
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: TintedIcon(icon: icon, color: color, size: 36),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right_rounded, color: RhythmaColors.mutedFg),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20).copyWith(bottom: 100, top: 24),
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Column(
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildHeader(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _statsFade,
            child: SlideTransition(
              position: _statsSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'Quick Stats'),
                  _buildStatsCards(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _menuFade,
            child: SlideTransition(
              position: _menuSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader(title: 'Account Settings'),
                  _buildActionMenu(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
