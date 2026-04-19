import 'package:flutter/material.dart';
import '../widgets/nav_button.dart';
import 'system_services_page.dart';
import 'ui_page.dart';
import 'stm32/stm32_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color(0xFF121212),
        title: const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text(
            "Settings",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Transform.translate(
        offset: const Offset(0, -30),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              NavButton(
                label: 'WiFi',
                icon: Icons.wifi,
                color: const Color(0xFF08C4A1),
                onPressed: () => print("Open WiFi Config"),
              ),
              NavButton(
                label: 'System Services',
                icon: Icons.monitor_heart_outlined,
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SystemServicesPage()),
                  );
                },
              ),
              NavButton(
                label: 'STM32 Controller',
                icon: Icons.memory,
                color: Colors.indigoAccent,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const STM32Page()))
              ),
              NavButton(
                label: 'UI',
                icon: Icons.tune,
                color: Colors.orangeAccent,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UiPage()))
              ),
            ],
          ),
        ),
      ),
    );
  }
}