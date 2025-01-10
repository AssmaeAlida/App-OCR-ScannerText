import 'package:flutter/material.dart';
import 'package:text_recognition_flutter/document_scan_screen.dart';
import 'package:text_recognition_flutter/main.dart';
import 'main.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              _buildFeatureCards(),
              _buildStartButton(context),
             _buildDocumentScanButton(context),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.document_scanner, size: 100, color: Colors.blue),
        ),
        const SizedBox(height: 24),
        const Text(
          'Smart Text Scanner',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Extract text from images instantly with our advanced OCR technology',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFeatureCard(
            icon: Icons.speed,
            title: 'Fast Recognition',
            description: 'Extract text in seconds',
          ),
          _buildFeatureCard(
            icon: Icons.copy,
            title: 'Copy & Share',
            description: 'Easy to copy and share results',
          ),
          _buildFeatureCard(
            icon: Icons.translate,
            title: 'Multi-language',
            description: 'Supports multiple languages',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
ButtonStyle _buttonStyle() {
  return ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 5,
    backgroundColor: Colors.white,
    shadowColor: Colors.blue.withOpacity(0.3),
  );
}

Widget _buildStartButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        ),
        style: _buttonStyle(),
        child: const Text(
          'Extract Text',
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

Widget _buildDocumentScanButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DocumentScanScreen()),
        ),
        style: _buttonStyle(),
        child: const Text(
          'Scan to PDF',
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
}