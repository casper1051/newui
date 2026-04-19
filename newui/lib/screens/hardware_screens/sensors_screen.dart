import 'package:flutter/material.dart';
import '../../../widgets/nav_button.dart';
import 'detail_screen.dart';


class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar("Sensors"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavButton(
              label: 'Digital',
              icon: Icons.fingerprint,
              color: const Color(0xFF08C4A1),
              onPressed: () => _navTo(context, const DigitalSensorsPage()),
            ),
            const SizedBox(height: 20),
            NavButton(
              label: 'Analog',
              icon: Icons.analytics,
              color: Colors.orangeAccent,
              onPressed: () => _navTo(context, const AnalogSensorsPage()),
            ),
            const SizedBox(height: 20),
            NavButton(
              label: 'Misc',
              icon: Icons.miscellaneous_services,
              color: Colors.indigoAccent,
              onPressed: () => _navTo(context, const MiscSensorsPage()),
            ),
          ],
        ),
      ),
    );
  }
}




class DigitalSensorsPage extends StatelessWidget {
  const DigitalSensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar("Digital Sensors"),
      body: _buildSymmetricGrid(
        context,
        crossAxisCount: 4, 
        children: List.generate(8, (i) => _sensorBtn(context, "D$i", Icons.settings_input_component, const Color(0xFF08C4A1))),
      ),
    );
  }
}


class AnalogSensorsPage extends StatelessWidget {
  const AnalogSensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar("Analog Sensors"),
      body: _buildSymmetricGrid(
        context,
        crossAxisCount: 3, 
        children: List.generate(6, (i) => _sensorBtn(context, "A$i", Icons.linear_scale, Colors.orangeAccent)),
      ),
    );
  }
}


class MiscSensorsPage extends StatelessWidget {
  const MiscSensorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar("Misc Sensors"),
      body: _buildSymmetricGrid(
        context,
        crossAxisCount: 4,
        children: [
          _sensorBtn(context, "Gyro 0", Icons.screen_rotation, Colors.indigoAccent),
          _sensorBtn(context, "Gyro 1", Icons.screen_rotation, Colors.indigoAccent),
          _sensorBtn(context, "Gyro 2", Icons.screen_rotation, Colors.indigoAccent),
          _sensorBtn(context, "User 0", Icons.touch_app, Colors.blueAccent),
          _sensorBtn(context, "B-EMF 0", Icons.electric_bolt, Colors.redAccent),
          _sensorBtn(context, "B-EMF 1", Icons.electric_bolt, Colors.redAccent),
          _sensorBtn(context, "B-EMF 2", Icons.electric_bolt, Colors.redAccent),
          _sensorBtn(context, "B-EMF 3", Icons.electric_bolt, Colors.redAccent),
        ],
      ),
    );
  }
}

Widget _buildSymmetricGrid(BuildContext context, {required int crossAxisCount, required List<Widget> children}) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.8, 
      children: children,
    ),
  );
}

PreferredSizeWidget _buildAppBar(String title) {
  return AppBar(
    toolbarHeight: 80,
    backgroundColor: const Color(0xFF121212),
    title: Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
  );
}

void _navTo(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

Widget _sensorBtn(BuildContext context, String name, IconData icon, Color color) {
  return NavButton(
    label: name,
    icon: icon,
    color: color,
    size: Size.infinite, 
    onPressed: () => _navTo(context, SensorDisplayDetail(sensorName: name)),
  );
}