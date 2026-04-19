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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      title: const Text(
                        "Hide Interface?",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        "Are you sure you want to exit the UI? \n\nNote: A system reboot will be required to bring the interface back.",
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            exit(0);
                          },
                          child: const Text("HIDE UI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  },
                );
              },
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
  bool _isAutoUpdateEnabled = false;
  bool _isChecking = false;
  String _currentVersion = "1.0.8";
  String _statusMessage = "Check updates to determine status.";
  String _remoteVersion = "1.0.8";
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isAutoUpdateEnabled = false);
  }

  Future<void> _toggleAutoUpdate(bool value) async {
    setState(() => _isAutoUpdateEnabled = false);
  }

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

  Future<void> _runUpdateSequence() async {
    List<String> commands = [
      'mkdir -p /home/user/newui_update',
      'cd /home/user/newui_update && wget https://raw.githubusercontent.com/casper1051/newui/main/update/included.zip',
      'cd /home/user/newui_update && unzip -o ./included.zip -d .',
      'rm /home/user/newui_update/included.zip',
      'mkdir -p /home/user/newui',
      'cp -r /home/user/newui_update/update/included /home/user/newui',
      'rm -rf /home/user/newui_update'
    ];

    List<String> logOutput = [];
    bool hasFailed = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: 600,
                height: 400,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("SYSTEM UPDATE IN PROGRESS", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 5),
                    const Text("Do not close the application or power off.", 
                      style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                    const Divider(color: Colors.white10, height: 30),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: logOutput.map((log) => Text(
                              log,
                              style: const TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 13),
                            )).toList(),
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    if (!hasFailed && logOutput.length < (commands.length * 2))
                      const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Color(0xFF08C4A1)),
                      )),
                    if (hasFailed || logOutput.length >= (commands.length * 2))
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: hasFailed ? Colors.redAccent : const Color(0xFF08C4A1),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(hasFailed ? "CLOSE (ERROR)" : "CONFIRM & EXIT", 
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    for (var cmd in commands) {
      if (hasFailed) break;

      setState(() => logOutput.add("> Running: $cmd"));
      
      try {
        final result = await Process.run('bash', ['-c', cmd]);
        if (result.exitCode == 0) {
          setState(() => logOutput.add("  Success."));
        } else {
          hasFailed = true;
          setState(() => logOutput.add("  FAILED: ${result.stderr}"));
        }
      } catch (e) {
        hasFailed = true;
        setState(() => logOutput.add("  EXCEPTION: $e"));
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
    }

    setState(() {
      _isChecking = false;
      _statusMessage = hasFailed ? "Update failed." : "Update successful!";
    });
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
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              title: const Text("Auto-Download Updates", style: TextStyle(fontSize: 18, color: Colors.white)),
              subtitle: const Text("Automatically prepare updates in the background", style: TextStyle(color: Colors.white38, fontSize: 13)),
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
                    label: "Check Updates",
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
                    onPressed: (_updateAvailable && !_isChecking) ? _runUpdateSequence : null,
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
        backgroundColor: isDisabled ? Colors.grey.withOpacity(0.1) : color,
        foregroundColor: isDisabled ? Colors.white24 : textColor,
        disabledBackgroundColor: Colors.white10,
        padding: const EdgeInsets.symmetric(vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
    );
  }
}