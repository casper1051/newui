import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/nav_button.dart';

class UiPage extends StatelessWidget {
  const UiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text(
            "UI Settings",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white,),
          ),
        ),
      ),
      body: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            NavButton(
              label: 'Update Interface',
              icon: Icons.update,
              color: const Color(0xFF08C4A1),
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const UpdatePage())
              ),
            ),
            NavButton(
              label: 'Hide UI',
              icon: Icons.visibility_off,
              color: Colors.redAccent,
              onPressed: () => print("Hiding UI..."),
            ),
          ],
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
  // State Variables
  bool _isAutoUpdateEnabled = false;
  bool _isChecking = false;
  String _currentVersion = "1.0.3";
  String _statusMessage = "System is up to date.";
  String _remoteVersion = "1.0.3";
  bool _updateAvailable = false;

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
    setState(() => _isAutoUpdateEnabled = value);
  }

  // Version Comparison Logic
  bool _isNewerVersion(String current, String remote) {
    try {
      List<int> currentParts = current.split('.').map(int.parse).toList();
      List<int> remoteParts = remote.split('.').map(int.parse).toList();

      for (var i = 0; i < remoteParts.length; i++) {
        int currentDigit = i < currentParts.length ? currentParts[i] : 0;
        if (remoteParts[i] > currentDigit) return true;
        if (remoteParts[i] < currentDigit) return false;
      }
    } catch (e) {
      debugPrint("Parsing Error: $e");
    }
    return false;
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _statusMessage = "Checking for updates...";
    });

    try {
      final url = Uri.parse('https://raw.githubusercontent.com/casper1051/newui/refs/heads/main/update/stable.json');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String newVer = data['version'];
        
        setState(() {
          _remoteVersion = newVer;
          _updateAvailable = _isNewerVersion(_currentVersion, _remoteVersion);
          _statusMessage = _updateAvailable 
              ? "A newer version ($_remoteVersion) is available." 
              : "System is up to date.";
        });
      } else {
        setState(() => _statusMessage = "Update server unreachable.");
      }
    } catch (e) {
      setState(() => _statusMessage = "Check failed. Check your internet.");
    } finally {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("System Updates", 
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version Info Card
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
                        _isChecking ? Icons.sync : (_updateAvailable ? Icons.info_outline : Icons.check_circle_outline), 
                        color: _isChecking ? Colors.orangeAccent : (_updateAvailable ? Colors.blueAccent : Colors.greenAccent), 
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

            // Settings Tile
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: const Text("Auto-Download Updates", 
                style: TextStyle(fontSize: 18, color: Colors.white)),
              subtitle: const Text("Automatically prepare updates in the background", 
                style: TextStyle(color: Colors.white38, fontSize: 13)),
              trailing: Switch(
                value: false,
                activeColor: const Color(0xFF08C4A1),
                onChanged: _toggleAutoUpdate,
              ),
            ),

            const Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: "Check Updates",
                    icon: Icons.search,
                    color: Colors.white10,
                    textColor: Colors.white,
                    // Graying out happens in the helper method below
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
                    onPressed: (_updateAvailable && !_isChecking) ? () async {
                      setState(() {
                        _isChecking = true;
                        _statusMessage = "Updating...";
                      });
                      final result = await Process.run('bash', ['-c', 'mkdir -p /home/user/newui_update && cd /home/user/newui_update && wget https://raw.githubusercontent.com/casper1051/newui/refs/heads/main/update/included.zip && unzip ./included.zip && rm ./included.zip && mkdir -p /home/user/newui && cp -r ./update/included /home/user/newui && cd /home/user && rm -rf /home/user/newui_update']);
                      if (result.exitCode == 0) {
                        setState(() {
                          _statusMessage = "Update successful!";
                          _isChecking = false;
                        });
                      } else {
                        setState(() {
                          _statusMessage = "Error: ${result.stderr}";
                          _isChecking = false;
                        });
                      }
                    } : null,
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
    bool isDisabled = onPressed == null;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        // Switch to Gray if disabled
        backgroundColor: isDisabled ? Colors.grey.withOpacity(0.1) : color,
        foregroundColor: isDisabled ? Colors.white24 : textColor,
        disabledBackgroundColor: Colors.white10, // Backup for Flutter's default
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    );
  }
}