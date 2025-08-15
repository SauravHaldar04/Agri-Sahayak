import 'package:flutter/material.dart';

class DiagnosisCard extends StatelessWidget {
  const DiagnosisCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final String issue = (data['issue'] as String?) ?? 'Unknown Issue';
    final double probability = (data['probability'] as num?)?.toDouble() ?? 0.0;
    final String recommendation =
        (data['recommendation'] as String?) ?? 'No recommendation available.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Diagnosis: $issue',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text('Confidence: ${(probability * 100).toStringAsFixed(0)}%'),
        const SizedBox(height: 8),
        Text('Recommendation:', style: Theme.of(context).textTheme.labelLarge),
        Text(recommendation),
      ],
    );
  }
}
