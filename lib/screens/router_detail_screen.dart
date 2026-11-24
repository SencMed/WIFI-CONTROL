import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/router_capability.dart';
import '../models/router_profile.dart';
import '../services/router_registry.dart';

class RouterDetailScreen extends StatelessWidget {
  final RouterProfile profile;
  const RouterDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final adapter = RouterRegistry.adapterFor(profile);
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha del router')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.router, size: 42, color: Color(0xFF1769AA)),
                  const SizedBox(height: 12),
                  Text(profile.manufacturer,
                      style: const TextStyle(color: Colors.black54)),
                  Text(profile.model,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  const Divider(height: 28),
                  _InfoRow('Dirección local', profile.localAddress),
                  _InfoRow('Tipo', profile.connectionType),
                  _InfoRow('Hardware', profile.hardwareVersion.isEmpty
                      ? 'No informado'
                      : profile.hardwareVersion),
                  _InfoRow('Software', profile.softwareVersion.isEmpty
                      ? 'No informado'
                      : profile.softwareVersion),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: profile.localAddress == 'Por detectar' || profile.localAddress.isEmpty
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RouterWebViewScreen(
                            title: '${profile.manufacturer} ${profile.model}',
                            address: profile.localAddress,
                          ),
                        ),
                      ),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Abrir panel del router'),
            ),
          ),
          if (profile.localAddress == 'Por detectar')
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Detectá primero la red para obtener la dirección del KAON.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
          const SizedBox(height: 12),
          Text('Compatibilidad del equipo',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (adapter == null)
            const Card(
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Adaptador no disponible'),
                subtitle: Text('Este modelo aún no tiene un adaptador registrado.'),
              ),
            )
          else
            ...adapter.capabilities.map((capability) =>
                _CapabilityTile(capability: capability)),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.shield_outlined, color: Color(0xFF1769AA)),
              title: Text('Modo seguro'),
              subtitle: Text(
                'Por ahora solo se comprueba la conectividad del panel. '
                'No se envían contraseñas ni se modifican ajustes del router. '
                'Las funciones no verificadas se muestran como manuales.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityTile extends StatelessWidget {
  final RouterCapability capability;
  const _CapabilityTile({required this.capability});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (capability.state) {
      RouterCapabilityState.available =>
        (Icons.check_circle_outline, 'Prueba disponible'),
      RouterCapabilityState.manualOnly =>
        (Icons.touch_app_outlined, 'Consulta manual'),
      RouterCapabilityState.notVerified =>
        (Icons.pending_outlined, 'Pendiente de verificar'),
      RouterCapabilityState.unavailable =>
        (Icons.block_outlined, 'No disponible'),
    };
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1769AA)),
        title: Text(capability.name),
        subtitle: Text('$label · ${capability.explanation}'),
        isThreeLine: true,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 132,
              child: Text(label, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}


class RouterWebViewScreen extends StatefulWidget {
  final String title;
  final String address;
  const RouterWebViewScreen({super.key, required this.title, required this.address});

  @override
  State<RouterWebViewScreen> createState() => _RouterWebViewScreenState();
}

class _RouterWebViewScreenState extends State<RouterWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final rawAddress = widget.address.startsWith('http://') || widget.address.startsWith('https://')
        ? widget.address
        : 'http://${widget.address}';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
        onWebResourceError: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(rawAddress));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
          ),
        ]),
        body: Column(children: [
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: WebViewWidget(controller: _controller)),
        ]),
      );
}
