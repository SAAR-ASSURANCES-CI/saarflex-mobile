import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/providers/auth_provider.dart';
import 'constants/colors.dart';
import 'screens/auth/welcome_screen.dart';

void main() {
  runApp(const SaarflexApp());
}

class SaarflexApp extends StatelessWidget {
  const SaarflexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Saarflex',
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
      ),
    );
  }
}
