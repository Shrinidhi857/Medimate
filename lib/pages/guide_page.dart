import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medimate Guide'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Welcome to MediMate!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // App Description with proper formatting
            const Text(
              '📱 MediMate Home Page Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Welcome to MediMate – your smart medication assistant. Here\'s a quick guide to understanding the dashboard and key features:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            _buildSection(
              '🏠 Home / Dashboard',
              [
                'The "Dispense" button provides the next scheduled medication, including dosage information based on the data provided by the user.',
                'A complete list of all medications assigned for the day is displayed for easy tracking.',
                'The "Medication" button connects to the IoT device (Raspberry Pi Zero 2 W) via Bluetooth and triggers the respective compartment for dispensing.',
              ],
            ),

            _buildSection(
              '📅 Calendar (Drawer Menu)',
              [
                'Shows all historical medication intake records.',
                'Helps you track drug adherence over time.',
              ],
            ),

            _buildSection(
              '🔗 Bluetooth Connectivity',
              [
                'Seamless integration with the Raspberry Pi Zero 2 W.',
                'Ensures real-time dispensing by pairing with the MediMate IoT hardware.',
              ],
            ),

            _buildSection(
              '➕ Add Medication Page',
              [
                'Allows users to add, delete, or edit medications.',
                'Stores complete information such as dosage, quantity, and intake schedule.',
                'On adding a new medication, a notification is automatically scheduled at the specified time.',
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              '🛠️ MediMate simplifies medication management, improves adherence, and connects seamlessly with your smart dispenser hardware.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Developed by Shrinidhi Achar',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  point,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        )).toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}