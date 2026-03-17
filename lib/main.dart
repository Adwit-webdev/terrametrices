import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const TerraMetricsApp());
}

class TerraMetricsApp extends StatelessWidget {
  const TerraMetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TerraMetrics',
      debugShowCheckedModeBanner: false, // Removes the ugly red debug banner
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const DashboardScreen(),
    );
  }
}