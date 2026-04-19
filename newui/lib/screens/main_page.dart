import 'package:flutter/material.dart';
import '../widgets/nav_button.dart';
import 'hardware_page.dart';
import 'settings_page.dart';
import 'programs_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color(0xFF121212),
        title: const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text("newui", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavButton(
              label: 'Programs',
              icon: Icons.terminal,
              color: const Color(0xFF08C4A1),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProgramsPage())),
            ),
            const SizedBox(height: 20),
            NavButton(
              label: 'Hardware',
              icon: Icons.settings_input_component,
              color: Colors.orangeAccent,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HardwarePage())),
            ),
            const SizedBox(height: 20),
            NavButton(
              label: 'Settings',
              icon: Icons.settings,
              color: Colors.blueAccent,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
            ),
          ],
        ),
      ),
    );
  }
}