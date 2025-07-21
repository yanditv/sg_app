import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/socket_provider.dart';

class ChartData {
  final int x;
  final int y;
  ChartData(this.x, this.y);
}

class ECGScreen extends StatefulWidget {
  final BluetoothProvider? controller;
  const ECGScreen({super.key, this.controller});

  @override
  State<ECGScreen> createState() => _ECGScreenState();
}

class _ECGScreenState extends State<ECGScreen> {
  final int maxPoints = 80;
  List<ChartData> chartData = [];
  ChartSeriesController? _seriesController;
  List<int> get ecgData => widget.controller?.ecgData ?? [];
  bool get isConnecting => widget.controller?.isConnecting ?? true;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerUpdate);
    widget.controller?.initBluetooth();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (ecgData.isNotEmpty) {
      final nextX = chartData.isNotEmpty ? chartData.last.x + 1 : 0;
      chartData.add(ChartData(nextX, ecgData.last));
      if (chartData.length > maxPoints) {
        chartData.removeAt(0);
      }
      if (_seriesController != null) {
        _seriesController!.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
          removedDataIndexes: chartData.length > maxPoints ? <int>[0] : null,
        );
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastValue = chartData.isNotEmpty ? chartData.last.y : null;
    final btController = widget.controller;
    final isConnected =
        btController?.statusString.contains('Conectado') ?? false;
    final deviceName = btController?.deviceName ?? 'Sin dispositivo';

    final socketProvider = Provider.of<SocketProvider?>(context, listen: true);
    final estadoAnalisis = socketProvider?.estadoAnalisis;

    // Calcular minY y maxY con margen para visualización
    double minY = 50;
    double maxY = 120;
    if (chartData.isNotEmpty) {
      minY =
          chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b).toDouble() -
          5;
      maxY =
          chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b).toDouble() +
          5;
      if (minY < 0) minY = 0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: isConnecting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado visual
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.red[50],
                          child: Icon(
                            Icons.monitor_heart,
                            color: Colors.redAccent,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ECG en tiempo real',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.redAccent,
                                ),
                              ),
                              Text(
                                deviceName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Resumen de conexión
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      color: isConnected ? Colors.green[50] : Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isConnected
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth_disabled,
                              color: isConnected ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isConnected
                                        ? 'Dispositivo conectado'
                                        : 'Sin conexión',
                                    style: TextStyle(
                                      color: isConnected
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    deviceName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isConnected && lastValue != null)
                              Chip(
                                label: Text(
                                  'ECG: $lastValue',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    // Estado de análisis
                    if (estadoAnalisis != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.analytics, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Text(
                              'Análisis: $estadoAnalisis',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Gráfica destacada
                    SizedBox(
                      height: 400,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Último valor',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      lastValue != null
                                          ? lastValue.toString()
                                          : 'N/A',
                                    ),
                                    backgroundColor: Colors.redAccent.withAlpha(
                                      (0.1 * 255).toInt(),
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Expanded(
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  margin: EdgeInsets.zero,
                                  primaryXAxis: NumericAxis(isVisible: false),
                                  primaryYAxis: NumericAxis(
                                    minimum: minY,
                                    maximum: maxY,
                                    isVisible: false,
                                  ),
                                  series: <SplineSeries<ChartData, int>>[
                                    SplineSeries<ChartData, int>(
                                      onRendererCreated: (controller) {
                                        _seriesController = controller;
                                      },
                                      dataSource: chartData,
                                      xValueMapper: (ChartData data, _) =>
                                          data.x,
                                      yValueMapper: (ChartData data, _) =>
                                          data.y,
                                      color: Colors.redAccent,
                                      width: 2.5,
                                      markerSettings: const MarkerSettings(
                                        isVisible: false,
                                      ),
                                      splineType: SplineType.natural,
                                      animationDuration: 0,
                                    ),
                                  ],
                                  enableAxisAnimation: false,
                                  isTransposed: false,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Muestras: ${ecgData.length}',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Icon(
                                    Icons.show_chart,
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Métricas rápidas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MetricCard(
                          label: 'Mínimo',
                          value: ecgData.isNotEmpty
                              ? ecgData
                                    .reduce((a, b) => a < b ? a : b)
                                    .toString()
                              : '--',
                        ),
                        _MetricCard(
                          label: 'Máximo',
                          value: ecgData.isNotEmpty
                              ? ecgData
                                    .reduce((a, b) => a > b ? a : b)
                                    .toString()
                              : '--',
                        ),
                        _MetricCard(
                          label: 'Muestras',
                          value: ecgData.length.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Sección educativa
                    Text(
                      'Educación y ayuda',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blueAccent,
                              size: 28,
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'El electrocardiograma (ECG) registra la actividad eléctrica del corazón. Observa la gráfica en tiempo real y consulta a un profesional ante anomalías.',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.blueAccent),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
