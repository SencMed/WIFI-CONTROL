import 'package:flutter/material.dart';
import '../services/network_discovery_service.dart';
import '../services/router_fingerprint_service.dart';

class NetworkScanScreen extends StatefulWidget {
  const NetworkScanScreen({super.key});

  @override
  State<NetworkScanScreen> createState() => _NetworkScanScreenState();
}

class _NetworkScanScreenState extends State<NetworkScanScreen> {
  final NetworkDiscoveryService _discovery = NetworkDiscoveryService();
  final RouterFingerprintService _fingerprinter = RouterFingerprintService();
  RouterFingerprint? _fingerprint;
  bool _identifying = false;
  LocalNetworkSnapshot? _snapshot;
  bool _loading = false;
  String? _error;

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _error = null;
      _snapshot = null;
      _fingerprint = null;
      _identifying = false;
    });
    try {
      final result = await _discovery.scanCurrentNetwork();
      if (!mounted) return;
      setState(() => _snapshot = result);
      if (result.gatewayIp != null) {
        setState(() => _identifying = true);
        try {
          final fingerprint = await _fingerprinter.identify(result.gatewayIp!);
          if (!mounted) return;
          setState(() => _fingerprint = fingerprint);
        } finally {
          if (mounted) setState(() => _identifying = false);
        }
      }
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
            const SizedBox(height: 12),
            const Text('Identificación del router', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_identifying)
              const Card(child: ListTile(leading: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)), title: Text('Revisando la página local del router...')))
            else if (_fingerprint != null) ...[
              Card(child: ListTile(
                leading: const Icon(Icons.router, color: Color(0xFF1769AA)),
                title: Text(_fingerprint!.manufacturer, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_fingerprint!.modelHint ?? _fingerprint!.note),
              )),
              if (_fingerprint!.pageTitle != null)
                _ResultTile(icon: Icons.web, label: 'Título del panel', value: _fingerprint!.pageTitle!),
              if (_fingerprint!.serverHeader != null)
                _ResultTile(icon: Icons.dns, label: 'Servidor HTTP', value: _fingerprint!.serverHeader!),
              _ResultTile(icon: Icons.link, label: 'Dirección revisada', value: _fingerprint!.checkedUrl),
              const Text('La identificación se basa en indicios públicos de la página local; no es una confirmación del modelo y no inicia sesión ni cambia ajustes.', style: TextStyle(color: Colors.black54, fontSize: 12)),
            ] else
              const Card(child: ListTile(title: Text('No se pudo revisar el panel'), subtitle: Text('La puerta de enlace no respondió por HTTP o no se encontró una página accesible.'))),
            const SizedBox(height: 8),
            const Text(
              'La exploración es de solo lectura: no envía contraseñas ni modifica el router.',
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
