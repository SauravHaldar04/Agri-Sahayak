import 'package:supabase_flutter/supabase_flutter.dart';
import 'secrets.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Secrets.SUPABASE_URL,
      anonKey: Secrets.SUPABASE_ANON_KEY,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with OAuth (Google, etc.)
  Future<void> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
  }) async {
    try {
      await auth.signInWithOAuth(provider, redirectTo: redirectTo);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get user session
  Session? get session => auth.currentSession;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await auth.updateUser(UserAttributes(data: userData));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Create or update user profile
  Future<void> upsertUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await client.from('profiles').upsert({
        'id': userId,
        ...profileData,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      // Note: Admin operations require server-side implementation
      // For now, we'll just sign out the user
      await signOut();
    } catch (e) {
      rethrow;
    }
  }
}
