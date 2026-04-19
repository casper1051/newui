import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  TextEditingController? _activeController;

  String currentSSID = "Loading...";
  String localIP = "0.0.0.0";
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    _fetchNetworkInfo();
  }

  
Future<void> _fetchNetworkInfo() async {
  String ssid = "Disconnected";
  String ip = "No IP";

  try {
    
    
    final ssidResult = await Process.run('nmcli', [
      '-t', 
      '-f', 'active,ssid', 
      'dev', 'wifi'
    ]);

    if (ssidResult.exitCode == 0) {
      
      final lines = LineSplitter.split(ssidResult.stdout.toString());
      for (var line in lines) {
        if (line.startsWith('yes:')) {
          ssid = line.split(':')[1];
          break;
        }
      }
    }

    
    
    final ipResult = await Process.run('hostname', ['-I']);
    if (ipResult.exitCode == 0) {
      
      ip = ipResult.stdout.toString().split(' ').first.trim();
    }

  } catch (e) {
    print("Error fetching network info: $e");
    ssid = "Error";
    ip = "Error";
  }

  setState(() {
    currentSSID = ssid;
    localIP = ip;
  });
}

  void _connectToNetwork() {
    setState(() => isConnecting = true);
    
    debugPrint("Connecting to ${_ssidController.text}...");
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isConnecting = false);
      _activeController = null; 
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: 100,
        centerTitle: true,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          "Network Settings",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildInputField("SSID", _ssidController, Icons.wifi),
                const SizedBox(height: 16),
                _buildInputField("Password", _passController, Icons.lock, isPassword: true),
                const SizedBox(height: 24),
                _buildConnectButton(),
              ],
            ),
          ),
          if (_activeController != null) _buildVirtualKeyboard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.router, color: Colors.blueAccent, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(currentSSID, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("IP: $localIP", style: TextStyle(color: Colors.white.withOpacity(0.5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    bool isActive = _activeController == controller;
    return GestureDetector(
      onTap: () => setState(() => _activeController = controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.blueAccent : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.blueAccent.withOpacity(0.7), fontSize: 12)),
                  Text(
                    isPassword ? "•" * controller.text.length : controller.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (controller.text.isEmpty)
                    Text("Tap to type...", style: TextStyle(color: Colors.white.withOpacity(0.2))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: isConnecting ? null : _connectToNetwork,
        child: isConnecting 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("CONNECT TO NETWORK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildVirtualKeyboard() {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Column(
        children: [
          _buildKeyboardRow(["1","2","3","4","5","6","7","8","9","0"]),
          _buildKeyboardRow(["Q","W","E","R","T","Y","U","I","O","P"]),
          _buildKeyboardRow(["A","S","D","F","G","H","J","K","L"]),
          _buildKeyboardRow(["Z","X","C","V","B","N","M", "⌫"]),
          _buildKeyboardRow(["SPACE", "DONE"]),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Material(
            color: (key == "DONE" || key == "⌫") ? Colors.blueGrey[800] : const Color(0xFF333333),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => _handleKeyPress(key),
              child: Container(
                width: (key == "SPACE" || key == "DONE") ? 100 : 40,
                height: 45,
                alignment: Alignment.center,
                child: Text(key, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleKeyPress(String key) {
    if (_activeController == null) return;
    setState(() {
      if (key == "⌫") {
        if (_activeController!.text.isNotEmpty) {
          _activeController!.text = _activeController!.text.substring(0, _activeController!.text.length - 1);
        }
      } else if (key == "DONE") {
        _activeController = null;
      } else if (key == "SPACE") {
        _activeController!.text += " ";
      } else {
        _activeController!.text += key.toLowerCase();
      }
    });
  }
}