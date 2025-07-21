import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

typedef ECGDataCallback = void Function(List<int> ecgData);

class BluetoothService {
  BluetoothDevice? _device;
  List<int> ecgData = [];
  bool isConnecting = false;
  String? deviceName;
  String statusString = 'Desconectado';
  StreamSubscription? _connectionSubscription;
  StreamSubscription<List<int>>? _valueSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  ECGDataCallback? onECGData;

  // Constants
  static const String serviceUUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String characteristicUUID =
      'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String targetDeviceName = 'ESP32_SG';

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
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
        throw 'Permisos Bluetooth insuficientes';
      }
    }
  }

  Future<void> setupBluetoothStateListener(
    Function(String, bool) onState,
  ) async {
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        onState('Bluetooth desactivado', false);
      }
    });
  }

  Future<void> checkBluetoothState() async {
    if (!await FlutterBluePlus.isSupported) {
      throw 'Bluetooth no disponible en este dispositivo';
    }
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      throw 'Active Bluetooth en ajustes del dispositivo';
    }
  }

  Future<void> reconnect(Function(String, bool) onState) async {
    if (isConnecting) return;
    await Future.delayed(const Duration(milliseconds: 50));
    await connectToESP32(onState);
  }

  Future<void> connectToESP32(Function(String, bool) onState) async {
    isConnecting = true;
    statusString = 'Buscando $targetDeviceName...';
    onState(statusString, isConnecting);
    try {
      await disposeResources();
      await scanAndConnect(onState);
    } catch (e) {
      onState('Error: $e', false);
    } finally {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> scanAndConnect(Function(String, bool) onState) async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 12),
      androidUsesFineLocation: true,
    );
    final espDevice = await findESP32Device();
    if (espDevice == null) throw '$targetDeviceName no encontrado';
    await connectAndSetupDevice(espDevice, onState);
  }

  Future<BluetoothDevice?> findESP32Device() async {
    final completer = Completer<BluetoothDevice?>();
    late StreamSubscription<List<ScanResult>> scanSub;
    scanSub = FlutterBluePlus.scanResults.listen((results) {
      try {
        for (final result in results) {
          if (result.device.advName == targetDeviceName ||
              result.advertisementData.serviceUuids.contains(
                Guid(serviceUUID),
              )) {
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

  Future<void> connectAndSetupDevice(
    BluetoothDevice device,
    Function(String, bool) onState,
  ) async {
    _device = device;
    deviceName = device.advName;
    _connectionSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        onState('Desconectado de $deviceName', false);
      }
    });
    statusString = 'Conectando a $deviceName...';
    onState(statusString, true);
    await Future.delayed(const Duration(milliseconds: 30));
    await device.connect(
      autoConnect: false,
      timeout: const Duration(seconds: 8),
      mtu: 512,
    );
    await setupServices(device, onState);
    statusString = 'Conectado a $deviceName';
    isConnecting = false;
    onState(statusString, false);
  }

  Future<void> setupServices(
    BluetoothDevice device,
    Function(String, bool) onState,
  ) async {
    statusString = 'Configurando $deviceName...';
    onState(statusString, isConnecting);
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
    _valueSubscription = characteristic.onValueReceived.listen(processECGData);
  }

  void processECGData(List<int> value) {
    try {
      final raw = utf8.decode(value);
      final json = jsonDecode(raw);
      print('Datos ECG recibidos: $json');
      final ecgValue = json['ecg'] as int;
      ecgData.add(ecgValue);
      if (ecgData.length > 200) ecgData.removeAt(0);
      onECGData?.call(List.unmodifiable(ecgData));
    } catch (e) {
      // Silenciar error
    }
  }

  Future<void> disposeResources() async {
    await _valueSubscription?.cancel();
    await _connectionSubscription?.cancel();
    _valueSubscription = null;
    _connectionSubscription = null;
  }

  Future<void> dispose() async {
    await _adapterStateSubscription?.cancel();
    await disposeResources();
    await _device?.disconnect();
  }
}
