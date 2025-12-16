import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class P2PService {
  // ================= SINGLETON =================
  static final P2PService _instance = P2PService._internal();
  factory P2PService() => _instance;
  P2PService._internal();

  final FlutterP2pHost _host = FlutterP2pHost();
  final FlutterP2pClient _client = FlutterP2pClient();

  bool _initialized = false;

  // ================= STREAMS =================
  StreamSubscription<HotspotHostState>? _hostStateSub;
  StreamSubscription<HotspotClientState>? _clientStateSub;
  StreamSubscription<String>? _hostMsgSub;
  StreamSubscription<String>? _clientMsgSub;

  // ================= CALLBACKS =================
  Function(HotspotHostState)? onHostStateChanged;
  Function(HotspotClientState)? onClientStateChanged;
  Function(String)? onMessageReceived;
  Function(String)? onLog;
  Function(List<BleDiscoveredDevice>)? onDevicesDiscovered;
  Function(bool)? onScanningChanged;

  void setCallbacks({
    Function(HotspotHostState)? hostState,
    Function(HotspotClientState)? clientState,
    Function(String)? message,
    Function(String)? log,
    Function(List<BleDiscoveredDevice>)? devicesDiscovered,
    Function(bool)? scanningChanged,
  }) {
    onHostStateChanged = hostState;
    onClientStateChanged = clientState;
    onMessageReceived = message;
    onLog = log;
    onDevicesDiscovered = devicesDiscovered;
    onScanningChanged = scanningChanged;
  }

  // ================= INIT =================
  Future<void> initialize() async {
    if (_initialized) {
      onLog?.call("P2P already initialized – skipping");
      return;
    }

    await _host.initialize();
    await _client.initialize();

    _hostStateSub = _host.streamHotspotState().listen((state) {
      onHostStateChanged?.call(state);
      onLog?.call("HOST: ${state.isActive ? 'ACTIVE' : 'INACTIVE'}");
    });

    _clientStateSub = _client.streamHotspotState().listen((state) {
      onClientStateChanged?.call(state);
      onLog?.call("CLIENT: ${state.isActive ? 'CONNECTED' : 'DISCONNECTED'}");
    });

    _hostMsgSub = _host.streamReceivedTexts().listen((msg) {
      onMessageReceived?.call("HOST received: $msg");
    });

    _clientMsgSub = _client.streamReceivedTexts().listen((msg) {
      onMessageReceived?.call("CLIENT received: $msg");
    });

    _initialized = true;
    onLog?.call("P2P initialized successfully");
  }

  // ================= HOST =================
  Future<void> createGroupAndAdvertise() async {
    await removeConnection();
    final state = await _host.createGroup(advertise: true);

    if (state.isActive) {
      onLog?.call("Host group created: ${state.ssid}");
    } else {
      onLog?.call("Host creation failed: ${state.failureReason}");
    }
  }

  // ================= CLIENT =================
  Future<void> startDiscoveryViaBLE() async {
    await removeConnection();
    onScanningChanged?.call(true);
    onDevicesDiscovered?.call([]);

    await _client.startScan((devices) {
      onDevicesDiscovered?.call(devices);
    });

    onLog?.call("BLE scan started");
  }

  Future<void> stopDiscovery() async {
    await _client.stopScan();
    onScanningChanged?.call(false);
    onLog?.call("BLE scan stopped");
  }

  Future<void> connectToDiscoveredHost(BleDiscoveredDevice device) async {
    await stopDiscovery();
    onLog?.call("Connecting to ${device.deviceName}");
    await _client.connectWithDevice(device);
  }

  // ================= COMMON =================
  Future<void> broadcastText(String msg,
      {bool asHost = false, bool asClient = false}) async {
    if (msg.isEmpty) return;

    if (asHost) {
      await _host.broadcastText(msg);
    } else if (asClient) {
      await _client.broadcastText(msg);
    }
  }

  Future<void> removeConnection() async {
    try {
      await _client.disconnect();
    } catch (_) {}

    try {
      await _host.removeGroup();
    } catch (_) {}
  }

  // ================= SAFE DISPOSE =================
  Future<void> safeDispose() async {
    if (!_initialized) return;

    await removeConnection();

    await _hostStateSub?.cancel();
    await _clientStateSub?.cancel();
    await _hostMsgSub?.cancel();
    await _clientMsgSub?.cancel();

    await _client.dispose();
    await _host.dispose();

    _initialized = false;
    onLog?.call("P2P disposed safely");
  }

  // ================= PERMISSIONS =================
  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    final p2p = FlutterP2pHost();

    if (!await p2p.checkP2pPermissions()) {
      await p2p.askP2pPermissions();
    }
    if (!await p2p.checkBluetoothPermissions()) {
      await p2p.askBluetoothPermissions();
    }
    if (!await p2p.checkStoragePermission()) {
      await p2p.askStoragePermission();
    }
  }

  static Future<void> checkAndEnableServices(BuildContext context) async {
    final p2p = FlutterP2pHost();

    if (!await p2p.checkWifiEnabled()) {
      await p2p.enableWifiServices();
    }
    if (!await p2p.checkLocationEnabled()) {
      await p2p.enableLocationServices();
    }
    if (!await p2p.checkBluetoothEnabled()) {
      await p2p.enableBluetoothServices();
    }
  }
}
