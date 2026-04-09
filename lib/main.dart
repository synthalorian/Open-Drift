import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'theme/synthwave_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for the ambient vibe
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Dark status bar for the synthwave aesthetic
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0221),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive for local persistence
  await Hive.initFlutter();
  await Hive.openBox<String>('saved_mixes');

  runApp(
    const ProviderScope(
      child: OpenDriftApp(),
    ),
  );
}

class OpenDriftApp extends StatelessWidget {
  const OpenDriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenDrift',
      debugShowCheckedModeBanner: false,
      theme: SynthwaveTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
