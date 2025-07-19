import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends ChangeNotifier {
  /// Llama a esto desde la UI si statusString contiene 'denegado permanentemente'.
  Future<void> openAppSettingsIfNeeded() async {
    if (Platform.isIOS && statusString.contains('denegado permanentemente')) {
      await openAppSettings();
    }
  }

  BluetoothDevice? _device;
  // BluetoothCharacteristic? _characteristic; // Removed unused field
  List<int> ecgData = [];
  bool isConnecting = false;
  String? deviceName;
  String statusString = 'Desconectado';
  StreamSubscription? _connectionSubscription;
  StreamSubscription<List<int>>? _valueSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  // Constants
  static const String serviceUUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String characteristicUUID =
      'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String targetDeviceName = 'ESP32_SG';

  Future<void> initBluetooth() async {
    try {
      // Initialize with delay to allow UI to stabilize
      await Future.delayed(const Duration(milliseconds: 100));
      await _requestPermissions();
      await _setupBluetoothStateListener();
      await _checkBluetoothState();
    } catch (e) {
      statusString = 'Error inicial: $e';
      notifyListeners();
      // No relanzar la excepción para evitar que la app se rompa
    }
  }

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isIOS) {
        // Según la guía oficial de flutter_blue_plus, en iOS NO se debe pedir permiso de localización.
        // Solo asegúrate de que Info.plist tenga las claves necesarias.
        // No se solicita ningún permiso aquí para iOS.
        return;
      } else {
        final statuses = await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();
        if (!statuses[Permission.bluetooth]!.isGranted ||
            !statuses[Permission.bluetoothScan]!.isGranted ||
            !statuses[Permission.bluetoothConnect]!.isGranted) {
          statusString = 'Permisos Bluetooth insuficientes';
          notifyListeners();
          throw 'Permisos Bluetooth insuficientes';
        }
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      rethrow;
    }
  }

  Future<void> _setupBluetoothStateListener() async {
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        statusString = 'Bluetooth desactivado';
        isConnecting = false;
        notifyListeners();
      }
    });
  }

  Future<void> _checkBluetoothState() async {
    if (!await FlutterBluePlus.isAvailable) {
      throw 'Bluetooth no disponible en este dispositivo';
    }
    if (!await FlutterBluePlus.isOn) {
      throw 'Active Bluetooth en ajustes del dispositivo';
    }
  }

  Future<void> reconnect() async {
    if (isConnecting) return;
    await Future.delayed(const Duration(milliseconds: 50));
    await _connectToESP32();
  }

  Future<void> _connectToESP32() async {
    isConnecting = true;
    statusString = 'Buscando $targetDeviceName...';
    notifyListeners();
    try {
      await _disposeResources();
      await _scanAndConnect();
    } catch (e) {
      await _handleConnectionError(e);
    } finally {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> _scanAndConnect() async {
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        androidUsesFineLocation: true,
      );
      debugPrint('Escaneando dispositivos BLE...');
      final espDevice = await _findESP32Device();
      if (espDevice == null) throw '$targetDeviceName no encontrado';
      await _connectAndSetupDevice(espDevice);
    } catch (e) {
      debugPrint('Scan error: $e');
      rethrow;
    }
  }

  Future<BluetoothDevice?> _findESP32Device() async {
    final completer = Completer<BluetoothDevice?>();
    late StreamSubscription<List<ScanResult>> scanSub;
    scanSub = FlutterBluePlus.scanResults.listen((results) {
      try {
        for (final result in results) {
          if (result.device.advName == targetDeviceName ||
              result.advertisementData.serviceUuids.contains(
                Guid(serviceUUID),
              )) {
            debugPrint('Dispositivo encontrado: [${result.device.remoteId}]');
            completer.complete(result.device);
            scanSub.cancel();
            return;
          }
        }
      } catch (e) {
        completer.completeError(e);
      }
    });
    scanSub.onError(completer.completeError);
    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => null,
    );
  }

  Future<void> _connectAndSetupDevice(BluetoothDevice device) async {
    try {
      _device = device;
      deviceName = device.advName;
      _connectionSubscription = device.connectionState.listen(
        _handleConnectionState,
      );
      statusString = 'Conectando a $deviceName...';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 30));
      await device.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 8),
        mtu: 512,
      );
      await _setupServices(device);
      statusString = 'Conectado a $deviceName';
      isConnecting = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Connection error: $e');
      await device.disconnect();
      rethrow;
    }
  }

  void _handleConnectionState(BluetoothConnectionState state) {
    if (state == BluetoothConnectionState.disconnected) {
      statusString = 'Desconectado de $deviceName';
      isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> _setupServices(BluetoothDevice device) async {
    statusString = 'Configurando $deviceName...';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 20));
    final services = await device.discoverServices();
    final service = services.firstWhere(
      (s) => s.uuid == Guid(serviceUUID),
      orElse: () => throw 'Servicio ECG no encontrado',
    );
    final characteristic = service.characteristics.firstWhere(
      (c) => c.uuid == Guid(characteristicUUID),
      orElse: () => throw 'Característica ECG no encontrada',
    );
    await characteristic.setNotifyValue(true);
    // _characteristic = characteristic; // Removed assignment to unused field
    _valueSubscription = characteristic.onValueReceived.listen(_processECGData);
  }

  void _processECGData(List<int> value) {
    try {
      Future.microtask(() {
        final raw = utf8.decode(value);
        final json = jsonDecode(raw);
        final ecgValue = json['ecg'] as int;
        ecgData.add(ecgValue);
        if (ecgData.length > 200) ecgData.removeAt(0);
        if (DateTime.now().difference(_lastNotifyTime).inMilliseconds > 16) {
          notifyListeners();
          _lastNotifyTime = DateTime.now();
        }
      });
    } catch (e) {
      debugPrint('Error procesando datos ECG: $e');
    }
  }

  DateTime _lastNotifyTime = DateTime.now();

  Future<void> _handleConnectionError(dynamic error) async {
    statusString = 'Error: ${error.toString()}';
    isConnecting = false;
    debugPrint('Connection error: $error');
    notifyListeners();
  }

  Future<void> _disposeResources() async {
    await _valueSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _valueSubscription = null;
    _connectionSubscription = null;
  }

  @override
  Future<void> dispose() async {
    await _adapterStateSubscription?.cancel();
    await _disposeResources();
    await _device?.disconnect();
    super.dispose();
  }
}
