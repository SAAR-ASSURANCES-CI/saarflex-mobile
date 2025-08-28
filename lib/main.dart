import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saarflex_app/providers/simulation_provider.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

import 'providers/product_provider.dart';

import 'screens/auth/welcome_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';

import 'constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Saarflex());
} 

class Saarflex extends StatelessWidget {
  const Saarflex({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..initializeAuth(),
        ),
    ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider()),

        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<SimulationProvider>(create: (_) => SimulationProvider()),
      ],
      child: MaterialApp(
        title: 'SAAR Assurance',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          fontFamily: GoogleFonts.poppins().fontFamily,

          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.white,
            background: AppColors.white,
          ),

          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: AppColors.primary),
          ),
        ),

        home: const AuthenticationWrapper(),
        
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },

      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement en cours...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

        if (authProvider.isLoggedIn) {
          return const DashboardScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}

class DebugAuthInfo extends StatelessWidget {
  const DebugAuthInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DEBUG AUTH STATE',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                'Loading: ${auth.isLoading}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                'Logged In: ${auth.isLoggedIn}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                'User: ${auth.currentUser?.nom ?? "None"}',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              if (auth.errorMessage != null)
                Text(
                  'Error: ${auth.errorMessage}',
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
            ],
          ),
        );
      },
    );
  }
}
