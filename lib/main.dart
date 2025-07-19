import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/acerca_page.dart';
import 'screens/home_dashboard.dart';
import 'screens/ecg_screen.dart';
import 'screens/settings_page.dart';
import 'screens/permission_screen.dart';
import 'providers/bluetooth_provider.dart';

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

void main() => runApp(const ECGApp());

class ECGApp extends StatelessWidget {
  const ECGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BluetoothProvider>(
      create: (_) => BluetoothProvider(useSimulator: true)..initBluetooth(),
      child: MaterialApp(
        title: 'ECG Bluetooth Classic',
        theme: appTheme,
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (context, btController, _) {
        final status = btController.statusString;
        final isPermDenied =
            status.contains('denegado permanentemente') ||
            status.contains('insuficiente');
        final isBtOff =
            status.trim() == 'Bluetooth desactivado' ||
            status.trim() == 'Active Bluetooth en ajustes del dispositivo';

        if (isPermDenied) {
          return PermissionScreen(
            message: status,
            onOpenSettings: btController.openAppSettingsIfNeeded,
            onRetry: () async {
              await btController.initBluetooth();
              if (mounted) setState(() {});
            },
          );
        }

        return _buildMainScaffold(isBtOff, btController);
      },
    );
  }

  Widget _buildMainScaffold(bool isBtOff, BluetoothProvider btController) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        maintainBottomViewPadding: false,
        child: Column(
          children: [
            if (isBtOff)
              Container(
                width: double.infinity,
                color: Colors.red.withAlpha((0.12 * 255).toInt()),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bluetooth_disabled,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Activa el Bluetooth para conectar con dispositivos.',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  HomeDashboard(userName: 'Roxsel Gonzalez'),
                  ECGScreen(controller: btController),
                  SettingsPage(controller: btController),
                  AcercaPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: CircleNavBar(
        activeIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        circleColor: Colors.blueAccent,
        elevation: 0,
        color: Colors.white,
        height: 90,
        circleWidth: 60,
        shadowColor: Colors.black26,
        activeIcons: const [
          Icon(LineAwesomeIcons.home_solid, color: Colors.white),
          Icon(LineAwesomeIcons.heart, color: Colors.white),
          Icon(LineAwesomeIcons.bluetooth, color: Colors.white),
          Icon(LineAwesomeIcons.info_circle_solid, color: Colors.white),
        ],
        inactiveIcons: const [
          Icon(LineAwesomeIcons.home_solid, color: Colors.blueAccent),
          Icon(LineAwesomeIcons.heart, color: Colors.red),
          Icon(LineAwesomeIcons.bluetooth, color: Colors.green),
          Icon(LineAwesomeIcons.info_circle_solid, color: Colors.blueAccent),
        ],
      ),
    );
  }
}
// ...existing code...

//
