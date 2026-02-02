import 'package:saarciflex_app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:saarciflex_app/core/utils/session_manager.dart';
import 'package:saarciflex_app/core/utils/font_helper.dart';
import 'package:saarciflex_app/presentation/shared/app_lifecycle_wrapper.dart';
import 'package:saarciflex_app/presentation/shared/splash_screen.dart';
import 'package:saarciflex_app/core/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
            fontFamily: FontHelper.poppinsFontFamily,
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleTextStyle: FontHelper.poppins(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: IconThemeData(color: AppColors.primary),
            ),
          ),

          routes: {
            '/': (context) => const SplashScreen(),
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
  bool _biometricDialogShown = false;

  @override 
  void initState() {
    super.initState();  
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await context.read<AuthViewModel>().initializeAuth();
        if (mounted) {
          setState(() {
            _initialized = true;
          });
          _checkAndShowBiometricDialog();
        }
      }
    });
  }

  Future<void> _checkAndShowBiometricDialog() async {
    if (_biometricDialogShown) return;

    final authProvider = context.read<AuthViewModel>();
    
    if (authProvider.isLoggedIn) return;

    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    final hasBiometricPassword = prefs.getString('biometric_password') != null;
    final hasBiometricEmail = prefs.getString('biometric_email') != null;

    if (!biometricEnabled || !hasBiometricPassword || !hasBiometricEmail) return;

    final isDeviceAuthSupported = await BiometricService.isDeviceAuthSupported();
    if (!isDeviceAuthSupported) return;

    _biometricDialogShown = true;

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final authenticated = await BiometricService.authenticateWithFallback(
      reason: 'Authentifiez-vous pour accéder à votre compte SAAR CI',
    );

    if (authenticated && mounted) {
      final biometricEmail = prefs.getString('biometric_email');
      final biometricPassword = prefs.getString('biometric_password');

      if (biometricEmail != null && biometricPassword != null) {
        await authProvider.login(
          email: biometricEmail,
          password: biometricPassword,
        );
      }
    }
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
                    style: FontHelper.poppins(
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
 