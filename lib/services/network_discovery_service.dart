import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNetworkSnapshot {
  final String? wifiName;
  final String? localIp;
  final String? gatewayIp;
  final String? subnetMask;
  final bool gatewayResponded;

  const LocalNetworkSnapshot({
    this.wifiName,
    this.localIp,
    this.gatewayIp,
    this.subnetMask,
    required this.gatewayResponded,
  });
}

class NetworkDiscoveryService {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<LocalNetworkSnapshot> scanCurrentNetwork() async {
    // Android protects SSID/BSSID behind location permission on many versions.
    // iOS may return null unless the app satisfies Apple's Wi-Fi information
    // entitlement and authorization requirements.
    if (!kIsWeb && Platform.isAndroid) {
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        // Continue: IP and gateway may still be available without the SSID.
      }
    }

    final results = await Future.wait<String?>([
      _networkInfo.getWifiName(),
      _networkInfo.getWifiIP(),
      _networkInfo.getWifiGatewayIP(),
      _networkInfo.getWifiSubmask(),
    ]);

    final gateway = results[2];
    final responded = gateway == null ? false : await _probeGateway(gateway);

    return LocalNetworkSnapshot(
      wifiName: _cleanSsid(results[0]),
      localIp: results[1],
      gatewayIp: gateway,
      subnetMask: results[3],
      gatewayResponded: responded,
    );
  }

  Future<bool> _probeGateway(String address) async {
    // A successful TCP handshake only confirms that the gateway answers on
    // one of these common management ports; it does not identify the vendor.
    for (final port in const [80, 443]) {
      Socket? socket;
      try {
        socket = await Socket.connect(
          address,
          port,
          timeout: const Duration(seconds: 2),
        );
        return true;
      } on SocketException {
        // Try the next port.
      } on IOException {
        // Try the next port.
      } finally {
        socket?.destroy();
      }
    }
    return false;
  }

  String? _cleanSsid(String? value) {
    if (value == null) return null;
    final cleaned = value.replaceAll('"', '').trim();
    if (cleaned.isEmpty || cleaned == '<unknown ssid>') return null;
    return cleaned;
  }
}
