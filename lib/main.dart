import 'package:efootballranking/controller/entry_controller.dart';
import 'package:efootballranking/controller/match_result_controller.dart';
import 'package:efootballranking/controller/player_controller.dart';
import 'package:efootballranking/pages/home.dart';
import 'package:efootballranking/pages/landing_page.dart';
import 'package:efootballranking/pages/match_result.dart';
import 'package:efootballranking/pages/playerpage.dart';
import 'package:efootballranking/pages/report.dart';
import 'package:efootballranking/pages/settings.dart';
import 'package:efootballranking/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase
  await Supabase.initialize(
    url: 'https://naljobovnfkdqqexckxw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hbGpvYm92bmZrZHFxZXhja3h3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5OTM4NTAsImV4cCI6MjA2MTU2OTg1MH0.20emXeGuJMgpcp0Vh-8G5F4AuGdcWWkx2eqairO0ttI',
  );

  // ✅ Initialize OneSignal
  OneSignal.initialize('cf8de49d-ef20-4983-abd8-ad994200eb26');

  // Optional: Ask for notification permissions (especially for iOS)
  OneSignal.Notifications.requestPermission(true);

  // ✅ Start app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProvider()..fetchPlayers()),
        ChangeNotifierProvider(create: (_) => PlayerMatchResultProvider()),
        ChangeNotifierProvider(create: (_) => EntryProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // ✅ Enable immersive full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock orientation after UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/table':
            (context) => HomePage(), // Replace with your actual table page
        '/add_player':
            (context) => PlayerNameFormPage(), // You'll need to create this
        '/add_result':
            (context) => PlayerMatchResultPage(), // You'll need to create this
        '/settings': (context) => SettingPage(), // You'll need to create this
        '/report': (context) => ReportPage(),
      },
    );
  }
}
