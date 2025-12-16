import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class P2PService {
  final FlutterP2pHost _host = FlutterP2pHost();
  final FlutterP2pClient _client = FlutterP2pClient();

  StreamSubscription<HotspotHostState>? _hostStateSubscription;
  StreamSubscription<HotspotClientState>? _clientStateSubscription;
  StreamSubscription<String>? _hostMessageSubscription;
  StreamSubscription<String>? _clientMessageSubscription;

  // Callbacks
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

  Future<void> initialize() async {
    await _host.initialize();
    await _client.initialize();

    _hostStateSubscription = _host.streamHotspotState().listen((state) {
      onHostStateChanged?.call(state);
      onLog?.call("Host State: ${state.isActive ? 'Active' : 'Inactive'}");
    });

    _hostMessageSubscription = _host.streamReceivedTexts().listen((message) {
      onMessageReceived?.call("HOST received: $message");
      onLog?.call("Message received as HOST: $message");
    });

    _clientStateSubscription = _client.streamHotspotState().listen((state) {
      onClientStateChanged?.call(state);
      onLog?.call("Client State: ${state.isActive ? 'Connected' : 'Disconnected'}");
    });

    _clientMessageSubscription = _client.streamReceivedTexts().listen((message) {
      onMessageReceived?.call("CLIENT received: $message");
      onLog?.call("Message received as CLIENT: $message");
    });

    onLog?.call("P2P Initialized. Ready for actions.");
  }

  Future<void> createGroupAndAdvertise(HotspotHostState? hostState, HotspotClientState? clientState) async {
    await removeGroup(hostState, clientState);
    final state = await _host.createGroup(advertise: true);
    if (state.isActive) {
      onLog?.call("Group Created (Host). SSID: ${state.ssid}");
    } else {
      onLog?.call("Failed to create group: ${state.failureReason}");
    }
  }

  Future<void> removeGroup(HotspotHostState? hostState, HotspotClientState? clientState) async {
    if (hostState?.isActive == true) {
      await _host.removeGroup();
      onLog?.call("Host group removed.");
    } else if (clientState?.isActive == true) {
      await _client.disconnect();
      onLog?.call("Client disconnected.");
    } else {
      onLog?.call("Not connected/hosting.");
    }
  }

  Future<void> startDiscoveryViaBLE() async {
    await removeGroup(null, null); // Assuming states not needed here, or pass them
    onScanningChanged?.call(true);
    onDevicesDiscovered?.call([]);
    await _client.startScan((devices) {
      onDevicesDiscovered?.call(devices);
    });
    onLog?.call("BLE Discovery started.");
  }

  Future<void> stopDiscovery() async {
    await _client.stopScan();
    onScanningChanged?.call(false);
    onLog?.call("BLE Discovery stopped.");
  }

  Future<void> connectToDiscoveredHost(BleDiscoveredDevice device) async {
    await stopDiscovery();
    onLog?.call("Attempting to connect to ${device.deviceName}...");
    await _client.connectWithDevice(device);
  }

  Future<void> broadcastTextMessage(String message, HotspotHostState? hostState, HotspotClientState? clientState) async {
    if (message.isEmpty) return;
    if (hostState?.isActive == true) {
      await _host.broadcastText(message);
      onLog?.call("Host sent: $message");
    } else if (clientState?.isActive == true) {
      await _client.broadcastText(message);
      onLog?.call("Client sent: $message");
    } else {
      onLog?.call("Cannot send: Not connected or hosting.");
    }
  }

  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    final p2p = FlutterP2pHost();
    if (!await p2p.checkP2pPermissions()) {
      await p2p.askP2pPermissions();
    }
    if (!await p2p.checkStoragePermission()) {
      await p2p.askStoragePermission();
    }
    if (!await p2p.checkBluetoothPermissions()) {
      await p2p.askBluetoothPermissions();
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

  void dispose() {
    _hostStateSubscription?.cancel();
    _clientStateSubscription?.cancel();
    _hostMessageSubscription?.cancel();
    _clientMessageSubscription?.cancel();
    _client.dispose();
    _host.dispose();
  }
}