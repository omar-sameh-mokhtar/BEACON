import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/service/notification_service.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'dart:async';
import '../model/service/p2p_service.dart';
import '../model/service/connected_device_service.dart';
import '../model/service/message_service.dart';
import '../model/Device.helper.dart';
import '../model/mapper/device_mapper.dart';
import '../model/data/Message.dart';
import '../model/data/Device.dart';
import 'package:collection/collection.dart';

class P2PViewModel extends ChangeNotifier {

  String myId = 'unknown-device';
  final P2PService _service = P2PService();
  final ConnectedDeviceDao _deviceDao = ConnectedDeviceDao();
  final MessageDao _messageDao = MessageDao();
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

  Future<void> initP2P(BuildContext context, bool newHost) async {

    if(isActive && !isHost && !newHost) return; // Already connected as client and pressed join again -> navigate back without changes
    if(isActive){ 
      await disconnect(isHost);
    }
    _service.ensurePermissions();
    _service.ensureServices();

    if (!context.mounted) return;
    
    startP2P(newHost);
    
  }

  void startP2P(bool isHost) async {
    /*if(myId == 'unknown-device'){
      myId = await DeviceIdHelper.getDeviceId();
    }*/
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
      connectionStatus = state.isActive ? "Hosting: ${state.ssid}" : "Hosting...";
      notifyListeners();
    });
    _listenForPeers(true);
    _listenForMessages(true);
  }

  void _setupClientStreams() {
    _stateSub = _service.clientInterface.streamHotspotState().listen((state) {
      isActive = state.isActive;
      connectionStatus = state.isActive ? "Connected" : "Disconnected";
      if (state.isActive) isConnecting = false;
      notifyListeners();
    });
    _listenForPeers(false);
    _listenForMessages(false);
  }

  

  void _listenForPeers(bool isHost) {

    final listEquals = const IterableEquality().equals;

    _peerSub = _service
      .getPeerStream(isHost)
      .distinct((prev, next) => listEquals(prev, next))
      .listen((list) async{
        if (list.length > peers.length) {
          final joiner = list.firstWhere(
          (n) => !peers.any((p) => p.id == n.id),
          //orElse: () => list.last,
        );
          NotificationService.showAlert(
            "Network Update", 
            "${joiner.username} has joined. ${joiner.isHost ? 'HOST' : 'CLIENT'}", 
            'client_channel'
          );
          if(isHost){
            sendMessage("ID|${joiner.id}", joiner.id, isHost);
          }
          if(peers.isEmpty && !isHost){
            sendMessage("ID|${joiner.id}", joiner.id, isHost);
          }/*else{
            sendMessage("ID|${joiner.id}", joiner.id, isHost);
          }*/
          /*
          Device shadow = Device(
            id: joiner.id,
            deviceId: "unknown",
            name: joiner.username, 
            lastSeen: DateTime.now().toIso8601String(),
            firstDiscovered: DateTime.now().toIso8601String(),
            connectionStatus: "identifying",
            isConnected: true,
          );
          await _deviceDao.insertConnectedDevice(shadow);
          */
        } 
        else if (list.length < peers.length) {
          final leaver = peers.firstWhere(
          (p) => !list.any((n) => n.id == p.id),
          orElse: () => peers.first,
        );
          NotificationService.showAlert(
            "Network Update", 
            "${leaver.username} has left the network.", 
            'client_channel'
          );
        }

        peers = list;
        notifyListeners();
      });
  }

  void _listenForMessages(bool isHost) {
    _msgSub = _service.getMessageStream(isHost).listen((msg) async {
      
      if (msg.startsWith("REQ:")) {
        NotificationService.showAlert(
          "Resource Request",
          msg.substring(4),
          'resource_channel'
        );
      }else if (msg.startsWith("ID|")) {
          final parts = msg.split('|');
          String realId = parts[1];
          myId = realId;
          //String hardwareName = parts[2];

        
        //await _deviceDao.markClient(hardwareName, realId);
        //String did = await _deviceDao.getDeviceId(realId) ?? "unknown";
        /*NotificationService.showAlert(
          "Neww Message",
          realId + msg.startsWith("ID|").toString(),
          'chat_channel'
        );*/
      }
      else {
        List<String> parts = msg.split('|');

        String senderId = parts[0];
        String message = parts.sublist(1).join('|');
        

        Message newMessage = Message(
          senderDeviceId: senderId,
          messageType: "text",
          content: message,
          timestamp: DateTime.now().toIso8601String(),
          delivered: 1,
        );

        _messageDao.insertMessage(newMessage);

        //chatHistory.insert(0, msg);

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

    await _service.clientInterface.startScan((devices) async {
      if (devices.isNotEmpty && !isActive && !isConnecting) {
        isConnecting = true;
        final target = devices.first;
        connectionStatus = "Auto-joining ${target.deviceName}...";
        notifyListeners();
        
        await _service.clientInterface.stopScan();//.then((_) {
          _service.clientInterface.connectWithDevice(target);
        
        isConnecting = false;
        //});

      }
    });
  }

  Future<void> sendMessage(String text, String targetId, bool isHost) async {
    bool ok = false;
    if (!text.startsWith("ID|") && !text.startsWith("REQ:")) {
      
      text = "$myId|$text";
    }

    if (isHost) {
      ok = await _service.hostInterface.sendTextToClient(text, targetId);
    } else {
      ok = await _service.clientInterface.sendTextToClient(text, targetId); 
    }

    if (ok) {
      //chatHistory.insert(0, text);
      if(!text.startsWith("ID|") && !text.startsWith("REQ:")){
        List<String> parts = text.split('|');
        String content = parts.sublist(1).join('|');
        Message newMessage = Message(
          senderDeviceId: myId,
          messageType: "text",
          content: content,
          timestamp: DateTime.now().toIso8601String(),
          delivered: 0,
        );
      
        _messageDao.insertMessage(newMessage);
      
        notifyListeners();
      }
    }
  }

  // inside P2PViewModel
  Future<List<Message>> getAllSavedMessages() async {
    return await _messageDao.getAll();
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _peerSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  Future<void> disconnect(bool isHost) async {
    
      if (isHost) {
        await _service.hostInterface.removeGroup();
        await _service.hostInterface.dispose();
        //print("[DEBUG] Host: Group removed and disconnected.");
      } else {
        await _service.clientInterface.stopScan();
        await _service.clientInterface.disconnect();
        await _service.clientInterface.dispose();
      }
      
      peers = [];
      chatHistory = [];
      isActive = false;
      connectionStatus = "Disconnected";
      isHost=false;
      isConnecting=false;
      
      _msgSub?.cancel();
      _peerSub?.cancel();
      _stateSub?.cancel();
      _msgSub = null;
      _peerSub = null;
      _stateSub = null;
      
      notifyListeners();
    
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
