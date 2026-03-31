import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o App')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Center(child: AppLogo(size: 72)),
          const SizedBox(height: 12),
          Text(
            'Choperia 820',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cardapio Digital',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Objetivo',
            color: colorScheme.primary,
            child: const Text(
              'Aplicativo de cardapio digital da Choperia 820 para oferecer '
              'uma experiencia rapida, moderna e intuitiva no pedido de porcoes.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 10),
          _InfoCard(
            icon: Icons.people_outline_rounded,
            title: 'Integrantes',
            color: colorScheme.primary,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _MemberTile(name: 'Nome 1'),
                _MemberTile(name: 'Nome 2'),
                _MemberTile(name: 'Nome 3'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _InfoCard(
            icon: Icons.school_outlined,
            title: 'Disciplina',
            color: colorScheme.primary,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _DetailRow(label: 'Disciplina', value: 'Projeto de Desenvolvimento Mobile'),
                _DetailRow(label: 'Professor(a)', value: '____________________'),
                _DetailRow(label: 'Semestre', value: '________________________'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _InfoCard(
            icon: Icons.code_rounded,
            title: 'Tecnologias',
            color: colorScheme.primary,
            child: const Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                _TechChip(label: 'Flutter'),
                _TechChip(label: 'Dart'),
                _TechChip(label: 'Provider'),
                _TechChip(label: 'Material 3'),
                _TechChip(label: 'Google Fonts'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          const Icon(Icons.person_outline_rounded, size: 16),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}
