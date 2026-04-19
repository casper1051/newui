import 'package:flutter/material.dart';
import 'dart:io';

class STM32Page extends StatefulWidget {
  const STM32Page({super.key});

  @override
  State<STM32Page> createState() => _STM32PageState();
}

class _STM32PageState extends State<STM32Page> {
  bool _isProcessing = false;
  String _statusMessage = "Ready to flash.";

  Future<void> _reflashSTM32() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = "Flashing firmware... Do not power off.";
    });

    
    _showLockingOverlay(context);

    try {
      
      final result = await Process.run('bash', ['-c', 'cd /home/user/newui']);
      
      setState(() {
        _statusMessage = result.exitCode == 0 ? "Reflash successful!" : "Error: ${result.stderr}";
      });
    } catch (e) {
      setState(() => _statusMessage = "System Error: $e");
    } finally {
      
      Navigator.of(context).pop(); 
      setState(() => _isProcessing = false);
    }
  }

  
  void _showLockingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, 
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.orangeAccent),
                  SizedBox(height: 20),
                  Text(
                    "Reflashing firmware",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none
                    ),
                  ),
                  Text(
                    "Please do not power off your device.",
                    style: TextStyle(
                      color: Colors.white54, 
                      fontSize: 14,
                      decoration: TextDecoration.none
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReflashConfirm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text("Confirm Reflash", style: TextStyle(color: Colors.white)),
          content: const Text("System will be locked until the process finishes."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CANCEL", style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.of(context).pop();
                _reflashSTM32();
              },
              child: const Text("CONFIRM", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.transparent,
        
        automaticallyImplyLeading: !_isProcessing, 
        title: const Text("STM32 Management", 
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_statusMessage, style: const TextStyle(color: Colors.white70, fontSize: 18)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _showReflashConfirm,
                icon: const Icon(Icons.bolt),
                label: const Text("REFLASH FIRMWARE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}