import 'dart:async';
import 'package:flutter/material.dart';
import 'bluetooth_provider.dart';
import '../services/socket_service.dart';

class SocketProvider extends ChangeNotifier {
  final BluetoothProvider bluetoothController;
  final SocketService _socketService = SocketService();
  String? estadoAnalisis;
  Timer? _timer;
  bool _initialized = false;

  SocketProvider({required this.bluetoothController});

  void init() {
    if (_initialized) return;
    _initialized = true;
    _socketService.connect((estado) {
      estadoAnalisis = estado;
      notifyListeners();
    });
    _startPeriodicSend();
  }

  void _startPeriodicSend() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => sendEcgData());
    // Enviar inmediatamente al iniciar
    sendEcgData();
  }

  void sendEcgData() {
    final data = bluetoothController.ecgData;
    if (data.length >= 200) {
      final ventana = data.sublist(data.length - 200);
      _socketService.enviarVentana(ventana);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _socketService.dispose();
    super.dispose();
  }
}
