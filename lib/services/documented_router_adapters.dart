import 'dart:io';

import '../models/network_device.dart';
import '../models/router_capability.dart';
import '../models/router_profile.dart';
import 'router_adapter.dart';

/// Reference adapters are deliberately read-only until a vendor API is
/// verified for the exact firmware. A TCP probe is not an admin login.
abstract class DocumentedRouterAdapter implements RouterAdapter {
  @override
  final RouterProfile profile;

  DocumentedRouterAdapter(this.profile);

  Uri get panelUri => Uri(scheme: 'http', host: profile.localAddress);

  List<RouterCapability> get capabilities;

  Future<bool> _probePort(String host, int port) async {
    Socket? socket;
    try {
      socket = await Socket.connect(host, port,
          timeout: const Duration(seconds: 2));
      return true;
    } on SocketException {
      return false;
    } finally {
      socket?.destroy();
    }
  }

  @override
  Future<bool> testConnection() async {
    final host = profile.localAddress;
    if (host == 'Por detectar' || host.trim().isEmpty) return false;
    if (await _probePort(host, 80)) return true;
    return _probePort(host, 443);
  }

  @override
  Future<List<NetworkDevice>> getConnectedDevices() {
    throw UnsupportedError(
      'La lectura automática de dispositivos aún no está verificada '
      'para \${profile.manufacturer} \${profile.model}.',
    );
  }

  @override
  Future<Map<String, String>> getWifiStatus() async => {
        'estado': 'No verificado',
        'detalle':
            'El panel documenta ajustes Wi-Fi, pero no hay un método de '
                'lectura autenticada validado para este firmware.',
      };
}

class HuaweiHg8245w5Adapter extends DocumentedRouterAdapter {
  HuaweiHg8245w5Adapter() : super(RouterProfile.huaweiHg8245w5);

  @override
  List<RouterCapability> get capabilities => const [
        RouterCapability(
          id: 'connection',
          name: 'Comprobar panel local',
          state: RouterCapabilityState.available,
          explanation:
              'Prueba TCP en puertos web 80 y 443; no inicia sesión.',
        ),
        RouterCapability(
          id: 'devices',
          name: 'Dispositivos conectados',
          state: RouterCapabilityState.manualOnly,
          explanation:
              'La lista existe en Home Network, pero la consulta automática autenticada no está validada.',
        ),
        RouterCapability(
          id: 'wifi',
          name: 'Estado Wi-Fi 2.4 / 5 GHz',
          state: RouterCapabilityState.manualOnly,
          explanation:
              'El panel expone ambas bandas; la lectura automática aún no está validada.',
        ),
        RouterCapability(
          id: 'diagnostics',
          name: 'Diagnóstico y pruebas',
          state: RouterCapabilityState.manualOnly,
          explanation:
              'Las pruebas del panel requieren revisión manual antes de automatizarse.',
        ),
      ];
}

class KaonCg3000Adapter extends DocumentedRouterAdapter {
  KaonCg3000Adapter() : super(RouterProfile.kaonCg3000);

  @override
  List<RouterCapability> get capabilities => const [
        RouterCapability(
          id: 'connection',
          name: 'Comprobar panel local',
          state: RouterCapabilityState.notVerified,
          explanation:
              'La IP local del CG3000 debe detectarse en cada red antes de probar puertos.',
        ),
        RouterCapability(
          id: 'devices',
          name: 'Dispositivos conectados',
          state: RouterCapabilityState.manualOnly,
          explanation:
              'El panel documenta estaciones asociadas; no se ha validado una API de lectura.',
        ),
        RouterCapability(
          id: 'wifi',
          name: 'Estado Wi-Fi',
          state: RouterCapabilityState.manualOnly,
          explanation:
              'El panel expone ajustes y filtrado MAC; no se automatizarán cambios no verificados.',
        ),
        RouterCapability(
          id: 'diagnostics',
          name: 'Diagnóstico DOCSIS',
          state: RouterCapabilityState.manualOnly,
          explanation:
              'Las métricas DOCSIS y los registros se consultan manualmente.',
        ),
      ];
}
