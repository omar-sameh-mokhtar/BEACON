import 'dart:convert';

import 'package:beacon/model/data/UserProfile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/data/Resource.dart';
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

import '../model/service/resource_service.dart';
import '../model/service/user_profile_service.dart';
import 'ProfileViewModel.dart';

class P2PViewModel extends ChangeNotifier {

  String myId = 'unknown-device';
  final P2PService _service = P2PService();
  final ConnectedDeviceDao _deviceDao = ConnectedDeviceDao();
  final MessageDao _messageDao = MessageDao();
  get service => _service;
  final UserProfileDao userProfileDao = UserProfileDao();

  final ResourceDao _resourceDao = ResourceDao();

  
  bool isHost = false;
  List<P2pClientInfo> peers = [];
  //List<String> chatHistory = [];
  String? activePeerId;
  List<Message> currentChatMessages = [];
  Map<String, Message?> lastMessages = {};
  String connectionStatus = "Disconnected";
  bool isActive = false;
  bool isConnecting = false;
  
  StreamSubscription? _msgSub;
  StreamSubscription? _peerSub;
  StreamSubscription? _stateSub;
  String owner = "";

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
          /*NotificationService.showAlert(
            "Network Update", 
            "${joiner.username} has joined. ${joiner.isHost ? 'HOST' : 'CLIENT'}", 
            'client_channel'
          );*/
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
        final UserProfile? currentUser = await userProfileDao.getUserProfile();

