import 'package:flutter/material.dart';

class PolicyCard extends StatelessWidget {
  const PolicyCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final String title = (data['title'] as String?) ?? 'Policy';
    final String summary =
        (data['summary'] as String?) ?? 'Summary not available.';
    final String cta = (data['cta'] as String?) ?? 'View details';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(summary),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: () {}, child: Text(cta)),
        ),
      ],
    );
  }
}
