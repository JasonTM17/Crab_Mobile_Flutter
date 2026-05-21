import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_constants.dart';
import '../../shared/services/auth_storage.dart';

class SocketClient {
  final AuthStorage authStorage;
  final Map<String, io.Socket> _sockets = {};

  SocketClient({required this.authStorage});

  Future<io.Socket> connect(String namespace) async {
    if (_sockets.containsKey(namespace) && _sockets[namespace]!.connected) {
      return _sockets[namespace]!;
    }
    final token = await authStorage.getAccessToken();
    final socket = io.io(
      '${ApiConstants.socketUrl}$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableForceNew()
          .build(),
    );
    socket.connect();
    _sockets[namespace] = socket;
    return socket;
  }

  void disconnect(String namespace) {
    _sockets[namespace]?.disconnect();
    _sockets.remove(namespace);
  }

  void disconnectAll() {
    for (final s in _sockets.values) {
      s.disconnect();
    }
    _sockets.clear();
  }

  io.Socket? getSocket(String namespace) => _sockets[namespace];

  Future<io.Socket> get rideSocket => connect(ApiConstants.rideNamespace);
  Future<io.Socket> get foodSocket => connect(ApiConstants.foodNamespace);
  Future<io.Socket> get chatSocket => connect(ApiConstants.chatNamespace);
  Future<io.Socket> get notificationSocket =>
      connect(ApiConstants.notificationNamespace);
}
