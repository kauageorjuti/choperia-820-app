import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Horário de funcionamento da Choperia 820.
/// Edite aqui para atualizar os horários no app.
const List<_DayHours> _schedule = <_DayHours>[
  _DayHours(day: 'Segunda-feira',    open: '17:00', close: '23:00'),
  _DayHours(day: 'Terça-feira',      open: '17:00', close: '23:00'),
  _DayHours(day: 'Quarta-feira',     open: '17:00', close: '23:00'),
  _DayHours(day: 'Quinta-feira',     open: '17:00', close: '23:00'),
  _DayHours(day: 'Sexta-feira',      open: '17:00', close: '00:30'),
  _DayHours(day: 'Sábado',           open: '10:00', close: '00:30'),
  _DayHours(day: 'Domingo',          open: '10:00', close: '00:00'),
];

class StoreInfoPage extends StatelessWidget {
  const StoreInfoPage({super.key});

  /// Retorna o status atual da loja: 'open', 'closed' ou 'closing_soon'.
  static StoreStatus currentStatus() {
    final DateTime now = DateTime.now();
    final int weekday = now.weekday; // 1=seg … 7=dom
    final _DayHours hours = _schedule[weekday - 1];

    final TimeOfDay current = TimeOfDay(hour: now.hour, minute: now.minute);
    final TimeOfDay open  = _parseTime(hours.open);
    final TimeOfDay close = _parseTime(hours.close);

    final int currentMins = current.hour * 60 + current.minute;
    final int openMins    = open.hour  * 60 + open.minute;
    int closeMins = close.hour * 60 + close.minute;

    // Horário de fechamento passando meia-noite (ex: 01:00)
    if (closeMins < openMins) closeMins += 24 * 60;
    int adjCurrent = currentMins;
    if (closeMins > 24 * 60 && currentMins < openMins) {
      adjCurrent += 24 * 60;
    }

    if (adjCurrent < openMins || adjCurrent >= closeMins) {
      return StoreStatus.closed;
    }
    if (adjCurrent >= closeMins - 30) return StoreStatus.closingSoon;
    return StoreStatus.open;
  }

  static TimeOfDay _parseTime(String hhmm) {
    final List<String> parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final StoreStatus status = currentStatus();

    return Scaffold(
      appBar: AppBar(title: const Text('Informações')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: <Widget>[
          // ── Status atual ─────────────────────────────────
          _SectionTitle(label: 'Status'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: status.color,
                  ),
                ),
              ],
            ),
          ),
          const _Divider(),

          // ── Endereço ─────────────────────────────────────
          _SectionTitle(label: 'Endereço'),
          const _InfoRow(
            icon: Icons.location_on_outlined,
            text: 'Rua Hum, 820 — Centro\nOrlândia/SP',
          ),
          const _Divider(),

          // ── Contato ──────────────────────────────────────
          _SectionTitle(label: 'Contato'),
          _InfoRow(
            icon: Icons.phone_outlined,
            text: '(16) 99987-2820',
            isLink: true,
            onTap: () async {
              final Uri url = Uri.parse('https://wa.me/5516999872820');
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          _InfoRow(
            icon: Icons.email_outlined,
            text: 'contato@choperia820.com.br',
            isLink: true,
            onTap: () async {
              final Uri url = Uri.parse('mailto:contato@choperia820.com.br');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
          ),
          const _Divider(),

          // ── Horário de funcionamento ─────────────────────
          _SectionTitle(label: 'Horário de Funcionamento'),
          ..._schedule.asMap().entries.map((_DayEntry entry) {
            final bool isToday = entry.key + 1 == DateTime.now().weekday;
            return _HourRow(hours: entry.value, isToday: isToday);
          }),
          const _Divider(),

          // ── Formas de pagamento ───────────────────────────
          _SectionTitle(label: 'Formas de Pagamento'),
          const _InfoRow(
            icon: Icons.credit_card_outlined,
            text: 'Crédito, Débito, Pix, Dinheiro',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widgets internos
// ────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.onTap, this.isLink = false});
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool isLink;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14, 
                height: 1.45,
                color: isLink ? Theme.of(context).colorScheme.primary : null,
                decoration: isLink ? TextDecoration.underline : null,
                decorationColor: isLink ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({required this.hours, required this.isToday});
  final _DayHours hours;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 130,
            child: Text(
              hours.day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday ? cs.primary : cs.onSurface,
              ),
            ),
          ),
          Text(
            '${hours.open} – ${hours.close}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              color: isToday ? cs.primary : cs.onSurface,
            ),
          ),
          if (isToday) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Hoje',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Modelos de dados internos
// ────────────────────────────────────────────────────────────────────────────

typedef _DayEntry = MapEntry<int, _DayHours>;

class _DayHours {
  const _DayHours({
    required this.day,
    required this.open,
    required this.close,
  });

  final String day;
  final String open;
  final String close;
}

enum StoreStatus {
  open(label: 'Loja Aberta', color: Color(0xFF479F76)),
  closingSoon(label: 'Fechando em breve', color: Color(0xFFFFC107)),
  closed(label: 'Loja Fechada', color: Color(0xFFDC3545));

  const StoreStatus({required this.label, required this.color});

  final String label;
  final Color color;
}
