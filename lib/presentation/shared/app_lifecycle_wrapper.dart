import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saarflex_app/core/utils/session_manager.dart';
import 'package:saarflex_app/main.dart';
import 'package:saarflex_app/presentation/features/auth/viewmodels/auth_viewmodel.dart';

class AppLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const AppLifecycleWrapper({super.key, required this.child});

  @override
  State<AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<AppLifecycleWrapper>
    with WidgetsBindingObserver {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionManager.onLogout = _handleLogout;
  }
  
  void _handleLogout(LogoutType type) {
    final navigator = navigatorKey.currentState;
    final context = navigatorKey.currentContext;
    if (navigator == null) return;
    
    if (context != null) {
      try {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        authViewModel.forceLogout();
      } catch (e) {
      }
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (type) {
        case LogoutType.pauseTimeout:
          navigator.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
          break;
        case LogoutType.reload:
          break;
        case LogoutType.appClosed:
          navigator.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
          break;
      }
    });
  }

  @override
  void dispose() {
    _sessionManager.onAppClosed();
    _sessionManager.onLogout = null;
    WidgetsBinding.instance.removeObserver(this);
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _sessionManager.onAppReload();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _sessionManager.onAppResumed();
        _refreshUserProfileIfNeeded();
        break;
      case AppLifecycleState.paused:
        _sessionManager.onAppPaused();
        break;
      case AppLifecycleState.detached:
        _sessionManager.onAppClosed();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _refreshUserProfileIfNeeded() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        authViewModel.ensureUserProfileLoaded();
      } catch (e) {
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

