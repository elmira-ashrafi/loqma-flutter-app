import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../models/ticket_model.dart';
import '../services/ticket_service.dart';
import '../support_l10n.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final int ticketId;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TicketService _service = TicketService();
  TicketModel? _ticket;
  bool _loading = true;
  String? _error;
  final TextEditingController _replyController = TextEditingController();
  bool _sending = false;
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
      color: color ?? Theme.of(context).colorScheme.onSurface,
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
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ticket = await _service.getTicketById(widget.ticketId);
      if (!mounted) return;
      setState(() {
        _ticket = ticket;
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

  Future<void> _sendReply() async {
    final msg = _replyController.text.trim();
    if (msg.isEmpty || msg.length < 5 || _ticket == null || _ticket!.isClosed) return;
    setState(() => _sending = true);
    try {
      await _service.reply(widget.ticketId, msg);
      _replyController.clear();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _closeTicket() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.closeTicketTitle),
        content: Text(l10n.closeTicketMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.ticketCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.closeAction)),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _service.close(widget.ticketId);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ticketClosedSuccess), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _reopenTicket() async {
    try {
      await _service.reopen(widget.ticketId);
      await _load();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.ticketReopenedSuccess), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        title: Text(
          l10n.ticketScreenTitle,
          style: _textStyle(
            l10n.ticketScreenTitle,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : _error != null
              ? Center(
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
                )
              : _ticket == null
                  ? const SizedBox.shrink()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: theme.colorScheme.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(context, _ticket!),
                            const SizedBox(height: 20),
                            _buildMessages(context, _ticket!),
                            if (!_ticket!.isClosed) ...[
                              const SizedBox(height: 20),
                              _buildReplyForm(context),
                            ] else
                              _buildClosedBanner(context),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildHeader(BuildContext context, TicketModel ticket) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statusColor = _statusColor(ticket.status);
    final statusLabel = ticket.statusLabel(l10n);
    final priorityLabel = ticket.priorityLabel(l10n);
    final categoryLabel = ticket.categoryLabel(l10n);
    final createdLabel = SupportL10n.formatTicketDate(context, ticket.createdAt);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ticket.ticketNumber,
                style: _textStyle(
                  ticket.ticketNumber,
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ).copyWith(fontFamily: 'monospace'),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: _textStyle(
                    statusLabel,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              if (!ticket.isClosed)
                TextButton(
                  onPressed: _closeTicket,
                  child: Text(l10n.closeAction),
                )
              else
                TextButton(
                  onPressed: _reopenTicket,
                  child: Text(l10n.reopenAction),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.subject,
            style: _textStyle(
              ticket.subject,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                '🏷️ $categoryLabel',
                style: _textStyle(
                  categoryLabel,
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '⚑ $priorityLabel',
                style: _textStyle(
                  priorityLabel,
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (createdLabel.isNotEmpty)
                Text(
                  '📅 $createdLabel',
                  style: _textStyle(
                    createdLabel,
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (ticket.assignedAgentName != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.ticketAssignedTo(ticket.assignedAgentName!),
              style: _textStyle(
                l10n.ticketAssignedTo(ticket.assignedAgentName!),
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
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

  Widget _buildMessages(BuildContext context, TicketModel ticket) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (ticket.messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Text(
          l10n.ticketMessagesEmptyHint,
          style: _textStyle(
            l10n.ticketMessagesEmptyHint,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: ticket.messages.map((msg) {
        final isStaff = msg.isStaff;
        final senderName = msg.senderName ?? (isStaff ? l10n.support : l10n.ordersTabMapLegendDestination);
        final timeLabel = SupportL10n.formatTicketDate(context, msg.createdAt, includeTime: true);
        final metaLine = timeLabel.isEmpty ? senderName : '$senderName · $timeLabel';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isStaff ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isStaff)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.22),
                  child: Text(
                    senderName.isNotEmpty ? senderName[0].toUpperCase() : 'S',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (isStaff) const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: isStaff ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    Text(
                      metaLine,
                      style: _textStyle(
                        metaLine,
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isStaff
                            ? theme.colorScheme.surfaceContainer
                            : theme.colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isStaff ? 4 : 16),
                          bottomRight: Radius.circular(isStaff ? 16 : 4),
                        ),
                        border: isStaff ? Border.all(color: theme.colorScheme.outlineVariant) : null,
                      ),
                      child: Text(
                        msg.message,
                        style: _textStyle(
                          msg.message,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isStaff) const SizedBox(width: 10),
              if (!isStaff)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReplyForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.ticketReplySectionTitle,
            style: _textStyle(
              l10n.ticketReplySectionTitle,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _replyController,
            maxLines: 4,
            minLines: 3,
            style: _textStyle(_replyController.text),
            decoration: InputDecoration(
              hintText: l10n.ticketReplyHint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _sending ? null : _sendReply,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _sending
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                  )
                : Text(l10n.sendReply),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            l10n.ticketClosedStateMessage,
            style: _textStyle(
              l10n.ticketClosedStateMessage,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _reopenTicket,
            child: Text(l10n.reopenIfPersists),
          ),
        ],
      ),
    );
  }
}
