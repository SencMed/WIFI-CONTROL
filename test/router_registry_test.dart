import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_control/models/router_capability.dart';
import 'package:wifi_control/models/router_profile.dart';
import 'package:wifi_control/services/documented_router_adapters.dart';
import 'package:wifi_control/services/router_registry.dart';

void main() {
  group('RouterRegistry', () {
    test('crea el adaptador documentado de Huawei', () {
      final adapter =
          RouterRegistry.adapterFor(RouterProfile.huaweiHg8245w5);
      expect(adapter, isA<HuaweiHg8245w5Adapter>());
      expect(adapter!.capabilities.map((item) => item.id),
          containsAll(['connection', 'devices', 'wifi', 'diagnostics']));
    });

    test('crea el adaptador documentado de KAON', () {
      final adapter = RouterRegistry.adapterFor(RouterProfile.kaonCg3000);
      expect(adapter, isA<KaonCg3000Adapter>());
      expect(
        adapter!.capabilities
            .firstWhere((item) => item.id == 'devices')
            .state,
        RouterCapabilityState.manualOnly,
      );
    });

    test('no asigna adaptador a un fabricante desconocido', () {
      const unknown = RouterProfile(
        vendor: RouterVendor.unknown,
        manufacturer: 'Desconocido',
        model: 'Modelo no identificado',
        localAddress: '192.168.1.1',
      );
      expect(RouterRegistry.adapterFor(unknown), isNull);
    });
  });
}
