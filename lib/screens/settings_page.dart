import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:sg_app/bluetooth_controller.dart';

class SettingsPage extends StatefulWidget {
  final BluetoothController? controller;
  const SettingsPage({super.key, this.controller});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _buttonLocked = false;

  void _handleReconnect(BluetoothController controller) async {
    setState(() {
      _buttonLocked = true;
    });
    controller.reconnect();
    await Future.delayed(const Duration(seconds: 7));
    if (mounted) {
      setState(() {
        _buttonLocked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    bool isLoading = controller?.isConnecting ?? false;
    bool isButtonDisabled = isLoading || _buttonLocked;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de Bluetooth')),
      body: controller == null
          ? const Center(child: Text('Controlador no disponible'))
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          LineAwesomeIcons.bluetooth,
                          color: controller.isConnecting
                              ? Colors.grey
                              : Colors.blueAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: controller.isConnecting
                                    ? Colors.orange
                                    : (controller.statusString.contains(
                                            'Conectado',
                                          )
                                          ? Colors.green
                                          : Colors.red),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.statusString,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (controller.deviceName != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LineAwesomeIcons.microchip_solid,
                                color: Colors.blueGrey,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Dispositivo: [controller.deviceName]',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        if (controller.deviceName != null)
                          const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: isButtonDisabled
                                ? null
                                : () => _handleReconnect(controller),
                            child: isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Text('Reconectando...'),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.refresh),
                                      SizedBox(width: 12),
                                      Text('Reintentar conexión'),
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
