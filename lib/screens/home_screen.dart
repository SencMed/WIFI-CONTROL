import 'package:flutter/material.dart';
import '../services/router_registry.dart';
import 'router_detail_screen.dart';
import 'network_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const modules = <_ModuleInfo>[
    _ModuleInfo(Icons.radar, 'Conexión', 'Detección automática y manual'),
    _ModuleInfo(Icons.devices_outlined, 'Dispositivos', 'Equipos conectados a la red'),
    _ModuleInfo(Icons.wifi, 'Wi-Fi', 'Bandas, redes y seguridad'),
    _ModuleInfo(Icons.speed, 'Velocidad', 'Pruebas y diagnóstico'),
    _ModuleInfo(Icons.shield_outlined, 'Seguridad', 'Acceso y registros'),
    _ModuleInfo(Icons.monitor_heart_outlined, 'Diagnóstico', 'Estado y mantenimiento'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WIFI CONTROL', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        actions: const [Padding(padding: EdgeInsets.only(right: 18), child: Icon(Icons.wifi, color: Color(0xFF1769AA)))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF155A96), Color(0xFF2787C8)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.router, color: Colors.white, size: 34),
                SizedBox(height: 12),
                Text('Tu red, bajo control', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('Administración multimarca de routers compatibles', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Routers de prueba', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...RouterRegistry.supportedProfiles.map((profile) => Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              leading: const CircleAvatar(backgroundColor: Color(0xFFE7F1FA), child: Icon(Icons.router, color: Color(0xFF1769AA))),
              title: Text('${profile.manufacturer} ${profile.model}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(profile.localAddress),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RouterDetailScreen(profile: profile))),
            ),
          )),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NetworkScanScreen())),
            icon: const Icon(Icons.radar),
            label: const Text('Detectar mi red'),
          ),
          const SizedBox(height: 16),
          const Text('Módulos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.12,
            ),
            itemBuilder: (context, index) {
              final item = modules[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: const Color(0xFF1769AA), size: 30),
                      const SizedBox(height: 12),
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(item.subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          const Text('Versión inicial 0.1.0 · Integraciones reales pendientes de implementación y pruebas.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ModuleInfo {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ModuleInfo(this.icon, this.title, this.subtitle);
}
