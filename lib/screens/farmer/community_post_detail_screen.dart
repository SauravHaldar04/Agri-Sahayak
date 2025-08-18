import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/community_models.dart';
import '../../services/community_service.dart';
import '../../providers/auth_provider.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final CommunityPost post;
  
  const CommunityPostDetailScreen({super.key, required this.post});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _responseController = TextEditingController();
  
  List<CommunityResponse> _responses = [];
  bool _isLoading = false;
  bool _isLiked = false;
  bool _isSubmittingResponse = false;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _loadResponses() async {
    setState(() => _isLoading = true);
    
    try {
      final responses = await _communityService.getResponsesForPost(widget.post.id);
      setState(() {
        _responses = responses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading responses: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load responses: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addResponse() async {
    if (_responseController.text.trim().isEmpty) return;
    
    setState(() => _isSubmittingResponse = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final userProfile = authProvider.userProfile;
      
      if (userProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to respond')),
        );
        return;
      }

      await _communityService.addCommunityResponse(
        postId: widget.post.id,
        responderName: userProfile['full_name'] ?? 'Anonymous',
        responderEmail: userProfile['email'],
        responseContent: _responseController.text.trim(),
      );

      _responseController.clear();
      await _loadResponses();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Response added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding response: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add response: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmittingResponse = false);
    }
  }

  Future<void> _toggleLike() async {
    try {
      final result = await _communityService.likePost(widget.post.id);
      setState(() => _isLiked = result);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? 'Post liked!' : 'Post unliked!'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Like error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to like post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleLike,
            tooltip: 'Like this post',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _sharePost();
                  break;
                case 'report':
                  _reportPost();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Post details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post content
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category and urgency badges
                          Row(
                            children: [
                              _buildCategoryChip(widget.post.category),
                              const SizedBox(width: 8),
                              _buildUrgencyChip(widget.post.urgencyLevel),
                              const Spacer(),
                              _buildStatusChip(widget.post.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Title
                          Text(
                            widget.post.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Content
                          Text(
                            widget.post.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          
                          // Additional info
                          if (widget.post.cropType != null) ...[
                            Row(
                              children: [
                                Icon(Icons.grass, size: 16, color: Colors.green.shade600),
                                const SizedBox(width: 4),
                                Text('Crop: ${widget.post.cropType}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          if (widget.post.location != null) ...[
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                                const SizedBox(width: 4),
                                Text('Location: ${widget.post.location}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          if (widget.post.tags != null && widget.post.tags!.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              children: widget.post.tags!
                                  .map((tag) => Chip(
                                        label: Text(tag, style: const TextStyle(fontSize: 12)),
                                        backgroundColor: Colors.grey.shade200,
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Author and stats
                          Row(
                            children: [
                              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'By ${widget.post.authorName}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${widget.post.viewCount} views • ${widget.post.likeCount} likes',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted ${_formatTime(widget.post.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Responses section
                  Row(
                    children: [
                      Text(
                        'Responses (${_responses.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _loadResponses,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_responses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No responses yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to help!',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._responses.map((response) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  response.responderName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                if (response.isVerified) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Colors.blue.shade600,
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  _formatTime(response.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(response.responseContent),
                            if (response.helpfulCount > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${response.helpfulCount} found this helpful',
                                    style: TextStyle(
                                      color: Colors.green.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    )).toList(),
                ],
              ),
            ),
          ),
          
          // Response input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _responseController,
                    decoration: const InputDecoration(
                      hintText: 'Write your response...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmittingResponse ? null : _addResponse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmittingResponse
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCategoryDisplayName(category),
        style: TextStyle(color: Colors.blue.shade700, fontSize: 10),
      ),
    );
  }

  Widget _buildUrgencyChip(String urgency) {
    Color color;
    switch (urgency) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      case 'low':
      default:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        urgency.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'resolved':
        color = Colors.green;
        break;
      case 'closed':
        color = Colors.grey;
        break;
      case 'open':
      default:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'pest_control':
        return 'Pest Control';
      case 'disease_management':
        return 'Disease Management';
      case 'soil_health':
        return 'Soil Health';
      case 'crop_care':
        return 'Crop Care';
      default:
        return category
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _sharePost() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _reportPost() {
    // Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report functionality coming soon!')),
    );
  }
}
