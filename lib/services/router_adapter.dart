import '../models/network_device.dart';
import '../models/router_profile.dart';

/// Interfaz común para adaptadores específicos de cada fabricante/modelo.
/// Cada implementación debe documentar autenticación, permisos y capacidades.
/// No asumir que todos los routers exponen una API estándar.
abstract class RouterAdapter {
  RouterProfile get profile;
  Future<bool> testConnection();
  Future<List<NetworkDevice>> getConnectedDevices();
  Future<Map<String, String>> getWifiStatus();
}
