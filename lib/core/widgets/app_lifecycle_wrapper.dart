import 'package:flutter/material.dart';
import 'package:saarflex_app/core/utils/session_manager.dart';
import 'package:saarflex_app/core/utils/logger.dart';

/// Widget wrapper pour gérer le cycle de vie de l'application
/// Intègre le SessionManager avec les événements Flutter
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
    AppLogger.info('📱 AppLifecycleWrapper initialisé');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App revient au premier plan
        AppLogger.info('🟢 App resumed - Annulation timer background');
        _sessionManager.onAppResumed();
        break;

      case AppLifecycleState.paused:
        // App passe en background
        AppLogger.info('🟡 App paused - Démarrage timer 5min');
        _sessionManager.onAppPaused();
        break;

      case AppLifecycleState.detached:
        // App fermée
        AppLogger.info('🔴 App detached - Déconnexion immédiate');
        _sessionManager.onAppClosed();
        break;

      case AppLifecycleState.inactive:
        // App inactive (transition)
        AppLogger.info('⚪ App inactive - Transition');
        break;

      case AppLifecycleState.hidden:
        // App cachée (rare)
        AppLogger.info('👻 App hidden - Transition');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
