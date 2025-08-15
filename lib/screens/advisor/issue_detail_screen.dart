import 'package:flutter/material.dart';

import '../../models/farmer_issue.dart';

class IssueDetailScreen extends StatelessWidget {
  const IssueDetailScreen({super.key, required this.issue});

  final FarmerIssue issue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Issue ${issue.issueId}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(issue.query, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('From: ${issue.farmerName} (${issue.farmerId})'),
          Text('Created: ${issue.timestamp}'),
          const SizedBox(height: 16),
          const Divider(),
          Text(
            'Farmer Context',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('Location: Pune District'),
          const Text('Primary Crops: Sugarcane, Soybean'),
          const Text('Recent Queries: MSP, pest management'),
          const SizedBox(height: 16),
          const Divider(),
          Text('Advisor Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Add your notes and action items here (placeholder).'),
        ],
      ),
    );
  }
}
