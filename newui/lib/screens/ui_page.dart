import 'package:flutter/material.dart';
import '../widgets/nav_button.dart';

import 'package:shared_preferences/shared_preferences.dart';


class UiPage extends StatelessWidget {
  const UiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color(0xFF121212),
        title: const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text(
            "UI Settings",
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
                label: 'Update Interface',
                icon: Icons.update,
                color: const Color(0xFF08C4A1),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdatePage()))
              ),
              NavButton(
                label: 'Version',
                icon: Icons.verified,
                color: Colors.redAccent,
                onPressed: () => {}
              ),
              /*NavButton(
                label: 'STM32 Controller',
                icon: Icons.memory,
                color: Colors.indigoAccent,
                onPressed: () => print("Coprocessor Settings"),
              ),
              NavButton(
                label: 'UI Settings',
                icon: Icons.tune,
                color: Colors.orangeAccent,
                onPressed: () => print("Display/Theme Settings"),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}


class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool _isAutoUpdateEnabled = false;
  bool _isChecking = false;
  String _currentVersion = "v1.0.3-nightly";
  String _statusMessage = "System is up to date.";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAutoUpdateEnabled = prefs.getBool('auto_update') ?? false;
    });
  }

  Future<void> _toggleAutoUpdate(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_update', value);
    setState(() {
      _isAutoUpdateEnabled = value;
    });
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _statusMessage = "Checking for updates...";
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isChecking = false;
      _statusMessage = "A newer version (@TODO Display newer version) is available.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("System Updates", 
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CURRENT VERSION", 
                    style: TextStyle(color: Colors.white38, letterSpacing: 1.2, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text(_currentVersion, 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const Divider(height: 30, color: Colors.white10),
                  Row(
                    children: [
                      Icon(
                        _isChecking ? Icons.sync : Icons.check_circle_outline, 
                        color: _isChecking ? Colors.orangeAccent : Colors.greenAccent, 
                        size: 20
                      ),
                      const SizedBox(width: 10),
                      Text(_statusMessage, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: const Text("Auto-Download Updates", 
                style: TextStyle(fontSize: 18, color: Colors.white)),
              subtitle: const Text("Automatically download and prepare updates in the background", 
                style: TextStyle(color: Colors.white38, fontSize: 13)),
              trailing: Switch(
                value: _isAutoUpdateEnabled,
                activeColor: const Color(0xFF08C4A1),
                onChanged: _toggleAutoUpdate,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: "Check for Updates",
                    icon: Icons.search,
                    color: Colors.white10,
                    textColor: Colors.white,
                    onPressed: _isChecking ? null : _checkForUpdates,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _actionButton(
                    label: "Update Now",
                    icon: Icons.system_update_alt,
                    color: const Color(0xFF08C4A1),
                    textColor: Colors.black,
                    onPressed: () {
                      print("Updating newui...");
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}