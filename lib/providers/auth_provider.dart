import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  User? _currentUser;
  Session? _currentSession;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<AuthState>? _authSub;

  // Getters
  User? get currentUser => _currentUser;
  Session? get currentSession => _currentSession;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get userRole => _userProfile?['role'];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _userProfile != null;

  AuthProvider() {
    initialize();
    _bindAuthListener();
  }

  // Initialize auth state
  Future<void> initialize() async {
    print('AuthProvider: Initializing...');
    _setLoading(true);
    try {
      final session = _supabaseService.session;
      print('AuthProvider: Current session exists: ${session != null}');
      
      if (session?.user != null) {
        print('AuthProvider: Loading user profile for: ${session!.user.id}');
        _currentUser = session!.user;
        _currentSession = session;

        // Load user profile
        final profile = await _supabaseService.getUserProfileAndRole(
          session.user.id,
        );
        
        if (profile != null) {
          print('AuthProvider: Profile loaded successfully');
          _userProfile = profile;
        } else {
          print('AuthProvider: No profile found for user');
        }
      }
    } catch (e) {
      print('AuthProvider: Initialization error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
      print('AuthProvider: Initialization complete');
    }
  }

  void _bindAuthListener() {
    _authSub?.cancel();
    _authSub = _supabaseService.authStateChanges.listen((
      AuthState state,
    ) async {
      final session = state.session;
      switch (state.event) {
        case AuthChangeEvent.signedOut:
          _currentUser = null;
          _currentSession = null;
          _userProfile = null;
          notifyListeners();
          break;
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
          if (session?.user != null) {
            _currentUser = session!.user;
            _currentSession = session;
            // Load/refresh profile after deep link completes
            _userProfile = await _supabaseService.getUserProfileAndRole(
              session.user.id,
            );
            notifyListeners();
          }
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // Sign up with role and profile
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    Map<String, dynamic>? roleSpecificData,
  }) async {
    try {
      print('AuthProvider: Starting signup for email: $email');
      _setLoading(true);
      _clearError();

      final response = await _supabaseService.signUpWithProfile(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phone: phone,
        roleSpecificData: roleSpecificData,
      );

      if (response.user != null) {
        print('AuthProvider: Signup successful for user: ${response.user!.id}');
        _currentUser = response.user;
        _currentSession = response.session;

        // Load the created profile
        try {
          final profile = await _supabaseService.getUserProfileAndRole(
            response.user!.id,
          );
          _userProfile = profile;
          print('AuthProvider: Profile loaded after signup');
        } catch (profileError) {
          print('AuthProvider: Warning - could not load profile after signup: $profileError');
        }

        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Signup failed - no user returned');
      }
      return false;
    } catch (e) {
      print('AuthProvider: Signup error: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in and load profile
  Future<bool> signIn({required String email, required String password}) async {
    try {
      print('AuthProvider: Starting signin for email: $email');
      _setLoading(true);
      _clearError();

      final result = await _supabaseService.signInAndGetProfile(
        email: email,
        password: password,
      );

      if (result != null) {
        print('AuthProvider: Signin successful');
        _currentUser = result['user'];
        _currentSession = result['session'];
        _userProfile = result['profile'];

        notifyListeners();
        return true;
      } else {
        print('AuthProvider: Signin failed - no result returned');
      }
      return false;
    } catch (e) {
      print('AuthProvider: Signin error: $e');
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with OAuth
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabaseService.signInWithOAuth(provider);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabaseService.signOut();
      _currentUser = null;
      _currentSession = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabaseService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabaseService.updateProfile(userData: userData);

      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      return await _supabaseService.getUserProfile(userId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser != null) {
        await _supabaseService.updateUserProfile(
          userId: _currentUser!.id,
          profileData: updates,
        );

        // Reload profile
        final updatedProfile = await _supabaseService.getUserProfileAndRole(
          _currentUser!.id,
        );
        _userProfile = updatedProfile;

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      await _supabaseService.deleteAccount();
      _currentUser = null;
      _currentSession = null;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get dashboard route based on role
  String getDashboardRoute() {
    switch (userRole) {
      case 'advisor':
        return '/advisor-dashboard';
      case 'policymaker':
        return '/policymaker-dashboard';
      case 'farmer':
      default:
        return '/farmer-dashboard';
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
