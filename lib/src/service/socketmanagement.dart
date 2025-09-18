import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:zenify_auth/zenify_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

typedef ConnectionStateCallback =
    void Function(bool isConnected, bool isReconnecting);

class SocketIOManager {
  late IO.Socket socket;

  SocketIOManager._();
  static final SocketIOManager _instance = SocketIOManager._();
  static SocketIOManager get instance => _instance;

  bool _isConnected = false;
  bool _isReconnecting = false;
  bool get isConnected => _isConnected;
  bool get isReconnecting => _isReconnecting;

  int _reconnectionAttempts = 0;
  final int _maxReconnectionAttempts = 5;
  Timer? _reconnectionTimer;
  final List<Function(bool)> _connectionListeners = [];
  final List<Map<String, dynamic>> _messageQueue = [];

  // Connection state listeners
  final List<ConnectionStateCallback> _connectionStateListeners = [];

  /// Add listener for connection state
  // void addConnectionChangeListener(Function(bool) listener) {
  //   _connectionListeners.add(listener);
  // }

  // void addConnectionListener(Function(bool) listener) {
  //   _connectionListeners.add(listener);
  // }
  set isConnected(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    for (final listener in _connectionListeners) {
      listener(
        _isConnected,
      ); // Pass the current connection status to the listener
    }
  }

  void addConnectionChangeListener(Function(bool) listener) {
    _connectionListeners.add(listener);
  }

  void removeConnectionChangeListener(Function(bool) listener) {
    _connectionListeners.remove(listener);
  }

  void addConnectionListener(Function(bool) listener) {
    _connectionListeners.add(listener);
  }

  void _notifyConnectionListeners(bool isConnected) {
    for (var listener in _connectionListeners) {
      listener(isConnected);
    }
  }

  // Remove connection state listener
  void removeConnectionListener(Function(bool) listener) {
    _connectionListeners.remove(listener);
  }

  /// Remove listener
  void removeConnectionStateListener(ConnectionStateCallback listener) {
    _connectionStateListeners.remove(listener);
  }

  /// Notify listeners about connection/reconnection state
  void _notifyConnectionStateListeners() {
    for (var listener in _connectionStateListeners) {
      listener(_isConnected, _isReconnecting);
    }
  }

  Future<void> onSocketConnected() async {
    _isConnected = true;
    _isReconnecting = false;

    // Process any queued messages
    // await _processQueuedMessages();
  }

  /// Initialize socket
  Future<void> initialize({
    required String url,
    String path = '/socket.io',
  }) async {
    //Hive.registerAdapter(HiveCookieAdapter());
    final box = await Hive.openBox('authBox'); // Use your actual box name
    var b = await Hive.openBox('cookieBox');
    _notifyListeners();
    //
    var headers = <String, String>{};
    String? cookieValue = await b.get('ZENIFY_SESSION_ID');
    // We saved this at login
    if (!kIsWeb) {
      final authRepo = ZenifyAuth.authRepo;
      //  cookieValue = await authRepo.getCookieValue(url, 'ZENIFY_SESSION_ID');
      //f//inal cookieBox = Hive.box('cookieBox');

      // Get the saved cookie string
      final savedCookie = await b.get('ZENIFY_SESSION_ID');

      // Use it in headers or socket
      headers = {'Cookie': '$savedCookie'};
    }
    print("Loaded cookie from storage cookieValue: $cookieValue");

    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableMultiplex()
          .setExtraHeaders(headers)
          .enableForceNew()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      _isConnected = true;
      _reconnectionAttempts = 0;
      _isReconnecting = true;
      print('Socket connected with ID: ${socket.id}');
      _notifyConnectionListeners(true);
      onSocketConnected(); // Process any queued messages
      _notifyListeners();
    });

    socket.onDisconnect((_) {
      _isConnected = false;
      print('Socket disconnected');
      _scheduleReconnection("https://api.staging.zenifytrip.com");
      _notifyConnectionStateListeners();
      _notifyListeners();
    });

    socket.onConnectError((err) {
      _isConnected = false;
      _isReconnecting = false;
      print('Socket connection error: $err');
      _notifyListeners();
      _scheduleReconnection("https://api.staging.zenifytrip.com");
      _notifyConnectionStateListeners();
    });

    socket.onError((error) {
      print('Socket error: $error');
      _isConnected = false;
      _isReconnecting = false;
      _scheduleReconnection("https://api.staging.zenifytrip.com");
    });
  }

  void _scheduleReconnection(String url) {
    if (_isReconnecting || _reconnectionAttempts >= _maxReconnectionAttempts)
      return;

    _isReconnecting = true;

    // Calculate backoff time (exponential with jitter)
    // Fixed calculation to avoid double to int type error
    int backoffSeconds = (1 << _reconnectionAttempts);
    double jitter = 1 + (0.1 * (DateTime.now().millisecondsSinceEpoch % 10));
    int delayMs = (backoffSeconds * jitter).round();

    print(
      'Scheduling reconnection attempt ${_reconnectionAttempts + 1} in ${delayMs}ms',
    );

    _reconnectionTimer = Timer(Duration(milliseconds: delayMs), () {
      _reconnectionAttempts++;
      _isReconnecting = false;
      _isConnected = false;
      initialize(url: url);
      _notifyConnectionListeners(true);
    });
  }

  void cancelReconnection() {
    _reconnectionTimer?.cancel();
    _isReconnecting = false;
    _notifyConnectionStateListeners();
  }

  void sendEvent(String event, dynamic data) {
    if (_isConnected) {
      socket.emit(event, data);
    } else {
      _messageQueue.add({'event': event, 'data': data});
      print('Message queued for offline delivery: $event');
    }
  }

  void onEvent(String event, Function(dynamic) callback) {
    socket.on(event, callback);
  }

  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
      _isConnected = false;
      _notifyConnectionStateListeners();
    }
    cancelReconnection();
  }

  void _processQueuedMessages() {
    if (_messageQueue.isEmpty) return;

    print('Sending ${_messageQueue.length} queued messages');
    for (var msg in _messageQueue) {
      socket.emit(msg['event'], msg['data']);
    }
    _messageQueue.clear();
  }
}
