import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          const ListTile(
            title: Text('Account Settings'),
            subtitle: Text('Manage your profile and preferences'),
            leading: Icon(Icons.person_outline),
          ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () {
              AuthService.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
} 