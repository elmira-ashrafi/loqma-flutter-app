import 'package:shared_preferences/shared_preferences.dart';

import 'app_constants.dart';

/// API base URL and endpoint constants for Laravel backend.
/// Base URL: /api/v1/
class ApiConstants {
  ApiConstants._();

  /// Dedicated API host. If mobile gets "Checking your browser", disable
  /// Hostinger CDN in hPanel → loqma.af → Performance → CDN (or whitelist /api/*).
  static const String apiOriginPrimary = 'https://loqma.af';

  /// Extra origins only used after a successful connection on another host.
  /// Do not include www — Hostinger hCDN treats it as a separate cookie origin.
  static const List<String> apiOriginFallbacks = <String>[];

  static String _activeOrigin = apiOriginPrimary;

  /// Active API origin (may be restored from a previous successful connection).
  static String get apiOrigin => _activeOrigin;

  static String get baseUrl => '$apiOrigin/api/v1';

  /// All origins to try, active first.
  static List<String> get allApiOrigins => [
        _activeOrigin,
        ...apiOriginFallbacks.where((origin) => origin != _activeOrigin),
      ];

  static Future<void> initActiveOrigin() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.apiActiveOriginKey);
    if (saved != null) {
      final normalized = _normalizeOrigin(saved);
      if (_isAllowedOrigin(normalized)) {
        _activeOrigin = normalized;
        if (normalized != saved) {
          await prefs.setString(AppConstants.apiActiveOriginKey, normalized);
        }
        return;
      }
      await prefs.remove(AppConstants.apiActiveOriginKey);
    }
  }

  static String _normalizeOrigin(String origin) {
    final uri = Uri.tryParse(origin);
    if (uri == null) return origin;
    final host = uri.host.toLowerCase();
    if (host == 'www.loqma.af' || host == 'loqma.af') {
      return apiOriginPrimary;
    }
    return origin;
  }

  static Future<void> setActiveOrigin(String origin) async {
    if (!_isAllowedOrigin(origin)) return;
    _activeOrigin = origin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.apiActiveOriginKey, origin);
  }

  static bool _isAllowedOrigin(String origin) {
    return origin == apiOriginPrimary || apiOriginFallbacks.contains(origin);
  }

  /// Base URL without path for refresh token (same host)
  static String get baseUrlHost {
    final uri = Uri.tryParse(baseUrl);
    if (uri != null) {
      final isDefaultPort =
          (uri.scheme == 'https' && uri.port == 443) ||
          (uri.scheme == 'http' && uri.port == 80);
      return isDefaultPort
          ? '${uri.scheme}://${uri.host}'
          : '${uri.scheme}://${uri.host}:${uri.port}';
    }
    return baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
  }

  /// Public account-deletion page (Google Play Data safety requirement).
  static const String accountDeletionWebUrl = '$apiOriginPrimary/delete-account';

  // Auth (paths relative to baseUrl)
  // If register fails with 404, your backend may use /auth/register — change register to '/auth/register'.
  static const String login = '/login';
  static const String register = '/register';
  static const String registerAlt = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authSendOtp = '/auth/send-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authGoogle = '/auth/google';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authPasswordResetRequest = '/auth/password-reset-request';
  static const String authPasswordResetStatus = '/auth/password-reset-status';
  static const String authCompleteProfile = '/auth/complete-profile';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh';
  static const String me = '/me';

  // Home
  static const String home = '/home';
  static const String banners = '/banners';
  static const String bannersHero = '/banners/hero';

  /// Categories list for home tab (GET /categories).
  static const String categories = '/categories';
  // Restaurants
  static const String restaurants = '/restaurants';

  /// POST body: `{ "text": "..." }` — Google Translate for current `lang` / Accept-Language.
  static const String contentTranslate = '/content/translate';
  static String restaurantById(int id) => '/restaurants/$id';

  /// GET /restaurants/{idOrSlug}/reviews — public paginated customer reviews.
  static String restaurantReviews(String idOrSlug) {
    final encoded = Uri.encodeComponent(idOrSlug.trim());
    return '$restaurants/$encoded/reviews';
  }

  /// Active special-offer menu items (GET /offers).
  static const String offers = '/offers';

  // Foods (optional; if your backend exposes it)
  static const String foods = '/foods';

  // Cart
  static const String cartCalculate = '/cart/calculate';
  static const String cart = '/cart';

  // Checkout
  static const String checkout = '/checkout';

  /// POST same body as v1 checkout — Laravel `POST /api/pay` (auth:sanctum).
  static String get payAbsoluteUrl => '$apiOrigin/api/pay';

  static String paymentCallbackAbsoluteUrl(int orderId, {String? transactionId}) {
    final params = <String, String>{'order_id': '$orderId'};
    if (transactionId != null && transactionId.trim().isNotEmpty) {
      params['transaction_id'] = transactionId.trim();
    }
    return '$apiOrigin/api/payment/callback?${Uri(queryParameters: params).query}';
  }

  /// GET payment status for an order (auth:sanctum).
  static String paymentStatusAbsoluteUrl(int orderId) =>
      '$apiOrigin/api/payment/status/$orderId';

  // Customer
  /// GET customer orders - use 'orders' if Laravel route is Route::get('/orders', ...) under api/v1.
  static const String orders = '/orders';
  static const String customerOrders = '/customer/orders';
  static String customerOrderById(int id) => '/customer/orders/$id';
  static String customerOrderTrack(int id) => '/customer/orders/$id/track';
  static String customerOrderReview(int id) => '/customer/orders/$id/review';
  static String customerOrderCancel(int id) => '/customer/orders/$id/cancel';
  static String customerOrderReorder(int id) => '/customer/orders/$id/reorder';
  static const String customerFavorites = '/customer/favorites';
  static const String customerDashboard = '/customer/dashboard';
  static const String customerFavoritesToggle = '/customer/favorites/toggle';
  static const String customerProfile = '/customer/profile';
  static const String customerProfileUpdate = '/customer/profile';

  /// POST body: `{ "fcm_token": "<device token>" }` — enables push when app is closed (order updates).
  static const String customerFcmToken = '/customer/device/fcm-token';
  static const String customerAddresses = '/customer/addresses';
  static String customerAddressById(int id) => '/customer/addresses/$id';
  static const String customerSettings = '/customer/settings';
  static const String customerSettingsLanguage = '/customer/settings/language';
  static const String customerSettingsPassword = '/customer/settings/password';
  static const String customerSettingsAvatar = '/customer/settings/avatar';
  static const String customerAccountDeletion = '/customer/account-deletion';

  // Notifications (auth:sanctum — same prefix as /api/v1)
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static String notificationById(String id) => '/notifications/$id';

  // Support
  static const String customerTickets = '/customer/tickets';
  static String customerTicketById(int id) => '/customer/tickets/$id';
  static String customerTicketReply(int id) => '/customer/tickets/$id/reply';
  static String customerTicketClose(int id) => '/customer/tickets/$id/close';
  static String customerTicketReopen(int id) => '/customer/tickets/$id/reopen';

  // App update (public)
  static const String appVersion = '/app/version';

  /// Google Maps (public): browser key for web; geocode uses server key on backend.
  static const String mapsConfig = '/maps/config';
  static const String mapsGeocode = '/maps/geocode';
  static const String mapsReverseGeocode = '/maps/reverse-geocode';

  // Settings
  static const String settings = '/settings';

  // Cities
  static const String cities = '/cities';
  static String cityDistricts(int cityId) => '/cities/$cityId/districts';

  // Driver (role: driver)
  static const String driverDashboard = '/driver/dashboard';
  static const String driverToggleOnline = '/driver/toggle-online';
  static const String driverUpdateLocation = '/driver/update-location';
  static const String driverEarnings = '/driver/earnings';
  static const String driverPayoutRequest = '/driver/payout/request';
  static String driverAcceptOrder(int id) => '/driver/orders/$id/accept';
  static String driverOrderStatus(int id) => '/driver/orders/$id/status';
  static const String driverProfile = '/driver/profile';
  static const String driverProfileUpdate = '/driver/profile';
  static const String driverOrders = '/driver/orders';
  static String driverOrderById(int id) => '/driver/orders/$id';
  static const String driverRegister = '/driver/register';
  static const String driverPending = '/driver/pending';

  // Restaurant (role: restaurant_owner)
  static const String restaurantRegister = '/restaurant/register';
  static const String restaurantDashboard = '/restaurant/dashboard';
  static const String restaurantToggleStatus = '/restaurant/toggle-status';
  static const String restaurantOrders = '/restaurant/orders';
  static String restaurantOrderStatus(int id) =>
      '/restaurant/orders/$id/status';
  static const String restaurantSettings = '/restaurant/settings';
  static const String restaurantMenu = '/restaurant/menu';
  static String restaurantMenuItemSpecialOffer(int itemId) =>
      '/restaurant/menu/items/$itemId/special-offer';

  // Admin (role: super_admin|admin)
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';
  static String adminUserById(int id) => '/admin/users/$id';
  static const String adminRestaurants = '/admin/restaurants';
  static String adminRestaurantById(int id) => '/admin/restaurants/$id';
  static const String adminDrivers = '/admin/drivers';
  static String adminDriverById(int id) => '/admin/drivers/$id';
  static const String adminOrders = '/admin/orders';
  static String adminOrderById(int id) => '/admin/orders/$id';
}
