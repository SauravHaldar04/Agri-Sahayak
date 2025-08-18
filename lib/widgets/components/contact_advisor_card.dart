import 'package:agri_sahayak/screens/farmer/ask_expert_screen.dart';
import 'package:agri_sahayak/services/community_service.dart';
import 'package:agri_sahayak/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactAdvisorCard extends StatelessWidget {
  const ContactAdvisorCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final contactData = data;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.cyan.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.shade200.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.cyan.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Need Expert Help?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This seems like a complex local issue. For the best advice, you can:',
            style: TextStyle(
              color: Colors.cyan.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          
          // Ask Community button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton(
              onPressed: () => _showCommunityPostDialog(context, contactData),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Ask the Farmer Community',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Community subtext
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              'Get practical advice from nearby farmers',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          // Contact Advisor button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AskExpertScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.cyan.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.cyan.shade600, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Contact an Official Advisor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Advisor subtext
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Text(
              'Connect with a certified expert from your local KVK',
              style: TextStyle(
                color: Colors.cyan.shade600,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          // Quick contact info
          if (contactData['expertName'] != null || contactData['contact'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.cyan.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Contact',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyan.shade800,
                        ),
                      ),
                    ],
                  ),
                  if (contactData['expertName'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expert: ${contactData['expertName']}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (contactData['contact'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Contact: ${contactData['contact']}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCommunityPostDialog(BuildContext context, Map<String, dynamic> contactData) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final locationController = TextEditingController();
    final cropController = TextEditingController();
    
    String selectedCategory = 'general';
    String selectedUrgency = 'medium';
    final List<String> tags = [];
    final tagController = TextEditingController();

    // Pre-fill content based on contact data
    if (contactData['issue'] != null) {
      contentController.text = contactData['issue'];
    }
    if (contactData['crop'] != null) {
      cropController.text = contactData['crop'];
      selectedCategory = _getCategoryFromIssue(contactData['issue'] ?? '');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.group, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ask the Community',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Question Title *',
                            hintText: 'What\'s your agricultural question?',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 16),

                        // Category Selection
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.category),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'general', child: Text('General')),
                            DropdownMenuItem(value: 'pest_control', child: Text('Pest Control')),
                            DropdownMenuItem(value: 'disease_management', child: Text('Disease Management')),
                            DropdownMenuItem(value: 'soil_health', child: Text('Soil Health')),
                            DropdownMenuItem(value: 'irrigation', child: Text('Irrigation')),
                            DropdownMenuItem(value: 'fertilizers', child: Text('Fertilizers')),
                            DropdownMenuItem(value: 'crop_care', child: Text('Crop Care')),
                            DropdownMenuItem(value: 'weather', child: Text('Weather')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Content Field
                        TextFormField(
                          controller: contentController,
                          decoration: InputDecoration(
                            labelText: 'Detailed Description *',
                            hintText: 'Describe your issue in detail...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),

                        // Crop and Location Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: cropController,
                                decoration: InputDecoration(
                                  labelText: 'Crop',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: const Icon(Icons.grass),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: locationController,
                                decoration: InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  prefixIcon: const Icon(Icons.location_on),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Urgency Selection
                        DropdownButtonFormField<String>(
                          value: selectedUrgency,
                          decoration: InputDecoration(
                            labelText: 'Urgency Level',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.priority_high),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'low', child: Text('Low')),
                            DropdownMenuItem(value: 'medium', child: Text('Medium')),
                            DropdownMenuItem(value: 'high', child: Text('High')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedUrgency = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Tags Field
                        TextFormField(
                          controller: tagController,
                          decoration: InputDecoration(
                            labelText: 'Tags (comma separated)',
                            hintText: 'e.g. organic, pesticide, irrigation',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            prefixIcon: const Icon(Icons.tag),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submitCommunityPost(
                              context,
                              titleController.text,
                              contentController.text,
                              selectedCategory,
                              selectedUrgency,
                              cropController.text,
                              locationController.text,
                              tagController.text,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Post to Community',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitCommunityPost(
    BuildContext context,
    String title,
    String content,
    String category,
    String urgency,
    String crop,
    String location,
    String tagsText,
  ) async {
    print('Submitting community post: $title');
    
    if (title.trim().isEmpty || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in the title and description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.userProfile;
      
      print('User profile available: ${userProfile != null}');
      
      if (userProfile == null) {
        throw Exception('User profile not found. Please sign in again.');
      }

      // Parse tags
      List<String> tags = [];
      if (tagsText.isNotEmpty) {
        tags = tagsText.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
      }

      print('Creating community post with ${tags.length} tags');

      // Create community post
      final communityService = CommunityService();
      final postId = await communityService.createCommunityPost(
        title: title.trim(),
        content: content.trim(),
        authorName: userProfile['full_name'] ?? 'Anonymous',
        authorEmail: userProfile['email'],
        authorPhone: userProfile['phone'],
        category: category,
        tags: tags.isNotEmpty ? tags : null,
        location: location.trim().isNotEmpty ? location.trim() : null,
        cropType: crop.trim().isNotEmpty ? crop.trim() : null,
        urgencyLevel: urgency,
      );

      print('Community post created with ID: $postId');
      Navigator.pop(context); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Your question has been posted to the community!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to community tab
              print('Navigate to community post: $postId');
            },
          ),
        ),
      );
    } catch (e) {
      print('Error creating community post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post question: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getCategoryFromIssue(String issue) {
    final lowerIssue = issue.toLowerCase();
    
    if (lowerIssue.contains('pest') || lowerIssue.contains('insect') || lowerIssue.contains('bug')) {
      return 'pest_control';
    } else if (lowerIssue.contains('disease') || lowerIssue.contains('infection') || lowerIssue.contains('fungus')) {
      return 'disease_management';
    } else if (lowerIssue.contains('soil') || lowerIssue.contains('nutrient') || lowerIssue.contains('fertilizer')) {
      return 'soil_health';
    } else if (lowerIssue.contains('water') || lowerIssue.contains('irrigation') || lowerIssue.contains('drought')) {
      return 'irrigation';
    } else if (lowerIssue.contains('weather') || lowerIssue.contains('rain') || lowerIssue.contains('sun')) {
      return 'weather';
    } else {
      return 'general';
    }
  }
}
