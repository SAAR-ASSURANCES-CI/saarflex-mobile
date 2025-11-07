import 'package:saarflex_app/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LogoutType {
  pauseTimeout,
  reload,
  appClosed,
}

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final AuthService _authService = AuthService();
  
  Function(LogoutType)? onLogout;

  bool _isInBackground = false;
  bool _isAppClosed = false;
  static bool _hasBeenInitialized = false;
  DateTime? _pausedAt;
  static const Duration _pauseTimeout = Duration(minutes: 10);

  void initialize() {
    if (_hasBeenInitialized) {
      onAppReload();
    }
    _hasBeenInitialized = true;
    _setupAppLifecycleListener();
  }

  void _setupAppLifecycleListener() {
    _detectReload();
  }

  void _detectReload() {
  }

  void onAppPaused() {
    if (_isAppClosed) return;
    _isInBackground = true;
    _pausedAt = DateTime.now();
  }

  void onAppResumed() {
    if (_isAppClosed) return;
    _isInBackground = false;
    
    if (_pausedAt != null) {
      final pauseDuration = DateTime.now().difference(_pausedAt!);
      if (pauseDuration >= _pauseTimeout) {
        _logoutUser('Application en pause depuis plus de 15 minutes', LogoutType.pauseTimeout);
      }
      _pausedAt = null;
    }
  }

  void onAppReload() {
    _logoutUser('Application rechargée', LogoutType.reload);
  }

  void onAppClosed() {
    if (_isAppClosed) return;
    _isAppClosed = true;
    _logoutUser('Application fermée', LogoutType.appClosed);
  }

  Future<void> _logoutUser(String reason, LogoutType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_timestamp');
      
      _authService.logout().catchError((e) {
      });
      
      _isInBackground = false;
      _isAppClosed = false;
      _pausedAt = null;
      
      if (onLogout != null) {
        onLogout!(type);
      }
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('auth_timestamp');
      } catch (e2) {
      }
      
      if (onLogout != null) {
        onLogout!(type);
      }
    }
  }

  bool get isInBackground => _isInBackground;

  bool get isAppClosed => _isAppClosed;

  void dispose() {
  }
}
