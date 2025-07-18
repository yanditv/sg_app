import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'screens/info_page.dart';
import 'screens/ecg_screen.dart';
import 'screens/settings_page.dart';
import 'bluetooth_controller.dart';

void main() => runApp(const ECGApp());

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF7FAFC),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blueAccent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 22,
      color: Colors.blueAccent,
    ),
    iconTheme: IconThemeData(color: Colors.blueAccent),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  ),
);

// ...existing code up to appTheme...

class ECGApp extends StatelessWidget {
  const ECGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ECG Bluetooth Classic',
      theme: appTheme,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final BluetoothController _btController = BluetoothController();

  @override
  void initState() {
    super.initState();
    _btController.initBluetooth();
  }

  @override
  void dispose() {
    _btController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              InfoPage(),
              ECGScreen(controller: _btController),
              SettingsPage(controller: _btController),
            ],
          ),
        ),
        bottomNavigationBar: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: [
            SalomonBottomBarItem(
              icon: Icon(LineAwesomeIcons.home_solid),
              title: const Text('Inicio'),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: Icon(LineAwesomeIcons.heart),
              title: const Text('ECG'),
              selectedColor: Colors.red,
            ),
            SalomonBottomBarItem(
              icon: Icon(LineAwesomeIcons.bluetooth),
              title: const Text('Ajustes'),
              selectedColor: Colors.green,
            ),
          ],
          backgroundColor: Colors.white.withOpacity(0.95),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          duration: const Duration(milliseconds: 350),
        ),
      ),
    );
  }
}

//
