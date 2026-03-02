import 'package:flutter/material.dart';

class ExperienceScreen extends StatelessWidget {
  const ExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Experience")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "Developed full-stack systems including Hospital Management "
              "System and Online Paper Submission System using MySQL, "
              "PHP, HTML, CSS, JavaScript.",
        ),
      ),
    );
  }
}