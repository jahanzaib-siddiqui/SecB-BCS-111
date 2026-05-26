import 'package:flutter/material.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  String selectedGender = 'Male';
  double height = 170;
  double weight = 60;

  String _result = '';
  String _statusText = '';
  Color _statusColor = Colors.black;

  void _calculateBMI() {
    final double bmi = weight / ((height / 100) * (height / 100));
    String status;
    Color statusColor;

    if (bmi < 18.5) {
      status = "Underweight";
      statusColor = Colors.orange;
    } else if (bmi < 24.9) {
      status = "Normal";
      statusColor = Colors.green;
    } else if (bmi < 29.9) {
      status = "Overweight";
      statusColor = Colors.orange;
    } else {
      status = "Obese";
      statusColor = Colors.red;
    }

    setState(() {
      _result = "Your BMI is ${bmi.toStringAsFixed(1)}";
      _statusText = "Status: $status";
      _statusColor = statusColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              "Select Gender",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                genderButton("Male", Icons.male),
                genderButton("Female", Icons.female),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              "Height: ${height.round()} cm",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: height,
              min: 100,
              max: 220,
              divisions: 120,
              activeColor: Colors.deepPurple,
              onChanged: (value) {
                setState(() => height = value);
              },
            ),

            const SizedBox(height: 20),
            Text(
              "Weight: ${weight.round()} kg",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: weight,
              min: 30,
              max: 150,
              divisions: 120,
              activeColor: Colors.deepPurple,
              onChanged: (value) {
                setState(() => weight = value);
              },
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _calculateBMI,
              child: const Text("Calculate BMI"),
            ),
            const SizedBox(height: 20),

            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _result,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget genderButton(String gender, IconData icon) {
    bool isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: isSelected ? Colors.white : Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
