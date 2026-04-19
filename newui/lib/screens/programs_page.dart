import 'package:flutter/material.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  int _selectedProgramIndex = 0;

  final List<Map<String, String>> _programs = [
    {'name': 'Tournament Code', 'lastRun': 'undefined'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Program Manager", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: _programs.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedProgramIndex == index;
                    return ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      tileColor: isSelected ? Colors.indigoAccent.withOpacity(0.2) : Colors.transparent,
                      title: Text(
                        _programs[index]['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.indigoAccent : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text("Last run: ${_programs[index]['lastRun']}", 
                        style: const TextStyle(fontSize: 12, color: Colors.white24)),
                      leading: Icon(
                        Icons.code, 
                        color: isSelected ? Colors.indigoAccent : Colors.white24
                      ),
                      onTap: () => setState(() => _selectedProgramIndex = index),
                    );
                  },
                ),
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActionButton(
                    label: "RUN",
                    icon: Icons.play_arrow_rounded,
                    color: Colors.greenAccent,
                    onPressed: () => _sendCommand("RUN"),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    label: "RECOMPILE",
                    icon: Icons.build_circle_outlined,
                    color: Colors.orangeAccent,
                    onPressed: () => _sendCommand("RECOMPILE"),
                  ),
                  const SizedBox(height: 20),
                  _buildActionButton(
                    label: "TOURNAMENT",
                    icon: Icons.emoji_events_outlined,
                    color: Colors.indigoAccent,
                    onPressed: () => _sendCommand("TOURNAMENT"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5), width: 2),
        padding: const EdgeInsets.symmetric(vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _sendCommand(String action) {
    String programName = _programs[_selectedProgramIndex]['name']!;
    debugPrint("Sending: $action for $programName");
  }
}