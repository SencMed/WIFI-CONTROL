import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_control/services/lan_device_discovery_service.dart';

void main() {
  group('LanDeviceDiscoveryService', () {
    test('rechaza una dirección IPv4 no válida', () async {
      final service = LanDeviceDiscoveryService();
      expect(
        () => service.discover(
          localIp: '192.168.1.300',
          subnetMask: '255.255.255.0',
        ),
        throwsFormatException,
      );
    });

    test('rechaza una máscara IPv4 no válida', () async {
      final service = LanDeviceDiscoveryService();
      expect(
        () => service.discover(
          localIp: '192.168.1.20',
          subnetMask: '255.255.0',
        ),
        throwsFormatException,
      );
    });
  });
}
