import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class AcercaPage extends StatelessWidget {
  final String? customMessage;
  final IconData? icon;
  const AcercaPage({super.key, this.customMessage, this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Acerca de la App'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon ?? LineAwesomeIcons.heart,
              color: Colors.blueAccent,
              size: 80,
            ),
            const SizedBox(height: 18),
            Text(
              customMessage ?? 'ECG BLE',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (customMessage == null) ...[
              const SizedBox(height: 10),
              Text(
                'Conecta tu dispositivo y visualiza tu electrocardiograma en tiempo real.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline, color: Colors.blueAccent, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Esta aplicación permite visualizar señales biomédicas (ECG, temperatura) en tiempo real mediante Bluetooth BLE. Ideal para prácticas educativas, monitoreo personal y proyectos biomédicos.',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: Colors.green,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tus datos no se almacenan ni se comparten. Todo el procesamiento ocurre localmente en tu dispositivo.',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(
                    Icons.email_outlined,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¿Dudas o sugerencias? Contáctanos: soporte@biomedapp.com',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
