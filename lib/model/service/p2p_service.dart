import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';
import 'package:permission_handler/permission_handler.dart';

class P2PService {

  final FlutterP2pHost hostInterface = FlutterP2pHost();
  final FlutterP2pClient clientInterface = FlutterP2pClient();


  int getClientLength(){
    return hostInterface.clientList.length;
  }

  Future<void> initHost() async => await hostInterface.initialize();
  Future<void> initClient() async => await clientInterface.initialize();

  
  Future<bool> ensurePermissions() async {
    if (!await hostInterface.checkP2pPermissions()) {
      hostInterface.askP2pPermissions();
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices, 
    ].request();

    bool isBluetoothGranted = statuses[Permission.bluetoothConnect]!.isGranted;
    bool isNearbyGranted = statuses[Permission.nearbyWifiDevices]!.isGranted;
    bool isP2pGranted = await hostInterface.checkP2pPermissions();

    return isP2pGranted && isBluetoothGranted && isNearbyGranted;
  }

  Future<void> ensureServices() async {
    if (!await hostInterface.checkLocationEnabled()) {
      hostInterface.enableLocationServices();
    }
    if (!await hostInterface.checkWifiEnabled()) {
      hostInterface.enableWifiServices();
    }
    if (!await hostInterface.checkBluetoothEnabled()) {
    hostInterface.enableBluetoothServices();
  }
  }

  Stream<String> getMessageStream(bool isHost) {
    return isHost 
        ? hostInterface.streamReceivedTexts() 
        : clientInterface.streamReceivedTexts();
  }

  Stream<List<P2pClientInfo>> getPeerStream(bool isHost) {
    return isHost 
        ? hostInterface.streamClientList() 
        : clientInterface.streamClientList();
  }


}
