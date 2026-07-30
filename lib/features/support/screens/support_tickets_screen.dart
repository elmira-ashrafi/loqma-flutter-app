import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/localized_number.dart';
import '../models/ticket_model.dart';
import '../services/ticket_service.dart';
import '../support_l10n.dart';
import 'ticket_create_screen.dart';
import 'ticket_detail_screen.dart';
import '../../../l10n/app_localizations.dart';

/// Support tickets list with stats and status filters (parity with web).
class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final TicketService _service = TicketService();
  List<TicketModel> _tickets = [];
  int _openCount = 0;
  int _resolvedCount = 0;
  String? _statusFilter;
  bool _loading = true;
  String? _error;
  Worker? _localeWorker;

  String get _languageCode => Get.find<LocaleController>().locale.languageCode;

  TextStyle _textStyle(
    String text, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return FontHelper.getTextStyle(
      text: text,
      languageCode: _languageCode,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black,
    );
  }

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<LocaleController>()) {
      _localeWorker = ever(Get.find<LocaleController>().localeRx, (_) {
        if (mounted) setState(() {});
      });
    }
    _load();
  }

  @override
  void dispose() {
    _localeWorker?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.getTickets(status: _statusFilter);
      if (!mounted) return;
      setState(() {
        _tickets = result['items'] as List<TicketModel>;
        _openCount = result['open'] as int;
        _resolvedCount = result['resolved'] as int;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = userFriendlyErrorMessage(e);
          _loading = false;
        });
      }
    }
  }

  void _setFilter(String? status) {
    setState(() => _statusFilter = status);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final filterLabels = SupportL10n.statusFilterLabels(l10n);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.supportTickets,
          style: _textStyle(
            l10n.supportTickets,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TicketCreateScreen()),
              );
              _load();
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              l10n.newTicket,
              style: _textStyle(
                l10n.newTicket,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  l10n.supportTrackManage,
                  style: _textStyle(
                    l10n.supportTrackManage,
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        count: formatAppInteger(context, _openCount),
                        label: l10n.ticketStatusOpen,
                        color: theme.colorScheme.primary,
                        textStyle: _textStyle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatChip(
                        count: formatAppInteger(context, _resolvedCount),
                        label: l10n.ticketStatusResolved,
                        color: AppColors.success,
                        textStyle: _textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: SupportL10n.statusFilterKeys.length,
                  itemBuilder: (context, i) {
                    final selected = _statusFilter == SupportL10n.statusFilterKeys[i];
                    final label = filterLabels[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          label,
                          style: _textStyle(
                            label,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) => _setFilter(SupportL10n.statusFilterKeys[i]),
                        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (_loading)
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: _textStyle(
                            _error!,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_tickets.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎫', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(
                          l10n.supportNoTicketsTitle,
                          style: _textStyle(
                            l10n.supportNoTicketsTitle,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.supportNoTicketsSubtitle,
                          style: _textStyle(
                            l10n.supportNoTicketsSubtitle,
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TicketCreateScreen()),
                            );
                            _load();
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: Text(l10n.newTicket),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final ticket = _tickets[i];
                      return _TicketTile(
                        ticket: ticket,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TicketDetailScreen(ticketId: ticket.id),
                            ),
                          );
                          _load();
                        },
                      );
                    },
                    childCount: _tickets.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.count,
    required this.label,
    required this.color,
    required this.textStyle,
  });

  final String count;
  final String label;
  final Color color;
  final TextStyle Function(
    String text, {
    double fontSize,
    FontWeight fontWeight,
    Color? color,
  }) textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: textStyle(
              count,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textStyle(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket, required this.onTap});

  final TicketModel ticket;
  final VoidCallback onTap;

  static Color _statusColor(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case 'open':
        return cs.primary;
      case 'in_progress':
        return AppColors.warning;
      case 'waiting_response':
        return cs.tertiary;
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return cs.onSurfaceVariant;
      default:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final theme = Theme.of(context);
    final statusLabel = ticket.statusLabel(l10n);
    final dateLabel = SupportL10n.formatTicketDate(context, ticket.createdAt);
    final replyLabel = SupportL10n.replyCountLabel(context, l10n, ticket);
    final categoryLabel = ticket.categoryLabel(l10n);

    TextStyle tileStyle(
      String text, {
      double fontSize = 14,
      FontWeight fontWeight = FontWeight.normal,
      Color? color,
    }) {
      return FontHelper.getTextStyle(
        text: text,
        languageCode: languageCode,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? theme.colorScheme.onSurface,
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ticket.ticketNumber,
                    style: tileStyle(
                      ticket.ticketNumber,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ).copyWith(fontFamily: 'monospace'),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(context, ticket.status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: tileStyle(
                        statusLabel,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(context, ticket.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.subject,
                style: tileStyle(
                  ticket.subject,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    categoryLabel,
                    style: tileStyle(
                      categoryLabel,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    replyLabel,
                    style: tileStyle(
                      replyLabel,
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (dateLabel.isNotEmpty)
                    Text(
                      dateLabel,
                      style: tileStyle(
                        dateLabel,
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 20, color: theme.colorScheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
