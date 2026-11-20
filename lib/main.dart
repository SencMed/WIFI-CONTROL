import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WifiControlApp());
}

class WifiControlApp extends StatelessWidget {
  const WifiControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF1769AA);
    return MaterialApp(
      title: 'WIFI CONTROL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: brandBlue, brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        appBarTheme: const AppBarTheme(centerTitle: false, backgroundColor: Color(0xFFF4F7FB)),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
