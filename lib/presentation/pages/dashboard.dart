import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';
import 'chat.dart';
import 'dart:async';
import '../../model/service/p2p_service.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/p2p_viewmodel.dart';

//final FlutterP2pHost hostInterface = FlutterP2pHost();
//final FlutterP2pClient clientInterface = FlutterP2pClient();

class NetworkDashboardPage extends StatefulWidget {
  final bool isHost;
  const NetworkDashboardPage({super.key, required this.isHost});

  @override
  State<NetworkDashboardPage> createState() => _NetworkDashboardPageState();
}

class _NetworkDashboardPageState extends State<NetworkDashboardPage> {

  /*List<P2pClientInfo> _peers = [];
  List<BleDiscoveredDevice> _discoveredHosts = [];
  String _connectionStatus = "Initializing...";
  bool _isActive = false;
  bool _isConnecting = false;*/

  /*StreamSubscription? _stateSub;
  StreamSubscription? _peerSub;*/

  /*@override
  void initState() {
    super.initState();
    _startP2PEngine();
  }*/
  /*
  Future<void> _startP2PEngine() async {
    try {
      if (widget.isHost) {
        await hostInterface.initialize(); //
        _stateSub = hostInterface.streamHotspotState().listen((state) {
          setState(() {
            _isActive = state.isActive;
            _connectionStatus = state.isActive ? "Hosting: ${state.ssid}" : "Failed: ${state.failureReason}";
          });
          print("[HOST STATE] Active: ${state.isActive}, SSID: ${state.ssid}");
        });
        _peerSub = hostInterface.streamClientList().listen((list) {
          setState(() => _peers = list);
          print("[HOST PEERS] Count: ${list.length}");
        });
        await hostInterface.createGroup(advertise: true);
      } else {
        await clientInterface.initialize(); //
        _stateSub = clientInterface.streamHotspotState().listen((state) {
          setState(() {
            _isActive = state.isActive;
            _connectionStatus = state.isActive ? "Connected to Network" : "Searching...";
            if (state.isActive) _isConnecting = false;
          });
        });
        _peerSub = clientInterface.streamClientList().listen((list) => setState(() => _peers = list));
        _scanForHosts();
      }
    } catch (e) {
      setState(() => _connectionStatus = "Error: $e");
    }
  }*/
/*
  void _scanForHosts() async {
    print("[CLIENT] Starting Auto-Scan...");
    setState(() => _connectionStatus = "Scanning for emergency signal...");

    await clientInterface.startScan((devices) {
      setState(() => _discoveredHosts = devices);

      // AUTO-JOIN LOGIC:
      // If we found a device, aren't active yet, and aren't already trying to connect
      if (devices.isNotEmpty && !_isActive && !_isConnecting) {
        _isConnecting = true;
        final target = devices.first;
        
        print("[CLIENT] Found ${target.deviceName}. Auto-connecting...");
        
        setState(() => _connectionStatus = "Auto-joining: ${target.deviceName}...");
        
        // It's best practice to stop scanning before initiating a connection
        clientInterface.stopScan().then((_) {
          clientInterface.connectWithDevice(target);
        });
      }
    });
  }*/
/*
  @override
  void dispose() {
    _stateSub?.cancel();
    _peerSub?.cancel();
    super.dispose();
  }*/
  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    final p2pVM = context.watch<P2PViewModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title:"Network Dashboard"),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Connected: ${p2pVM.peers.length} Devices",
                    style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    /*DropdownButton(
                      dropdownColor: Colors.grey[900],
                      style: TextStyle(color: Colors.white),
                      value: selectedRange,
                      items: ["50m", "100m", "200m"]
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedRange = v!;
                        });
                      },
                    ),*/
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.refresh, color: Colors.white))
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
            Text("Network Status: ${p2pVM.connectionStatus}",
                style: TextStyle(color: Colors.green)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: p2pVM.peers.length,
                itemBuilder: (context, i) {
                  final p = p2pVM.peers[i];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.person, color: Colors.white)),
                      title: Text(p.username!,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p2pVM.peers[i].isHost! ? "Host" : "Role: Client",
                              style: TextStyle(color: Colors.grey)),
                          Text("Last seen: 3 min ago",
                              style: TextStyle(color: Colors.grey)),
                          Text("Last msg: hey",
                              style: TextStyle(color: Colors.grey))
                        ],
                      ),
                      trailing: Icon(Icons.chat_bubble_outline, color: Colors.red),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChattingPage(target: p, isHost: widget.isHost))),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width:  MediaQuery.of(context).size.width * 0.7,
              child: ElevatedButton(
                key: const Key('Broadcast_button'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(vertical: 14)),
                onPressed: () {},
                child: Text("Send Broadcast Message",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Floatingvoicebutton(),
      bottomNavigationBar: NavigationBarBottom(currentIndex: 0)
    );
  }
}
