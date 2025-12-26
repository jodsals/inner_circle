import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/animated_logo.dart';
import '../widgets/animated_text.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';

/// Authentication page with login and registration
/// Designed for accessibility and users with chronic illnesses
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();

    // Shine animation controller
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Shine animation moves from -1 to 2 (left to right)
    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Start periodic shine animation every 8 seconds
    _startPeriodicShine();
  }

  void _startPeriodicShine() {
    _periodicTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        _shineController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _shineController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo with shine animation
                  Center(
                    child: AnimatedLogo(
                      height: 120,
                      assetPath: 'assets/app_logo/inner_circle_logo_highlighted.svg',
                      shineAnimation: _shineAnimation,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Welcome text with shine animation
                  AnimatedShineText(
                    text: 'InnerCircle',
                    shineAnimation: _shineAnimation,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Ihre sichere Community für Gesundheit und Wohlbefinden',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Auth Form with Card styling
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isLogin
                            ? LoginForm(
                                key: const ValueKey('login'),
                                onToggleMode: _toggleAuthMode,
                              )
                            : RegisterForm(
                                key: const ValueKey('register'),
                                onToggleMode: _toggleAuthMode,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Privacy Notice - Enhanced styling
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ihre Daten sind verschlüsselt und sicher geschützt',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
