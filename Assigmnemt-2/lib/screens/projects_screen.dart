import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Projects")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text("Doctor Appointment System (MERN)"),
            subtitle: Text("JWT Auth, RBAC, Scheduling Algorithm"),
          ),
          ListTile(
            title: Text("Health & Fitness Tracker (Flutter)"),
            subtitle: Text("BMI, Water Tracker, Diet Planner, Stats Module"),
          ),
          ListTile(
            title: Text("Hospital Management System"),
            subtitle: Text("PHP + MySQL, Role Based Access Control"),
          ),
        ],
      ),
    );
  }
}