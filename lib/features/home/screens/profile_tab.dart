import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/phone_display.dart';
import '../../../core/widgets/app_button.dart';
import '../../addresses/screens/addresses_screen.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../customer/screens/customer_dashboard_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../orders/screens/order_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../l10n/app_localizations.dart';

/// Profile tab: user info and shortcuts to account screens.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static bool _compact(BuildContext context) => MediaQuery.sizeOf(context).width < 400;
  static bool _narrow(BuildContext context) => MediaQuery.sizeOf(context).width < 360;

  static double _listBottomPad(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + (_compact(context) ? 88.0 : 100.0);

  TextStyle _style(
    String text,
    String languageCode, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return FontHelper.getTextStyle(
      text: text,
      languageCode: languageCode,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = Get.find<AuthController>();
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final hPad = context.pageHorizontalPadding;
    final compact = _compact(context);
    final narrow = _narrow(context);

    return Obx(() {
      final user = auth.currentUser;
      if (user == null) {
        final emptyIcon = narrow ? 52.0 : (compact ? 58.0 : 64.0);
        final signInMessage = l10n.signInToViewProfile;
        return Scaffold(
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: emptyIcon,
                        color: cs.onSurfaceVariant,
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        signInMessage,
                        style: _style(
                          signInMessage,
                          languageCode,
                          fontSize: compact ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: compact ? 20 : 24),
                      AppButton(
                        label: l10n.signIn,
                        onPressed: () => Get.offAllNamed('/login'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final tileDensity = compact ? VisualDensity.compact : VisualDensity.standard;
      final avatarR = narrow ? 20.0 : (compact ? 22.0 : 24.0);
      final phoneShown = displayAfghanLocalPhone(user.phone);
      final editHint = l10n.profileTabEditHint;
      final titleStyle = _style(
        l10n.profileTitle,
        languageCode,
        fontSize: compact ? 17 : 18,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      );

      Widget menuTile({
        required IconData icon,
        required String label,
        required String semanticsLabel,
        required VoidCallback onTap,
        Color? iconColor,
        Color? labelColor,
        FontWeight labelWeight = FontWeight.normal,
      }) {
        return Semantics(
          label: semanticsLabel,
          button: true,
          child: ListTile(
            leading: Icon(icon, size: compact ? 22 : 24, color: iconColor),
            title: Text(
              label,
              style: _style(
                label,
                languageCode,
                fontSize: compact ? 15 : 16,
                fontWeight: labelWeight,
                color: labelColor ?? cs.onSurface,
              ),
            ),
            onTap: onTap,
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              l10n.profileTitle,
              maxLines: 1,
              style: titleStyle,
            ),
          ),
        ),
        body: MaxWidthBody(
          alignment: AlignmentDirectional.topStart,
          child: Theme(
            data: theme.copyWith(
              listTileTheme: ListTileThemeData(visualDensity: tileDensity),
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, _listBottomPad(context)),
              children: [
                Semantics(
                  label: l10n.profileTabOpenAccount,
                  button: true,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: compact ? 4 : 8,
                      vertical: compact ? 4 : 0,
                    ),
                    leading: CircleAvatar(
                      radius: avatarR,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: user.avatar != null && user.avatar!.isNotEmpty
                          ? null
                          : Icon(
                              Icons.person_rounded,
                              color: AppColors.primary,
                              size: compact ? 22 : 24,
                            ),
                    ),
                    title: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _style(
                        user.name,
                        languageCode,
                        fontSize: compact ? 16 : 17,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    subtitle: phoneShown.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.email,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _style(
                                  user.email,
                                  languageCode,
                                  fontSize: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                editHint,
                                style: _style(
                                  editHint,
                                  languageCode,
                                  fontSize: 12,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.email,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: _style(
                                  user.email,
                                  languageCode,
                                  fontSize: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  phoneShown,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _style(
                                    phoneShown,
                                    languageCode,
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                editHint,
                                style: _style(
                                  editHint,
                                  languageCode,
                                  fontSize: 12,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    ),
                  ),
                ),
                const Divider(),
                menuTile(
                  icon: Icons.dashboard_rounded,
                  label: l10n.dashboard,
                  semanticsLabel: l10n.profileTabNavDashboard,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()),
                  ),
                ),
                menuTile(
                  icon: Icons.receipt_long_rounded,
                  label: l10n.orders,
                  semanticsLabel: l10n.profileTabNavOrders,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const OrderListScreen()),
                  ),
                ),
                menuTile(
                  icon: Icons.location_on_rounded,
                  label: l10n.addresses,
                  semanticsLabel: l10n.profileTabNavAddresses,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddressesScreen()),
                  ),
                ),
                menuTile(
                  icon: Icons.favorite_rounded,
                  label: l10n.favorites,
                  semanticsLabel: l10n.profileTabNavFavorites,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  ),
                ),
                menuTile(
                  icon: Icons.notifications_rounded,
                  label: l10n.notifications,
                  semanticsLabel: l10n.profileTabNavNotifications,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  ),
                ),
                menuTile(
                  icon: Icons.settings_rounded,
                  label: l10n.settings,
                  semanticsLabel: l10n.profileTabNavSettings,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  ),
                ),
                const Divider(),
                menuTile(
                  icon: Icons.logout_rounded,
                  label: l10n.logout,
                  semanticsLabel: l10n.profileTabNavLogout,
                  iconColor: AppColors.error,
                  labelColor: AppColors.error,
                  labelWeight: FontWeight.w600,
                  onTap: () async {
                    await auth.logout();
                    Get.offAllNamed('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
