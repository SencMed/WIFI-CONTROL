enum RouterVendor { huawei, kaon, unknown }

class RouterProfile {
  final RouterVendor vendor;
  final String manufacturer;
  final String model;
  final String localAddress;
  final String connectionType;
  final String hardwareVersion;
  final String softwareVersion;
  final bool profileOnly;

  const RouterProfile({
    required this.vendor,
    required this.manufacturer,
    required this.model,
    required this.localAddress,
    this.connectionType = 'Desconocida',
    this.hardwareVersion = '',
    this.softwareVersion = '',
    this.profileOnly = true,
  });

  static const huaweiHg8245w5 = RouterProfile(
    vendor: RouterVendor.huawei,
    manufacturer: 'Huawei',
    model: 'EchoLife HG8245W5-6T',
    localAddress: '192.168.1.1',
    connectionType: 'GPON / ONT',
    hardwareVersion: '1A3D.A',
    softwareVersion: 'V5R020C00S330',
  );

  static const kaonCg3000 = RouterProfile(
    vendor: RouterVendor.kaon,
    manufacturer: 'KAON',
    model: 'CG3000',
    localAddress: 'Por detectar',
    connectionType: 'Cable / DOCSIS',
  );
}
