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
            child: Icon(
              LineAwesomeIcons.heart,
              color: Colors.redAccent,
              size: 28,
            ),
          ),
        ],
      ),
      body: isConnecting
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Último valor: [ecgData.isNotEmpty ? ecgData.last : "N/A"]',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 220,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 4095,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
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
                                  isCurved: false,
                                  color: Colors.redAccent,
                                  barWidth: 2.5,
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
