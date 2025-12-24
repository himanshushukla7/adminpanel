import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Add this import

import './screens/login_screen.dart';
import './screens/dashboard_screen.dart'; // 2. Import your Dashboard Screen

void main() async {
  // 3. Required for async code in main
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Check the saved session status
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 5. Pass the status to MyApp
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  // 6. Accept the status in the constructor
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: const Color(0xFF0461A5),
        useMaterial3: true,
      ),
      // 7. LOGIC: If logged in, show Dashboard; otherwise, show Login
      home: isLoggedIn ? const DashboardScreen() : const LoginScreen(), 
    );
  }
}