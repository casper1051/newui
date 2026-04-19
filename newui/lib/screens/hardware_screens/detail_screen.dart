import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../widgets/nav_button.dart';


class SensorStreamer {
  Socket? _socket;
  StreamSubscription? _subscription;
  
  final _controller = StreamController<String>.broadcast();
  bool _isConnected = false;

  Future<bool> connect() async {
    try {
      _socket = await Socket.connect('127.0.0.1', 8080, timeout: const Duration(seconds: 1));
      _socket!.setOption(SocketOption.tcpNoDelay, true);
      
      _isConnected = true;

      _subscription = _socket!.listen(
        (data) {
          
          String response = utf8.decode(data).trim();
          _controller.add(response);
        },
        onError: (err) {
          debugPrint("Socket Error: $err");
          _isConnected = false;
        },
        onDone: () {
          debugPrint("Socket Connection Closed by Server");
          _isConnected = false;
        },
      );
      
      return true;
    } catch (e) {
      debugPrint("Connection failed: $e");
      return false;
    }
  }

  void sendCommand(String cmd) {
    if (_socket != null && _isConnected) {
      
      _socket!.add(utf8.encode(cmd));
      _socket!.flush(); 
    }
  }

  Stream<String> get responseStream => _controller.stream;

  void dispose() {
    _isConnected = false;
    _subscription?.cancel();
    _socket?.destroy();
    _controller.close();
  }
}


String getCommand(String name) {
  String label = name.toLowerCase();
  String cmd = "";
  if (label.startsWith('d')) cmd = "DIGITAL G ${label.replaceFirst('d', '')} 0";
  else if (label.startsWith('a')) cmd = "ANALOG G ${label.replaceFirst('a', '')} 0";
  else if (label.contains('gyro')) {
    String axis = label.contains('0') ? 'X' : (label.contains('1') ? 'Y' : 'Z');
    cmd = "GYRO $axis 0 0";
  }
  else if (label.contains('b-emf')) cmd = "MOTOR G ${label.split(' ').last} 0";
  else cmd = "SIDE_BUTTON G 0 0";

  return "$cmd\n"; 
}


class SensorDisplayDetail extends StatefulWidget {
  final String sensorName;
  const SensorDisplayDetail({super.key, required this.sensorName});

  @override
  State<SensorDisplayDetail> createState() => _SensorDisplayDetailState();
}

class _SensorDisplayDetailState extends State<SensorDisplayDetail> {
  final SensorStreamer _streamer = SensorStreamer();
  late List<double> dataBuffer;
  StreamSubscription? _dataSub;
  Timer? pollTimer;
  int lastIntVal = 0;
  bool isDigital = false;

  @override
  void initState() {
    super.initState();
    isDigital = widget.sensorName.toLowerCase().startsWith('d') || widget.sensorName.toLowerCase().contains('user');
    
    dataBuffer = List<double>.generate(100, (_) => 0.0, growable: true);
    _initConnection();
  }

  void _initConnection() async {
    bool ok = await _streamer.connect();
    if (ok) {
      _dataSub = _streamer.responseStream.listen((data) {
        if (mounted) {
          setState(() {
            
            lastIntVal = int.tryParse(data) ?? lastIntVal;
            dataBuffer.add(lastIntVal.toDouble());
            dataBuffer.removeAt(0);
          });
        }
      });

      
      pollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
        _streamer.sendCommand(getCommand(widget.sensorName));
      });
    } else {
      debugPrint("Could not connect to server.");
    }
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    _dataSub?.cancel();
    _streamer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(widget.sensorName),
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(lastIntVal.toString(), 
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, fontFamily: 'Courier', color: Colors.white)),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.white24)),
                child: CustomPaint(
                  painter: ScrollingGraphPainter(
                    data: dataBuffer, 
                    maxRange: isDigital ? 1 : 4096,
                    lineColor: isDigital ? Colors.greenAccent : Colors.orangeAccent
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ScrollingGraphPainter extends CustomPainter {
  final List<double> data;
  final int maxRange;
  final Color lineColor;

  ScrollingGraphPainter({required this.data, required this.maxRange, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    double xStep = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double normalizedY = size.height - ((data[i] / maxRange) * size.height);
      normalizedY = normalizedY.clamp(0.0, size.height);
      double x = i * xStep;

      if (i == 0) path.moveTo(x, normalizedY);
      else {
        if (maxRange == 1) { 
          double prevY = size.height - ((data[i-1] / maxRange) * size.height);
          path.lineTo(x, prevY);
        }
        path.lineTo(x, normalizedY);
      }
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(ScrollingGraphPainter oldDelegate) => true;
}


PreferredSizeWidget _buildAppBar(String title) => AppBar(
  toolbarHeight: 80, backgroundColor: const Color(0xFF121212), elevation: 0, centerTitle: true,
  title: Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
);

void _navTo(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute(builder: (context) => page));

Widget _sensorBtn(BuildContext context, String name, IconData icon, Color color) => NavButton(
  label: name, icon: icon, color: color, size: Size.infinite,
  onPressed: () => _navTo(context, SensorDisplayDetail(sensorName: name)),
);

Widget _buildSymmetricGrid(BuildContext context, int count, List<Widget> children) => Padding(
  padding: const EdgeInsets.all(20),
  child: GridView.count(crossAxisCount: count, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.8, children: children),
);

class SensorsPage extends StatelessWidget {
  const SensorsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar("Sensors Hub"),
    body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        NavButton(label: 'Digital', icon: Icons.fingerprint, color: const Color(0xFF08C4A1), onPressed: () => _navTo(context, const DigitalSensorsPage())),
        const SizedBox(height: 20),
        NavButton(label: 'Analog', icon: Icons.analytics, color: Colors.orangeAccent, onPressed: () => _navTo(context, const AnalogSensorsPage())),
        const SizedBox(height: 20),
        NavButton(label: 'Misc', icon: Icons.miscellaneous_services, color: Colors.indigoAccent, onPressed: () => _navTo(context, const MiscSensorsPage())),
      ]),
    ),
  );
}

class DigitalSensorsPage extends StatelessWidget {
  const DigitalSensorsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar("Digital"),
    body: _buildSymmetricGrid(context, 4, List.generate(8, (i) => _sensorBtn(context, "D$i", Icons.settings_input_component, const Color(0xFF08C4A1)))),
  );
}

class AnalogSensorsPage extends StatelessWidget {
  const AnalogSensorsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar("Analog"),
    body: _buildSymmetricGrid(context, 3, List.generate(6, (i) => _sensorBtn(context, "A$i", Icons.linear_scale, Colors.orangeAccent))),
  );
}

class MiscSensorsPage extends StatelessWidget {
  const MiscSensorsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _buildAppBar("Misc"),
    body: _buildSymmetricGrid(context, 4, [
      ...List.generate(3, (i) => _sensorBtn(context, "Gyro 0", Icons.screen_rotation, Colors.indigoAccent)),
      _sensorBtn(context, "User 0", Icons.touch_app, Colors.blueAccent),
      ...List.generate(4, (i) => _sensorBtn(context, "B-EMF 0", Icons.electric_bolt, Colors.redAccent)),
    ]),
  );
}