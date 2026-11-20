import 'dart:async';
import 'dart:io';

import '../models/network_device.dart';

/// Best-effort discovery of local IPv4 hosts through common TCP services.
/// Devices without an open service may not be detected.
class LanDeviceDiscoveryService {
  static const List<int> _ports = [80, 443, 22, 445, 5555, 62078];
  static const int _maxConcurrentHosts = 24;
  static const Duration _timeout = Duration(milliseconds: 350);

  Future<List<NetworkDevice>> discover({
    required String localIp,
    required String subnetMask,
  }) async {
    final targets = _hostsInSubnet(localIp, subnetMask);
    final found = <NetworkDevice>[];
    var next = 0;

    Future<void> worker() async {
      while (true) {
        final index = next++;
        if (index >= targets.length) return;
        final host = targets[index];
        final openPorts = await _openPorts(host);
        if (openPorts.isNotEmpty) {
          found.add(NetworkDevice(
            name: _describePorts(openPorts),
            ipAddress: host,
            macAddress: 'No disponible',
            connectionType: 'Red local',
            bandOrSsid: 'No identificado',
            detectedPorts: openPorts,
            status: DeviceConnectionStatus.online,
          ));
        }
      }
    }

    final workerCount = targets.length < _maxConcurrentHosts
        ? targets.length
        : _maxConcurrentHosts;
    await Future.wait(List.generate(workerCount, (_) => worker()));
    found.sort((a, b) => _compareIpv4(a.ipAddress, b.ipAddress));
    return found;
  }

  Future<List<int>> _openPorts(String host) async {
    final checks = await Future.wait(_ports.map((port) async {
      Socket? socket;
      try {
        socket = await Socket.connect(host, port, timeout: _timeout);
        return port;
      } on SocketException {
        return null;
      } on TimeoutException {
        return null;
      } finally {
        socket?.destroy();
      }
    }));
    return checks.whereType<int>().toList()..sort();
  }

  List<String> _hostsInSubnet(String localIp, String subnetMask) {
    final ip = _ipv4ToInt(localIp);
    final mask = _ipv4ToInt(subnetMask);
    if (ip == null || mask == null || !_isContiguousMask(mask)) {
      throw const FormatException('IP local o máscara IPv4 no válida.');
    }
    final network = ip & mask;
    final broadcast = network | (~mask & 0xFFFFFFFF);
    final first = network + 1;
    final last = broadcast - 1;
    if (last < first || last - first > 1022) {
      throw const FormatException(
        'El rango de red es demasiado grande para el escaneo inicial.',
      );
    }
    return [
      for (var address = first; address <= last; address++)
        if (address != ip) _intToIpv4(address),
    ];
  }

  bool _isContiguousMask(int mask) {
    final inverted = (~mask) & 0xFFFFFFFF;
    return (inverted & (inverted + 1)) == 0;
  }

  int? _ipv4ToInt(String value) {
    final parts = value.split('.');
    if (parts.length != 4) return null;
    var result = 0;
    for (final part in parts) {
      final octet = int.tryParse(part);
      if (octet == null || octet < 0 || octet > 255) return null;
      result = (result << 8) | octet;
    }
    return result;
  }

  String _intToIpv4(int value) => [
        (value >> 24) & 255,
        (value >> 16) & 255,
        (value >> 8) & 255,
        value & 255,
      ].join('.');

  int _compareIpv4(String a, String b) =>
      (_ipv4ToInt(a) ?? 0).compareTo(_ipv4ToInt(b) ?? 0);

  String _describePorts(List<int> ports) {
    final labels = ports.map((port) {
      switch (port) {
        case 80:
          return 'Web';
        case 443:
          return 'Web seguro';
        case 22:
          return 'SSH';
        case 445:
          return 'Compartir archivos';
        case 5555:
          return 'Servicio Android';
        case 62078:
          return 'Servicio móvil';
        default:
          return 'TCP $port';
      }
    }).toList();
    return labels.join(' · ');
  }
}
