import 'package:flutter/material.dart';

// Temporary scaffold used until each feature module builds its real screen.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label)),
    );
  }
}
