import 'package:flutter/material.dart';
import '../widgets/section_card.dart';
import '../widgets/info_tile.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Education")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ListTile(
              title: Text("BS Computer Science"),
              subtitle: Text("COMSATS University Islamabad (2023 - 2026)"),
            ),
            ListTile(
              title: Text("FSC Pre-Medical"),
              subtitle: Text("Aspire College (2020 - 2022)"),
            ),
          ],
        ),
      ),
    );
  }
}