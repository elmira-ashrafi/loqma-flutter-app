import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_ps.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('ps'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'لقمه'**
  String get appTitle;

  /// No description provided for @foodDelivery.
  ///
  /// In en, this message translates to:
  /// **'Food delivery'**
  String get foodDelivery;

  /// No description provided for @deliveryTo.
  ///
  /// In en, this message translates to:
  /// **'Delivery to'**
  String get deliveryTo;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search delicious food...'**
  String get searchHint;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @topRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Top Restaurants'**
  String get topRestaurants;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @freeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Free Delivery'**
  String get freeDelivery;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @freeDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get freeDeliveryLabel;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'{amount} delivery fee'**
  String deliveryFeeLabel(String amount);

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minLabel(String minutes);

  /// No description provided for @minRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'{low}–{high} min'**
  String minRangeLabel(String low, String high);

  /// No description provided for @restaurantOpenBadge.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get restaurantOpenBadge;

  /// No description provided for @restaurantClosedBadge.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get restaurantClosedBadge;

  /// No description provided for @orderNow.
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get orderNow;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get loadingEllipsis;

  /// No description provided for @ordersFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Show orders'**
  String get ordersFilterTitle;

  /// No description provided for @ordersFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All orders'**
  String get ordersFilterAll;

  /// No description provided for @ordersFilterActiveOnly.
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get ordersFilterActiveOnly;

  /// No description provided for @ordersFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersFilterCompleted;

  /// No description provided for @ordersFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersFilterCancelled;

  /// No description provided for @ordersFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter orders'**
  String get ordersFilterTooltip;

  /// No description provided for @ordersSectionActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ORDERS'**
  String get ordersSectionActive;

  /// No description provided for @ordersSectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED ORDERS'**
  String get ordersSectionCompleted;

  /// No description provided for @ordersSectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get ordersSectionCancelled;

  /// No description provided for @orderPlacedAt.
  ///
  /// In en, this message translates to:
  /// **'Placed {when}'**
  String orderPlacedAt(String when);

  /// No description provided for @orderRelativeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get orderRelativeJustNow;

  /// No description provided for @orderRelativeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String orderRelativeMinutesAgo(String count);

  /// No description provided for @orderRelativeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hr ago'**
  String orderRelativeHoursAgo(String count);

  /// No description provided for @orderRelativeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String orderRelativeDaysAgo(String count);

  /// No description provided for @orderStatusActiveGeneric.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orderStatusActiveGeneric;

  /// No description provided for @orderCallRider.
  ///
  /// In en, this message translates to:
  /// **'Call rider'**
  String get orderCallRider;

  /// No description provided for @orderMapLegendRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Rest.'**
  String get orderMapLegendRestaurant;

  /// No description provided for @orderMapLegendYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get orderMapLegendYou;

  /// No description provided for @ordersReviewBannerOne.
  ///
  /// In en, this message translates to:
  /// **'1 order needs your review'**
  String get ordersReviewBannerOne;

  /// No description provided for @ordersReviewBannerMany.
  ///
  /// In en, this message translates to:
  /// **'{count} orders need your review'**
  String ordersReviewBannerMany(String count);

  /// No description provided for @qtyWithCount.
  ///
  /// In en, this message translates to:
  /// **'{label}: {count}'**
  String qtyWithCount(String label, String count);

  /// No description provided for @navOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get navOffers;

  /// No description provided for @navFavs.
  ///
  /// In en, this message translates to:
  /// **'Favs'**
  String get navFavs;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartBadgeMax.
  ///
  /// In en, this message translates to:
  /// **'99+'**
  String get cartBadgeMax;

  /// No description provided for @cartFabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartFabTooltip;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, language, and legal information.'**
  String get settingsHeroSubtitle;

  /// No description provided for @settingsNavDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display & preferences'**
  String get settingsNavDisplay;

  /// No description provided for @settingsNavLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsNavLanguage;

  /// No description provided for @settingsNavAbout.
  ///
  /// In en, this message translates to:
  /// **'About & legal'**
  String get settingsNavAbout;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @browseRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Browse restaurants'**
  String get browseRestaurants;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartEmpty;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @viewCartCheckout.
  ///
  /// In en, this message translates to:
  /// **'View cart & checkout'**
  String get viewCartCheckout;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @selectOrAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Select or add address'**
  String get selectOrAddAddress;

  /// No description provided for @deliveryLocationPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your delivery address'**
  String get deliveryLocationPromptTitle;

  /// No description provided for @deliveryLocationPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your city and area so we can show nearby restaurants and deliver to your door.'**
  String get deliveryLocationPromptSubtitle;

  /// No description provided for @deliveryLocationPromptAction.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get deliveryLocationPromptAction;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDelivery;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @orderPlacedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully.'**
  String get orderPlacedSnackbar;

  /// No description provided for @itemAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'{item} added to cart'**
  String itemAddedToCart(String item);

  /// No description provided for @cartDifferentRestaurantMessage.
  ///
  /// In en, this message translates to:
  /// **'Your cart already has items from {restaurant}. Please complete that order or clear your cart before ordering from another restaurant.'**
  String cartDifferentRestaurantMessage(String restaurant);

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @useDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get useDarkTheme;

  /// No description provided for @notificationsSetting.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSetting;

  /// No description provided for @pushAndInApp.
  ///
  /// In en, this message translates to:
  /// **'Push and in-app'**
  String get pushAndInApp;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageSelectionTitle;

  /// No description provided for @languageSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to use in the app.'**
  String get languageSelectionSubtitle;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we collect, use, and protect your information across our platform.'**
  String get privacyPolicyHeroSubtitle;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @termsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules for using Loqma, orders, delivery, and your account.'**
  String get termsHeroSubtitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Request permanent account removal'**
  String get deleteAccountSettingsSubtitle;

  /// No description provided for @deleteAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'Your request will be reviewed by our team. If approved, your profile, saved addresses, favorites, and login access will be removed. Order history may be kept for legal compliance.'**
  String get deleteAccountIntro;

  /// No description provided for @deleteAccountWebPolicyLink.
  ///
  /// In en, this message translates to:
  /// **'View account deletion policy online'**
  String get deleteAccountWebPolicyLink;

  /// No description provided for @deleteAccountReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get deleteAccountReasonLabel;

  /// No description provided for @deleteAccountReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us why you want to delete your account'**
  String get deleteAccountReasonHint;

  /// No description provided for @deleteAccountSubmit.
  ///
  /// In en, this message translates to:
  /// **'Request deletion'**
  String get deleteAccountSubmit;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your request will be sent to our team for approval. This action cannot be undone after approval.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Deletion request submitted. We will notify you after review.'**
  String get deleteAccountSubmitted;

  /// No description provided for @deleteAccountCancelled.
  ///
  /// In en, this message translates to:
  /// **'Deletion request cancelled.'**
  String get deleteAccountCancelled;

  /// No description provided for @deleteAccountCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get deleteAccountCancelRequest;

  /// No description provided for @deleteAccountCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current request status'**
  String get deleteAccountCurrentStatus;

  /// No description provided for @deleteAccountStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending admin approval'**
  String get deleteAccountStatusPending;

  /// No description provided for @deleteAccountStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved — your account has been deleted'**
  String get deleteAccountStatusApproved;

  /// No description provided for @deleteAccountStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get deleteAccountStatusRejected;

  /// No description provided for @deleteAccountStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get deleteAccountStatusCancelled;

  /// No description provided for @deleteAccountWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'What will be removed'**
  String get deleteAccountWhatHappens;

  /// No description provided for @deleteAccountMayBeKept.
  ///
  /// In en, this message translates to:
  /// **'May be kept'**
  String get deleteAccountMayBeKept;

  /// No description provided for @deleteAccountDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get deleteAccountDangerZone;

  /// No description provided for @deleteAccountRemovedProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile, phone, and saved addresses'**
  String get deleteAccountRemovedProfile;

  /// No description provided for @deleteAccountRemovedFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites and notification preferences'**
  String get deleteAccountRemovedFavorites;

  /// No description provided for @deleteAccountRemovedAccess.
  ///
  /// In en, this message translates to:
  /// **'Login access to the Loqma app'**
  String get deleteAccountRemovedAccess;

  /// No description provided for @deleteAccountKeptOrders.
  ///
  /// In en, this message translates to:
  /// **'Order history (legal compliance)'**
  String get deleteAccountKeptOrders;

  /// No description provided for @deleteAccountKeptPayments.
  ///
  /// In en, this message translates to:
  /// **'Payment records if required by law'**
  String get deleteAccountKeptPayments;

  /// No description provided for @deleteAccountRedirectingToLogin.
  ///
  /// In en, this message translates to:
  /// **'Account deleted. Redirecting to sign in…'**
  String get deleteAccountRedirectingToLogin;

  /// No description provided for @deleteAccountSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted. Please sign in again with your phone number.'**
  String get deleteAccountSessionEnded;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get signInRequired;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportTickets.
  ///
  /// In en, this message translates to:
  /// **'Support tickets'**
  String get supportTickets;

  /// No description provided for @createTicketHelp.
  ///
  /// In en, this message translates to:
  /// **'Create a ticket for help'**
  String get createTicketHelp;

  /// No description provided for @newTicket.
  ///
  /// In en, this message translates to:
  /// **'New ticket'**
  String get newTicket;

  /// No description provided for @supportTrackManage.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your support requests'**
  String get supportTrackManage;

  /// No description provided for @supportNoTicketsTitle.
  ///
  /// In en, this message translates to:
  /// **'No tickets found'**
  String get supportNoTicketsTitle;

  /// No description provided for @supportNoTicketsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a ticket for help'**
  String get supportNoTicketsSubtitle;

  /// No description provided for @ticketFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit a Support Request'**
  String get ticketFormTitle;

  /// No description provided for @ticketFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue and we\'ll get back to you as soon as possible.'**
  String get ticketFormSubtitle;

  /// No description provided for @ticketSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject *'**
  String get ticketSubjectLabel;

  /// No description provided for @ticketSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of your issue'**
  String get ticketSubjectHint;

  /// No description provided for @ticketCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category *'**
  String get ticketCategoryLabel;

  /// No description provided for @ticketPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Priority *'**
  String get ticketPriorityLabel;

  /// No description provided for @ticketRelatedOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Related Order (optional)'**
  String get ticketRelatedOrderLabel;

  /// No description provided for @ticketRelatedOrderNone.
  ///
  /// In en, this message translates to:
  /// **'Not related to an order'**
  String get ticketRelatedOrderNone;

  /// No description provided for @ticketMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message *'**
  String get ticketMessageLabel;

  /// No description provided for @ticketMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Please describe your issue in detail...'**
  String get ticketMessageHint;

  /// No description provided for @ticketMessageMinCharsHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 20 characters'**
  String get ticketMessageMinCharsHint;

  /// No description provided for @ticketCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ticketCancel;

  /// No description provided for @ticketSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get ticketSubmit;

  /// No description provided for @ticketSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Ticket submitted. We will get back to you soon.'**
  String get ticketSubmitted;

  /// No description provided for @ticketMessageTooShort.
  ///
  /// In en, this message translates to:
  /// **'Message must be at least 20 characters'**
  String get ticketMessageTooShort;

  /// No description provided for @ticketSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String ticketSubmitFailed(String error);

  /// No description provided for @noSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get noSavedAddresses;

  /// No description provided for @addAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Add an address for faster checkout'**
  String get addAddressHint;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesYet;

  /// No description provided for @favoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Restaurants you like will appear here'**
  String get favoritesHint;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @newNotificationReceived.
  ///
  /// In en, this message translates to:
  /// **'You\'ve received a new notification'**
  String get newNotificationReceived;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @fcmChannelName.
  ///
  /// In en, this message translates to:
  /// **'Orders & alerts'**
  String get fcmChannelName;

  /// No description provided for @fcmChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Delivery and account notifications'**
  String get fcmChannelDescription;

  /// No description provided for @notificationDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Loqma'**
  String get notificationDefaultTitle;

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @pleaseSignInToViewNotifications.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view notifications.'**
  String get pleaseSignInToViewNotifications;

  /// No description provided for @notificationOrderConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed'**
  String get notificationOrderConfirmedTitle;

  /// No description provided for @notificationOrderPreparingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Food is Being Prepared'**
  String get notificationOrderPreparingTitle;

  /// No description provided for @notificationOrderReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Ready for Pickup'**
  String get notificationOrderReadyTitle;

  /// No description provided for @notificationOrderPickedUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Picked Up Your Order'**
  String get notificationOrderPickedUpTitle;

  /// No description provided for @notificationOrderOnTheWayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Order is On The Way'**
  String get notificationOrderOnTheWayTitle;

  /// No description provided for @notificationOrderDeliveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Delivered'**
  String get notificationOrderDeliveredTitle;

  /// No description provided for @notificationOrderCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get notificationOrderCancelledTitle;

  /// No description provided for @notificationOrderUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Update'**
  String get notificationOrderUpdateTitle;

  /// No description provided for @notificationOrderConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} from {restaurant} has been confirmed and will be prepared soon.'**
  String notificationOrderConfirmedMessage(
    String orderNumber,
    String restaurant,
  );

  /// No description provided for @notificationOrderPreparingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} is now being prepared at {restaurant}.'**
  String notificationOrderPreparingMessage(
    String orderNumber,
    String restaurant,
  );

  /// No description provided for @notificationOrderReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} is ready! A driver will pick it up soon.'**
  String notificationOrderReadyMessage(String orderNumber);

  /// No description provided for @notificationOrderPickedUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} has been picked up by {driver}.'**
  String notificationOrderPickedUpMessage(String orderNumber, String driver);

  /// No description provided for @notificationOrderOnTheWayMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} is on the way! {driver} is bringing your food.'**
  String notificationOrderOnTheWayMessage(String orderNumber, String driver);

  /// No description provided for @notificationOrderDeliveredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} has been delivered. Enjoy your meal!'**
  String notificationOrderDeliveredMessage(String orderNumber);

  /// No description provided for @notificationOrderCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} has been cancelled.'**
  String notificationOrderCancelledMessage(String orderNumber);

  /// No description provided for @notificationOrderUpdateMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order #{orderNumber} status has been updated to {status}.'**
  String notificationOrderUpdateMessage(String orderNumber, String status);

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get allCaughtUp;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @profileUpdatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Profile updated (wire to /customer/profile)'**
  String get profileUpdatedSnackbar;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePashto.
  ///
  /// In en, this message translates to:
  /// **'پښتو'**
  String get languagePashto;

  /// No description provided for @languageDari.
  ///
  /// In en, this message translates to:
  /// **'دری'**
  String get languageDari;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue ordering'**
  String get signInToContinue;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @authNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 2 characters for your name.'**
  String get authNameTooShort;

  /// No description provided for @authNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'That name is too long (maximum 80 characters).'**
  String get authNameTooLong;

  /// No description provided for @authNameLooksLikePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'That looks like a phone number. Enter your name in the name field.'**
  String get authNameLooksLikePhoneNumber;

  /// No description provided for @authNameMustContainLetters.
  ///
  /// In en, this message translates to:
  /// **'Enter a name using letters (not only numbers or symbols).'**
  String get authNameMustContainLetters;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @signInToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view profile'**
  String get signInToViewProfile;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @proceedToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout'**
  String get proceedToCheckout;

  /// No description provided for @cartEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add items from a restaurant to get started'**
  String get cartEmptyHint;

  /// No description provided for @cannotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach server'**
  String get cannotReachServer;

  /// No description provided for @orderHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Your order history will appear here'**
  String get orderHistoryHint;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @pullToRefreshOrRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh or try again'**
  String get pullToRefreshOrRetry;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @customerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening with your account today.'**
  String get customerDashboardSubtitle;

  /// No description provided for @customerDashboardTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total orders'**
  String get customerDashboardTotalOrders;

  /// No description provided for @customerDashboardActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get customerDashboardActiveOrders;

  /// No description provided for @customerDashboardTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get customerDashboardTotalSpent;

  /// No description provided for @customerDashboardOpenTickets.
  ///
  /// In en, this message translates to:
  /// **'Open tickets'**
  String get customerDashboardOpenTickets;

  /// No description provided for @customerDashboardOrderFood.
  ///
  /// In en, this message translates to:
  /// **'Order food'**
  String get customerDashboardOrderFood;

  /// No description provided for @customerDashboardOrderMeta.
  ///
  /// In en, this message translates to:
  /// **'{placed} · {items}'**
  String customerDashboardOrderMeta(String placed, String items);

  /// No description provided for @orderStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get orderStatusRefunded;

  /// No description provided for @discountCode.
  ///
  /// In en, this message translates to:
  /// **'Discount Code'**
  String get discountCode;

  /// No description provided for @supportTicket.
  ///
  /// In en, this message translates to:
  /// **'Support Ticket'**
  String get supportTicket;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @foods.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get foods;

  /// No description provided for @searchAllHint.
  ///
  /// In en, this message translates to:
  /// **'Search restaurants & food...'**
  String get searchAllHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @tryDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords'**
  String get tryDifferentKeywords;

  /// No description provided for @allRestaurants.
  ///
  /// In en, this message translates to:
  /// **'All Restaurants'**
  String get allRestaurants;

  /// No description provided for @specialDeals.
  ///
  /// In en, this message translates to:
  /// **'Special Deals'**
  String get specialDeals;

  /// No description provided for @orderSummaryCaps.
  ///
  /// In en, this message translates to:
  /// **'ORDER SUMMARY'**
  String get orderSummaryCaps;

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get sizeLabel;

  /// No description provided for @promoCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Promo code copied'**
  String get promoCodeCopied;

  /// No description provided for @freeDeliveryAboveDeal.
  ///
  /// In en, this message translates to:
  /// **'Free delivery on orders above {amount}'**
  String freeDeliveryAboveDeal(String amount);

  /// No description provided for @deliveryFeeDeal.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee: {amount}'**
  String deliveryFeeDeal(String amount);

  /// No description provided for @welcomeToLoqma.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Loqma'**
  String get welcomeToLoqma;

  /// No description provided for @signInWithPhoneWhatsAppOtp.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your phone number. We will send a message OTP.'**
  String get signInWithPhoneWhatsAppOtp;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @sendRegistrationOtp.
  ///
  /// In en, this message translates to:
  /// **'Send registration OTP'**
  String get sendRegistrationOtp;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number.'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @invalidAfghanPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Afghan mobile (07 or +937, then 0–4 or 6–9, e.g. 072 123 4567).'**
  String get invalidAfghanPhone;

  /// No description provided for @testOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Test OTP'**
  String get testOtpTitle;

  /// No description provided for @testOtpUseCode.
  ///
  /// In en, this message translates to:
  /// **'Use code {code}'**
  String testOtpUseCode(String code);

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @otpEnterCodeWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 3-digit code sent to your message number.'**
  String get otpEnterCodeWhatsApp;

  /// No description provided for @otpTestModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Test mode is enabled. You can use the code below directly.'**
  String get otpTestModeDescription;

  /// No description provided for @otpTestModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Test mode is enabled. Use OTP: {code}'**
  String otpTestModeBanner(String code);

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP code'**
  String get otpCodeLabel;

  /// No description provided for @otpCodeHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get otpCodeHint;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify and continue'**
  String get verifyAndContinue;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @otpEnterSixDigits.
  ///
  /// In en, this message translates to:
  /// **'Enter the 3-digit OTP code.'**
  String get otpEnterSixDigits;

  /// No description provided for @otpIncompleteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter all 3 digits of the code.'**
  String get otpIncompleteCode;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 3-digit code (numbers only).'**
  String get otpInvalidCode;

  /// No description provided for @otpSentAgain.
  ///
  /// In en, this message translates to:
  /// **'OTP sent again'**
  String get otpSentAgain;

  /// No description provided for @otpSentAgainTest.
  ///
  /// In en, this message translates to:
  /// **'OTP sent again. Test code: {code}'**
  String otpSentAgainTest(String code);

  /// No description provided for @authWhatsYourName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get authWhatsYourName;

  /// No description provided for @authEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get authEnterPhoneNumber;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// No description provided for @authPhoneVerifyHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a 3-digit code to verify your identity.'**
  String get authPhoneVerifyHint;

  /// No description provided for @authVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get authVerification;

  /// No description provided for @authEnterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to'**
  String get authEnterCodeSentTo;

  /// No description provided for @authVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify account'**
  String get authVerifyAccount;

  /// No description provided for @authResendVerificationCodeUpper.
  ///
  /// In en, this message translates to:
  /// **'RESEND VERIFICATION CODE'**
  String get authResendVerificationCodeUpper;

  /// No description provided for @nameHintExample.
  ///
  /// In en, this message translates to:
  /// **'Ahmad Karimi'**
  String get nameHintExample;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableMessageDefault.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available.'**
  String get updateAvailableMessageDefault;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateInstallPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow installing apps from this source (or install unknown apps) to continue.'**
  String get updateInstallPermissionMessage;

  /// No description provided for @updateCouldNotOpenInstaller.
  ///
  /// In en, this message translates to:
  /// **'Could not open the installer.'**
  String get updateCouldNotOpenInstaller;

  /// No description provided for @updateDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed.'**
  String get updateDownloadFailed;

  /// No description provided for @backToOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Back to order details'**
  String get backToOrderDetails;

  /// No description provided for @couldNotLoadTracking.
  ///
  /// In en, this message translates to:
  /// **'Could not load tracking.'**
  String get couldNotLoadTracking;

  /// No description provided for @restaurantDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantDefaultName;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @mapMarkerRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get mapMarkerRestaurant;

  /// No description provided for @mapMarkerDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get mapMarkerDelivery;

  /// No description provided for @mapMarkerDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get mapMarkerDriver;

  /// No description provided for @orderTrackDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String orderTrackDistanceKm(String distance);

  /// No description provided for @orderTrackEtaApprox.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min'**
  String orderTrackEtaApprox(String minutes);

  /// No description provided for @orderTrackEtaScheduled.
  ///
  /// In en, this message translates to:
  /// **'{time}'**
  String orderTrackEtaScheduled(String time);

  /// No description provided for @orderTrackCenterMap.
  ///
  /// In en, this message translates to:
  /// **'Fit route'**
  String get orderTrackCenterMap;

  /// No description provided for @orderTrackZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get orderTrackZoomIn;

  /// No description provided for @orderTrackZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get orderTrackZoomOut;

  /// No description provided for @orderTrackDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get orderTrackDirections;

  /// No description provided for @orderTrackDirectionsCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open Maps.'**
  String get orderTrackDirectionsCouldNotOpen;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumberLabel(String orderId);

  /// No description provided for @estimatedDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery time'**
  String get estimatedDeliveryTime;

  /// No description provided for @routeFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get routeFromLabel;

  /// No description provided for @routeToLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get routeToLabel;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call driver'**
  String get callDriver;

  /// No description provided for @vehicleDefault.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleDefault;

  /// No description provided for @lookingForDriver.
  ///
  /// In en, this message translates to:
  /// **'Looking for a driver…'**
  String get lookingForDriver;

  /// No description provided for @deliveryAddressSection.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddressSection;

  /// No description provided for @yourDriver.
  ///
  /// In en, this message translates to:
  /// **'Your driver'**
  String get yourDriver;

  /// No description provided for @trackDriverLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get trackDriverLive;

  /// No description provided for @trackStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get trackStatusPending;

  /// No description provided for @trackStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get trackStatusConfirmed;

  /// No description provided for @trackStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get trackStatusPreparing;

  /// No description provided for @trackStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get trackStatusReady;

  /// No description provided for @trackStatusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get trackStatusPickedUp;

  /// No description provided for @trackStatusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get trackStatusOnTheWay;

  /// No description provided for @trackStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get trackStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @menuSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get menuSectionTitle;

  /// No description provided for @customerReviewsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER REVIEWS'**
  String get customerReviewsSectionTitle;

  /// No description provided for @noCustomerReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noCustomerReviewsYet;

  /// No description provided for @reviewsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Reviews couldn’t load. Try opening this screen again.'**
  String get reviewsCouldNotLoad;

  /// No description provided for @similarRestaurantsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'SIMILAR RESTAURANTS'**
  String get similarRestaurantsSectionTitle;

  /// No description provided for @availableOffersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE OFFERS'**
  String get availableOffersSectionTitle;

  /// No description provided for @loadingRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Loading restaurant…'**
  String get loadingRestaurant;

  /// No description provided for @searchMenuItemsHint.
  ///
  /// In en, this message translates to:
  /// **'Search menu items…'**
  String get searchMenuItemsHint;

  /// No description provided for @copiedCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Copied {code}'**
  String copiedCodeMessage(String code);

  /// No description provided for @defaultLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'City center'**
  String get defaultLocationPlaceholder;

  /// No description provided for @defaultRestaurantCategoryTagline.
  ///
  /// In en, this message translates to:
  /// **'Fast food • Pizza'**
  String get defaultRestaurantCategoryTagline;

  /// No description provided for @restaurantsInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'Restaurants in this category'**
  String get restaurantsInThisCategory;

  /// No description provided for @discoverOrderBestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover & order from the best'**
  String get discoverOrderBestSubtitle;

  /// No description provided for @superAdminPayments.
  ///
  /// In en, this message translates to:
  /// **'Super Admin Payments'**
  String get superAdminPayments;

  /// No description provided for @viewFullPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'View full payment details'**
  String get viewFullPaymentDetails;

  /// No description provided for @completeRawResponsePayload.
  ///
  /// In en, this message translates to:
  /// **'Complete raw response payload'**
  String get completeRawResponsePayload;

  /// No description provided for @unknownEntity.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownEntity;

  /// No description provided for @labelRestaurantId.
  ///
  /// In en, this message translates to:
  /// **'Restaurant ID'**
  String get labelRestaurantId;

  /// No description provided for @driverProfileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get driverProfileAndSettings;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedSuccess;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @orderUpdatedToStatus.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNumber} updated to {status}'**
  String orderUpdatedToStatus(String orderNumber, String status);

  /// No description provided for @orderUpdatedShort.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNumber} updated'**
  String orderUpdatedShort(String orderNumber);

  /// No description provided for @restaurantDashboard.
  ///
  /// In en, this message translates to:
  /// **'Restaurant dashboard'**
  String get restaurantDashboard;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent orders'**
  String get recentOrders;

  /// No description provided for @noRecentOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No recent orders yet.'**
  String get noRecentOrdersYet;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave review'**
  String get leaveReview;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @leaveAReview.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get leaveAReview;

  /// No description provided for @browseToReorderFromRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Browse restaurants to order again from this restaurant'**
  String get browseToReorderFromRestaurant;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @cancelOrderAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrderAction;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @specialOfferDealsTab.
  ///
  /// In en, this message translates to:
  /// **'Special offer (Deals tab)'**
  String get specialOfferDealsTab;

  /// No description provided for @specialOfferDealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requires a discounted price below regular price'**
  String get specialOfferDealsSubtitle;

  /// No description provided for @listUnderDeals.
  ///
  /// In en, this message translates to:
  /// **'List under Deals'**
  String get listUnderDeals;

  /// No description provided for @listUnderDealsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant must be active; discount dates apply if set'**
  String get listUnderDealsSubtitle;

  /// No description provided for @enterDiscountedPricePositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a discounted price greater than zero.'**
  String get enterDiscountedPricePositive;

  /// No description provided for @specialOfferForItem.
  ///
  /// In en, this message translates to:
  /// **'Special offer: {itemName}'**
  String specialOfferForItem(String itemName);

  /// No description provided for @menuManagement.
  ///
  /// In en, this message translates to:
  /// **'Menu management'**
  String get menuManagement;

  /// No description provided for @noMenuCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No menu categories yet'**
  String get noMenuCategoriesYet;

  /// No description provided for @createFirstCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first category to organize your menu.'**
  String get createFirstCategoryHint;

  /// No description provided for @createFirstCategory.
  ///
  /// In en, this message translates to:
  /// **'Create first category'**
  String get createFirstCategory;

  /// No description provided for @itemsCountInCategory.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCountInCategory(String count);

  /// No description provided for @noItemsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No items in this category yet.'**
  String get noItemsInCategory;

  /// No description provided for @restaurantSettingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Restaurant settings updated'**
  String get restaurantSettingsUpdated;

  /// No description provided for @restaurantSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant settings'**
  String get restaurantSettingsTitle;

  /// No description provided for @acceptCashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Accept cash on delivery'**
  String get acceptCashOnDelivery;

  /// No description provided for @acceptOnlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Accept online payment'**
  String get acceptOnlinePayment;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @restaurantOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant orders'**
  String get restaurantOrdersTitle;

  /// No description provided for @noOrdersForFilter.
  ///
  /// In en, this message translates to:
  /// **'No orders found for this filter.'**
  String get noOrdersForFilter;

  /// No description provided for @orderActionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get orderActionConfirm;

  /// No description provided for @orderActionStartPreparing.
  ///
  /// In en, this message translates to:
  /// **'Start preparing'**
  String get orderActionStartPreparing;

  /// No description provided for @orderActionMarkReady.
  ///
  /// In en, this message translates to:
  /// **'Mark ready'**
  String get orderActionMarkReady;

  /// No description provided for @driverWithName.
  ///
  /// In en, this message translates to:
  /// **'Driver: {name}'**
  String driverWithName(String name);

  /// No description provided for @myEarningsTitle.
  ///
  /// In en, this message translates to:
  /// **'My earnings'**
  String get myEarningsTitle;

  /// No description provided for @payoutRequested.
  ///
  /// In en, this message translates to:
  /// **'Payout requested'**
  String get payoutRequested;

  /// No description provided for @requestPayout.
  ///
  /// In en, this message translates to:
  /// **'Request payout'**
  String get requestPayout;

  /// No description provided for @offersDealsTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers & deals'**
  String get offersDealsTitle;

  /// No description provided for @offersDealsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Restaurants can add special offers on menu items; they will appear here.'**
  String get offersDealsEmptyHint;

  /// No description provided for @closeTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Close ticket?'**
  String get closeTicketTitle;

  /// No description provided for @closeTicketMessage.
  ///
  /// In en, this message translates to:
  /// **'You can reopen it later if your issue persists.'**
  String get closeTicketMessage;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @ticketClosedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket closed.'**
  String get ticketClosedSuccess;

  /// No description provided for @ticketReopenedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ticket reopened.'**
  String get ticketReopenedSuccess;

  /// No description provided for @ticketScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketScreenTitle;

  /// No description provided for @sendReply.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get sendReply;

  /// No description provided for @reopenIfPersists.
  ///
  /// In en, this message translates to:
  /// **'Reopen if your issue persists'**
  String get reopenIfPersists;

  /// No description provided for @failedToSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String failedToSendMessage(String error);

  /// No description provided for @deleteAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete address?'**
  String get deleteAddressTitle;

  /// No description provided for @deleteAddressMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove “{label}”? This cannot be undone.'**
  String deleteAddressMessage(String label);

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @addressRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address removed'**
  String get addressRemovedSuccess;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @removeAllNotificationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all notifications from this device list?'**
  String get removeAllNotificationsConfirm;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @orderHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistoryTitle;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get pleaseSelectCity;

  /// No description provided for @citiesStillLoading.
  ///
  /// In en, this message translates to:
  /// **'Cities are still loading. Try again in a moment.'**
  String get citiesStillLoading;

  /// No description provided for @turnOnLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to use this option.'**
  String get turnOnLocationServices;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to detect your address.'**
  String get locationPermissionRequired;

  /// No description provided for @couldNotResolveAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve an address from your location.'**
  String get couldNotResolveAddress;

  /// No description provided for @cityNotDetectedChoose.
  ///
  /// In en, this message translates to:
  /// **'City not detected automatically — please choose your city below.'**
  String get cityNotDetectedChoose;

  /// No description provided for @locationAppliedReviewSave.
  ///
  /// In en, this message translates to:
  /// **'Location applied. Review the fields and tap Save.'**
  String get locationAppliedReviewSave;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location: {error}'**
  String couldNotGetLocation(String error);

  /// No description provided for @setAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get setAsDefaultAddress;

  /// No description provided for @openRestaurantNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Open restaurant not available for this item'**
  String get openRestaurantNotAvailable;

  /// No description provided for @hesabPayTitle.
  ///
  /// In en, this message translates to:
  /// **'HesabPay'**
  String get hesabPayTitle;

  /// No description provided for @paymentNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment was not completed.'**
  String get paymentNotCompleted;

  /// No description provided for @paymentSuccessfulConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment successful. Order confirmed.'**
  String get paymentSuccessfulConfirmed;

  /// No description provided for @paymentFailedOrCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or was cancelled.'**
  String get paymentFailedOrCancelled;

  /// No description provided for @paymentProcessingCheckOrders.
  ///
  /// In en, this message translates to:
  /// **'Payment is still processing. Check My orders shortly.'**
  String get paymentProcessingCheckOrders;

  /// No description provided for @payOnlineSecurely.
  ///
  /// In en, this message translates to:
  /// **'Pay online securely'**
  String get payOnlineSecurely;

  /// No description provided for @acceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept order'**
  String get acceptOrder;

  /// No description provided for @navEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get navEarnings;

  /// No description provided for @navRestaurantMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get navRestaurantMenu;

  /// No description provided for @orderCancelledRefundHint.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled. Refund will be processed if applicable.'**
  String get orderCancelledRefundHint;

  /// No description provided for @failedToCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel: {error}'**
  String failedToCancelOrder(String error);

  /// No description provided for @cancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get cancelOrderTitle;

  /// No description provided for @keepOrder.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get keepOrder;

  /// No description provided for @cancelOrderConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel?'**
  String get cancelOrderConfirmTitle;

  /// No description provided for @cancelOrderConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. If you have already paid, a refund will be processed.'**
  String get cancelOrderConfirmBody;

  /// No description provided for @cancelReasonSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Please tell us why'**
  String get cancelReasonSectionTitle;

  /// No description provided for @cancelAdditionalDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get cancelAdditionalDetailsLabel;

  /// No description provided for @cancelReasonChangedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed my mind'**
  String get cancelReasonChangedMind;

  /// No description provided for @cancelReasonWrongOrder.
  ///
  /// In en, this message translates to:
  /// **'Wrong order placed'**
  String get cancelReasonWrongOrder;

  /// No description provided for @cancelReasonFoundElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Found food elsewhere'**
  String get cancelReasonFoundElsewhere;

  /// No description provided for @cancelReasonDeliveryLong.
  ///
  /// In en, this message translates to:
  /// **'Delivery time too long'**
  String get cancelReasonDeliveryLong;

  /// No description provided for @cancelReasonPriceIssue.
  ///
  /// In en, this message translates to:
  /// **'Price or payment issue'**
  String get cancelReasonPriceIssue;

  /// No description provided for @cancelReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cancelReasonOther;

  /// No description provided for @cancelReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Help us improve by sharing more details…'**
  String get cancelReasonHint;

  /// No description provided for @pleaseRateRestaurantAndFood.
  ///
  /// In en, this message translates to:
  /// **'Please rate the restaurant and food (1–5 stars).'**
  String get pleaseRateRestaurantAndFood;

  /// No description provided for @orderReviewScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with this order?'**
  String get orderReviewScreenSubtitle;

  /// No description provided for @orderReviewRateRestaurantTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the restaurant'**
  String get orderReviewRateRestaurantTitle;

  /// No description provided for @orderReviewRateFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the food'**
  String get orderReviewRateFoodTitle;

  /// No description provided for @orderReviewRateDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate the delivery'**
  String get orderReviewRateDeliveryTitle;

  /// No description provided for @orderReviewAddPhotosSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add photos (optional)'**
  String get orderReviewAddPhotosSectionTitle;

  /// No description provided for @thankYouReviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your review has been submitted.'**
  String get thankYouReviewSubmitted;

  /// No description provided for @failedSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review: {error}'**
  String failedSubmitReview(String error);

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addPhotos;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @reviewDeliveryHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with the delivery…'**
  String get reviewDeliveryHint;

  /// No description provided for @reviewRestaurantHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with the food and restaurant…'**
  String get reviewRestaurantHint;

  /// No description provided for @addressLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Home, Work'**
  String get addressLabelHint;

  /// No description provided for @addressAreaHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Karte-e-Char'**
  String get addressAreaHint;

  /// No description provided for @addressStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Street name and number'**
  String get addressStreetHint;

  /// No description provided for @addressNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ring doorbell, call on arrival'**
  String get addressNotesHint;

  /// No description provided for @ticketReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Type your reply here…'**
  String get ticketReplyHint;

  /// No description provided for @dateHintExampleStart.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2026-03-28 00:00:00'**
  String get dateHintExampleStart;

  /// No description provided for @dateHintExampleEnd.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2026-04-01 23:59:59'**
  String get dateHintExampleEnd;

  /// No description provided for @optionalStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start (optional)'**
  String get optionalStartLabel;

  /// No description provided for @optionalEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End (optional)'**
  String get optionalEndLabel;

  /// No description provided for @isoDateHint.
  ///
  /// In en, this message translates to:
  /// **'ISO or Y-m-d H:i'**
  String get isoDateHint;

  /// No description provided for @restaurantNameField.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name'**
  String get restaurantNameField;

  /// No description provided for @restaurantNameDariField.
  ///
  /// In en, this message translates to:
  /// **'Restaurant name (Dari)'**
  String get restaurantNameDariField;

  /// No description provided for @verifyOtpAppBar.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpAppBar;

  /// No description provided for @orderStatusTimeSeparator.
  ///
  /// In en, this message translates to:
  /// **'{status} • {time}'**
  String orderStatusTimeSeparator(String status, String time);

  /// No description provided for @ticketCategoryRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get ticketCategoryRestaurant;

  /// No description provided for @restaurantSampleOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'20% off burgers'**
  String get restaurantSampleOfferTitle;

  /// No description provided for @restaurantSampleOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get 20% off on all burgers. Min order \$15.'**
  String get restaurantSampleOfferSubtitle;

  /// No description provided for @restaurantDeliveryOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery offer'**
  String get restaurantDeliveryOfferTitle;

  /// No description provided for @restaurantOfferFreeDeliveryNext.
  ///
  /// In en, this message translates to:
  /// **'Free delivery on your next order. No minimum.'**
  String get restaurantOfferFreeDeliveryNext;

  /// No description provided for @restaurantOfferFreeDeliveryOverAmount.
  ///
  /// In en, this message translates to:
  /// **'Free delivery on orders over {amount}.'**
  String restaurantOfferFreeDeliveryOverAmount(String amount);

  /// No description provided for @restaurantOfferLimitedDeliverySavings.
  ///
  /// In en, this message translates to:
  /// **'Limited-time delivery savings.'**
  String get restaurantOfferLimitedDeliverySavings;

  /// No description provided for @backToOrders.
  ///
  /// In en, this message translates to:
  /// **'Back to orders'**
  String get backToOrders;

  /// No description provided for @ticketCategoryOrderIssue.
  ///
  /// In en, this message translates to:
  /// **'Order issue'**
  String get ticketCategoryOrderIssue;

  /// No description provided for @ticketCategoryPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get ticketCategoryPayment;

  /// No description provided for @ticketCategoryDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get ticketCategoryDelivery;

  /// No description provided for @ticketCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get ticketCategoryAccount;

  /// No description provided for @ticketCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ticketCategoryOther;

  /// No description provided for @ticketStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get ticketStatusOpen;

  /// No description provided for @ticketStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get ticketStatusInProgress;

  /// No description provided for @ticketStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get ticketStatusWaiting;

  /// No description provided for @ticketStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get ticketStatusResolved;

  /// No description provided for @ticketStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get ticketStatusClosed;

  /// No description provided for @ticketPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get ticketPriorityLow;

  /// No description provided for @ticketPriorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get ticketPriorityMedium;

  /// No description provided for @ticketPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get ticketPriorityHigh;

  /// No description provided for @ticketPriorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get ticketPriorityUrgent;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @ticketRelatedOrderOption.
  ///
  /// In en, this message translates to:
  /// **'#{orderId} — {restaurant}'**
  String ticketRelatedOrderOption(String orderId, String restaurant);

  /// No description provided for @tapViewDetailsForItems.
  ///
  /// In en, this message translates to:
  /// **'Tap View details for items'**
  String get tapViewDetailsForItems;

  /// No description provided for @orderDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load order details.'**
  String get orderDetailLoadError;

  /// No description provided for @orderItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order items'**
  String get orderItemsTitle;

  /// No description provided for @noItemsInOrder.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItemsInOrder;

  /// No description provided for @orderTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Order timeline'**
  String get orderTimelineTitle;

  /// No description provided for @deliveryDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery details'**
  String get deliveryDetailsTitle;

  /// No description provided for @paymentSummaryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get paymentSummaryDetailTitle;

  /// No description provided for @deliveryFeeShort.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFeeShort;

  /// No description provided for @paymentStatusPendingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentStatusPendingGeneric;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentStatusFailed;

  /// No description provided for @paymentMethodOnline.
  ///
  /// In en, this message translates to:
  /// **'Online payment'**
  String get paymentMethodOnline;

  /// No description provided for @orderItemQtyTimesPrice.
  ///
  /// In en, this message translates to:
  /// **'{qty} × {price}'**
  String orderItemQtyTimesPrice(String qty, String price);

  /// No description provided for @emptyValueDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emptyValueDash;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @restaurantSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurantSectionTitle;

  /// No description provided for @detailRowAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get detailRowAddress;

  /// No description provided for @paymentStatusDetail.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get paymentStatusDetail;

  /// No description provided for @ticketReplyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String ticketReplyCount(String count);

  /// No description provided for @checkoutLoadingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Loading addresses…'**
  String get checkoutLoadingAddresses;

  /// No description provided for @offersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load offers.'**
  String get offersLoadFailed;

  /// No description provided for @offersNoDealsNow.
  ///
  /// In en, this message translates to:
  /// **'No active deals right now'**
  String get offersNoDealsNow;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutDocumentTitle;

  /// No description provided for @aboutHero.
  ///
  /// In en, this message translates to:
  /// **'Delivering happiness, one meal at a time'**
  String get aboutHero;

  /// No description provided for @aboutHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your favourite local restaurants, delivered fast and fresh.'**
  String get aboutHeroSubtitle;

  /// No description provided for @aboutStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Our story'**
  String get aboutStoryTitle;

  /// No description provided for @aboutStoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Loqma connects hungry customers with trusted local restaurants. We built this platform to make ordering food simple, transparent, and enjoyable—whether you are at home, at work, or on the go.'**
  String get aboutStoryDesc;

  /// No description provided for @aboutMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionDesc.
  ///
  /// In en, this message translates to:
  /// **'To empower communities by making quality food accessible to everyone through technology and reliable delivery.'**
  String get aboutMissionDesc;

  /// No description provided for @aboutVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our vision'**
  String get aboutVisionTitle;

  /// No description provided for @aboutVisionDesc.
  ///
  /// In en, this message translates to:
  /// **'To become the most loved food delivery experience in the region—known for speed, fairness, and the restaurants we serve.'**
  String get aboutVisionDesc;

  /// No description provided for @aboutValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our core values'**
  String get aboutValuesTitle;

  /// No description provided for @aboutValue1Title.
  ///
  /// In en, this message translates to:
  /// **'Customer first'**
  String get aboutValue1Title;

  /// No description provided for @aboutValue1Desc.
  ///
  /// In en, this message translates to:
  /// **'Every feature starts with what diners and partners need.'**
  String get aboutValue1Desc;

  /// No description provided for @aboutValue2Title.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get aboutValue2Title;

  /// No description provided for @aboutValue2Desc.
  ///
  /// In en, this message translates to:
  /// **'We champion great food and dependable service.'**
  String get aboutValue2Desc;

  /// No description provided for @aboutValue3Title.
  ///
  /// In en, this message translates to:
  /// **'Partnership'**
  String get aboutValue3Title;

  /// No description provided for @aboutValue3Desc.
  ///
  /// In en, this message translates to:
  /// **'Restaurants are partners; we grow together.'**
  String get aboutValue3Desc;

  /// No description provided for @aboutValue4Title.
  ///
  /// In en, this message translates to:
  /// **'Innovation'**
  String get aboutValue4Title;

  /// No description provided for @aboutValue4Desc.
  ///
  /// In en, this message translates to:
  /// **'We keep improving routes, payments, and your in-app experience.'**
  String get aboutValue4Desc;

  /// No description provided for @aboutWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why choose us'**
  String get aboutWhyTitle;

  /// No description provided for @aboutWhy1.
  ///
  /// In en, this message translates to:
  /// **'Fast, reliable delivery you can track in real time.'**
  String get aboutWhy1;

  /// No description provided for @aboutWhy2.
  ///
  /// In en, this message translates to:
  /// **'A curated selection of popular and local restaurants.'**
  String get aboutWhy2;

  /// No description provided for @aboutWhy3.
  ///
  /// In en, this message translates to:
  /// **'Clear pricing and secure checkout.'**
  String get aboutWhy3;

  /// No description provided for @aboutWhy4.
  ///
  /// In en, this message translates to:
  /// **'Support when you need it.'**
  String get aboutWhy4;

  /// No description provided for @aboutWhy5.
  ///
  /// In en, this message translates to:
  /// **'Built for the communities we serve.'**
  String get aboutWhy5;

  /// No description provided for @aboutWhy6.
  ///
  /// In en, this message translates to:
  /// **'Continuous updates and new features.'**
  String get aboutWhy6;

  /// No description provided for @aboutStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Loqma by the numbers'**
  String get aboutStatsTitle;

  /// No description provided for @aboutStat1Num.
  ///
  /// In en, this message translates to:
  /// **'500+'**
  String get aboutStat1Num;

  /// No description provided for @aboutStat1Label.
  ///
  /// In en, this message translates to:
  /// **'Restaurant partners'**
  String get aboutStat1Label;

  /// No description provided for @aboutStat2Num.
  ///
  /// In en, this message translates to:
  /// **'50K+'**
  String get aboutStat2Num;

  /// No description provided for @aboutStat2Label.
  ///
  /// In en, this message translates to:
  /// **'Orders delivered'**
  String get aboutStat2Label;

  /// No description provided for @aboutStat3Num.
  ///
  /// In en, this message translates to:
  /// **'24/7'**
  String get aboutStat3Num;

  /// No description provided for @aboutStat3Label.
  ///
  /// In en, this message translates to:
  /// **'Customer support'**
  String get aboutStat3Label;

  /// No description provided for @aboutStat4Num.
  ///
  /// In en, this message translates to:
  /// **'100%'**
  String get aboutStat4Num;

  /// No description provided for @aboutStat4Label.
  ///
  /// In en, this message translates to:
  /// **'Commitment to you'**
  String get aboutStat4Label;

  /// No description provided for @aboutCoverageTitle.
  ///
  /// In en, this message translates to:
  /// **'Service coverage'**
  String get aboutCoverageTitle;

  /// No description provided for @aboutCoverageDesc.
  ///
  /// In en, this message translates to:
  /// **'We are expanding across cities and neighbourhoods. Enter your address in the app to see restaurants available near you.'**
  String get aboutCoverageDesc;

  /// No description provided for @aboutCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a question?'**
  String get aboutCtaTitle;

  /// No description provided for @aboutCtaBtn.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get aboutCtaBtn;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @contactDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactDocumentTitle;

  /// No description provided for @contactHero.
  ///
  /// In en, this message translates to:
  /// **'We are here to help'**
  String get contactHero;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reach our team by phone, email, or the form below.'**
  String get contactSubtitle;

  /// No description provided for @contactNavReachTooltip.
  ///
  /// In en, this message translates to:
  /// **'Phone, email, and office locations'**
  String get contactNavReachTooltip;

  /// No description provided for @contactNavFormTooltip.
  ///
  /// In en, this message translates to:
  /// **'Message form'**
  String get contactNavFormTooltip;

  /// No description provided for @contactNavFaqTooltip.
  ///
  /// In en, this message translates to:
  /// **'Common questions'**
  String get contactNavFaqTooltip;

  /// No description provided for @contactNavOverviewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Contact details and form'**
  String get contactNavOverviewTooltip;

  /// No description provided for @contactCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get contactCallTitle;

  /// No description provided for @contactCallOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get contactCallOffice;

  /// No description provided for @contactCallMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get contactCallMobile;

  /// No description provided for @contactEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmailTitle;

  /// No description provided for @contactEmailGeneral.
  ///
  /// In en, this message translates to:
  /// **'General inquiries'**
  String get contactEmailGeneral;

  /// No description provided for @contactEmailSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get contactEmailSupport;

  /// No description provided for @contactVisitTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit us'**
  String get contactVisitTitle;

  /// No description provided for @contactVisitMazarLabel.
  ///
  /// In en, this message translates to:
  /// **'Mazar-e-Sharif'**
  String get contactVisitMazarLabel;

  /// No description provided for @contactVisitMazarBody.
  ///
  /// In en, this message translates to:
  /// **'Mazar intersection, Zinat Plaza (Azizi Bank Central), 4th floor, Salayan Company, Mazar-e-Sharif.'**
  String get contactVisitMazarBody;

  /// No description provided for @contactVisitKabulLabel.
  ///
  /// In en, this message translates to:
  /// **'Kabul'**
  String get contactVisitKabulLabel;

  /// No description provided for @contactVisitKabulBody.
  ///
  /// In en, this message translates to:
  /// **'Shahr-e-Naw, next to Atoma Company, Clock Tower, 5th floor, Salayan Company, Kabul.'**
  String get contactVisitKabulBody;

  /// No description provided for @contactFollowTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get contactFollowTitle;

  /// No description provided for @contactHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Business hours'**
  String get contactHoursTitle;

  /// No description provided for @contactHoursDays.
  ///
  /// In en, this message translates to:
  /// **'Monday – Saturday'**
  String get contactHoursDays;

  /// No description provided for @contactHoursTime.
  ///
  /// In en, this message translates to:
  /// **'8:00 AM – 8:00 PM'**
  String get contactHoursTime;

  /// No description provided for @contactHoursNote.
  ///
  /// In en, this message translates to:
  /// **'Hours may vary on public holidays.'**
  String get contactHoursNote;

  /// No description provided for @contactFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Send us a message'**
  String get contactFormTitle;

  /// No description provided for @contactFormName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get contactFormName;

  /// No description provided for @contactFormEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactFormEmail;

  /// No description provided for @contactFormPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get contactFormPhone;

  /// No description provided for @contactFormSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get contactFormSubject;

  /// No description provided for @contactFormSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Select a topic'**
  String get contactFormSubjectHint;

  /// No description provided for @contactFormSubjectGeneral.
  ///
  /// In en, this message translates to:
  /// **'General inquiry'**
  String get contactFormSubjectGeneral;

  /// No description provided for @contactFormSubjectSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer support'**
  String get contactFormSubjectSupport;

  /// No description provided for @contactFormSubjectPartnership.
  ///
  /// In en, this message translates to:
  /// **'Restaurant / partnership'**
  String get contactFormSubjectPartnership;

  /// No description provided for @contactFormSubjectDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver inquiry'**
  String get contactFormSubjectDriver;

  /// No description provided for @contactFormSubjectComplaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get contactFormSubjectComplaint;

  /// No description provided for @contactFormSubjectFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get contactFormSubjectFeedback;

  /// No description provided for @contactFormSubjectOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get contactFormSubjectOther;

  /// No description provided for @contactFormMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactFormMessage;

  /// No description provided for @contactFormSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get contactFormSubmit;

  /// No description provided for @contactFormSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your email app should open with your message.'**
  String get contactFormSuccessSnackbar;

  /// No description provided for @contactFormSubjectError.
  ///
  /// In en, this message translates to:
  /// **'Please choose a subject.'**
  String get contactFormSubjectError;

  /// No description provided for @contactFormRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get contactFormRequired;

  /// No description provided for @contactFormEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get contactFormEmailInvalid;

  /// No description provided for @contactEmailSubjectPrefix.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactEmailSubjectPrefix;

  /// No description provided for @contactSocialSoon.
  ///
  /// In en, this message translates to:
  /// **'Social link coming soon.'**
  String get contactSocialSoon;

  /// No description provided for @contactFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get contactFaqTitle;

  /// No description provided for @contactFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I track my order?'**
  String get contactFaq1Q;

  /// No description provided for @contactFaq1A.
  ///
  /// In en, this message translates to:
  /// **'Open Orders in the app and select your order to see live status and delivery updates.'**
  String get contactFaq1A;

  /// No description provided for @contactFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'How do I change my delivery address?'**
  String get contactFaq2Q;

  /// No description provided for @contactFaq2A.
  ///
  /// In en, this message translates to:
  /// **'Before checkout you can pick a saved address or add a new one. After ordering, contact support as soon as possible.'**
  String get contactFaq2A;

  /// No description provided for @contactFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'What payment methods are supported?'**
  String get contactFaq3Q;

  /// No description provided for @contactFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Available options are shown at checkout and may include cash on delivery and online payment where enabled.'**
  String get contactFaq3A;

  /// No description provided for @contactFaq4Q.
  ///
  /// In en, this message translates to:
  /// **'How do I partner as a restaurant?'**
  String get contactFaq4Q;

  /// No description provided for @contactFaq4A.
  ///
  /// In en, this message translates to:
  /// **'Choose “Restaurant / partnership” in the form and our team will follow up with onboarding details.'**
  String get contactFaq4A;

  /// No description provided for @contactFaq5Q.
  ///
  /// In en, this message translates to:
  /// **'How quickly will you respond?'**
  String get contactFaq5Q;

  /// No description provided for @contactFaq5A.
  ///
  /// In en, this message translates to:
  /// **'We aim to reply within one business day. For urgent order issues, call the support number listed above.'**
  String get contactFaq5A;

  /// No description provided for @totalEarningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total earnings'**
  String get totalEarningsLabel;

  /// No description provided for @pendingPayoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending payout'**
  String get pendingPayoutLabel;

  /// No description provided for @totalDeliveriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total deliveries'**
  String get totalDeliveriesLabel;

  /// No description provided for @ratingStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingStatLabel;

  /// No description provided for @todaysEarningsLabel.
  ///
  /// In en, this message translates to:
  /// **'Today\'s earnings'**
  String get todaysEarningsLabel;

  /// No description provided for @thisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeekLabel;

  /// No description provided for @driverOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get driverOfflineTitle;

  /// No description provided for @driverActiveDeliveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'You have active deliveries'**
  String get driverActiveDeliveriesTitle;

  /// No description provided for @driverNoOrdersReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders ready for pickup'**
  String get driverNoOrdersReadyTitle;

  /// No description provided for @clearAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllTooltip;

  /// No description provided for @reopenAction.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopenAction;

  /// No description provided for @refreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshTooltip;

  /// No description provided for @addressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address saved'**
  String get addressSavedSuccess;

  /// No description provided for @addressUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get addressUpdatedSuccess;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInformation;

  /// No description provided for @deliveryAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Delivery and payment'**
  String get deliveryAndPayment;

  /// No description provided for @locationSection.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationSection;

  /// No description provided for @operatingHours.
  ///
  /// In en, this message translates to:
  /// **'Operating hours'**
  String get operatingHours;

  /// No description provided for @todayOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Today orders'**
  String get todayOrdersLabel;

  /// No description provided for @todayRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Today revenue'**
  String get todayRevenueLabel;

  /// No description provided for @pendingOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending orders'**
  String get pendingOrdersLabel;

  /// No description provided for @tapOpenSupportTicket.
  ///
  /// In en, this message translates to:
  /// **'Tap to open support ticket'**
  String get tapOpenSupportTicket;

  /// No description provided for @tapViewOrderNotification.
  ///
  /// In en, this message translates to:
  /// **'Tap to view order'**
  String get tapViewOrderNotification;

  /// No description provided for @noLineItems.
  ///
  /// In en, this message translates to:
  /// **'No line items'**
  String get noLineItems;

  /// No description provided for @pleaseWaitProcessing.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pleaseWaitProcessing;

  /// No description provided for @districtHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Karte-e-Char'**
  String get districtHint;

  /// No description provided for @streetHint.
  ///
  /// In en, this message translates to:
  /// **'Street name and number'**
  String get streetHint;

  /// No description provided for @deliveryNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ring doorbell, call on arrival'**
  String get deliveryNotesHint;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @driverDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver dashboard'**
  String get driverDashboardTitle;

  /// No description provided for @driverVehicleInformation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle information'**
  String get driverVehicleInformation;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type (e.g., motorcycle, car)'**
  String get vehicleTypeLabel;

  /// No description provided for @vehicleModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle model'**
  String get vehicleModelLabel;

  /// No description provided for @vehicleColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle color'**
  String get vehicleColorLabel;

  /// No description provided for @licensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get licensePlateLabel;

  /// No description provided for @driverMinimumPayoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Minimum payout amount is {amount}. Keep delivering to reach the threshold!'**
  String driverMinimumPayoutMessage(String amount);

  /// No description provided for @driverReadyForPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for payout!'**
  String get driverReadyForPayoutTitle;

  /// No description provided for @driverPayoutAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {amount} available for withdrawal.'**
  String driverPayoutAvailableMessage(String amount);

  /// No description provided for @driverEarningLabel.
  ///
  /// In en, this message translates to:
  /// **'earning'**
  String get driverEarningLabel;

  /// No description provided for @reviewsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} reviews'**
  String reviewsCountLabel(String count);

  /// No description provided for @driverActiveDeliveriesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Active deliveries'**
  String get driverActiveDeliveriesSectionTitle;

  /// No description provided for @driverEarningPrefix.
  ///
  /// In en, this message translates to:
  /// **'Earning:'**
  String get driverEarningPrefix;

  /// No description provided for @driverAvailableOrdersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Available orders'**
  String get driverAvailableOrdersSectionTitle;

  /// No description provided for @driverOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Go online to start receiving delivery requests.'**
  String get driverOfflineBody;

  /// No description provided for @driverBusyDeliveriesBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your current deliveries to receive new orders.'**
  String get driverBusyDeliveriesBody;

  /// No description provided for @driverNoOrdersReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Orders will appear here when restaurants mark them as ready.'**
  String get driverNoOrdersReadyBody;

  /// No description provided for @driverUpcomingOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming orders'**
  String get driverUpcomingOrdersTitle;

  /// No description provided for @driverUpcomingOrdersHint.
  ///
  /// In en, this message translates to:
  /// **'These orders will be available for pickup once restaurants mark them as ready.'**
  String get driverUpcomingOrdersHint;

  /// No description provided for @recentDeliveriesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent deliveries'**
  String get recentDeliveriesSectionTitle;

  /// No description provided for @restaurantOpenAcceptingOrders.
  ///
  /// In en, this message translates to:
  /// **'Your restaurant is currently accepting orders.'**
  String get restaurantOpenAcceptingOrders;

  /// No description provided for @restaurantCurrentlyClosedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your restaurant is currently closed.'**
  String get restaurantCurrentlyClosedNotice;

  /// No description provided for @restaurantPendingApprovalNotice.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review. Complete your settings and wait for approval.'**
  String get restaurantPendingApprovalNotice;

  /// No description provided for @restaurantApplicationRejectedNotice.
  ///
  /// In en, this message translates to:
  /// **'Your restaurant application was rejected. Update your details in settings and contact support if needed.'**
  String get restaurantApplicationRejectedNotice;

  /// No description provided for @restaurantNewOrdersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'New orders'**
  String get restaurantNewOrdersSectionTitle;

  /// No description provided for @restaurantActiveOrdersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get restaurantActiveOrdersSectionTitle;

  /// No description provided for @restaurantNoPendingOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No pending orders right now.'**
  String get restaurantNoPendingOrdersSubtitle;

  /// No description provided for @restaurantNoActiveOrdersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No active orders right now.'**
  String get restaurantNoActiveOrdersSubtitle;

  /// No description provided for @rejectOrderAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectOrderAction;

  /// No description provided for @partnerAccountStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active partner account'**
  String get partnerAccountStatusActive;

  /// No description provided for @partnerAccountStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get partnerAccountStatusPending;

  /// No description provided for @partnerAccountStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get partnerAccountStatusRejected;

  /// No description provided for @adminHesabPayLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load HesabPay payments.'**
  String get adminHesabPayLoadError;

  /// No description provided for @adminNoHesabPayPayments.
  ///
  /// In en, this message translates to:
  /// **'No HesabPay payments found yet.'**
  String get adminNoHesabPayPayments;

  /// No description provided for @hesabPayPaymentOrderHeader.
  ///
  /// In en, this message translates to:
  /// **'HesabPay payment {order}'**
  String hesabPayPaymentOrderHeader(String order);

  /// No description provided for @paymentImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment image'**
  String get paymentImageLabel;

  /// No description provided for @summaryAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get summaryAmountLabel;

  /// No description provided for @summaryCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get summaryCustomerLabel;

  /// No description provided for @summaryCreatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get summaryCreatedAtLabel;

  /// No description provided for @summaryTransactionRefLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction ref'**
  String get summaryTransactionRefLabel;

  /// No description provided for @ticketReplySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get ticketReplySectionTitle;

  /// No description provided for @ticketMessagesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get ticketMessagesEmptyHint;

  /// No description provided for @ticketAssignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned to: {name}'**
  String ticketAssignedTo(String name);

  /// No description provided for @ticketClosedStateMessage.
  ///
  /// In en, this message translates to:
  /// **'This ticket is closed.'**
  String get ticketClosedStateMessage;

  /// No description provided for @hoursOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get hoursOpenLabel;

  /// No description provided for @hoursCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get hoursCloseLabel;

  /// No description provided for @deliveryFeeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFeeFieldLabel;

  /// No description provided for @minimumOrderFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum order'**
  String get minimumOrderFieldLabel;

  /// No description provided for @freeDeliveryAboveFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Free delivery above'**
  String get freeDeliveryAboveFieldLabel;

  /// No description provided for @averagePrepTimeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Average preparation time'**
  String get averagePrepTimeFieldLabel;

  /// No description provided for @coordinatesSavedHint.
  ///
  /// In en, this message translates to:
  /// **'Coordinates saved with this address: {lat}, {lng}'**
  String coordinatesSavedHint(String lat, String lng);

  /// No description provided for @useCurrentLocationAction.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocationAction;

  /// No description provided for @gettingLocationEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Getting location…'**
  String get gettingLocationEllipsis;

  /// No description provided for @deliveryInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery instructions'**
  String get deliveryInstructionsLabel;

  /// No description provided for @addressLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get addressLabelShort;

  /// No description provided for @cityRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'City *'**
  String get cityRequiredLabel;

  /// No description provided for @requiredFieldIndicator.
  ///
  /// In en, this message translates to:
  /// **'*'**
  String get requiredFieldIndicator;

  /// No description provided for @streetAddressRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Street address *'**
  String get streetAddressRequiredLabel;

  /// No description provided for @streetAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street name and number'**
  String get streetAddressHint;

  /// No description provided for @buildingFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get buildingFieldLabel;

  /// No description provided for @floorFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floorFieldLabel;

  /// No description provided for @apartmentFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartmentFieldLabel;

  /// No description provided for @areaFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaFieldLabel;

  /// No description provided for @editAddressScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddressScreenTitle;

  /// No description provided for @updateAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Update address'**
  String get updateAddressButton;

  /// No description provided for @saveAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get saveAddressButton;

  /// No description provided for @addressChooseCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get addressChooseCityTitle;

  /// No description provided for @addressChooseCitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We currently deliver in these cities.'**
  String get addressChooseCitySubtitle;

  /// No description provided for @addressChooseDistrictTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your district'**
  String get addressChooseDistrictTitle;

  /// No description provided for @addressChooseDistrictSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a district in {city}.'**
  String addressChooseDistrictSubtitle(String city);

  /// No description provided for @addressStreetDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Street details'**
  String get addressStreetDetailsTitle;

  /// No description provided for @addressStreetDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your street and house number in {district}, {city}.'**
  String addressStreetDetailsSubtitle(String district, String city);

  /// No description provided for @addressStreetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Street name & number'**
  String get addressStreetNameLabel;

  /// No description provided for @addressStreetNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Street 5, block 12'**
  String get addressStreetNameHint;

  /// No description provided for @addressHouseNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'House / office number'**
  String get addressHouseNumberLabel;

  /// No description provided for @addressHouseNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. House 24 or Office 3'**
  String get addressHouseNumberHint;

  /// No description provided for @addressStreetRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your street name.'**
  String get addressStreetRequired;

  /// No description provided for @addressHouseNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your house or office number.'**
  String get addressHouseNumberRequired;

  /// No description provided for @addressNoCitiesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No delivery cities are available right now.'**
  String get addressNoCitiesAvailable;

  /// No description provided for @addressNoDistrictsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No districts found for this city.'**
  String get addressNoDistrictsAvailable;

  /// No description provided for @addressProfileNamePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Your profile name and phone are required to save an address.'**
  String get addressProfileNamePhoneRequired;

  /// No description provided for @addItemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItemTooltip;

  /// No description provided for @addCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryTooltip;

  /// No description provided for @newCategoryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategoryDialogTitle;

  /// No description provided for @editCategoryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategoryDialogTitle;

  /// No description provided for @categoryNameFaLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (Dari)'**
  String get categoryNameFaLabel;

  /// No description provided for @newMenuItemTitle.
  ///
  /// In en, this message translates to:
  /// **'New menu item'**
  String get newMenuItemTitle;

  /// No description provided for @editMenuItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit menu item'**
  String get editMenuItemTitle;

  /// No description provided for @foodCategoryDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get foodCategoryDropdownLabel;

  /// No description provided for @discountedPriceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Discounted price'**
  String get discountedPriceFieldLabel;

  /// No description provided for @preparationTimeMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Preparation time'**
  String get preparationTimeMinutesLabel;

  /// No description provided for @menuItemHasSizesLabel.
  ///
  /// In en, this message translates to:
  /// **'Offer sizes (Kids, Small, Medium, Large, Family)'**
  String get menuItemHasSizesLabel;

  /// No description provided for @menuItemSmallPriceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a price only for sizes you offer. Leave blank to skip — Small is not selected by default.'**
  String get menuItemSmallPriceHint;

  /// No description provided for @menuItemKidsPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Kids price (optional)'**
  String get menuItemKidsPriceLabel;

  /// No description provided for @menuItemSmallPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Small price (optional)'**
  String get menuItemSmallPriceLabel;

  /// No description provided for @menuItemMediumPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium price (optional)'**
  String get menuItemMediumPriceLabel;

  /// No description provided for @menuItemLargePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Large price (optional)'**
  String get menuItemLargePriceLabel;

  /// No description provided for @menuItemFamilyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Family Size price (optional)'**
  String get menuItemFamilyPriceLabel;

  /// No description provided for @menuItemSizesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Sizes available'**
  String get menuItemSizesAvailable;

  /// No description provided for @offerLabelOptionalField.
  ///
  /// In en, this message translates to:
  /// **'Offer label (optional)'**
  String get offerLabelOptionalField;

  /// No description provided for @discountStartOptionalField.
  ///
  /// In en, this message translates to:
  /// **'Discount start (optional)'**
  String get discountStartOptionalField;

  /// No description provided for @discountEndOptionalField.
  ///
  /// In en, this message translates to:
  /// **'Discount end (optional)'**
  String get discountEndOptionalField;

  /// No description provided for @discountedPriceCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Discounted price (AFN)'**
  String get discountedPriceCurrencyHint;

  /// No description provided for @labelOptionalField.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get labelOptionalField;

  /// No description provided for @discountedMustBeBelowRegular.
  ///
  /// In en, this message translates to:
  /// **'Discounted price must be less than regular price ({regular}).'**
  String discountedMustBeBelowRegular(String regular);

  /// No description provided for @specialOfferDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Special offer: {itemName}'**
  String specialOfferDialogTitle(String itemName);

  /// No description provided for @specialOfferTooltip.
  ///
  /// In en, this message translates to:
  /// **'Special offer'**
  String get specialOfferTooltip;

  /// No description provided for @descriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionFieldLabel;

  /// No description provided for @defaultLocationStreetFallback.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get defaultLocationStreetFallback;

  /// No description provided for @coordinateLatitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get coordinateLatitudeLabel;

  /// No description provided for @coordinateLongitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get coordinateLongitudeLabel;

  /// No description provided for @restaurantStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get restaurantStatusOpen;

  /// No description provided for @restaurantStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get restaurantStatusClosed;

  /// No description provided for @prepTimeRange.
  ///
  /// In en, this message translates to:
  /// **'{low}–{high} min'**
  String prepTimeRange(String low, String high);

  /// No description provided for @prepTimeDefault.
  ///
  /// In en, this message translates to:
  /// **'35–45 min'**
  String get prepTimeDefault;

  /// No description provided for @cartFabWithCount.
  ///
  /// In en, this message translates to:
  /// **'Cart, {count} items'**
  String cartFabWithCount(int count);

  /// No description provided for @mainNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home tab'**
  String get mainNavHome;

  /// No description provided for @mainNavOffers.
  ///
  /// In en, this message translates to:
  /// **'Offers tab'**
  String get mainNavOffers;

  /// No description provided for @mainNavFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites tab'**
  String get mainNavFavorites;

  /// No description provided for @mainNavOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders tab'**
  String get mainNavOrders;

  /// No description provided for @cartQtyLine.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity}'**
  String cartQtyLine(int quantity);

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @cartFromRestaurant.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String cartFromRestaurant(String name);

  /// No description provided for @adminSuperPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Admin Payments'**
  String get adminSuperPaymentsTitle;

  /// No description provided for @adminRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminRefresh;

  /// No description provided for @adminCouldNotLoadPayments.
  ///
  /// In en, this message translates to:
  /// **'Could not load HesabPay payments.'**
  String get adminCouldNotLoadPayments;

  /// No description provided for @adminHesabPayPaymentOrder.
  ///
  /// In en, this message translates to:
  /// **'HesabPay payment {order}'**
  String adminHesabPayPaymentOrder(String order);

  /// No description provided for @adminRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get adminRestaurant;

  /// No description provided for @adminCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get adminCustomer;

  /// No description provided for @adminAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get adminAmount;

  /// No description provided for @adminPaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get adminPaymentStatus;

  /// No description provided for @adminViewPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'View full payment details'**
  String get adminViewPaymentDetails;

  /// No description provided for @adminOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get adminOrderId;

  /// No description provided for @adminCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get adminCreatedAt;

  /// No description provided for @adminPaymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get adminPaymentDetails;

  /// No description provided for @ordersTabFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter orders'**
  String get ordersTabFilterTooltip;

  /// No description provided for @ordersTabShowOrders.
  ///
  /// In en, this message translates to:
  /// **'Show orders'**
  String get ordersTabShowOrders;

  /// No description provided for @ordersTabFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All orders'**
  String get ordersTabFilterAll;

  /// No description provided for @ordersTabFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active only'**
  String get ordersTabFilterActive;

  /// No description provided for @ordersTabFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ordersTabFilterCompleted;

  /// No description provided for @ordersTabFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get ordersTabFilterCancelled;

  /// No description provided for @ordersTabSectionActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ORDERS'**
  String get ordersTabSectionActive;

  /// No description provided for @ordersTabSectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED ORDERS'**
  String get ordersTabSectionCompleted;

  /// No description provided for @ordersTabSectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get ordersTabSectionCancelled;

  /// No description provided for @ordersTabReviewsNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order needs your review} other{{count} orders need your review}}'**
  String ordersTabReviewsNeeded(int count);

  /// No description provided for @ordersTabPlacedRelative.
  ///
  /// In en, this message translates to:
  /// **'Placed {time}'**
  String ordersTabPlacedRelative(String time);

  /// No description provided for @ordersTabDefaultDeliveryWindow.
  ///
  /// In en, this message translates to:
  /// **'35-45 min'**
  String get ordersTabDefaultDeliveryWindow;

  /// No description provided for @ordersTabMapLegendRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Rest.'**
  String get ordersTabMapLegendRestaurant;

  /// No description provided for @ordersTabMapLegendDestination.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get ordersTabMapLegendDestination;

  /// No description provided for @relativeTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeTimeJustNow;

  /// No description provided for @relativeTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String relativeTimeMinutesAgo(int count);

  /// No description provided for @relativeTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hr ago'**
  String relativeTimeHoursAgo(int count);

  /// No description provided for @relativeTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String relativeTimeDaysAgo(int count);

  /// No description provided for @relativeTimeWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} w ago'**
  String relativeTimeWeeksAgo(int count);

  /// No description provided for @relativeTimeMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} mo ago'**
  String relativeTimeMonthsAgo(int count);

  /// No description provided for @relativeTimeYearsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} y ago'**
  String relativeTimeYearsAgo(int count);

  /// No description provided for @restaurantMenuEmpty.
  ///
  /// In en, this message translates to:
  /// **'No menu items available yet.'**
  String get restaurantMenuEmpty;

  /// No description provided for @restaurantMenuSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No menu items match your search.'**
  String get restaurantMenuSearchNoResults;

  /// No description provided for @restaurantDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this restaurant.'**
  String get restaurantDetailsLoadFailed;

  /// No description provided for @reviewAnonymousCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get reviewAnonymousCustomer;

  /// No description provided for @menuItemAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get menuItemAddToCart;

  /// No description provided for @menuItemOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get menuItemOptionsLabel;

  /// No description provided for @menuItemAddonsLabel.
  ///
  /// In en, this message translates to:
  /// **'Add-ons'**
  String get menuItemAddonsLabel;

  /// No description provided for @menuItemQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get menuItemQuantityLabel;

  /// No description provided for @profileTabEditHint.
  ///
  /// In en, this message translates to:
  /// **'View and edit your profile'**
  String get profileTabEditHint;

  /// No description provided for @profileTabOpenAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileTabOpenAccount;

  /// No description provided for @profileTabNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Open dashboard'**
  String get profileTabNavDashboard;

  /// No description provided for @profileTabNavOrders.
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get profileTabNavOrders;

  /// No description provided for @profileTabNavAddresses.
  ///
  /// In en, this message translates to:
  /// **'Open saved addresses'**
  String get profileTabNavAddresses;

  /// No description provided for @profileTabNavFavorites.
  ///
  /// In en, this message translates to:
  /// **'Open favorites'**
  String get profileTabNavFavorites;

  /// No description provided for @profileTabNavNotifications.
  ///
  /// In en, this message translates to:
  /// **'Open notifications'**
  String get profileTabNavNotifications;

  /// No description provided for @profileTabNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get profileTabNavSettings;

  /// No description provided for @profileTabNavLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileTabNavLogout;

  /// No description provided for @restaurantDetailsSignInForFavorites.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to save restaurants to your favorites.'**
  String get restaurantDetailsSignInForFavorites;

  /// No description provided for @restaurantDetailsFavoritesSnackbarTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get restaurantDetailsFavoritesSnackbarTitle;

  /// No description provided for @favoritesRemovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoritesRemovedMessage;

  /// No description provided for @favoritesRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoritesRemoveTooltip;

  /// No description provided for @authEmailOrPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get authEmailOrPhoneHint;

  /// No description provided for @authEnterEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number'**
  String get authEnterEmailOrPhone;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authCompleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get authCompleteProfileTitle;

  /// No description provided for @authCompleteProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your name and phone number to continue.'**
  String get authCompleteProfileSubtitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send a 6-digit reset code.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPasswordTitle;

  /// No description provided for @authEnterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to'**
  String get authEnterResetCode;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authResendCodeInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String authResendCodeInSeconds(int seconds);

  /// No description provided for @authPasswordMinEight.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authPasswordMinEight;

  /// No description provided for @authSendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get authSendResetCode;

  /// No description provided for @authSixDigitCodeHint.
  ///
  /// In en, this message translates to:
  /// **'000000'**
  String get authSixDigitCodeHint;

  /// No description provided for @authSetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get authSetNewPassword;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in with your new password.'**
  String get authPasswordResetSuccess;

  /// No description provided for @authResetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Reset code sent'**
  String get authResetCodeSent;

  /// No description provided for @authYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get authYourLocation;

  /// No description provided for @authRegisterLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Use GPS or type your delivery address manually.'**
  String get authRegisterLocationHint;

  /// No description provided for @authAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, area, city'**
  String get authAddressHint;

  /// No description provided for @authLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your delivery address (at least 5 characters).'**
  String get authLocationRequired;

  /// No description provided for @authEnterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get authEnterSixDigitCode;

  /// No description provided for @authInvalidSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit code.'**
  String get authInvalidSixDigitCode;

  /// No description provided for @couldNotDetectLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not detect your location. Enter your address manually.'**
  String get couldNotDetectLocation;

  /// No description provided for @authOrDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrDivider;

  /// No description provided for @authPleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authPleaseEnterPassword;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Loqma account to start ordering.'**
  String get authRegisterSubtitle;

  /// No description provided for @authPhoneFieldHint.
  ///
  /// In en, this message translates to:
  /// **'07X XXX XXXX'**
  String get authPhoneFieldHint;

  /// No description provided for @authHaveAccountSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authHaveAccountSignIn;

  /// No description provided for @authLoginStepPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue.'**
  String get authLoginStepPhoneHint;

  /// No description provided for @authLoginStepPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to sign in.'**
  String get authLoginStepPasswordHint;

  /// No description provided for @authRegisterStepNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us your name so restaurants know who you are.'**
  String get authRegisterStepNameHint;

  /// No description provided for @authRegisterStepPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this number for delivery updates.'**
  String get authRegisterStepPhoneHint;

  /// No description provided for @authRegisterStepPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a password with at least 8 characters.'**
  String get authRegisterStepPasswordHint;

  /// No description provided for @authRegisterStepConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password to confirm.'**
  String get authRegisterStepConfirmHint;

  /// No description provided for @authForgotPasswordAdminSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your name and phone number. An admin will assign a temporary password for you.'**
  String get authForgotPasswordAdminSubtitle;

  /// No description provided for @authRequestPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Request password reset'**
  String get authRequestPasswordReset;

  /// No description provided for @authPasswordResetRequestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get authPasswordResetRequestSentTitle;

  /// No description provided for @authPasswordResetRequestSentBody.
  ///
  /// In en, this message translates to:
  /// **'Your request was sent to the admin panel. Once they set a temporary password, sign in with it and change your password.'**
  String get authPasswordResetRequestSentBody;

  /// No description provided for @authAdminDefaultPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary password assigned'**
  String get authAdminDefaultPasswordTitle;

  /// No description provided for @authAdminDefaultPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Your password is a default password assigned by the admin. Please change it now to keep your account secure.'**
  String get authAdminDefaultPasswordBody;

  /// No description provided for @authThisIsYourNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'This is your new password'**
  String get authThisIsYourNewPasswordTitle;

  /// No description provided for @authThisIsYourNewPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'An admin assigned this temporary password for you. Sign in with it, then change it to something only you know.'**
  String get authThisIsYourNewPasswordBody;

  /// No description provided for @authUseThisPassword.
  ///
  /// In en, this message translates to:
  /// **'Use this password'**
  String get authUseThisPassword;

  /// No description provided for @authTemporaryPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get authTemporaryPassword;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authPasswordUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get authPasswordUpdatedTitle;

  /// No description provided for @authPasswordUpdatedBody.
  ///
  /// In en, this message translates to:
  /// **'Your new password is set. You can continue ordering.'**
  String get authPasswordUpdatedBody;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email/phone or password is incorrect. Please try again.'**
  String get authInvalidCredentials;

  /// No description provided for @authCheckPasswordAgain.
  ///
  /// In en, this message translates to:
  /// **'Double-check your password and try again.'**
  String get authCheckPasswordAgain;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Sign in instead.'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authPhoneAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered. Sign in instead.'**
  String get authPhoneAlreadyRegistered;

  /// No description provided for @authValidationFixFields.
  ///
  /// In en, this message translates to:
  /// **'Please fix the highlighted fields and try again.'**
  String get authValidationFixFields;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a moment and try again.'**
  String get authTooManyAttempts;

  /// No description provided for @authGoogleCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled.'**
  String get authGoogleCancelled;

  /// No description provided for @authGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google. Please try again.'**
  String get authGoogleFailed;

  /// No description provided for @authGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In is not set up yet. Add the app SHA-1 and a Web client ID in Firebase / Google Cloud, then try again.'**
  String get authGoogleNotConfigured;

  /// No description provided for @authGoogleNoIdToken.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In could not get an ID token. Add a Web OAuth client ID (serverClientId) and the app SHA-1 fingerprint in Firebase.'**
  String get authGoogleNoIdToken;

  /// No description provided for @authSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authSomethingWentWrong;

  /// No description provided for @authNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your network and try again.'**
  String get authNoInternet;

  /// No description provided for @authServerSlow.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long. Please try again.'**
  String get authServerSlow;

  /// No description provided for @authServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Server is temporarily unavailable. Please try again shortly.'**
  String get authServerUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa', 'ps'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'ps':
      return AppLocalizationsPs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
