import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          ListTile(
            title: Text('How to prevent pest attack on brinjal?'),
            subtitle: Text('12 answers · 4h ago'),
          ),
          Divider(),
          ListTile(
            title: Text('Best sowing time for chickpea in Pune?'),
            subtitle: Text('8 answers · 1d ago'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Ask Question'),
      ),
    );
  }
}
