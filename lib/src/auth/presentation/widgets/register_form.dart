import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../health_profile/presentation/widgets/disease_selection_widget.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_providers.dart';

/// Registration form with disease disclosure option
/// Designed for accessibility and users with chronic illnesses
class RegisterForm extends ConsumerStatefulWidget {
  final VoidCallback onToggleMode;

  const RegisterForm({
    super.key,
    required this.onToggleMode,
  });

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isSubmitting = false;
  List<String> _selectedConditionIds = [];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bitte bestätigen Sie Ihr Passwort';
    }
    if (value != _passwordController.text) {
      return 'Passwörter stimmen nicht überein';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return; // Prevent double submission

    // Validate chronic condition selection
    if (_selectedConditionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitte wählen Sie mindestens eine Erkrankung aus'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bitte akzeptieren Sie die Nutzungsbedingungen'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authController = ref.read(authControllerProvider.notifier);

      // Register user
      await authController.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      // Check if registration was successful
      final authState = ref.read(authControllerProvider);
      if (authState.user != null) {
        // Save health profile with selected conditions
        // Navigate to survey intro page after successful registration
        if (mounted) {
          context.go('/survey/intro/baseline');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    // Show error message if present
    ref.listen<AuthController>(
      authControllerProvider.notifier,
      (previous, next) {
        if (authState.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.errorMessage!),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
          ref.read(authControllerProvider.notifier).clearError();
        }
      },
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Konto erstellen',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Display Name Field
          TextFormField(
            controller: _displayNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Anzeigename',
              hintText: 'Wie möchten Sie genannt werden?',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) => Validators.validateRequired(value, "Anzeigename"),
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 20),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'E-Mail',
              hintText: 'ihre@email.de',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.validateEmail,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 20),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Passwort',
              hintText: 'Mindestens 8 Zeichen',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                tooltip: _obscurePassword
                    ? 'Passwort anzeigen'
                    : 'Passwort verbergen',
              ),
            ),
            validator: Validators.validatePassword,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 20),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Passwort bestätigen',
              hintText: 'Passwort wiederholen',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                tooltip: _obscureConfirmPassword
                    ? 'Passwort anzeigen'
                    : 'Passwort verbergen',
              ),
            ),
            validator: _validateConfirmPassword,
            enabled: !_isSubmitting,
          ),
          const SizedBox(height: 24),

          // Chronic Condition Selection
          DiseaseSelectionWidget(
            selectedDiseaseIds: _selectedConditionIds,
            onDiseasesSelected: (selectedIds) {
              setState(() {
                _selectedConditionIds = selectedIds;
              });
            },
          ),

          const SizedBox(height: 24),

          // Terms and Conditions
          CheckboxListTile(
            value: _acceptTerms,
            onChanged: _isSubmitting
                ? null
                : (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
            title: Text.rich(
              TextSpan(
                text: 'Ich akzeptiere die ',
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Nutzungsbedingungen',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' und '),
                  TextSpan(
                    text: 'Datenschutzerklärung',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          // Register Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleRegister,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Konto erstellen'),
          ),
          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'oder',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),

          // Switch to Login
          OutlinedButton(
            onPressed: _isSubmitting ? null : widget.onToggleMode,
            child: const Text('Bereits registriert? Anmelden'),
          ),
        ],
      ),
    );
  }
}
