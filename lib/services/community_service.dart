import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/community_models.dart';

class CommunityService {
  static final CommunityService _instance = CommunityService._internal();
  factory CommunityService() => _instance;
  CommunityService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new community post
  Future<String> createCommunityPost({
    required String title,
    required String content,
    required String authorName,
    String? authorEmail,
    String? authorPhone,
    required String category,
    List<String>? tags,
    String? location,
    String? cropType,
    String urgencyLevel = 'medium',
  }) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .insert({
            'title': title,
            'content': content,
            'author_name': authorName,
            'author_email': authorEmail,
            'author_phone': authorPhone,
            'category': category,
            'tags': tags,
            'location': location,
            'crop_type': cropType,
            'urgency_level': urgencyLevel,
            'user_id': _supabase.auth.currentUser?.id,
          })
          .select('id')
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to create community post: $e');
    }
  }

  // Get all community posts with filtering options
 Future<List<CommunityPost>> getAllCommunityPosts({
  String? category,
  String? status,
  String? orderBy = 'created_at',
  bool ascending = false,
  int limit = 50,
  int offset = 0,
}) async {
  try {
    // Start from a filter-capable builder
    PostgrestFilterBuilder<List<Map<String, dynamic>>> query =
        _supabase.from('community_posts').select('*');

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);          // or: query = query.filter('category', 'eq', category);
    }

    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);              // or: query = query.filter('status', 'eq', status);
    }

    final response = await query
        .order(orderBy ?? 'created_at', ascending: ascending)
        .range(offset, offset + limit - 1);

    return response
        .map<CommunityPost>((data) => CommunityPost.fromMap(data))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch community posts: $e');
  }
}


  // Get a specific community post by ID
  Future<CommunityPost?> getCommunityPostById(String id) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .select('*')
          .eq('id', id)
          .single();

      // Increment view count using the database function
      await _supabase.rpc('increment_post_view_count', params: {'post_uuid': id});

      return CommunityPost.fromMap(response);
    } catch (e) {
      print('Failed to fetch community post: $e');
      return null;
    }
  }

  // Add a response to a community post
  Future<String> addCommunityResponse({
    required String postId,
    required String responderName,
    String? responderEmail,
    String responderType = 'user',
    required String responseContent,
    bool isVerified = false,
  }) async {
    try {
      final response = await _supabase
          .from('community_responses')
          .insert({
            'post_id': postId,
            'responder_name': responderName,
            'responder_email': responderEmail,
            'responder_type': responderType,
            'response_content': responseContent,
            'is_verified': isVerified,
            'user_id': _supabase.auth.currentUser?.id,
          })
          .select('id')
          .single();

      return response['id'];
    } catch (e) {
      throw Exception('Failed to add response: $e');
    }
  }

  // Get all responses for a specific post
  Future<List<CommunityResponse>> getResponsesForPost(String postId) async {
    try {
      final response = await _supabase
          .from('community_responses')
          .select('*')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      return response.map<CommunityResponse>((data) => CommunityResponse.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch responses: $e');
    }
  }

  // Search community posts
  Future<List<CommunityPost>> searchCommunityPosts(String query) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .select('*')
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map<CommunityPost>((data) => CommunityPost.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  // Get posts by category
  Future<List<CommunityPost>> getPostsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('community_posts')
          .select('*')
          .eq('category', category)
          .order('created_at', ascending: false);

      return response.map<CommunityPost>((data) => CommunityPost.fromMap(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by category: $e');
    }
  }

  // Get popular posts
  Future<List<Map<String, dynamic>>> getPopularPosts({int daysLimit = 7}) async {
    try {
      final response = await _supabase
          .rpc('get_popular_posts', params: {'days_limit': daysLimit});

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch popular posts: $e');
    }
  }

  // Like a post
  Future<bool> likePost(String postId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Check if already liked
      final existing = await _supabase
          .from('user_interactions')
          .select('id')
          .eq('user_id', userId)
          .eq('post_id', postId)
          .eq('interaction_type', 'like')
          .maybeSingle();

      if (existing != null) {
        // Unlike - remove interaction and decrement count
        await _supabase
            .from('user_interactions')
            .delete()
            .eq('id', existing['id']);
        
        await _supabase
            .rpc('decrement_post_like_count', params: {'post_uuid': postId});
        
        return false;
      } else {
        // Like - add interaction and increment count
        await _supabase
            .from('user_interactions')
            .insert({
              'user_id': userId,
              'post_id': postId,
              'interaction_type': 'like',
            });
        
        await _supabase
            .rpc('increment_post_like_count', params: {'post_uuid': postId});
        
        return true;
      }
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  // Mark response as helpful
  Future<bool> markResponseHelpful(String responseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      // Check if already marked helpful
      final existing = await _supabase
          .from('user_interactions')
          .select('id')
          .eq('user_id', userId)
          .eq('response_id', responseId)
          .eq('interaction_type', 'helpful')
          .maybeSingle();

      if (existing != null) {
        // Remove helpful mark
        await _supabase
            .from('user_interactions')
            .delete()
            .eq('id', existing['id']);
        
        await _supabase
            .rpc('decrement_response_helpful_count', params: {'response_uuid': responseId});
        
        return false;
      } else {
        // Mark as helpful
        await _supabase
            .from('user_interactions')
            .insert({
              'user_id': userId,
              'response_id': responseId,
              'interaction_type': 'helpful',
            });
        
        await _supabase
            .rpc('increment_response_helpful_count', params: {'response_uuid': responseId});
        
        return true;
      }
    } catch (e) {
      throw Exception('Failed to mark response helpful: $e');
    }
  }

  // Get community statistics
  Future<Map<String, dynamic>> getCommunityStats() async {
    try {
      final totalPostsResponse = await _supabase
          .from('community_posts')
          .select('*').count(CountOption.exact);

      final openPostsResponse = await _supabase
          .from('community_posts')
          .select('*')
          .eq('status', 'open').count(CountOption.exact);

      final resolvedPostsResponse = await _supabase
          .from('community_posts')
          .select('*')
          .eq('status', 'resolved').count(CountOption.exact);

      final totalResponsesResponse = await _supabase
          .from('community_responses')
          .select('*').count(CountOption.exact);;

      return {
        'total_posts': totalPostsResponse.count ?? 0,
        'open_posts': openPostsResponse.count ?? 0,
        'resolved_posts': resolvedPostsResponse.count ?? 0,
        'total_responses': totalResponsesResponse.count ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch community stats: $e');
    }
  }

  // Update post status
  Future<bool> updatePostStatus(String postId, String status) async {
    try {
      await _supabase
          .from('community_posts')
          .update({'status': status})
          .eq('id', postId);
      
      return true;
    } catch (e) {
      throw Exception('Failed to update post status: $e');
    }
  }
}
