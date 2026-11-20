import '../models/router_profile.dart';

/// Catálogo inicial de equipos de referencia.
/// Estar registrado aquí NO significa que la conexión esté implementada.
class RouterRegistry {
  static const supportedProfiles = <RouterProfile>[
    RouterProfile.huaweiHg8245w5,
    RouterProfile.kaonCg3000,
  ];
}
