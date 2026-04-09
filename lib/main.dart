import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'theme/drift_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('open_drift_mixes');
  runApp(const ProviderScope(child: OpenDriftApp()));
}

class OpenDriftApp extends StatelessWidget {
  const OpenDriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenDrift',
      debugShowCheckedModeBanner: false,
      theme: DriftTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