        if( currentUser?.name == msg.split(":")[1]) {
          NotificationService.showAlert(
              "Resource Request from ${msg.split(":")[2]}",
              msg.substring(4),
              'resource_channel'
          );
        }
      }else if(msg.startsWith("PR|")){
        NotificationService.showAlert(
          "providing res",
          "y",
          'chat_channel'
        );
        final parts = msg.split('|');
        String clientId = parts[1];
        String resources = parts.sublist(2).join('|');
          // ID|clientId|resources
          if (isHost) {
             SyncToClient(clientId, resources);
          }

      }else if (msg.startsWith("ID|")) {
          final parts = msg.split('|');
          String realId = parts[1];
          myId = realId;
          if(!isHost){
            await sendJoinPing();
          }

        //await _deviceDao.markClient(hardwareName, realId);
        //String did = await _deviceDao.getDeviceId(realId) ?? "unknown";
        /*NotificationService.showAlert(
          "Neww Message",
          realId + msg.startsWith("ID|").toString(),
          'chat_channel'
        );*/
      }else if( msg.startsWith("SYNC|") ){
        final data = jsonDecode(msg.substring(5));

        for (final r in data) {
          await _resourceDao.upsertResource(Resource.fromMap(r));
        }

        NotificationService.showAlert(
          "upserting Resources",
          "ye",
          'chat_channel'
        );

        notifyListeners();
      }else if (msg.startsWith("DELETE_RES|")) {
        try {
          final int resourceId = int.parse(msg.substring(11));
          await _resourceDao.deleteResource(resourceId);

          NotificationService.showAlert(
              "Resource Synced",
              "Resource with ID $resourceId has been deleted.",
              'resource_channel'
          );

        } catch (e) {
          debugPrint("[ERROR] Failed to parse resource ID for deletion: $e");
        }
      }
      else {
        List<String> parts = msg.split('|');

        String senderId = parts[0];
        String message = parts.sublist(1).join('|');
        

        Message newMessage = Message(
          senderDeviceId: senderId,
          receiverDeviceId: myId,
          messageType: "text",
          content: message,
          timestamp: DateTime.now().toIso8601String(),
          delivered: 1,
        );

        _messageDao.insertMessage(newMessage);

        //await refreshMessages(senderId);
        updateLastMessageSummary(senderId);

        if (activePeerId != null) {
          if (senderId == activePeerId || newMessage.receiverDeviceId == "ALL") {
            await refreshMessages(activePeerId!); 
          }
        }

        NotificationService.showAlert(
          "New Message",
          msg,
          'chat_channel'
        );
      }
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
          receiverDeviceId: targetId,
          messageType: "text",
          content: content,
          timestamp: DateTime.now().toIso8601String(),
          delivered: 0,
        );
      
        _messageDao.insertMessage(newMessage);

        await refreshMessages(targetId);
        updateLastMessageSummary(targetId);
      }
    }
  }

  Future<List<Message>> getAllSavedMessages() async {
    return await _messageDao.getAll();
  }
  Future<void> refreshMessages(String peerId) async {
    currentChatMessages = await _messageDao.getChatHistory(myId, peerId);
    notifyListeners();
  }
  Future<void> updateLastMessageSummary(String peerId) async {
    final msg = await _messageDao.getLastMessageForPeer(myId, peerId);
    lastMessages[peerId] = msg;
    notifyListeners();
  }
  Future<void> loadChatWithPeer(String peerId) async {
    activePeerId = peerId;
    currentChatMessages = await _messageDao.getChatHistory(myId, peerId);
    notifyListeners();
  }void closeChat() {
    activePeerId = null;
    currentChatMessages = [];
    notifyListeners();
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
      //chatHistory = [];
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

  Future<void> SyncToClient(String ClientID, String resources_msg) async {
    try {
      final List<dynamic> decoded = jsonDecode(resources_msg);
      final List<Resource> incomingResources =
      decoded.map((e) => Resource.fromMap(e)).toList();
      NotificationService.showAlert(
          "Saved to db",
          "yes",
          'chat_channel'
        );

      for (final resource in incomingResources) {
        await _resourceDao.addResource(resource);
      }

      debugPrint(
        "[HOST] Synced ${incomingResources.length} resources from client $ClientID",
      );

      await sync_broadcast();

    } catch (e, stack) {
      debugPrint("[HOST][ERROR] Failed syncing resources: $e");
      debugPrint(stack.toString());
    }
    
    notifyListeners();
  }


  Future<void> sync_broadcast() async {
    final List<Resource> localResources = await _resourceDao.getAllResources();

    String msg =  "SYNC|${jsonEncode(
      localResources.map((r) => r.toMap()).toList(),
    )}";

    sendBroadcast(msg);
      NotificationService.showAlert(
          "Sent sync Message",
          msg,
          'chat_channel'
        );    

  }


  Future<void> sendJoinPing() async {
    NotificationService.showAlert(
          "Sent ping Message",
          "PINGGG",
          'chat_channel'
        );
    final List<Resource> localResources =
    await _resourceDao.getAllResources();

    final String msg = "PR|$myId|${jsonEncode(
      localResources.map((r) => r.toMap()).toList(),
    )}";

    _service.clientInterface.broadcastText(msg);
      NotificationService.showAlert(
          "Sent ping Message",
          msg,
          'chat_channel'
        );
  }



  Future<void> sendBroadcast(String message) async {
    if (!isActive) return;

    if (isHost) {
      await _service.hostInterface.broadcastText(message);
    } else {
      await _service.clientInterface.broadcastText(message);
    }
  }

  Future<void> broadcastDeleteResource(int resourceId) async {
    final String msg = "DELETE_RES|$resourceId";
    await sendBroadcast(msg);

    NotificationService.showAlert(
        "Broadcasting Deletion",
        "Sent delete command for resource ID: $resourceId",
        'resource_channel'
    );
  }


  Future<void> sendBroadcastMessage(String text, String senderId) async {

    if (isHost) {
      await _service.hostInterface.broadcastText('${senderId}|${text}');
    } else {
      await _service.clientInterface.broadcastText('${senderId}|${text}'); 
    }

    Message newMessage = Message(
      senderDeviceId: senderId,
      receiverDeviceId: "ALL",
      messageType: "broadcast",
      content: text,
      timestamp: DateTime.now().toIso8601String(),
      delivered: 0,
    );
  
    _messageDao.insertMessage(newMessage);

    await refreshMessages('ALL');
    updateLastMessageSummary('ALL');
  }    
  
  // REQ:resourceOwner:requester
  Future<void> requestResource(Resource resource, String name) async{
      await sendBroadcast("REQ:${resource.owner}:$name");
  }


}