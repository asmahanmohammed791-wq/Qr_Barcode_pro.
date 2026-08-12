import 'package:flutter/material.dart';
import 'generate_qr_screen.dart';
import 'generate_barcode_screen.dart';
import 'scan_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GenerateQRScreen(),
    const GenerateBarcodeScreen(),
    const ScanScreen(),
    const HistoryScreen(),
  ];

  final List<String> _titles = [
    'Generate QR',
    'Generate Barcode',
    'Scan QR',
    'History',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code),
            label: 'QR Code',
          ),
          NavigationDestination(
            icon: Icon(Icons.barcode_reader),
            label: 'Barcode',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
