import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:saarciflex_app/core/utils/session_manager.dart';
import 'package:saarciflex_app/presentation/shared/app_lifecycle_wrapper.dart';
import 'presentation/features/auth/viewmodels/auth_viewmodel.dart';
import 'presentation/features/profile/viewmodels/profile_viewmodel.dart';
import 'presentation/features/products/viewmodels/product_viewmodel.dart';
import 'presentation/features/simulation/viewmodels/simulation_viewmodel.dart';
import 'presentation/features/contracts/viewmodels/contract_viewmodel.dart';
import 'presentation/features/souscription/viewmodels/souscription_viewmodel.dart';
import 'presentation/features/auth/screens/welcome_screen.dart';
import 'presentation/features/dashboard/screens/dashboard_screen.dart';
import 'presentation/features/auth/screens/login_screen.dart';
import 'presentation/features/auth/screens/signup_screen.dart';
import 'presentation/features/contracts/screens/contracts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final sessionManager = SessionManager();
  assert(() {
    sessionManager.onAppReload();
    return true;
  }());
  sessionManager.initialize();
  
  await GoogleFonts.pendingFonts([
    GoogleFonts.poppins(),
  ]);
  
  runApp(const Saarciflex());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Saarciflex extends StatelessWidget {
  const Saarciflex({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider<ProductViewModel>(
          create: (_) => ProductViewModel(),
          lazy: true,
        ),
        ChangeNotifierProvider<ProfileViewModel>(
          create: (_) => ProfileViewModel(),
          lazy: true,
        ),
        ChangeNotifierProvider<SimulationViewModel>(
          create: (_) => SimulationViewModel(),
          lazy: true,
        ),
        ChangeNotifierProvider<ContractViewModel>(
          create: (_) => ContractViewModel(),
          lazy: true,
        ),
        ChangeNotifierProvider<SouscriptionViewModel>(
          create: (_) => SouscriptionViewModel(),
          lazy: true,
        ),
      ],
      child: AppLifecycleWrapper(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'SAAR Assurances',
          debugShowCheckedModeBanner: false,

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
          locale: const Locale('fr', 'FR'),

          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: AppColors.primary, 
            fontFamily: GoogleFonts.poppins().fontFamily,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.white,
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
            '/contracts': (context) => const ContractsScreen(),
          },
        ),
      ),
    );
  }
} 

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthViewModel>().initializeAuth();
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authProvider, child) {
        if (!_initialized || authProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
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
