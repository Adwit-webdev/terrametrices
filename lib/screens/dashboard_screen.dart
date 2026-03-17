import 'package:flutter/material.dart';
import 'micro_telematics_screen.dart'; 
import 'macro_map_screen.dart';
import 'economics_screen.dart';
import 'report_hazard_screen.dart'; // Add this line// The map we just built!

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Start on index 1 (Telematics) so you can instantly test your hardware code
  int _selectedIndex = 1; 

  // The 3 main screens of TerraMetrics
  final List<Widget> _screens = [
    const MacroMapScreen(), // Placeholder
    const MicroTelematicsScreen(), // Your working Phase B engine
    const EconomicsScreen(),
    const ReportHazardScreen(), // Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.tealAccent[400],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Phase A: Space', // Geospatial mapping
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vibration),
            label: 'Phase B: Road', // Telematics
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Phase C: Econ', // Financials
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_enhance),
            label: 'AI Cam',
          ),
        ],
      ),
    );
  }
}