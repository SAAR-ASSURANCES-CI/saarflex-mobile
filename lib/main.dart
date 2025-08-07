import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/profile/profile_screen.dart';
import 'constants/colors.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

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

      // Page d'accueil
      home: const WelcomeScreen(),

      // Routes nommées pour la navigation
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        // '/edit-profile': (context) => const EditProfileScreen(), // À décommenter
      },

      // Gestion des routes non trouvées
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      },
    );
  }
}
