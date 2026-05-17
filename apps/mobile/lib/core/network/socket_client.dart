import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';

@singleton
class SocketClient {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Map<String, io.Socket> _sockets = {};

  Future<io.Socket> connect(String namespace) async {
    if (_sockets.containsKey(namespace) &&
        _sockets[namespace]!.connected) {
      return _sockets[namespace]!;
    }

    final token = await _storage.read(key: ApiConstants.accessTokenKey);

    final socket = io.io(
      '${ApiConstants.wsUrl}$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setAuth({'token': token ?? ''})
          .build(),
    );

    socket.onConnect((_) {
      _log('Connected to namespace: $namespace');
    });

    socket.onDisconnect((_) {
      _log('Disconnected from namespace: $namespace');
    });

    socket.onConnectError((data) {
      _log('Connection error on $namespace: $data');
    });

    socket.onError((data) {
      _log('Error on $namespace: $data');
    });

    _sockets[namespace] = socket;
    return socket;
  }

  Future<io.Socket> get rideSocket =>
      connect(ApiConstants.rideNamespace);

  Future<io.Socket> get foodSocket =>
      connect(ApiConstants.foodNamespace);

  Future<io.Socket> get chatSocket =>
      connect(ApiConstants.chatNamespace);

  Future<io.Socket> get notificationSocket =>
      connect(ApiConstants.notificationNamespace);

  void disconnect(String namespace) {
    _sockets[namespace]?.disconnect();
    _sockets.remove(namespace);
  }

  void disconnectAll() {
    for (final socket in _sockets.values) {
      socket.disconnect();
    }
    _sockets.clear();
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[SocketClient] $message');
  }
}
