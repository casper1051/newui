import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';

class MotorController extends ChangeNotifier {
  
  static final MotorController _instance = MotorController._internal();
  factory MotorController() => _instance;
  MotorController._internal();

  Socket? _socket;
  bool isConnected = false;
  
  
  final List<double> speeds = [0.0, 0.0, 0.0, 0.0];
  final List<int> positions = [0, 0, 0, 0];
  
  final _responseController = StreamController<String>.broadcast();

  Future<void> init() async {
    if (isConnected) return;
    try {
      _socket = await Socket.connect('127.0.0.1', 8080, timeout: const Duration(seconds: 1));
      _socket!.setOption(SocketOption.tcpNoDelay, true);
      isConnected = true;

      _socket!.listen((data) {
        String resp = utf8.decode(data).trim();
        _responseController.add(resp);
        
        
      }, onDone: () => isConnected = false);
    } catch (e) {
      isConnected = false;
    }
  }

  void setSpeed(int port, double val) {
    speeds[port] = val;
    if (isConnected) {
      _socket!.write("MOTOR S $port ${val.round()}\n");
      _socket!.flush();
    }
    notifyListeners();
  }

  void clearCounter(int port) {
    if (isConnected) {
      _socket!.write("MOTOR C $port 0\n");
      _socket!.flush();
    }
  }

  void requestPosition(int port) {
    if (isConnected) {
      _socket!.write("MOTOR G $port 0\n");
      _socket!.flush();
    }
  }

  Stream<String> get responses => _responseController.stream;
}