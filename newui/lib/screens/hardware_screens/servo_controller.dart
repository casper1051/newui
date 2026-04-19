import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

class ServoController extends ChangeNotifier {
  static final ServoController _instance = ServoController._internal();
  factory ServoController() => _instance;
  ServoController._internal();

  Socket? _socket;
  bool isConnected = false;
  bool _isWriting = false; 

  final List<double> positions = List.filled(8, 1024.0);

  Future<void> init() async {
    if (isConnected) return;
    try {
      _socket = await Socket.connect('127.0.0.1', 8080, timeout: const Duration(seconds: 1));
      _socket!.setOption(SocketOption.tcpNoDelay, true);
      isConnected = true;
    } catch (e) {
      isConnected = false;
    }
  }

  void setPosition(int port, double val) async {
    positions[port] = val;
    notifyListeners();

    
    
    if (!isConnected || _socket == null || _isWriting) return;

    _isWriting = true;
    try {
      _socket!.write("SERVO S $port ${val.round()}\n");
      await _socket!.flush(); 
    } catch (e) {
      debugPrint("Socket write error: $e");
    } finally {
      _isWriting = false;
    }
  }
}