import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_providers.dart';

/// Login form with accessible design for users with chronic illnesses
class LoginForm extends ConsumerStatefulWidget {
  final VoidCallback onToggleMode;

  const LoginForm({
    super.key,
    required this.onToggleMode,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return; // Prevent double submission

    setState(() {
      _isSubmitting = true;
    });

    try {
      final controller = ref.read(authControllerProvider.notifier);
      await controller.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
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
            'Anmelden',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

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
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: 'Passwort',
              hintText: 'Ihr Passwort',
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
          const SizedBox(height: 12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSubmitting ? null : () {
                // TODO: Implement password reset
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwort zurücksetzen wird bald verfügbar sein'),
                  ),
                );
              },
              child: const Text('Passwort vergessen?'),
            ),
          ),
          const SizedBox(height: 24),

          // Login Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleLogin,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Anmelden'),
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

          // Switch to Register
          OutlinedButton(
            onPressed: _isSubmitting ? null : widget.onToggleMode,
            child: const Text('Neues Konto erstellen'),
          ),
        ],
      ),
    );
  }
}
