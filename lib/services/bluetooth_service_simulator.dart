import 'dart:async';
import 'dart:math';

/// Simula la recepción de datos ECG por Bluetooth generando datos aleatorios.
class BluetoothServiceSimulator {
  final List<int> _ecgData = [];
  final _random = Random();
  Timer? _timer;
  final int _maxLength;
  final void Function(List<int>)? onData;

  BluetoothServiceSimulator({this.onData, int maxLength = 1000})
    : _maxLength = maxLength;

  /// Inicia la simulación de recepción de datos.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _generateData(),
    );
  }

  /// Detiene la simulación.
  void stop() {
    _timer?.cancel();
  }

  /// Obtiene los datos simulados actuales.
  List<int> get ecgData => List.unmodifiable(_ecgData);

  void _generateData() {
    // Simula la llegada de 5 datos nuevos cada 100ms
    for (int i = 0; i < 5; i++) {
      _ecgData.add(500 + _random.nextInt(100)); // valores entre 500 y 599
    }
    if (_ecgData.length > _maxLength) {
      _ecgData.removeRange(0, _ecgData.length - _maxLength);
    }
    if (onData != null) {
      onData!(_ecgData);
    }
  }

  void dispose() {
    stop();
  }
}
