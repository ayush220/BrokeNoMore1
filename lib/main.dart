import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Supabase with direct values for web
    await SupabaseService().initialize(
      'https://kgdiaceernjantbiqqnf.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtnZGlhY2Vlcm5qYW50YmlxcW5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQwMTM4MTEsImV4cCI6MjA2OTU4OTgxMX0.3UBKr0zyfjMpsg1jRT6ywNDv4IyBsdPc02-4N3X42iI',
    );
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error during initialization: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrokeNoMore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
