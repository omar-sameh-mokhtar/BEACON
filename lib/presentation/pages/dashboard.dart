import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';

import '../../model/service/p2p_service.dart';

class NetworkDashboardPage extends StatefulWidget {
  const NetworkDashboardPage({super.key});

  @override
  State<NetworkDashboardPage> createState() => _NetworkDashboardPageState();
}

class _NetworkDashboardPageState extends State<NetworkDashboardPage> {
  final P2PService _p2pService = P2PService();

  // ====== STATE ======
  List<BleDiscoveredDevice> _discoveredDevices = [];
  bool _isScanning = false;
  HotspotClientState? _clientState;

  // ====== LIFECYCLE ======
  @override
  void initState() {
    super.initState();

    _p2pService.setCallbacks(
      clientState: (state) => setState(() => _clientState = state),
      devicesDiscovered: (devices) =>
          setState(() => _discoveredDevices = devices),
      scanningChanged: (scanning) =>
          setState(() => _isScanning = scanning),
      log: (msg) => debugPrint(msg),
    );

    _initP2P();
  }

  Future<void> _initP2P() async {
    await P2PService.checkAndRequestPermissions(context);
    await P2PService.checkAndEnableServices(context);
    await _p2pService.initialize(); // SAFE (singleton)
  }

  // ====== HELPERS ======
  String get _networkStatus {
    if (_clientState?.isActive == true) return "Connected";
    if (_isScanning) return "Scanning";
    return "Idle";
  }

  Color get _statusColor {
    switch (_networkStatus) {
      case "Connected":
        return Colors.green;
      case "Scanning":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarTop(title: "Network Dashboard"),
      floatingActionButton: Floatingvoicebutton(),
      bottomNavigationBar: const NavigationBarBottom(currentIndex: 0),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildStatus(),
            const SizedBox(height: 12),
            Expanded(child: _buildDevicesList()),
            const SizedBox(height: 10),
            _buildBroadcastButton(size),
          ],
        ),
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Discovered Devices: ${_discoveredDevices.length}",
          style: const TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: Icon(
            _isScanning ? Icons.stop : Icons.radar,
            color: _isScanning ? Colors.red : Colors.green,
          ),
          onPressed: _isScanning
              ? _p2pService.stopDiscovery
              : _p2pService.startDiscoveryViaBLE,
        ),
      ],
    );
  }

  Widget _buildStatus() {
    return Text(
      "Network Status: $_networkStatus",
      style: TextStyle(color: _statusColor),
    );
  }

  Widget _buildDevicesList() {
    if (_discoveredDevices.isEmpty) {
      return const Center(
        child: Text(
          "No devices discovered",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: _discoveredDevices.length,
      itemBuilder: (_, index) {
        final device = _discoveredDevices[index];
        return _deviceCard(device);
      },
    );
  }

  Widget _deviceCard(BleDiscoveredDevice device) {
    final connected = _clientState?.isActive == true;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: connected ? Colors.green : Colors.grey,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: const Icon(Icons.wifi, color: Colors.white),
        ),
        title: Text(
          device.deviceName ?? "Unknown Device",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          device.deviceAddress ?? "No address",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: ElevatedButton(
          onPressed: connected
              ? null
              : () => _p2pService.connectToDiscoveredHost(device),
          child: const Text("Connect"),
        ),
      ),
    );
  }

  Widget _buildBroadcastButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.018,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _clientState?.isActive == true
            ? () {
          // TODO: open broadcast dialog
        }
            : null,
        child: const Text(
          "Send Broadcast Message",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
