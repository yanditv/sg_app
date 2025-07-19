import 'package:flutter/rendering.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket socket;
  bool _connected = false;

  void connect(Function(String estado) onEstado) {
    socket = io.io(
      'http://localhost:8000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      _connected = true;
      debugPrint('Conectado al servidor Socket.IO');
    });

    socket.on('resultado_analisis', (data) {
      if (data is Map && data['estado'] != null) {
        onEstado(data['estado']);
      }
    });

    socket.onDisconnect((_) {
      _connected = false;
      debugPrint('Desconectado del servidor');
    });
  }

  void enviarVentana(List<int> ventana) {
    if (_connected) {
      socket.emit('analizar', {'ventana': ventana});
    }
  }

  void dispose() {
    socket.dispose();
  }
}
