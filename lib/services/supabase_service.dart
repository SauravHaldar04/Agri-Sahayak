import 'package:supabase_flutter/supabase_flutter.dart';
import 'secrets.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => Supabase.instance.client.auth;

  // Deep link redirect URL used by Supabase auth (must match your app's intent filter/universal link)
  static const String _redirectUrl = 'io.supabase.flutter://login-callback/';

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

  // Sign up with user profile creation
  Future<AuthResponse> signUpWithProfile({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    Map<String, dynamic>? roleSpecificData,
  }) async {
    try {
      final response = await auth.signUp(
        
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      
        // Ensure email verification opens the app instead of localhost
      );

      // If signup successful, create user profile
      if (response.user != null) {
        await createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          phone: phone,
          role: role,
          roleSpecificData: roleSpecificData,
        );
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in and load user profile
  Future<Map<String, dynamic>?> signInAndGetProfile({
    required String email,
    required String password,
  }) async {
    try {
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user profile from database
        final profile = await getUserProfile(response.user!.id);
        return {
          'user': response.user,
          'session': response.session,
          'profile': profile,
        };
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile with role-specific data
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
    String role = 'farmer',
    Map<String, dynamic>? roleSpecificData,
  }) async {
    try {
      final profileData = {
        'auth_id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role,
        'is_verified': false,
      };

      // Add role-specific fields
      if (roleSpecificData != null) {
        switch (role) {
          case 'farmer':
            profileData.addAll({
              'farm_size_hectares': roleSpecificData['farmSize'],
              'primary_crop': roleSpecificData['primaryCrop'],
              'secondary_crops': roleSpecificData['secondaryCrops'],
              'soil_type': roleSpecificData['soilType'],
              'irrigation_type': roleSpecificData['irrigationType'],
              'experience_years': roleSpecificData['experienceYears'],
              'location_latitude': roleSpecificData['latitude'],
              'location_longitude': roleSpecificData['longitude'],
              'location_address': roleSpecificData['address'],
            });
            break;
          case 'advisor':
            profileData.addAll({
              'specialization': roleSpecificData['specialization'],
              'certification': roleSpecificData['certification'],
              'advisory_districts': roleSpecificData['advisoryDistricts'],
              'consultation_rate': roleSpecificData['consultationRate'],
              'location_latitude': roleSpecificData['latitude'],
              'location_longitude': roleSpecificData['longitude'],
              'location_address': roleSpecificData['address'],
            });
            break;
          case 'policymaker':
            profileData.addAll({
              'department': roleSpecificData['department'],
              'designation': roleSpecificData['designation'],
              'jurisdiction': roleSpecificData['jurisdiction'],
              'policy_areas': roleSpecificData['policyAreas'],
              'location_latitude': roleSpecificData['latitude'],
              'location_longitude': roleSpecificData['longitude'],
              'location_address': roleSpecificData['address'],
            });
            break;
        }
      }

      await client.from('users').insert(profileData);
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
      await auth.signInWithOAuth(
        provider,
        // Fallback to deep link if not provided
        redirectTo: redirectTo ?? _redirectUrl,
      );
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
      // Ensure reset link opens the app
      await auth.resetPasswordForEmail(
        email,
        redirectTo: _redirectUrl,
      );
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
          .from('users')
          .select()
          .eq('auth_id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Get user profile and role
  Future<Map<String, dynamic>?> getUserProfileAndRole(String userId) async {
    try {
      final response = await client
          .from('users')
          .select('*')
          .eq('auth_id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUser == null) return null;
    return await getUserProfile(currentUser!.id);
  }

  // Update user profile in database
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      await client
          .from('users')
          .update({
            ...profileData,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Update user location
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    try {
      await client
          .from('users')
          .update({
            'location_latitude': latitude,
            'location_longitude': longitude,
            'location_address': address,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('auth_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Get all farmers (for advisors)
  Future<List<Map<String, dynamic>>> getAllFarmers() async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('role', 'farmer')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Get all advisors
  Future<List<Map<String, dynamic>>> getAllAdvisors() async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('role', 'advisor')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Create agricultural issue
  Future<void> createAgriculturalIssue({
    required String userId,
    required String issueType,
    required String description,
    String? cropAffected,
    String severity = 'medium',
    double? latitude,
    double? longitude,
  }) async {
    try {
      await client.from('agricultural_issues').insert({
        'user_id': userId,
        'issue_type': issueType,
        'crop_affected': cropAffected,
        'severity': severity,
        'description': description,
        'location_latitude': latitude,
        'location_longitude': longitude,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user's agricultural issues
  Future<List<Map<String, dynamic>>> getUserIssues(String userId) async {
    try {
      final response = await client
          .from('agricultural_issues')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Get all agricultural issues (for advisors)
  Future<List<Map<String, dynamic>>> getAllIssues() async {
    try {
      // Use LEFT JOIN-style embed to avoid dropping issues when users rows are not visible
      final response = await client
          .from('agricultural_issues')
          .select('''
            id,
            user_id,
            issue_type,
            crop_affected,
            severity,
            description,
            location_latitude,
            location_longitude,
            status,
            advisor_id,
            created_at,
            users (
              id,
              full_name,
              role,
              email,
              phone,
              primary_crop
            )
          ''') // left-join by default when embedding
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback without embed if RLS prevents reading users
      try {
        final response = await client
            .from('agricultural_issues')
            .select()
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } catch (_) {
        return [];
      }
    }
  }

  // Get advisor assigned issues (optional helper for advisor screens)
  Future<List<Map<String, dynamic>>> getAdvisorAssignedIssues(String advisorUserId) async {
    try {
      final response = await client
          .from('agricultural_issues')
          .select('''
            id,
            user_id,
            issue_type,
            crop_affected,
            severity,
            description,
            location_latitude,
            location_longitude,
            status,
            advisor_id,
            created_at,
            users (
              id,
              full_name,
              role,
              email,
              phone,
              primary_crop
            )
          ''')
          .eq('advisor_id', advisorUserId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Update issue status
  Future<void> updateIssueStatus({
    required String issueId,
    required String status,
    String? solution,
    String? advisorId,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (solution != null) {
        updateData['solution_provided'] = solution;
      }

      if (advisorId != null) {
        updateData['advisor_id'] = advisorId;
      }

      if (status == 'resolved') {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
      }

      await client
          .from('agricultural_issues')
          .update(updateData)
          .eq('id', issueId);
    } catch (e) {
      rethrow;
    }
  }

  // Save chat message
  Future<void> saveChatMessage({
    required String userId,
    required String messageText,
    required String senderType,
    String messageType = 'text',
    String? mediaUrl,
    double? latitude,
    double? longitude,
    String? address,
    Map<String, dynamic>? aiResponseData,
  }) async {
    try {
      await client.from('chat_messages').insert({
        'user_id': userId,
        'message_text': messageText,
        'sender_type': senderType,
        'message_type': messageType,
        'media_url': mediaUrl,
        'location_latitude': latitude,
        'location_longitude': longitude,
        'location_address': address,
        'ai_response_data': aiResponseData,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get user's chat messages
  Future<List<Map<String, dynamic>>> getUserChatMessages(String userId) async {
    try {
      final response = await client
          .from('chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>?> getUserStatistics(String userId) async {
    try {
      final response = await client
          .from('user_statistics')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
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
