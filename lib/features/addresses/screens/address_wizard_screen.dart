import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_cart_notice.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

/// Multi-step add-address flow: city → district → street details → save.
class AddressWizardScreen extends StatefulWidget {
  const AddressWizardScreen({
    super.key,
    this.initialName,
    this.initialPhone,
  });

  final String? initialName;
  final String? initialPhone;

  @override
  State<AddressWizardScreen> createState() => _AddressWizardScreenState();
}

class _AddressWizardScreenState extends State<AddressWizardScreen> {
  static const _totalSteps = 3;

  final _service = AddressService();
  final _streetController = TextEditingController();
  final _houseController = TextEditingController();

  int _step = 0;
  List<CityModel> _cities = [];
  bool _loadingCities = true;
  String? _loadError;
  CityModel? _city;
  DistrictModel? _district;
  bool _saving = false;
  String? _streetError;
  String? _houseError;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() {
      _loadingCities = true;
      _loadError = null;
    });
    try {
      final list = await _service.getCities();
      if (!mounted) return;
      setState(() {
        _cities = list;
        _loadingCities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = userFriendlyErrorMessage(e);
        _loadingCities = false;
      });
    }
  }

  void _selectCity(CityModel city) {
    setState(() {
      // Always reload districts from the API for the selected city.
      _city = CityModel(
        id: city.id,
        localized: city.localized,
        provinceName: city.provinceName,
        districts: const [],
      );
      _district = null;
      _step = 1;
    });
  }

  void _selectDistrict(DistrictModel district) {
    setState(() {
      _district = district;
      _step = 2;
    });
  }

  void _goBack() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step -= 1);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final street = _streetController.text.trim();
    final house = _houseController.text.trim();
    setState(() {
      _streetError = street.isEmpty ? l10n.addressStreetRequired : null;
      _houseError = house.isEmpty ? l10n.addressHouseNumberRequired : null;
    });
    if (_streetError != null || _houseError != null || _city == null || _district == null) {
      return;
    }

    final auth = Get.find<AuthController>();
    final user = auth.currentUser;
    final fullName = (widget.initialName ?? user?.name ?? '').trim();
    final phone = (widget.initialPhone ?? user?.phone ?? '').trim();
    if (fullName.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addressProfileNamePhoneRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.createAddress(
        AddressModel(
          id: 0,
          label: 'Home',
          fullName: fullName,
          phone: phone,
          cityId: _city!.id,
          city: _city!.localized,
          area: _district!.name,
          street: street,
          building: house,
          isDefault: true,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppAddressSavedNoticeAfterPop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userFriendlyErrorMessage(e)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _title(AppLocalizations l10n) {
    return switch (_step) {
      0 => l10n.addressChooseCityTitle,
      1 => l10n.addressChooseDistrictTitle,
      _ => l10n.addressStreetDetailsTitle,
    };
  }

  String _subtitle(AppLocalizations l10n) {
    return switch (_step) {
      0 => l10n.addressChooseCitySubtitle,
      1 => l10n.addressChooseDistrictSubtitle(_city?.displayName ?? ''),
      _ => l10n.addressStreetDetailsSubtitle(
          _district?.displayName ?? '',
          _city?.displayName ?? '',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Get.find<LocaleController>().locale.languageCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.addAddress),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: MaxWidthBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.pageHorizontalPadding,
                8,
                context.pageHorizontalPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepProgress(step: _step + 1, total: _totalSteps),
                  const SizedBox(height: 18),
                  Text(
                    _title(l10n),
                    style: FontHelper.getTextStyle(
                      text: _title(l10n),
                      languageCode: lang,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle(l10n),
                    style: FontHelper.getTextStyle(
                      text: _subtitle(l10n),
                      languageCode: lang,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStepBody(l10n, theme, lang),
                ),
              ),
            ),
            if (_step == 2)
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    8,
                    context.pageHorizontalPadding,
                    16,
                  ),
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF006241),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.saveAddressButton,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepBody(
    AppLocalizations l10n,
    ThemeData theme,
    String lang,
  ) {
    if (_step == 0) {
      if (_loadingCities) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_loadError != null) {
        return _ErrorState(
          message: _loadError!,
          onRetry: _loadCities,
          retryLabel: l10n.retry,
        );
      }
      if (_cities.isEmpty) {
        return Center(child: Text(l10n.addressNoCitiesAvailable));
      }
      return ListView.separated(
        padding: EdgeInsets.fromLTRB(
          context.pageHorizontalPadding,
          0,
          context.pageHorizontalPadding,
          24,
        ),
        itemCount: _cities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final city = _cities[index];
          return _SelectionTile(
            title: city.displayName,
            subtitle: city.provinceName,
            icon: Icons.location_city_rounded,
            selected: _city?.id == city.id,
            onTap: () => _selectCity(city),
            languageCode: lang,
          );
        },
      );
    }

    if (_step == 1) {
      final districts = _city?.districts ?? const <DistrictModel>[];
      if (districts.isEmpty) {
        return _DistrictLoader(
          cityId: _city!.id,
          service: _service,
          onLoaded: (list) {
            setState(() {
              _city = CityModel(
                id: _city!.id,
                localized: _city!.localized,
                provinceName: _city!.provinceName,
                districts: list,
              );
            });
          },
          builder: (list) {
            if (list.isEmpty) {
              return Center(child: Text(l10n.addressNoDistrictsAvailable));
            }
            return _districtList(list, lang);
          },
        );
      }
      return _districtList(districts, lang);
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.pageHorizontalPadding,
        0,
        context.pageHorizontalPadding,
        24,
      ),
      children: [
        TextField(
          controller: _streetController,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.addressStreetNameLabel,
            hintText: l10n.addressStreetNameHint,
            errorText: _streetError,
            prefixIcon: const Icon(Icons.signpost_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) {
            if (_streetError != null) setState(() => _streetError = null);
          },
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _houseController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.addressHouseNumberLabel,
            hintText: l10n.addressHouseNumberHint,
            errorText: _houseError,
            prefixIcon: const Icon(Icons.home_work_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (_) {
            if (_houseError != null) setState(() => _houseError = null);
          },
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF006241).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF006241).withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.place_rounded, color: Color(0xFF006241)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  [
                    if (_district != null) _district!.displayName,
                    if (_city != null) _city!.displayName,
                  ].join(' · '),
                  style: FontHelper.getTextStyle(
                    text: _city?.displayName ?? '',
                    languageCode: lang,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _districtList(List<DistrictModel> districts, String lang) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.pageHorizontalPadding,
        0,
        context.pageHorizontalPadding,
        24,
      ),
      itemCount: districts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final district = districts[index];
        return _SelectionTile(
          title: district.displayName,
          icon: Icons.map_outlined,
          selected: _district?.id == district.id,
          onTap: () => _selectDistrict(district),
          languageCode: lang,
        );
      },
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1) const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              decoration: BoxDecoration(
                color: i <= step
                    ? const Color(0xFF006241)
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.languageCode,
    this.subtitle,
    this.selected = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String languageCode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = const Color(0xFF006241);
    return Material(
      color: selected
          ? primary.withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FontHelper.getTextStyle(
                        text: title,
                        languageCode: languageCode,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: FontHelper.getTextStyle(
                          text: subtitle!,
                          languageCode: languageCode,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected ? primary : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class _DistrictLoader extends StatefulWidget {
  const _DistrictLoader({
    required this.cityId,
    required this.service,
    required this.onLoaded,
    required this.builder,
  });

  final int cityId;
  final AddressService service;
  final ValueChanged<List<DistrictModel>> onLoaded;
  final Widget Function(List<DistrictModel> list) builder;

  @override
  State<_DistrictLoader> createState() => _DistrictLoaderState();
}

class _DistrictLoaderState extends State<_DistrictLoader> {
  bool _loading = true;
  String? _error;
  List<DistrictModel> _list = const [];

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
      final list = await widget.service.getDistricts(widget.cityId);
      if (!mounted) return;
      setState(() {
        _list = list;
        _loading = false;
      });
      widget.onLoaded(list);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFriendlyErrorMessage(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _ErrorState(
        message: _error!,
        onRetry: _load,
        retryLabel: AppLocalizations.of(context)!.retry,
      );
    }
    return widget.builder(_list);
  }
}
