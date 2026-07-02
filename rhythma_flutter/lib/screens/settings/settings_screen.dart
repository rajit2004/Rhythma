import 'package:flutter/material.dart';
import '../../components/shared.dart';
import '../../config/theme.dart';
import '../../services/local_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Material(
            color: Colors.transparent,
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TintedIcon(
                    icon: Icons.logout_rounded,
                    color: RhythmaColors.coral,
                    size: 48,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Log Out',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Are you sure you want to log out of Rhythma?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: RhythmaColors.mutedFg,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: RhythmaColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: RhythmaColors.mutedFg),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // Close dialog
                            
                            // Mocking clearing state/data
                            await LocalStorageService.clearAll();
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logged out successfully'),
                                ),
                              );
                              Navigator.pop(context); // Go back to Profile screen
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RhythmaColors.coral,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Log Out'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: RhythmaGradients.bg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(title: 'App Preferences'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const TintedIcon(
                      icon: Icons.language_rounded,
                      color: RhythmaColors.primary,
                      size: 36,
                    ),
                    title: const Text('Language'),
                    subtitle: const Text('English'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: RhythmaColors.mutedFg),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: RhythmaColors.border),
                  ListTile(
                    leading: const TintedIcon(
                      icon: Icons.notifications_active_rounded,
                      color: RhythmaColors.teal,
                      size: 36,
                    ),
                    title: const Text('Reminders'),
                    subtitle: const Text('Daily logs, medication'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: RhythmaColors.mutedFg),
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: RhythmaColors.border),
                  ListTile(
                    leading: const TintedIcon(
                      icon: Icons.cloud_done_rounded,
                      color: RhythmaColors.rose,
                      size: 36,
                    ),
                    title: const Text('Cloud Synchronization'),
                    subtitle: const Text('Secured with Firebase'),
                    trailing: const Icon(Icons.chevron_right_rounded, color: RhythmaColors.mutedFg),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const TintedIcon(
                  icon: Icons.logout_rounded,
                  color: RhythmaColors.coral,
                  size: 36,
                ),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: RhythmaColors.coral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: RhythmaColors.mutedFg),
                onTap: () => _showLogoutDialog(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
