import 'package:flutter/material.dart';
import '../widgets/nav_button.dart';
import 'hardware_screens/sensors_screen.dart';
import 'hardware_screens/motors_screen.dart';
import 'hardware_screens/servo_screen.dart';

class HardwarePage extends StatelessWidget {
  const HardwarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        title: const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text(
            "Hardware",
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
                label: 'Sensors',
                icon: Icons.sensors,
                color: const Color(0xFF08C4A1),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SensorsPage()),
                  );
                },
              ),
              NavButton(
                label: 'Motors',
                icon: Icons.car_crash,
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MotorsPage()),
                  );
                },
              ),
              NavButton(
                label: 'Servos',
                icon: Icons.compass_calibration,
                color: Colors.indigoAccent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ServoPage()),
                  );
                },
              ),
              NavButton(
                label: 'Camera',
                icon: Icons.camera,
                //color: Colors.orangeAccent,
                color: Colors.blueGrey,
                onPressed: () => print("Camera is not implemented."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}