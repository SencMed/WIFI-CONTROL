enum DeviceConnectionStatus { online, offline, unknown }

class NetworkDevice {
  final String name;
  final String ipAddress;
  final String macAddress;
  final String connectionType;
  final String bandOrSsid;
  final int? signalDbm;
  final double? linkRateMbps;
  final DeviceConnectionStatus status;

  const NetworkDevice({
    required this.name,
    required this.ipAddress,
    required this.macAddress,
    required this.connectionType,
    required this.bandOrSsid,
    this.signalDbm,
    this.linkRateMbps,
    this.status = DeviceConnectionStatus.unknown,
  });
}
