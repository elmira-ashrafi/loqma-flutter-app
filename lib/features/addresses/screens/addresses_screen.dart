import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/widgets/app_cart_notice.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import 'address_form_screen.dart';
import 'address_wizard_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/widgets/loading_shimmer.dart';

/// Address list with add/edit/delete (parity with web customer addresses).
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final AddressService _service = AddressService();
  List<AddressModel> _addresses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = list;
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

  Future<void> _confirmDelete(BuildContext context, AddressModel address) async {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(this.context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteAddressTitle),
        content: Text(loc.deleteAddressMessage(address.label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.ticketCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.deleteAction),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await _service.deleteAddress(address.id);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      showAppAddressRemovedNotice(context);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(userFriendlyErrorMessage(e)),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = Get.find<AuthController>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.addresses),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => AddressWizardScreen(
                    initialName: user?.name,
                    initialPhone: user?.phone,
                  ),
                ),
              );
              if (result == true) _load();
            },
            icon: Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.addAddress),
          ),
        ],
      ),
      body: MaxWidthBody(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: _loading
            ? AddressListSkeleton(
                padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 8, context.pageHorizontalPadding, 24),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _load,
                            icon: Icon(Icons.refresh_rounded),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  )
                : _addresses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noSavedAddresses,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.addAddressHint,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              FilledButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => AddressWizardScreen(
                                        initialName: user?.name,
                                        initialPhone: user?.phone,
                                      ),
                                    ),
                                  );
                                  if (result == true) _load();
                                },
                                icon: Icon(Icons.add_rounded),
                                label: Text(l10n.addAddress),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 8, context.pageHorizontalPadding, 24),
                        itemCount: _addresses.length,
                        itemBuilder: (context, i) {
                          final address = _addresses[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _iconForLabel(address.label),
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  address.label.isNotEmpty
                                                      ? address.label[0].toUpperCase() +
                                                            address.label.substring(1).toLowerCase()
                                                      : 'Address',
                                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w700,
                                                        color: Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                ),
                                                if (address.isDefault) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.success.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      'Default',
                                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                            fontWeight: FontWeight.w600,
                                                            color: AppColors.success,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address.fullName,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                            ),
                                            Text(
                                              address.phone,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address.displayAddress,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (address.deliveryInstructions != null &&
                                                address.deliveryInstructions!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '💬 ${address.deliveryInstructions!}',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert_rounded),
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            final result = await Navigator.of(context).push<bool>(
                                              MaterialPageRoute(
                                                builder: (_) => AddressFormScreen(address: address),
                                              ),
                                            );
                                            if (result == true) _load();
                                          } else if (value == 'delete') {
                                            _confirmDelete(context, address);
                                          }
                                        },
                                        itemBuilder: (ctx) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text(AppLocalizations.of(ctx)!.editAction),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(AppLocalizations.of(ctx)!.deleteAction),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
        ),
      ),
    );
  }

  IconData _iconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}
