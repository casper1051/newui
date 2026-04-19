import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'motor_controller.dart';


class MotorStreamer {
  Socket? _socket;
  StreamSubscription? _subscription;
  final _controller = StreamController<String>.broadcast();
  bool _isConnected = false;

  Future<bool> connect() async {
    try {
      _socket = await Socket.connect('127.0.0.1', 8080, timeout: const Duration(seconds: 1));
      _socket!.setOption(SocketOption.tcpNoDelay, true);
      _isConnected = true;
      _subscription = _socket!.listen((data) => _controller.add(utf8.decode(data).trim()),
          onError: (e) => _isConnected = false, onDone: () => _isConnected = false);
      return true;
    } catch (e) { return false; }
  }

  void send(String cmd) {
    if (_socket != null && _isConnected) {
      _socket!.write("$cmd\n");
      _socket!.flush();
    }
  }

  Stream<String> get responseStream => _controller.stream;
  void dispose() { _subscription?.cancel(); _socket?.destroy(); _controller.close(); }
}
class MotorsPage extends StatefulWidget {
  const MotorsPage({super.key});
  @override
  State<MotorsPage> createState() => _MotorsPageState();
}

class _MotorsPageState extends State<MotorsPage> {
  final motorController = MotorController();
  int _selectedPort = 0;
  int _uiPosition = 0;
  StreamSubscription? _sub;
  Timer? _localPoll;

  @override
  void initState() {
    super.initState();
    
    motorController.init();
    
    
    _sub = motorController.responses.listen((data) {
      if (mounted) {
        setState(() => _uiPosition = int.tryParse(data) ?? _uiPosition);
      }
    });

    
    _localPoll = Timer.periodic(const Duration(milliseconds: 100), (t) {
      motorController.requestPosition(_selectedPort);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _localPoll?.cancel();
    super.dispose();
  }

  void _handleDialChange(double val) {
    motorController.setSpeed(_selectedPort, val);
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    
    double currentSpeed = motorController.speeds[_selectedPort];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Motor Control"), backgroundColor: Colors.transparent),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$_uiPosition", style: const TextStyle(fontSize: 42, color: Colors.greenAccent, fontFamily: 'Courier')),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () => motorController.clearCounter(_selectedPort),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                  child: const Text("CLEAR"),
                ),
                Expanded(
                  child: FittedBox(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularDial(
                          value: currentSpeed, 
                          min: -1500,
                          max: 1500,
                          onChanged: _handleDialChange,
                        ),
                        ElevatedButton(
                          onPressed: () => _handleDialChange(0),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: const CircleBorder(), padding: const EdgeInsets.all(25)),
                          child: const Text("STOP"),
                        ),
                      ],
                    ),
                  ),
                ),
                Text("${currentSpeed.round()}", style: const TextStyle(fontSize: 32, color: Colors.orangeAccent)),
              ],
            ),
          ),
          
          Container(
            width: 70,
            color: Colors.black26,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) => _buildPortButton(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortButton(int index) {
    bool isSelected = _selectedPort == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPort = index),
      child: Container(
        width: 45, height: 45,
        decoration: BoxDecoration(
          color: isSelected ? Colors.orangeAccent : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text("$index", style: TextStyle(color: isSelected ? Colors.black : Colors.white))),
      ),
    );
  }
}

class CircularDial extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CircularDial({super.key, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        Offset center = renderBox.size.center(Offset.zero);
        Offset touchPos = details.localPosition - center;
        
        
        double angle = math.atan2(touchPos.dy, touchPos.dx) - (math.pi * 0.75);
        
        
        double sweep = math.pi * 1.5;
        double normalized = (angle % (math.pi * 2)) / sweep;
        
        if (normalized >= 0 && normalized <= 1.0) {
          double newValue = (normalized * (max - min) + min).clamp(min, max);
          onChanged(newValue);
        }
      },
      child: CustomPaint(
        size: const Size(220, 220),
        painter: DialPainter(value: value, min: min, max: max),
      ),
    );
  }
}

class DialPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;

  DialPainter({required this.value, required this.min, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.45;
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final trackPaint = Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, trackPaint);

    final activePaint = Paint()..color = Colors.orangeAccent..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round;
    double progress = (value - min) / (max - min);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * progress, false, activePaint);

    
    final knobAngle = startAngle + (sweepAngle * progress);
    final knobOffset = Offset(center.dx + radius * math.cos(knobAngle), center.dy + radius * math.sin(knobAngle));
    canvas.drawCircle(knobOffset, 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(DialPainter oldDelegate) => oldDelegate.value != value;
}