import '../models/router_profile.dart';
import 'documented_router_adapters.dart';

/// Catálogo de equipos documentados y fábrica de adaptadores.
/// Un perfil registrado no implica que todas sus funciones estén habilitadas.
class RouterRegistry {
  static const supportedProfiles = <RouterProfile>[
    RouterProfile.huaweiHg8245w5,
    RouterProfile.kaonCg3000,
  ];

  static DocumentedRouterAdapter? adapterFor(RouterProfile profile) {
    switch (profile.vendor) {
      case RouterVendor.huawei:
        if (profile.model == RouterProfile.huaweiHg8245w5.model) {
          return HuaweiHg8245w5Adapter();
        }
        return null;
      case RouterVendor.kaon:
        if (profile.model == RouterProfile.kaonCg3000.model) {
          return KaonCg3000Adapter();
        }
        return null;
      case RouterVendor.unknown:
        return null;
    }
  }
}
