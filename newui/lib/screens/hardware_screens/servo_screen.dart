import 'package:flutter/material.dart';
import 'servo_controller.dart';
import 'dart:math' as math;

class ServoPage extends StatefulWidget {
  const ServoPage({super.key});
  @override
  State<ServoPage> createState() => _ServoPageState();
}

class _ServoPageState extends State<ServoPage> {
  final servoController = ServoController();
  int _selectedPort = 0;

  @override
  void initState() {
    super.initState();
    servoController.init();
  }

  void _handleDialChange(double val) {
    servoController.setPosition(_selectedPort, val);
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    double currentPos = servoController.positions[_selectedPort];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("Servo Control"), backgroundColor: Colors.transparent),
      body: Row(
        children: [
          
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("CURRENT ANGLE", style: TextStyle(color: Colors.white38, letterSpacing: 1.5)),
                Text("${currentPos.round()}", 
                  style: const TextStyle(fontSize: 60, fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: FittedBox(
                      child: CircularDial(
                        value: currentPos,
                        min: 0,
                        max: 2047,
                        onChanged: _handleDialChange,
                      ),
                    ),
                  ),
                ),
                
                const Text("0 - 2047 Range", style: TextStyle(color: Colors.white24)),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          Container(
            width: 70,
            color: Colors.black26,
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(4, (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildPortButton(index),
                )),
              ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 45, height: 45,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text("$index", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.white54))),
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

    
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, 
      Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round);

    
    double progress = (value - min) / (max - min);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * progress, false, 
      Paint()..color = Colors.blueAccent..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.round);

    
    final knobAngle = startAngle + (sweepAngle * progress);
    final knobOffset = Offset(center.dx + radius * math.cos(knobAngle), center.dy + radius * math.sin(knobAngle));
    canvas.drawCircle(knobOffset, 8, Paint()..color = Colors.white);
  }

  @override bool shouldRepaint(DialPainter oldDelegate) => oldDelegate.value != value;
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
