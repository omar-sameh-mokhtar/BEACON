import 'package:flutter/material.dart';
import 'package:beacon/model/data/Device.dart';
import 'package:beacon/model/mapper/device_mapper.dart';
import 'package:beacon/presentation/widgets/AppBarTop.dart';
import 'package:beacon/presentation/widgets/NavigationBarBottom.dart';
import 'package:beacon/presentation/widgets/FloatingVoiceButton.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

import '../../model/service/p2p_service.dart';

class NetworkDashboardPage extends StatefulWidget {
  const NetworkDashboardPage({super.key});

  @override
  State<NetworkDashboardPage> createState() => _NetworkDashboardPageState();
}

class _NetworkDashboardPageState extends State<NetworkDashboardPage> {
  final P2PService _p2pService = P2PService();

  final List<Device> _devices = [];

  bool _isScanning = false;
  String _networkStatus = "Idle";

  HotspotHostState? _hostState;
  HotspotClientState? _clientState;

  @override
  void initState() {
    super.initState();
    _initP2P();
  }

  Future<void> _initP2P() async {
    await P2PService.checkAndRequestPermissions(context);
    await P2PService.checkAndEnableServices(context);

    _p2pService.setCallbacks(
      hostState: (state) {
        setState(() {
          _hostState = state;
          _networkStatus = state.isActive ? "Hosting" : "Idle";
        });
      },
      clientState: (state) {
        setState(() {
          _clientState = state;
          _networkStatus = state.isActive ? "Connected" : "Idle";
        });
      },
      devicesDiscovered: (bleDevices) {
        setState(() {
          _devices
            ..clear()
            ..addAll(
              bleDevices.map(DeviceMapper.fromBle),
            );
        });
      },
      scanningChanged: (scanning) {
        setState(() {
          _isScanning = scanning;
        });
      },
      log: (msg) {
        debugPrint("[P2P] $msg");
      },
    );

    await _p2pService.initialize();
  }

  @override
  void dispose() {
    _p2pService.dispose();
    super.dispose();
  }

  void _startScan() async {
    await _p2pService.startDiscoveryViaBLE();
  }

  void _stopScan() async {
    await _p2pService.stopDiscovery();
  }

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

  // ---------------- UI PARTS ----------------

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Discovered Devices: ${_devices.length}",
          style: const TextStyle(color: Colors.white),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isScanning ? Icons.stop : Icons.radar,
                color: _isScanning ? Colors.red : Colors.green,
              ),
              onPressed: _isScanning ? _stopScan : _startScan,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatus() {
    Color color;

    switch (_networkStatus) {
      case "Hosting":
        color = Colors.orange;
        break;
      case "Connected":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Text(
      "Network Status: $_networkStatus",
      style: TextStyle(color: color),
    );
  }

  Widget _buildDevicesList() {
    if (_devices.isEmpty) {
      return const Center(
        child: Text(
          "No devices discovered",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (_, index) {
        final device = _devices[index];
        return _deviceCard(device);
      },
    );
  }

  Widget _deviceCard(Device device) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: device.isConnected ? Colors.green : Colors.grey,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          device.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Last seen: ${device.lastSeen}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: Icon(
          device.isConnected ? Icons.link : Icons.link_off,
          color: device.isConnected ? Colors.green : Colors.grey,
        ),
        onTap: () {
          // TODO
          // connect / open chat / send request
        },
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          // TODO: open broadcast dialog
        },
        child: const Text(
          "Send Broadcast Message",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
