import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemServicesPage extends StatefulWidget {
  const SystemServicesPage({super.key});

  @override
  State<SystemServicesPage> createState() => _SystemServicesPageState();
}

class _SystemServicesPageState extends State<SystemServicesPage> {
  bool isSshEnabled = false;
  bool isBridgeEnabled = false;
  bool isVncEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadServiceStates();
  }

  Future<void> _loadServiceStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSshEnabled = prefs.getBool('ssh_enabled') ?? false;
      isBridgeEnabled = prefs.getBool('bridge_enabled') ?? false;
      isVncEnabled = prefs.getBool('vnc_enabled') ?? false;
    });
  }

  Future<void> _toggleService(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    setState(() {
      if (key == 'ssh_enabled') isSshEnabled = value;
      if (key == 'bridge_enabled') isBridgeEnabled = value;
      if (key == 'vnc_enabled') isVncEnabled = value;
    });

    debugPrint("Service $key is now $value");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 40.0),
          child: Text(
            "System Services",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            _buildServiceTile(
              label: "SSH Server",
              subtitle: "Port 22 • Secure Shell",
              icon: Icons.terminal,
              value: isSshEnabled,
              onChanged: (val) => _toggleService('ssh_enabled', val),
            ),
            const SizedBox(height: 16),
            _buildServiceTile(
              label: "Network Bridge",
              subtitle: "br0 • Ethernet to WLAN",
              icon: Icons.router,
              value: isBridgeEnabled,
              onChanged: (val) => _toggleService('bridge_enabled', val),
            ),
            const SizedBox(height: 16),
            _buildServiceTile(
              label: "VNC Server",
              subtitle: "Port 5900 • Remote Desktop",
              icon: Icons.desktop_windows,
              value: isVncEnabled,
              onChanged: (val) => _toggleService('vnc_enabled', val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: value ? const Color(0xFF252525) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? Colors.blueAccent.withOpacity(0.5) : Colors.white10,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: value ? Colors.blueAccent : Colors.grey, size: 28),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        trailing: Switch(
          value: value,
          activeColor: Colors.blueAccent,
          onChanged: onChanged,
        ),
      ),
    );
  }
}