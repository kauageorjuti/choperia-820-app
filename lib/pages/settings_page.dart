import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_uploader.dart';
import '../utils/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppSettingsProvider settings = context.watch<AppSettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Aparência',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Tema',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_outlined),
                        label: Text('Claro'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_outlined),
                        label: Text('Escuro'),
                      ),
                    ],
                    selected: <ThemeMode>{settings.themeMode},
                    onSelectionChanged: (Set<ThemeMode> selected) {
                      settings.setThemeMode(selected.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Conta',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Consumer<AuthProvider>(
                    builder: (_, AuthProvider auth, _) {
                      if (auth.isAuthenticated) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Logado como: ${auth.currentUser?.name ?? "Cliente"}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            if (auth.currentUser?.email != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                auth.currentUser!.email,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                            const SizedBox(height: 14),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Você saiu da sua conta com sucesso.')),
                      );
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (Route<dynamic> _) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sair da Conta'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Manutenção (Admin)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enviando dados para o Firebase...')),
                        );
                        await FirestoreUploader.uploadMockData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Upload concluído com sucesso!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro no upload: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text('Popular Firebase com Dados Iniciais'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
