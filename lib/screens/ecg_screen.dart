import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import '../providers/socket_provider.dart';

class ECGScreen extends StatefulWidget {
  final BluetoothProvider? controller;
  const ECGScreen({super.key, this.controller});

  @override
  State<ECGScreen> createState() => _ECGScreenState();
}

class _ECGScreenState extends State<ECGScreen> {
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int maxPoints = 100; // Número máximo de puntos visibles en el gráfico
    final lastValue = ecgData.isNotEmpty ? ecgData.last : null;
    final btController = widget.controller;
    final isConnected =
        btController?.statusString.contains('Conectado') ?? false;
    final deviceName = btController?.deviceName ?? 'Sin dispositivo';

    final socketProvider = Provider.of<SocketProvider?>(context, listen: true);
    final estadoAnalisis = socketProvider?.estadoAnalisis;

    // Solo los últimos maxPoints datos
    final List<int> visibleData = ecgData.length > maxPoints
        ? ecgData.sublist(ecgData.length - maxPoints)
        : ecgData;

    // Calcular minY y maxY con margen para visualización
    double minY = 50;
    double maxY = 120;
    if (visibleData.isNotEmpty) {
      minY = visibleData.reduce((a, b) => a < b ? a : b).toDouble() - 5;
      maxY = visibleData.reduce((a, b) => a > b ? a : b).toDouble() + 5;
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
                                child: LineChart(
                                  LineChartData(
                                    minY: minY,
                                    maxY: maxY,
                                    titlesData: FlTitlesData(show: false),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 10,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: Colors.grey.withOpacity(0.2),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: [
                                          for (
                                            int i = 0;
                                            i < visibleData.length;
                                            i++
                                          )
                                            FlSpot(
                                              i.toDouble(),
                                              visibleData[i].toDouble(),
                                            ),
                                        ],
                                        isCurved: true,
                                        color: Colors.redAccent,
                                        barWidth: 2.5,
                                        dotData: FlDotData(show: false),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.redAccent.withOpacity(
                                            0.1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
