/// Application-wide constants: storage keys, timeouts, pagination, etc.
class AppConstants {
  AppConstants._();

  // Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String tokenExpiryKey = 'token_expiry';
  static const String userKey = 'user';

  // Preferences keys
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String languageSelectionDoneKey = 'language_selection_done';
  static const String firstDataLoadDoneKey = 'first_data_load_done';
  static const String userRoleKey = 'user_role';
  static const String apiActiveOriginKey = 'api_active_origin';

  /// Minimum splash duration on the very first app data load (ms).
  static const int bootstrapFirstLoadMs = 6000;
  static const String fcmTokenKey = 'fcm_token';
  static const String checkoutSelectedAddressIdKey =
      'checkout_selected_address_id';

  /// Set before opening HesabPay in the browser; cleared after deep link + status poll.
  static const String pendingHesabPayOrderIdKey = 'pending_hesabpay_order_id';

  /// True while the in-app HesabPay WebView checkout is open (skip duplicate deep-link handlers).
  static const String hesabPayInAppFlowKey = 'hesabpay_in_app_flow';

  // Network
  static const int connectTimeout = 60000; // ms
  static const int receiveTimeout = 60000;

  /// CDN browser-check page ("Please wait for up to 5 seconds...") before retry.
  static const int securityChallengeWaitMs = 6000;
  static const int securityChallengeMaxRetries = 3;
  static const int cdnChallengeTimeoutMs = 60000;
  static const String cdnSessionClearedExtraKey = 'cdn_session_cleared';
  static const String cdnOriginProbeExtraKey = 'cdn_origin_probe';
  /// Prevents infinite CDN recovery loops on the same request chain.
  static const String cdnChallengeHandledExtraKey = 'cdn_challenge_handled';

  /// Shorter timeout for non-critical startup checks (version, role probes) in ms.
  static const int startupNetworkTimeoutMs = 10000;
  static const int versionCheckTimeoutMs = 8000;

  // Pagination
  static const int defaultPageSize = 15;
  static const String pageParam = 'page';
  static const String perPageParam = 'per_page';

  // Animation durations
  static const int pageTransitionMs = 300;
  static const int shimmerDurationMs = 1500;

  // Play Store (Play-distributed builds use store updates, not sideloaded APKs).
  static const String androidPackageId = 'delivery.loqma';
  static const String playStoreListingUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';
}
