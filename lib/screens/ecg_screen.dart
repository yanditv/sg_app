import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:sg_app/bluetooth_controller.dart';

class ECGScreen extends StatefulWidget {
  final BluetoothController? controller;
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
    final lastValue = ecgData.isNotEmpty ? ecgData.last : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ECG en tiempo real'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.monitor_heart, color: Colors.redAccent, size: 28),
          ),
        ],
      ),
      body: isConnecting
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Card(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              backgroundColor: Colors.redAccent.withOpacity(
                                0.1,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 4095,
                              titlesData: FlTitlesData(show: false),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    for (int i = 0; i < ecgData.length; i++)
                                      FlSpot(
                                        i.toDouble(),
                                        ecgData[i].toDouble(),
                                      ),
                                  ],
                                  isCurved: true,
                                  color: Colors.redAccent,
                                  barWidth: 2.5,
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Muestras: ${ecgData.length}',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Icon(Icons.show_chart, color: Colors.blueAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Qué es el ECG?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El electrocardiograma (ECG) es una prueba que registra la actividad eléctrica del corazón. Observa la gráfica en tiempo real y consulta a un profesional ante anomalías.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
