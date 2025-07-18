import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.10),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Icon(
                    LineAwesomeIcons.heart,
                    color: Colors.blueAccent,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'ECG Biomédica',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Conecta tu dispositivo ESP32 y visualiza tus datos de ECG en tiempo real.\n\nEsta app es parte de un sistema biomédico moderno para monitoreo y análisis.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LineAwesomeIcons.bluetooth,
                      color: Colors.blueGrey,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      LineAwesomeIcons.microchip_solid,
                      color: Colors.blueGrey,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      LineAwesomeIcons.heart,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
