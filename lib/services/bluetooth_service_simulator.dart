import 'dart:async';
import 'dart:math';

class BluetoothServiceSimulator {
  final List<int> _ecgData = [];
  final List<int> _pqrstPattern = [];
  final int _maxLength;
  final void Function(List<int>)? onData;

  int _patternIndex = 0;
  Timer? _beatTimer;
  Timer? _pointTimer;
  final Random _random = Random();

  BluetoothServiceSimulator({this.onData, int maxLength = 1000})
    : _maxLength = maxLength {
    //_generatePQRSTPattern();
    _generateCriticalPattern();
  }

  void _generatePQRSTPattern() {
    // Valores base aproximados para una onda PQRST típica en bpm/unidad simulada
    _pqrstPattern.clear();
    _pqrstPattern.addAll([
      70, 75, 78, 75, // P onda suave
      70, 68, 65, // Q pequeña bajada
      90, 110, 95, // R pico fuerte
      80, 70, 60, // S descenso rápido
      65, 70, 72, 75, // T recuperación
      70, 70, 70, 70, 70, // línea base (reposo)
    ]);
  }

  void _generateCriticalPattern() {
    _pqrstPattern.clear();

    // Simulación de taquicardia (ritmo acelerado)
    _pqrstPattern.addAll([
      7, 75, 78, 75, // P
      70, 8, 65, // Q
      10, 10, 130, // R exagerado
      0, 60, 5, // S
      60, 65, 7, 75, // T
      0, 60, 0, 65,
    ]);

    // Simulación de arritmia: pérdida de onda R
    _pqrstPattern.addAll([
      7, 75, 78, 75, // P
      70, 8, 65, // Q
      10, 10, 10, // ausencia de R
      0, 65, 6, // S
      60, 62, 7, 72,
      0, 62, 0, 62,
    ]);

    // Simulación de bradicardia (ritmo muy lento)
    _pqrstPattern.addAll([
      6, 65, 68, 65,
      60, 7, 55,
      8, 8, 85, // R más bajo
      0, 55, 4,
      50, 55, 6, 60,
      0, 55, 0, 55,
    ]);
  }

  void start() {
    _scheduleNextBeat();
  }

  void _scheduleNextBeat() {
    final delay = 600 + _random.nextInt(400); // 600–1000 ms entre latidos
    _beatTimer = Timer(Duration(milliseconds: delay), () {
      _emitBeat();
      _scheduleNextBeat();
    });
  }

  void _emitBeat() {
    _patternIndex = 0;
    _pointTimer?.cancel();

    _pointTimer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      if (_patternIndex >= _pqrstPattern.length) {
        timer.cancel();
        return;
      }

      // Añadir pequeña variación aleatoria para simular latidos reales
      int baseValue = _pqrstPattern[_patternIndex];
      int variation = _random.nextInt(5) - 2; // variación entre -2 y +2
      int simulatedValue = (baseValue + variation).clamp(50, 120);

      _ecgData.add(simulatedValue);
      _patternIndex++;

      // Mantener máximo número de muestras
      if (_ecgData.length > _maxLength) {
        _ecgData.removeRange(0, _ecgData.length - _maxLength);
      }

      onData?.call(List.unmodifiable(_ecgData));
    });
  }

  void stop() {
    _beatTimer?.cancel();
    _pointTimer?.cancel();
  }

  List<int> get ecgData => List.unmodifiable(_ecgData);

  void dispose() {
    stop();
  }
}
