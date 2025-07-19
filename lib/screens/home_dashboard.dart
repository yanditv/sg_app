import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/socket_provider.dart';

class HomeDashboard extends StatelessWidget {
  final String userName;
  const HomeDashboard({super.key, this.userName = 'Usuario'});

  @override
  Widget build(BuildContext context) {
    final btController = Provider.of<BluetoothProvider>(context);
    final isConnected = btController.statusString.contains('Conectado');
    final deviceName = btController.deviceName ?? 'Sin dispositivo';
    final ecgValue = btController.ecgData.isNotEmpty
        ? btController.ecgData.last
        : null;
    final socketProvider = Provider.of<SocketProvider?>(context, listen: true);
    final estadoAnalisis = socketProvider?.estadoAnalisis;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[50],
                    child: Icon(
                      Icons.person,
                      size: 38,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido,',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                        Row(
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('👋', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
                            ? LineAwesomeIcons.bluetooth
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
                                color: isConnected ? Colors.green : Colors.red,
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
                      if (isConnected && ecgValue != null)
                        Chip(
                          label: Text(
                            'ECG: $ecgValue',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resumen Biomédico',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueAccent,
                    ),
                  ),
                  if (estadoAnalisis != null)
                    Chip(
                      label: Text(
                        'Análisis: $estadoAnalisis',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DashboardCard(
                    color: Colors.blue,
                    icon: Icons.monitor_heart,
                    title: 'ECG',
                    subtitle: ecgValue != null ? '$ecgValue μV' : '--',
                    onTap: () {},
                  ),
                  _DashboardCard(
                    color: Colors.pinkAccent,
                    icon: Icons.thermostat,
                    title: 'Temp.',
                    subtitle: '-- °C',
                    onTap: () {},
                  ),
                  _DashboardCard(
                    color: Colors.orange,
                    icon: Icons.person,
                    title: 'Paciente',
                    subtitle: isConnected ? 'Activo' : 'Inactivo',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Accesos rápidos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _QuickAccessButton(
                    icon: Icons.monitor_heart,
                    label: 'Ver ECG',
                  ),
                  _QuickAccessButton(
                    icon: Icons.thermostat,
                    label: 'Ver Temp.',
                  ),
                  _QuickAccessButton(icon: Icons.history, label: 'Historial'),
                  _QuickAccessButton(icon: Icons.edit, label: 'Editar Perfil'),
                ],
              ),
              const SizedBox(height: 32),
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
                          'Recuerda que esta app no reemplaza la consulta médica profesional. Ante cualquier duda, consulta a tu especialista.',
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

class _DashboardCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _DashboardCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: color.withAlpha((0.10 * 255).toInt()),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.07 * 255).toInt()),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// _ResultTile eliminado en rediseño

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAccessButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withAlpha((0.07 * 255).toInt()),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Icon(icon, color: Colors.blueAccent, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.blueAccent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
