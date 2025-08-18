import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community_service.dart';
import '../../providers/auth_provider.dart';

class CreateCommunityPostScreen extends StatefulWidget {
  const CreateCommunityPostScreen({super.key});

  @override
  State<CreateCommunityPostScreen> createState() => _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState extends State<CreateCommunityPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _cropController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String _selectedCategory = 'general';
  String _selectedUrgency = 'medium';
  bool _isLoading = false;

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

  final List<String> _urgencyLevels = ['low', 'medium', 'high'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _cropController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      final userProfile = authProvider.userProfile;
      
      if (userProfile == null) {
        throw Exception('User profile not found. Please sign in again.');
      }

      final tags = _tagsController.text.trim().isNotEmpty
          ? _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList()
          : null;

      final postId = await CommunityService().createCommunityPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorName: userProfile['full_name'] ?? 'Anonymous',
        authorEmail: userProfile['email'],
        authorPhone: userProfile['phone'],
        category: _selectedCategory,
        tags: tags,
        location: _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() : null,
        cropType: _cropController.text.trim().isNotEmpty 
            ? _cropController.text.trim() : null,
        urgencyLevel: _selectedUrgency,
      );

      print('Community post created with ID: $postId');
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error creating post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Question'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: Text(
              'POST',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ask your agricultural question and get help from the farming community!',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Question Title *',
                  hintText: 'What\'s your agricultural question?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value?.trim().isEmpty ?? true 
                    ? 'Please enter a title' : null,
                maxLength: 100,
              ),
              const SizedBox(height: 16),
              
              // Category and Urgency Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_getCategoryDisplayName(category)),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUrgency,
                      decoration: const InputDecoration(
                        labelText: 'Urgency',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: _urgencyLevels.map((urgency) {
                        return DropdownMenuItem(
                          value: urgency,
                          child: Text(urgency.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedUrgency = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Content Field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description *',
                  hintText: 'Describe your issue in detail...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 6,
                validator: (value) => value?.trim().isEmpty ?? true 
                    ? 'Please enter a description' : null,
                maxLength: 500,
              ),
              const SizedBox(height: 16),
              
              // Crop and Location Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cropController,
                      decoration: const InputDecoration(
                        labelText: 'Crop (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.grass),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tags Field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (Optional)',
                  hintText: 'e.g. organic, pesticide, irrigation',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                  helperText: 'Separate tags with commas',
                ),
              ),
              const SizedBox(height: 24),
              
              // Guidelines
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guidelines for posting:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Be specific about your problem\n'
                      '• Include crop and location details\n'
                      '• Use clear, descriptive titles\n'
                      '• Add relevant tags for better visibility\n'
                      '• Be respectful and helpful to others',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Posting...'),
                          ],
                        )
                      : const Text(
                          'Post Question',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
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
}
