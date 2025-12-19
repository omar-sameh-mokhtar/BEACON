import 'package:flutter/material.dart';
import '../model/service/notification_service.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'dart:async';
import '../model/service/p2p_service.dart';

class P2PViewModel extends ChangeNotifier {
  final P2PService _service = P2PService();
  get service => _service;
  
  bool isHost = false;
  List<P2pClientInfo> peers = [];
  List<String> chatHistory = [];
  String connectionStatus = "Disconnected";
  bool isActive = false;
  bool isConnecting = false;
  
  StreamSubscription? _msgSub;
  StreamSubscription? _peerSub;
  StreamSubscription? _stateSub;

  void startGlobalEngine(bool isHost) async {
    this.isHost = isHost;
    if (isHost) {
      await _service.initHost();
      _setupHostStreams();
      await _service.hostInterface.createGroup(advertise: true);
    } else {
      await _service.initClient();
      _setupClientStreams();
      _startAutoScan();
    }
  }

  void _setupHostStreams() {
    _stateSub = _service.hostInterface.streamHotspotState().listen((state) {
      isActive = state.isActive;
      connectionStatus = state.isActive ? "Hosting: ${state.ssid}" : "Error: ${state.failureReason}";
      notifyListeners();
    });
    _listenForPeers(true);
    _listenForMessages(true);
  }

  void _setupClientStreams() {
    _stateSub = _service.clientInterface.streamHotspotState().listen((state) {
      isActive = state.isActive;
      connectionStatus = state.isActive ? "Connected" : "Searching...";
      if (state.isActive) isConnecting = false;
      notifyListeners();
    });
    _listenForPeers(false);
    _listenForMessages(false);
  }

  void _listenForPeers(bool isHost) {
    _peerSub = _service.getPeerStream(isHost).listen((list) {
      peers = list;
      notifyListeners();
    });
  }

  void _listenForMessages(bool isHost) {
    _msgSub = _service.getMessageStream(isHost).listen((msg) {
      print("[DEBUG] P2P Packet Received: '$msg'");
      // Logic for different modules based on prefixes
      if (msg.startsWith("REQ:")) {
        NotificationService.showAlert(
          "Resource Request",
          msg.substring(4),
          'resource_channel'
        );
      } else {
        chatHistory.insert(0, msg);
        NotificationService.showAlert(
          "New Message",
          msg,
          'chat_channel'
        );
      }
      notifyListeners();
    });
  }

  void _startAutoScan() async {
    connectionStatus = "Scanning for networks...";
    notifyListeners();

    await _service.clientInterface.startScan((devices) {
      if (devices.isNotEmpty && !isActive && !isConnecting) {
        isConnecting = true;
        final target = devices.first;
        connectionStatus = "Auto-joining ${target.deviceName}...";
        notifyListeners();
        
        _service.clientInterface.stopScan().then((_) {
          _service.clientInterface.connectWithDevice(target);
        });
      }
    });
  }

  Future<void> sendMessage(String text, String targetId, bool isHost) async {
    bool ok = false;
    if (isHost) {
      ok = await _service.hostInterface.sendTextToClient(text, targetId);
    } else {
      await _service.clientInterface.broadcastText(text);
      ok = true; 
    }

    if (ok) {
      chatHistory.insert(0, text);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _peerSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }


  /*
  void startGlobalListeners(bool isHost) {
    final stream = isHost 
      ? hostInterface.streamReceivedTexts() 
      : clientInterface.streamReceivedTexts();

    stream.listen((data) {
      // 1. Check the type of data (Simple protocol: "REQ:Water" or "MSG:Hello")
      if (data.startsWith("REQ:")) {
        _handleResourceRequest(data.replaceFirst("REQ:", ""));
      } else {
        _handleChatMessage(data);
      }
    });
  }

  void _handleChatMessage(String msg) {
    chatHistory.insert(0, "Peer: $msg");
    NotificationService.showAlert("New Message", msg, 'chat_messages');
    notifyListeners();
  }

  void _handleResourceRequest(String request) {
    // Critical alert for resource modules
    NotificationService.showAlert("URGENT REQUEST", "Need: $request", 'emergency_alerts');
    // You could also add this to a separate "Requests" list here
    notifyListeners();
  }

  Future<void> sendData(String rawData, String? targetId, bool isHost) async {
    if (isHost) {
      await hostInterface.sendTextToClient(rawData, targetId!);
    } else {
      await clientInterface.broadcastText(rawData);
    }
  }*/
}