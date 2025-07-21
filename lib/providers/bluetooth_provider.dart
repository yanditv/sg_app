import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart';
import '../services/bluetooth_service_simulator.dart';

class BluetoothProvider extends ChangeNotifier {
  final bool useSimulator;
  late final BluetoothService _service;
  BluetoothServiceSimulator? _simulator;

  BluetoothProvider({this.useSimulator = false}) {
    if (useSimulator) {
      _simulator = BluetoothServiceSimulator(onData: (_) => notifyListeners());
      _simulator!.start();
    } else {
      _service = BluetoothService();
      _service.onECGData = (_) => notifyListeners();
    }
  }

  List<int> get ecgData =>
      useSimulator ? (_simulator?.ecgData ?? []) : _service.ecgData;
  bool get isConnecting => useSimulator ? false : _service.isConnecting;
  String? get deviceName => useSimulator ? 'Simulado' : _service.deviceName;
  String get statusString =>
      useSimulator ? 'Simulando datos' : _service.statusString;

  Future<void> initBluetooth() async {
    if (useSimulator) return;
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await _service.requestPermissions();
      await _service.setupBluetoothStateListener((status, connecting) {
        _service.statusString = status;
        _service.isConnecting = connecting;
        notifyListeners();
      });
      await _service.checkBluetoothState();
    } catch (e) {
      _service.statusString = 'Error inicial: $e';
      notifyListeners();
    }
  }

  Future<void> reconnect() async {
    if (useSimulator) return;
    await _service.reconnect((status, connecting) {
      _service.statusString = status;
      _service.isConnecting = connecting;
      notifyListeners();
    });
    notifyListeners();
  }

  /// Abre la configuración de la app si es necesario (iOS y permisos denegados permanentemente)
  Future<void> openAppSettingsIfNeeded() async {
    if (useSimulator) return;
    if (statusString.contains('denegado permanentemente')) {
      await openAppSettings();
    }
  }

  @override
  Future<void> dispose() async {
    if (useSimulator) {
      _simulator?.dispose();
    } else {
      await _service.dispose();
    }
    super.dispose();
  }
}
