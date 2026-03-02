import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'education_screen.dart';
import 'projects_screen.dart';
import 'experience_screen.dart';
import 'skills_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 20),

            /// Profile Image
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/Profile.jpeg'),
            ),

            const SizedBox(height: 15),

            const Text(
              "Jahanzaib Siddiqui",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "Computer Scientist | Flutter Developer",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 10),

            const Text("CGPA: 3.46 / 4.0"),

            const SizedBox(height: 25),

            /// Navigation Buttons
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  buildNavTile(context, "Education", Icons.school, const EducationScreen()),
                  buildNavTile(context, "Projects", Icons.work, const ProjectsScreen()),
                  buildNavTile(context, "Experience", Icons.business_center, const ExperienceScreen()),
                  buildNavTile(context, "Skills", Icons.star, const SkillsScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNavTile(BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}