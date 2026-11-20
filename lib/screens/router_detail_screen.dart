import 'package:flutter/material.dart';
import '../models/router_profile.dart';

class RouterDetailScreen extends StatelessWidget {
  final RouterProfile profile;
  const RouterDetailScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha del router')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.router, size: 42, color: Color(0xFF1769AA)),
                const SizedBox(height: 12),
                Text(profile.manufacturer, style: const TextStyle(color: Colors.black54)),
                Text(profile.model, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(height: 28),
                _InfoRow('Dirección local', profile.localAddress),
                _InfoRow('Tipo', profile.connectionType),
                _InfoRow('Hardware', profile.hardwareVersion.isEmpty ? 'No informado' : profile.hardwareVersion),
                _InfoRow('Software', profile.softwareVersion.isEmpty ? 'No informado' : profile.softwareVersion),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          const Card(child: ListTile(
            leading: Icon(Icons.info_outline, color: Color(0xFF1769AA)),
            title: Text('Perfil documentado'),
            subtitle: Text('Este equipo está registrado como referencia. La lectura automática y el control todavía deben implementarse y probarse.'),
          )),
        ],
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
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 132, child: Text(label, style: const TextStyle(color: Colors.black54))),
      Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
    ]),
  );
}
