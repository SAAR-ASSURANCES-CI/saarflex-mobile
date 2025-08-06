import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/colors.dart';
import 'screens/auth/welcome_screen.dart';

void main() {
  runApp(const MySaarApp());
}

class MySaarApp extends StatelessWidget {
  const MySaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySaar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
