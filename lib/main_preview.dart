import 'package:flutter/material.dart';
import 'screens/component_preview_screen.dart';

void main() {
  runApp(const ComponentPreviewApp());
}

class ComponentPreviewApp extends StatelessWidget {
  const ComponentPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri Sahayak - Component Preview',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const ComponentPreviewScreen(),
    );
  }
}
