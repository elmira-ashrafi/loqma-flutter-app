# Loqma — Food Delivery Mobile App

[![Tests](https://github.com/elmira-ashrafi/loqma-flutter-app/actions/workflows/tests.yml/badge.svg)](https://github.com/elmira-ashrafi/loqma-flutter-app/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A production-grade **Flutter** customer and operations app for a multi-role food delivery platform. Loqma connects diners, restaurant owners, drivers, and administrators to a **Laravel REST API**, delivering an end-to-end experience comparable to Uber Eats or FoodPanda — with first-class support for **English, Dari (fa), and Pashto (ps)**.

Built as a real-world mobile product with JWT authentication, push notifications, maps-based delivery, in-app payments, and role-based dashboards.

---

## Project overview

Loqma is the mobile front-end for a full-stack food delivery ecosystem. Customers browse restaurants, customize menu items, manage delivery addresses on a map, pay through integrated gateways, and track orders in real time. Beyond the customer flow, the same codebase ships dedicated experiences for **drivers**, **restaurant owners**, and **admins** — all routed by authenticated user role after login.

The app targets **Android and iOS** (with web and desktop scaffold support) and is designed to run against a Laravel backend exposing a versioned `/api/v1` REST surface.

---

## Main features

### Customer experience
- **Onboarding & auth** — Email/password, OTP phone verification, Google Sign-In, password reset, and profile completion
- **Home feed** — Hero banners, categories, featured and nearby restaurants with pull-to-refresh and shimmer loading
- **Restaurant discovery** — Search, sort, restaurant detail pages with reviews, and rich menu browsing
- **Menu customization** — Variant groups (sizes), add-ons, and special offers with live price calculation
- **Cart & checkout** — In-memory cart synced with `/cart/calculate`, address wizard with map pin, and HesabPay payment WebView
- **Orders** — Order history, live tracking, cancellation, reorder, and post-delivery reviews
- **Favorites** — Toggle and browse saved restaurants
- **Addresses** — Multi-step address wizard with reverse geocoding and city/district selection
- **Notifications** — In-app notification center with Firebase Cloud Messaging for background push
- **Support** — Create and manage support tickets with threaded replies
- **Settings** — Dark/light theme, language switcher, password change, avatar upload, and account deletion

### Multi-role dashboards
- **Driver** — Online toggle, order acceptance, location updates, earnings, and payout requests
- **Restaurant owner** — Dashboard, order management, menu editing, and special-offer controls
- **Admin** — User, restaurant, driver, and order management panels

### Platform capabilities
- **Trilingual UI** — English, Dari, and Pashto with RTL layout support
- **Material 3 theming** — Adaptive light/dark themes with Google Fonts
- **Maps** — Google Maps integration for address selection and delivery tracking
- **In-app updates** — Google Play immediate updates with API semver fallback
- **CDN resilience** — Cookie bridging, origin fallback, and edge-security challenge handling
- **Connectivity awareness** — Graceful offline and retry behavior

---

## Technologies and frameworks

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3+ / Dart 3.8+ |
| State management | [GetX](https://pub.dev/packages/get) |
| HTTP client | [Dio](https://pub.dev/packages/dio) with interceptors |
| Secure storage | [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) |
| Push notifications | Firebase Core & Messaging |
| Maps & location | google_maps_flutter, geolocator, geocoding |
| Localization | flutter_localizations + ARB files |
| UI | Material 3, shimmer, Lottie, cached_network_image |
| Auth | JWT (Sanctum), Google Sign-In, SMS OTP autofill |
| Backend (external) | Laravel REST API (`/api/v1`) |

---

## Architecture and project structure

The codebase follows **feature-based clean architecture** with shared infrastructure in `core/`:

```
lib/
├── core/                         # Shared infrastructure
│   ├── constants/                # API endpoints, app config
│   ├── controllers/              # Theme, locale controllers
│   ├── di/                       # GetX dependency injection
│   ├── l10n/                     # Localized content helpers
│   ├── layout/                   # Responsive layout utilities
│   ├── maps/                     # Maps loader, geocoding, markers
│   ├── network/                  # ApiClient, interceptors, CDN bridge
│   ├── routes/                   # GetX route definitions
│   ├── screens/                  # Bootstrap, language selection
│   ├── services/                 # In-app update, locale sync
│   ├── theme/                    # AppTheme, AppColors
│   ├── utils/                    # Extensions, error parser, formatting
│   └── widgets/                  # Reusable UI components
├── features/
│   ├── auth/                     # Login, register, OTP, Google auth
│   ├── home/                     # Main shell, home tab, profile tab
│   ├── restaurants/              # List, detail, menu models
│   ├── cart/                     # Cart controller and screen
│   ├── checkout/                 # Checkout flow, HesabPay WebView
│   ├── orders/                   # Order list, tracking, reviews
│   ├── addresses/                # Address wizard, delivery location
│   ├── favorites/                # Saved restaurants
│   ├── notifications/            # FCM, push service, alerts
│   ├── offers/                   # Deals and promotions
│   ├── settings/                 # Theme, language, account deletion
│   ├── support/                  # Support tickets
│   ├── app_update/               # Version check, update dialog
│   ├── driver/                   # Driver dashboard
│   ├── restaurant_owner/         # Restaurant owner dashboard
│   └── admin/                    # Admin panel
├── l10n/                         # ARB localization files
└── main.dart                     # App entry point
```

### Key design patterns

- **GetX bindings** — Controllers and services registered in `app_bindings.dart`
- **Interceptor pipeline** — Auth (JWT refresh), locale headers, CDN cookies, and fallback origins
- **Session guard** — Automatic logout and redirect on 401 after refresh failure
- **Localized API content** — `Accept-Language` / `X-App-Locale` headers on every request; server-side or client-side field resolution

---

## Installation and setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.8 or later
- Android Studio / Xcode for platform builds
- A running **Laravel backend** with the Loqma API (or your own compatible API)

### 1. Clone the repository

```bash
git clone https://github.com/elmira-ashrafi/loqma-flutter-app.git
cd loqma-flutter-app
```

### 2. Configure the API base URL

Edit `lib/core/constants/api_constants.dart` and set your backend origin:

```dart
static const String apiOriginPrimary = 'https://your-api.example.com';
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Firebase setup (push notifications)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android (`delivery.loqma`) and iOS apps
3. Download `google-services.json` → place in `android/app/`
4. Download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Enable Google Sign-In and create a **Web OAuth client** for `GOOGLE_WEB_CLIENT_ID`

### 5. Android release signing (optional)

```bash
cp android/key.properties.example android/key.properties
# Edit key.properties with your keystore credentials
```

### 6. Run the app

```bash
flutter run
```

For Google Sign-In, pass the web client ID at build time:

```bash
flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

---

## Usage

After launch, the app bootstraps session state and routes users based on authentication:

| State | Route |
|-------|-------|
| First launch | Language selection |
| Not authenticated | Login / Register |
| Customer | Main shell (Home, Offers, Cart, Favorites, Orders) |
| Driver | Driver dashboard |
| Restaurant owner | Restaurant dashboard |
| Admin | Admin panel |

Customers can browse restaurants, add items with variants and add-ons to the cart, select a delivery address on the map, and complete checkout. Order status updates arrive via push notifications and the in-app orders tab.

---

## API overview

All endpoints are relative to `{apiOrigin}/api/v1`. JWT tokens are sent as `Authorization: Bearer <token>`.

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Email/password login |
| POST | `/auth/register` | Customer registration |
| POST | `/auth/send-otp` | Send phone OTP |
| POST | `/auth/verify-otp` | Verify OTP |
| POST | `/auth/google` | Google Sign-In |
| POST | `/refresh` | Refresh JWT |
| GET | `/me` | Current user profile |
| POST | `/logout` | Revoke session |

### Customer
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/home` | Home feed data |
| GET | `/restaurants` | Restaurant listing |
| GET | `/restaurants/{id}` | Restaurant detail + menu |
| POST | `/cart/calculate` | Price calculation |
| POST | `/checkout` | Place order |
| GET | `/customer/orders` | Order history |
| GET | `/customer/orders/{id}/track` | Live tracking |
| GET/POST | `/customer/addresses` | Delivery addresses |
| GET/POST | `/customer/favorites` | Favorites |
| GET | `/notifications` | Notification inbox |
| GET/POST | `/customer/tickets` | Support tickets |

### Maps & utilities
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/maps/config` | Maps API configuration |
| POST | `/maps/reverse-geocode` | Coordinates → address |
| GET | `/app/version` | App version check |

Driver, restaurant owner, and admin endpoints are documented in `lib/core/constants/api_constants.dart`.

---

## Testing

Run the full test suite:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Tests cover menu item JSON parsing, in-app update service behavior, and model-level unit tests. CI runs on every push to `main` via GitHub Actions.

---

## Deployment

### Android

```bash
# App Bundle (Play Store)
flutter build appbundle --release

# APK
flutter build apk --release
```

Use `build_optimized.sh` / `build_optimized.bat` for optimized release builds. Configure signing via `android/key.properties` (never commit this file).

### iOS

```bash
flutter build ios --release
```

Archive and upload through Xcode or `xcrun altool`.

### Environment variables

| Variable | Purpose |
|----------|---------|
| `GOOGLE_WEB_CLIENT_ID` | Google Sign-In server client ID |

---

## Screenshots

> Add screenshots of the home feed, restaurant detail, cart, and checkout flows here to showcase the UI.

---

## Author

**Elmira Ashrafi**

- GitHub: [@elmira-ashrafi](https://github.com/elmira-ashrafi)

---

## License

This project is licensed under the [MIT License](LICENSE).
