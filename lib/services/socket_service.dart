import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef RequestListener = void Function(Map<String, dynamic> request);

class SocketService {
  IO.Socket? _socket;

  void connectAsEndUser(String baseUrl, String userId,
      {RequestListener? onCreated, RequestListener? onUpdated}) {
    _socket = IO.io(baseUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setQuery({"role": "enduser", "userId": userId})
        .build());
    _bindCommon(onCreated: onCreated, onUpdated: onUpdated);
    _socket!.connect();
  }

  void connectAsReceiver(String baseUrl,
      {RequestListener? onCreated, RequestListener? onUpdated}) {
    _socket = IO.io(baseUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setQuery({"role": "receiver"})
        .build());
    _bindCommon(onCreated: onCreated, onUpdated: onUpdated);
    _socket!.connect();
  }

  void _bindCommon({RequestListener? onCreated, RequestListener? onUpdated}) {
    _socket!.on("request_created", (data) {
      if (data is Map && onCreated != null) onCreated(Map<String, dynamic>.from(data));
    });
    _socket!.on("request_updated", (data) {
      if (data is Map && onUpdated != null) onUpdated(Map<String, dynamic>.from(data));
    });
  }

  void dispose() {
    _socket?.dispose();
    _socket = null;
  }
}
