/// Google Sign-In configuration for Android / iOS.
///
/// Requirements in Firebase / Google Cloud (same project as google-services.json):
/// 1. Android app package `delivery.loqma` with Play + debug SHA-1 / SHA-256
/// 2. Google Sign-In enabled (Authentication → Sign-in method)
/// 3. A **Web** OAuth client ID used as [webClientId] (serverClientId)
/// 4. Fresh `android/app/google-services.json` where `oauth_client` is not empty
///
/// Without [webClientId], Android often returns a null `idToken`.
abstract final class GoogleAuthConfig {
  GoogleAuthConfig._();

  /// OAuth client ID used as GoogleSignIn `serverClientId`.
  /// Must be a **Web application** client from Firebase project `loqma-app`
  /// (same project as `android/app/google-services.json`).
  ///
  /// Set via `--dart-define=GOOGLE_WEB_CLIENT_ID=...` or replace [defaultValue]
  /// after creating the Web client in Firebase → Authentication → Google.
  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static bool get hasWebClientId => webClientId.trim().isNotEmpty;
}
