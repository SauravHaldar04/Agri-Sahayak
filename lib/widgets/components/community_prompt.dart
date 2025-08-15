import 'package:flutter/material.dart';

class CommunityPrompt extends StatelessWidget {
  const CommunityPrompt({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final String prompt =
        (data['prompt'] as String?) ?? 'Ask the community for help.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(prompt),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Navigate to Community tab from bottom nav.'),
              ),
            );
          },
          icon: const Icon(Icons.groups_outlined),
          label: const Text('Go to Community'),
        ),
      ],
    );
  }
}
