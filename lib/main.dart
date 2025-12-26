import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import '../core/di/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialisieren
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ProviderContainer erstellen, um Provider vor runApp zu verwenden
  final container = ProviderContainer();
  final secureStorage = container.read(secureStorageServiceProvider);

  // runApp mit ProviderScope, den Container überschreiben
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
