import 'package:flutter/material.dart';
import 'micro_telematics_screen.dart'; 
import 'macro_map_screen.dart';
import 'economics_screen.dart';
import 'report_hazard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1; 

 
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