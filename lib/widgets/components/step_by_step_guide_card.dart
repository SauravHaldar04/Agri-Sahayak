import 'package:flutter/material.dart';

class StepByStepGuideCard extends StatelessWidget {
  const StepByStepGuideCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final guideData = data;

    // Parse all the fields with proper fallbacks
    final title = guideData['title']?.toString() ?? 'Step-by-Step Guide';
    final description = guideData['description']?.toString();
    final steps = guideData['steps'] as List<dynamic>? ?? [];
    final estimatedTime = guideData['estimatedTime']?.toString();
    final materials = guideData['materials'] as List<dynamic>?;
    final tips = guideData['tips']?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),

          // Description (if available)
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.teal.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Steps
          if (steps.isNotEmpty) ...[
            Text(
              'Steps:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 8),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final step = entry.value.toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade600,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(step, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Estimated Time (if available)
          if (estimatedTime != null && estimatedTime.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                Text(
                  'Estimated Time: $estimatedTime',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ],

          // Materials (if available)
          if (materials != null && materials.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Materials Needed:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: materials.map((material) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.shade300),
                  ),
                  child: Text(
                    material.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
                  ),
                );
              }).toList(),
            ),
          ],

          // Tips (if available)
          if (tips != null && tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: $tips',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
