import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../models/community_models.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'community_post_detail_screen.dart';
import 'create_community_post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  final CommunityService _communityService = CommunityService();
  late TabController _tabController;

  List<CommunityPost> _allPosts = [];
  List<CommunityPost> _popularPosts = [];
  Map<String, List<CommunityPost>> _categoryPosts = {};
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'general',
    'pest_control',
    'disease_management',
    'soil_health',
    'irrigation',
    'fertilizers',
    'crop_care',
    'weather',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCommunityData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunityData() async {
    setState(() => _isLoading = true);

    try {
      print('Loading community data...');

      // Load all posts
      final allPosts = await _communityService.getAllCommunityPosts(limit: 100);
      print('Loaded ${allPosts.length} posts');

      // Load popular posts (fallback to recent if function fails)
      List<Map<String, dynamic>> popularData = [];
      try {
        popularData = await _communityService.getPopularPosts(daysLimit: 7);
        print('Loaded ${popularData.length} popular posts');
      } catch (e) {
        print('Popular posts failed, using recent posts: $e');
        popularData = allPosts.take(10).map((post) => post.toMap()).toList();
      }

      // Convert popular data to CommunityPost objects
      final popularPosts = popularData
          .map((data) => CommunityPost.fromMap(data))
          .toList();

      // Group posts by category
      final Map<String, List<CommunityPost>> categoryPosts = {};
      for (final category in _categories) {
        categoryPosts[category] = allPosts
            .where((post) => post.category == category)
            .toList();
      }

      setState(() {
        _allPosts = allPosts;
        _popularPosts = popularPosts;
        _categoryPosts = categoryPosts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading community data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load community posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _searchPosts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _allPosts = _allPosts;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final searchResults = await _communityService.searchCommunityPosts(query);
      setState(() {
        _searchQuery = query;
        _allPosts = searchResults;
        _isLoading = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Farmer Community'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search questions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadCommunityData();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: _searchPosts,
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Recent', icon: Icon(Icons.access_time)),
                  Tab(text: 'Popular', icon: Icon(Icons.trending_up)),
                  Tab(text: 'Categories', icon: Icon(Icons.category)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecentTab(),
                _buildPopularTab(),
                _buildCategoriesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        icon: const Icon(Icons.add),
        label: const Text('Ask Question'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRecentTab() {
    if (_allPosts.isEmpty) {
      return _buildEmptyState(
        'No posts yet',
        'Be the first to ask a question!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommunityData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allPosts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_allPosts[index]);
        },
      ),
    );
  }

  Widget _buildPopularTab() {
    if (_popularPosts.isEmpty) {
      return _buildEmptyState(
        'No popular posts',
        'Posts with more engagement will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _popularPosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_popularPosts[index]);
      },
    );
  }

  Widget _buildCategoriesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final posts = _categoryPosts[category] ?? [];
        final categoryName = _getCategoryDisplayName(category);
        final categoryIcon = _getCategoryIcon(category);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: Icon(categoryIcon, color: Colors.green.shade600),
            title: Text(categoryName),
            subtitle: Text('${posts.length} questions'),
            children: posts.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No questions in this category yet'),
                    ),
                  ]
                : posts
                      .take(3)
                      .map((post) => _buildPostCard(post, compact: true))
                      .toList(),
          ),
        );
      },
    );
  }

  Widget _buildPostCard(CommunityPost post, {bool compact = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPostDetails(post),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with urgency indicator
              Row(
                children: [
                  _buildUrgencyChip(post.urgencyLevel),
                  const SizedBox(width: 8),
                  _buildCategoryChip(post.category),
                  const Spacer(),
                  Text(
                    _formatTime(post.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content preview
              if (!compact) ...[
                Text(
                  post.content,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // Footer with author and stats
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    post.authorName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  if (post.location != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.location!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.viewCount}'),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text('${post.likeCount}'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
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
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreatePostDialog,
            icon: const Icon(Icons.add),
            label: const Text('Ask First Question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showPostDetails(CommunityPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityPostDetailScreen(post: post),
      ),
    );
  }

  void _showCreatePostDialog() {
    // Navigate to create post screen or show dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCommunityPostScreen(),
      ),
    ).then((_) {
      // Refresh posts after creating new one
      _loadCommunityData();
    });
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'pest_control':
        return Icons.bug_report;
      case 'disease_management':
        return Icons.healing;
      case 'soil_health':
        return Icons.landscape;
      case 'irrigation':
        return Icons.water_drop;
      case 'fertilizers':
        return Icons.grass;
      case 'crop_care':
        return Icons.agriculture;
      case 'weather':
        return Icons.cloud;
      default:
        return Icons.help_outline;
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
}
