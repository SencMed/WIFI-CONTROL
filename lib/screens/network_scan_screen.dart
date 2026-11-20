import 'package:flutter/material.dart';
import '../services/network_discovery_service.dart';

class NetworkScanScreen extends StatefulWidget {
  const NetworkScanScreen({super.key});

  @override
  State<NetworkScanScreen> createState() => _NetworkScanScreenState();
}

class _NetworkScanScreenState extends State<NetworkScanScreen> {
  final NetworkDiscoveryService _discovery = NetworkDiscoveryService();
  LocalNetworkSnapshot? _snapshot;
  bool _loading = false;
  String? _error;

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _error = null;
      _snapshot = null;
    });
    try {
      final result = await _discovery.scanCurrentNetwork();
      if (!mounted) return;
      setState(() => _snapshot = result);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo leer la red: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _snapshot;
    return Scaffold(
      appBar: AppBar(title: const Text('Detección de red')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF1769AA)),
              title: Text('Análisis de la red local'),
              subtitle: Text('WIFI CONTROL consultará la información de la conexión actual y comprobará si la puerta de enlace responde en los puertos web habituales.'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _scan,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.radar),
            label: Text(_loading ? 'Analizando...' : 'Detectar mi red'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (data != null) ...[
            const SizedBox(height: 18),
            const Text('Resultado', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _ResultTile(icon: Icons.wifi, label: 'Red Wi-Fi', value: data.wifiName ?? 'No disponible'),
            _ResultTile(icon: Icons.phone_iphone, label: 'IP de este dispositivo', value: data.localIp ?? 'No disponible'),
            _ResultTile(icon: Icons.router, label: 'Puerta de enlace', value: data.gatewayIp ?? 'No disponible'),
            _ResultTile(icon: Icons.lan, label: 'Máscara de red', value: data.subnetMask ?? 'No disponible'),
            Card(
              child: ListTile(
                leading: Icon(
                  data.gatewayResponded ? Icons.check_circle : Icons.help_outline,
                  color: data.gatewayResponded ? Colors.green : Colors.orange,
                ),
                title: Text(data.gatewayResponded ? 'La puerta de enlace respondió' : 'No se confirmó respuesta web'),
                subtitle: const Text('La prueba revisa los puertos 80 y 443. Un resultado negativo no significa que el router esté apagado.'),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Este resultado identifica datos de la red local; todavía no identifica la marca ni permite cambiar la configuración del router.',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResultTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF1769AA)),
          title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          subtitle: SelectableText(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      );
}
