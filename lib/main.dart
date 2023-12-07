import 'package:flutter/material.dart';
import 'package:grafico_iot/app_themes.dart';
import 'package:grafico_iot/screens/home_screen.dart';
import 'package:grafico_iot/services/temp_alert.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await configureAppForNotifications();
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_KEY'] ?? '');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App IoT - Temperatura do servidor',
      theme: oceanicTheme,
      home: const HomeScreen(title: 'ColdServer IoT'),
    );
  }
}
