import 'package:flutter/material.dart';

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = [
      "Flutter",
      "Dart",
      "MERN Stack",
      "Laravel",
      "MySQL",
      "OOP",
      "Data Structures",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Skills")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: skills
              .map((skill) => Chip(
            label: Text(skill),
            backgroundColor: Colors.indigo.shade100,
          ))
              .toList(),
        ),
      ),
    );
  }
}