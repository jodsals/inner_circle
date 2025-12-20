import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';

/// Account settings page where users can manage their profile
class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontoeinstellungen'),
      ),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text('Nicht angemeldet'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (user.photoUrl != null)
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(user.photoUrl!),
                                )
                              else
                                const CircleAvatar(
                                  radius: 40,
                                  child: Icon(Icons.person, size: 40),
                                ),
                              const SizedBox(height: 16),
                              Text(
                                user.displayName ?? 'Unbekannt',
                                style: theme.textTheme.headlineSmall,
                              ),
                              Text(
                                user.email ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account Actions
                      Text(
                        'Kontoeinstellungen',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Change Display Name
                      _SettingsActionCard(
                        icon: Icons.person_outline,
                        title: 'Anzeigename ändern',
                        subtitle: user.displayName ?? 'Nicht festgelegt',
                        onTap: () => _showChangeDisplayNameDialog(context, ref, user.displayName),
                      ),
                      const SizedBox(height: 12),

                      // Change Profile Picture
                      _SettingsActionCard(
                        icon: Icons.photo_camera_outlined,
                        title: 'Profilbild ändern',
                        subtitle: user.photoUrl != null ? 'Bild festgelegt' : 'Kein Bild',
                        onTap: () => _showChangePhotoDialog(context, ref, user.photoUrl),
                      ),
                      const SizedBox(height: 12),

                      // Change Password
                      _SettingsActionCard(
                        icon: Icons.lock_outline,
                        title: 'Passwort ändern',
                        subtitle: 'Passwort aktualisieren',
                        onTap: () => _showChangePasswordDialog(context, ref),
                      ),
                      const SizedBox(height: 24),

                      // Logout Button
                      OutlinedButton.icon(
                        onPressed: () => _showLogoutConfirmation(context, ref),
                        icon: const Icon(Icons.logout),
                        label: const Text('Abmelden'),
                      ),
                      const SizedBox(height: 12),

                      // Delete Account Button
                      ElevatedButton.icon(
                        onPressed: () => _showDeleteAccountDialog(context, ref),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Konto löschen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Change Display Name Dialog
  static void _showChangeDisplayNameDialog(BuildContext context, WidgetRef ref, String? currentName) {
    showDialog(
      context: context,
      builder: (context) => _ChangeDisplayNameDialog(
        currentName: currentName,
        ref: ref,
      ),
    );
  }

  // Change Photo Dialog
  static void _showChangePhotoDialog(BuildContext context, WidgetRef ref, String? currentPhotoUrl) {
    showDialog(
      context: context,
      builder: (context) => _ChangePhotoDialog(
        currentPhotoUrl: currentPhotoUrl,
        ref: ref,
      ),
    );
  }

  // Change Password Dialog
  static void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ChangePasswordDialog(ref: ref),
    );
  }

  // Logout Confirmation
  static void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final authController = ref.read(authControllerProvider.notifier);
              await authController.logout();

              if (context.mounted) {
                context.go('/auth');
              }
            },
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );
  }

  // Delete Account Dialog
  static void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _DeleteAccountDialog(ref: ref),
    );
  }
}

/// Settings action card widget
class _SettingsActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Change Display Name Dialog
class _ChangeDisplayNameDialog extends StatefulWidget {
  final String? currentName;
  final WidgetRef ref;

  const _ChangeDisplayNameDialog({
    required this.currentName,
    required this.ref,
  });

  @override
  State<_ChangeDisplayNameDialog> createState() => _ChangeDisplayNameDialogState();
}

class _ChangeDisplayNameDialogState extends State<_ChangeDisplayNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Anzeigename ändern'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Neuer Anzeigename',
            hintText: 'Wie möchten Sie genannt werden?',
            border: OutlineInputBorder(),
          ),
          validator: (value) => Validators.validateRequired(value, 'Anzeigename'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            Navigator.of(context).pop();

            final authController = widget.ref.read(authControllerProvider.notifier);
            await authController.updateDisplayName(_controller.text.trim());

            if (context.mounted) {
              final state = widget.ref.read(authControllerProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'Anzeigename erfolgreich aktualisiert',
                  ),
                  backgroundColor: state.errorMessage != null ? Colors.red : Colors.green,
                ),
              );
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

/// Change Photo Dialog
class _ChangePhotoDialog extends StatefulWidget {
  final String? currentPhotoUrl;
  final WidgetRef ref;

  const _ChangePhotoDialog({
    required this.currentPhotoUrl,
    required this.ref,
  });

  @override
  State<_ChangePhotoDialog> createState() => _ChangePhotoDialogState();
}

class _ChangePhotoDialogState extends State<_ChangePhotoDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPhotoUrl ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Profilbild ändern'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Foto-URL',
                hintText: 'https://example.com/photo.jpg',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte geben Sie eine URL ein';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Geben Sie die URL Ihres Profilbilds ein',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            Navigator.of(context).pop();

            final authController = widget.ref.read(authControllerProvider.notifier);
            await authController.updatePhotoUrl(_controller.text.trim());

            if (context.mounted) {
              final state = widget.ref.read(authControllerProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'Profilbild erfolgreich aktualisiert',
                  ),
                  backgroundColor: state.errorMessage != null ? Colors.red : Colors.green,
                ),
              );
            }
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}

/// Change Password Dialog
class _ChangePasswordDialog extends StatefulWidget {
  final WidgetRef ref;

  const _ChangePasswordDialog({required this.ref});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Passwort ändern'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Aktuelles Passwort',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte geben Sie Ihr aktuelles Passwort ein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Neues Passwort',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Neues Passwort bestätigen',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwörter stimmen nicht überein';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            final authController = widget.ref.read(authControllerProvider.notifier);

            // Reauthenticate first
            await authController.reauthenticateWithPassword(_currentPasswordController.text);

            if (context.mounted) {
              final state = widget.ref.read(authControllerProvider);
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Update password
              await authController.updatePassword(_newPasswordController.text);

              if (context.mounted) {
                Navigator.of(context).pop();

                final updatedState = widget.ref.read(authControllerProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      updatedState.errorMessage ?? 'Passwort erfolgreich geändert',
                    ),
                    backgroundColor: updatedState.errorMessage != null ? Colors.red : Colors.green,
                  ),
                );
              }
            }
          },
          child: const Text('Ändern'),
        ),
      ],
    );
  }
}

/// Delete Account Dialog
class _DeleteAccountDialog extends StatefulWidget {
  final WidgetRef ref;

  const _DeleteAccountDialog({required this.ref});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Konto löschen'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sind Sie sicher, dass Sie Ihr Konto löschen möchten?',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            const Text(
              'Diese Aktion kann nicht rückgängig gemacht werden. Alle Ihre Daten werden dauerhaft gelöscht.',
            ),
            const SizedBox(height: 16),
            const Text('Bitte geben Sie Ihr Passwort ein, um fortzufahren:'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Passwort',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte geben Sie Ihr Passwort ein';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;

            final authController = widget.ref.read(authControllerProvider.notifier);

            // Reauthenticate first
            await authController.reauthenticateWithPassword(_passwordController.text);

            if (context.mounted) {
              final state = widget.ref.read(authControllerProvider);
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Delete account
              await authController.deleteAccount();

              if (context.mounted) {
                Navigator.of(context).pop();

                final updatedState = widget.ref.read(authControllerProvider);
                if (updatedState.errorMessage == null) {
                  context.go('/auth');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(updatedState.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Konto löschen'),
        ),
      ],
    );
  }
}
