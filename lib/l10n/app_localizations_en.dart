// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'لقمه';

  @override
  String get foodDelivery => 'Food delivery';

  @override
  String get deliveryTo => 'Delivery to';

  @override
  String get searchHint => 'Search delicious food...';

  @override
  String get categories => 'Categories';

  @override
  String get viewAll => 'View All';

  @override
  String get restaurants => 'Restaurants';

  @override
  String get clear => 'Clear';

  @override
  String get topRestaurants => 'Top Restaurants';

  @override
  String get seeAll => 'See All';

  @override
  String get freeDelivery => 'Free Delivery';

  @override
  String get featured => 'Featured';

  @override
  String get all => 'All';

  @override
  String get retry => 'Retry';

  @override
  String get freeDeliveryLabel => 'Free delivery';

  @override
  String deliveryFeeLabel(String amount) {
    return '$amount delivery fee';
  }

  @override
  String minLabel(String minutes) {
    return '$minutes min';
  }

  @override
  String minRangeLabel(String low, String high) {
    return '$low–$high min';
  }

  @override
  String get restaurantOpenBadge => 'OPEN';

  @override
  String get restaurantClosedBadge => 'CLOSED';

  @override
  String get orderNow => 'Order Now';

  @override
  String get loadingEllipsis => '…';

  @override
  String get ordersFilterTitle => 'Show orders';

  @override
  String get ordersFilterAll => 'All orders';

  @override
  String get ordersFilterActiveOnly => 'Active only';

  @override
  String get ordersFilterCompleted => 'Completed';

  @override
  String get ordersFilterCancelled => 'Cancelled';

  @override
  String get ordersFilterTooltip => 'Filter orders';

  @override
  String get ordersSectionActive => 'ACTIVE ORDERS';

  @override
  String get ordersSectionCompleted => 'COMPLETED ORDERS';

  @override
  String get ordersSectionCancelled => 'CANCELLED';

  @override
  String orderPlacedAt(String when) {
    return 'Placed $when';
  }

  @override
  String get orderRelativeJustNow => 'just now';

  @override
  String orderRelativeMinutesAgo(String count) {
    return '$count min ago';
  }

  @override
  String orderRelativeHoursAgo(String count) {
    return '$count hr ago';
  }

  @override
  String orderRelativeDaysAgo(String count) {
    return '$count days ago';
  }

  @override
  String get orderStatusActiveGeneric => 'Active';

  @override
  String get orderCallRider => 'Call rider';

  @override
  String get orderMapLegendRestaurant => 'Rest.';

  @override
  String get orderMapLegendYou => 'You';

  @override
  String get ordersReviewBannerOne => '1 order needs your review';

  @override
  String ordersReviewBannerMany(String count) {
    return '$count orders need your review';
  }

  @override
  String qtyWithCount(String label, String count) {
    return '$label: $count';
  }

  @override
  String get navOffers => 'Offers';

  @override
  String get navFavs => 'Favs';

  @override
  String get home => 'Home';

  @override
  String get orders => 'Orders';

  @override
  String get profile => 'Profile';

  @override
  String get cart => 'Cart';

  @override
  String get cartBadgeMax => '99+';

  @override
  String get cartFabTooltip => 'Cart';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get phone => 'Phone';

  @override
  String get profileTitle => 'Profile';

  @override
  String get addresses => 'Addresses';

  @override
  String get favorites => 'Favorites';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get settingsHeroSubtitle =>
      'Appearance, language, and legal information.';

  @override
  String get settingsNavDisplay => 'Display & preferences';

  @override
  String get settingsNavLanguage => 'Language';

  @override
  String get settingsNavAbout => 'About & legal';

  @override
  String get logout => 'Logout';

  @override
  String get myOrders => 'My Orders';

  @override
  String get browseRestaurants => 'Browse restaurants';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get goBack => 'Go back';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get delivery => 'Delivery';

  @override
  String get total => 'Total';

  @override
  String get qty => 'Qty';

  @override
  String get viewCartCheckout => 'View cart & checkout';

  @override
  String get checkout => 'Checkout';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get selectOrAddAddress => 'Select or add address';

  @override
  String get deliveryLocationPromptTitle => 'Add your delivery address';

  @override
  String get deliveryLocationPromptSubtitle =>
      'Choose your city and area so we can show nearby restaurants and deliver to your door.';

  @override
  String get deliveryLocationPromptAction => 'Add address';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cashOnDelivery => 'Cash on delivery';

  @override
  String get card => 'Card';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get orderPlacedSnackbar => 'Your order has been placed successfully.';

  @override
  String itemAddedToCart(String item) {
    return '$item added to cart';
  }

  @override
  String cartDifferentRestaurantMessage(String restaurant) {
    return 'Your cart already has items from $restaurant. Please complete that order or clear your cart before ordering from another restaurant.';
  }

  @override
  String get darkMode => 'Dark mode';

  @override
  String get useDarkTheme => 'Use dark theme';

  @override
  String get notificationsSetting => 'Notifications';

  @override
  String get pushAndInApp => 'Push and in-app';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get languageSelectionTitle => 'Choose your language';

  @override
  String get languageSelectionSubtitle =>
      'Select the language you want to use in the app.';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyPolicyHeroSubtitle =>
      'How we collect, use, and protect your information across our platform.';

  @override
  String get terms => 'Terms';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get termsHeroSubtitle =>
      'Rules for using Loqma, orders, delivery, and your account.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountSettingsSubtitle =>
      'Request permanent account removal';

  @override
  String get deleteAccountIntro =>
      'Your request will be reviewed by our team. If approved, your profile, saved addresses, favorites, and login access will be removed. Order history may be kept for legal compliance.';

  @override
  String get deleteAccountWebPolicyLink =>
      'View account deletion policy online';

  @override
  String get deleteAccountReasonLabel => 'Reason (optional)';

  @override
  String get deleteAccountReasonHint =>
      'Tell us why you want to delete your account';

  @override
  String get deleteAccountSubmit => 'Request deletion';

  @override
  String get deleteAccountConfirmTitle => 'Delete your account?';

  @override
  String get deleteAccountConfirmBody =>
      'Your request will be sent to our team for approval. This action cannot be undone after approval.';

  @override
  String get deleteAccountSubmitted =>
      'Deletion request submitted. We will notify you after review.';

  @override
  String get deleteAccountCancelled => 'Deletion request cancelled.';

  @override
  String get deleteAccountCancelRequest => 'Cancel request';

  @override
  String get deleteAccountCurrentStatus => 'Current request status';

  @override
  String get deleteAccountStatusPending => 'Pending admin approval';

  @override
  String get deleteAccountStatusApproved =>
      'Approved — your account has been deleted';

  @override
  String get deleteAccountStatusRejected => 'Rejected';

  @override
  String get deleteAccountStatusCancelled => 'Cancelled';

  @override
  String get deleteAccountWhatHappens => 'What will be removed';

  @override
  String get deleteAccountMayBeKept => 'May be kept';

  @override
  String get deleteAccountDangerZone => 'Danger zone';

  @override
  String get deleteAccountRemovedProfile =>
      'Profile, phone, and saved addresses';

  @override
  String get deleteAccountRemovedFavorites =>
      'Favorites and notification preferences';

  @override
  String get deleteAccountRemovedAccess => 'Login access to the Loqma app';

  @override
  String get deleteAccountKeptOrders => 'Order history (legal compliance)';

  @override
  String get deleteAccountKeptPayments => 'Payment records if required by law';

  @override
  String get deleteAccountRedirectingToLogin =>
      'Account deleted. Redirecting to sign in…';

  @override
  String get deleteAccountSessionEnded =>
      'Your account has been deleted. Please sign in again with your phone number.';

  @override
  String get signInRequired => 'Sign in required';

  @override
  String get support => 'Support';

  @override
  String get supportTickets => 'Support tickets';

  @override
  String get createTicketHelp => 'Create a ticket for help';

  @override
  String get newTicket => 'New ticket';

  @override
  String get supportTrackManage => 'Track and manage your support requests';

  @override
  String get supportNoTicketsTitle => 'No tickets found';

  @override
  String get supportNoTicketsSubtitle => 'Create a ticket for help';

  @override
  String get ticketFormTitle => 'Submit a Support Request';

  @override
  String get ticketFormSubtitle =>
      'Describe your issue and we\'ll get back to you as soon as possible.';

  @override
  String get ticketSubjectLabel => 'Subject *';

  @override
  String get ticketSubjectHint => 'Brief description of your issue';

  @override
  String get ticketCategoryLabel => 'Category *';

  @override
  String get ticketPriorityLabel => 'Priority *';

  @override
  String get ticketRelatedOrderLabel => 'Related Order (optional)';

  @override
  String get ticketRelatedOrderNone => 'Not related to an order';

  @override
  String get ticketMessageLabel => 'Message *';

  @override
  String get ticketMessageHint => 'Please describe your issue in detail...';

  @override
  String get ticketMessageMinCharsHint => 'Minimum 20 characters';

  @override
  String get ticketCancel => 'Cancel';

  @override
  String get ticketSubmit => 'Submit Ticket';

  @override
  String get ticketSubmitted =>
      'Ticket submitted. We will get back to you soon.';

  @override
  String get ticketMessageTooShort => 'Message must be at least 20 characters';

  @override
  String ticketSubmitFailed(String error) {
    return 'Failed: $error';
  }

  @override
  String get noSavedAddresses => 'No saved addresses';

  @override
  String get addAddressHint => 'Add an address for faster checkout';

  @override
  String get addAddress => 'Add address';

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get favoritesHint => 'Restaurants you like will appear here';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get newNotificationReceived => 'You\'ve received a new notification';

  @override
  String get gotIt => 'Got it';

  @override
  String get fcmChannelName => 'Orders & alerts';

  @override
  String get fcmChannelDescription => 'Delivery and account notifications';

  @override
  String get notificationDefaultTitle => 'Loqma';

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String get pleaseSignInToViewNotifications =>
      'Please sign in to view notifications.';

  @override
  String get notificationOrderConfirmedTitle => 'Order Confirmed';

  @override
  String get notificationOrderPreparingTitle => 'Your Food is Being Prepared';

  @override
  String get notificationOrderReadyTitle => 'Order Ready for Pickup';

  @override
  String get notificationOrderPickedUpTitle => 'Driver Picked Up Your Order';

  @override
  String get notificationOrderOnTheWayTitle => 'Your Order is On The Way';

  @override
  String get notificationOrderDeliveredTitle => 'Order Delivered';

  @override
  String get notificationOrderCancelledTitle => 'Order Cancelled';

  @override
  String get notificationOrderUpdateTitle => 'Order Update';

  @override
  String notificationOrderConfirmedMessage(
    String orderNumber,
    String restaurant,
  ) {
    return 'Your order #$orderNumber from $restaurant has been confirmed and will be prepared soon.';
  }

  @override
  String notificationOrderPreparingMessage(
    String orderNumber,
    String restaurant,
  ) {
    return 'Your order #$orderNumber is now being prepared at $restaurant.';
  }

  @override
  String notificationOrderReadyMessage(String orderNumber) {
    return 'Your order #$orderNumber is ready! A driver will pick it up soon.';
  }

  @override
  String notificationOrderPickedUpMessage(String orderNumber, String driver) {
    return 'Your order #$orderNumber has been picked up by $driver.';
  }

  @override
  String notificationOrderOnTheWayMessage(String orderNumber, String driver) {
    return 'Your order #$orderNumber is on the way! $driver is bringing your food.';
  }

  @override
  String notificationOrderDeliveredMessage(String orderNumber) {
    return 'Your order #$orderNumber has been delivered. Enjoy your meal!';
  }

  @override
  String notificationOrderCancelledMessage(String orderNumber) {
    return 'Your order #$orderNumber has been cancelled.';
  }

  @override
  String notificationOrderUpdateMessage(String orderNumber, String status) {
    return 'Your order #$orderNumber status has been updated to $status.';
  }

  @override
  String get allCaughtUp => 'You\'re all caught up';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileUpdatedSnackbar =>
      'Profile updated (wire to /customer/profile)';

  @override
  String get noOrdersYet => 'No orders yet';

  @override
  String get add => 'Add';

  @override
  String get viewCart => 'View cart';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePashto => 'پښتو';

  @override
  String get languageDari => 'دری';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue ordering';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get fullName => 'Full name';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get authNameTooShort =>
      'Please enter at least 2 characters for your name.';

  @override
  String get authNameTooLong =>
      'That name is too long (maximum 80 characters).';

  @override
  String get authNameLooksLikePhoneNumber =>
      'That looks like a phone number. Enter your name in the name field.';

  @override
  String get authNameMustContainLetters =>
      'Enter a name using letters (not only numbers or symbols).';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get signInToViewProfile => 'Sign in to view profile';

  @override
  String get save => 'Save';

  @override
  String get proceedToCheckout => 'Proceed to checkout';

  @override
  String get cartEmptyHint => 'Add items from a restaurant to get started';

  @override
  String get cannotReachServer => 'Cannot reach server';

  @override
  String get orderHistoryHint => 'Your order history will appear here';

  @override
  String get placeOrder => 'Place order';

  @override
  String get pullToRefreshOrRetry => 'Pull down to refresh or try again';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get customerDashboardSubtitle =>
      'Here\'s what\'s happening with your account today.';

  @override
  String get customerDashboardTotalOrders => 'Total orders';

  @override
  String get customerDashboardActiveOrders => 'Active orders';

  @override
  String get customerDashboardTotalSpent => 'Total spent';

  @override
  String get customerDashboardOpenTickets => 'Open tickets';

  @override
  String get customerDashboardOrderFood => 'Order food';

  @override
  String customerDashboardOrderMeta(String placed, String items) {
    return '$placed · $items';
  }

  @override
  String get orderStatusRefunded => 'Refunded';

  @override
  String get discountCode => 'Discount Code';

  @override
  String get supportTicket => 'Support Ticket';

  @override
  String get search => 'Search';

  @override
  String get foods => 'Foods';

  @override
  String get searchAllHint => 'Search restaurants & food...';

  @override
  String get noResults => 'No results';

  @override
  String get tryDifferentKeywords => 'Try different keywords';

  @override
  String get allRestaurants => 'All Restaurants';

  @override
  String get specialDeals => 'Special Deals';

  @override
  String get orderSummaryCaps => 'ORDER SUMMARY';

  @override
  String get sizeLabel => 'Size';

  @override
  String get promoCodeCopied => 'Promo code copied';

  @override
  String freeDeliveryAboveDeal(String amount) {
    return 'Free delivery on orders above $amount';
  }

  @override
  String deliveryFeeDeal(String amount) {
    return 'Delivery fee: $amount';
  }

  @override
  String get welcomeToLoqma => 'Welcome to Loqma';

  @override
  String get signInWithPhoneWhatsAppOtp =>
      'Sign in with your phone number. We will send a message OTP.';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get continueAction => 'Continue';

  @override
  String get sendRegistrationOtp => 'Send registration OTP';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number.';

  @override
  String get invalidAfghanPhone =>
      'Enter a valid Afghan mobile (07 or +937, then 0–4 or 6–9, e.g. 072 123 4567).';

  @override
  String get testOtpTitle => 'Test OTP';

  @override
  String testOtpUseCode(String code) {
    return 'Use code $code';
  }

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String get otpEnterCodeWhatsApp =>
      'Enter the 3-digit code sent to your message number.';

  @override
  String get otpTestModeDescription =>
      'Test mode is enabled. You can use the code below directly.';

  @override
  String otpTestModeBanner(String code) {
    return 'Test mode is enabled. Use OTP: $code';
  }

  @override
  String get otpCodeLabel => 'OTP code';

  @override
  String get otpCodeHint => '123456';

  @override
  String get verifyAndContinue => 'Verify and continue';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get otpEnterSixDigits => 'Enter the 3-digit OTP code.';

  @override
  String get otpIncompleteCode => 'Enter all 3 digits of the code.';

  @override
  String get otpInvalidCode => 'Enter a valid 3-digit code (numbers only).';

  @override
  String get otpSentAgain => 'OTP sent again';

  @override
  String otpSentAgainTest(String code) {
    return 'OTP sent again. Test code: $code';
  }

  @override
  String get authWhatsYourName => 'What\'s your name?';

  @override
  String get authEnterPhoneNumber => 'Enter phone number';

  @override
  String get authContinue => 'Continue';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authPhoneVerifyHint =>
      'We\'ll send a 3-digit code to verify your identity.';

  @override
  String get authVerification => 'Verification';

  @override
  String get authEnterCodeSentTo => 'Enter the code sent to';

  @override
  String get authVerifyAccount => 'Verify account';

  @override
  String get authResendVerificationCodeUpper => 'RESEND VERIFICATION CODE';

  @override
  String get nameHintExample => 'Ahmad Karimi';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String get updateAvailableMessageDefault =>
      'A new version of the app is available.';

  @override
  String get later => 'Later';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateInstallPermissionMessage =>
      'Allow installing apps from this source (or install unknown apps) to continue.';

  @override
  String get updateCouldNotOpenInstaller => 'Could not open the installer.';

  @override
  String get updateDownloadFailed => 'Download failed.';

  @override
  String get backToOrderDetails => 'Back to order details';

  @override
  String get couldNotLoadTracking => 'Could not load tracking.';

  @override
  String get restaurantDefaultName => 'Restaurant';

  @override
  String get yourLocation => 'Your location';

  @override
  String get mapMarkerRestaurant => 'Restaurant';

  @override
  String get mapMarkerDelivery => 'Delivery';

  @override
  String get mapMarkerDriver => 'Driver';

  @override
  String orderTrackDistanceKm(String distance) {
    return '$distance km';
  }

  @override
  String orderTrackEtaApprox(String minutes) {
    return '~$minutes min';
  }

  @override
  String orderTrackEtaScheduled(String time) {
    return '$time';
  }

  @override
  String get orderTrackCenterMap => 'Fit route';

  @override
  String get orderTrackZoomIn => 'Zoom in';

  @override
  String get orderTrackZoomOut => 'Zoom out';

  @override
  String get orderTrackDirections => 'Directions';

  @override
  String get orderTrackDirectionsCouldNotOpen => 'Could not open Maps.';

  @override
  String orderNumberLabel(String orderId) {
    return 'Order #$orderId';
  }

  @override
  String get estimatedDeliveryTime => 'Estimated delivery time';

  @override
  String get routeFromLabel => 'From';

  @override
  String get routeToLabel => 'To';

  @override
  String get callDriver => 'Call driver';

  @override
  String get vehicleDefault => 'Vehicle';

  @override
  String get lookingForDriver => 'Looking for a driver…';

  @override
  String get deliveryAddressSection => 'Delivery address';

  @override
  String get yourDriver => 'Your driver';

  @override
  String get trackDriverLive => 'Live';

  @override
  String get trackStatusPending => 'Order placed';

  @override
  String get trackStatusConfirmed => 'Confirmed';

  @override
  String get trackStatusPreparing => 'Preparing';

  @override
  String get trackStatusReady => 'Ready';

  @override
  String get trackStatusPickedUp => 'Picked up';

  @override
  String get trackStatusOnTheWay => 'On the way';

  @override
  String get trackStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get menuSectionTitle => 'MENU';

  @override
  String get customerReviewsSectionTitle => 'CUSTOMER REVIEWS';

  @override
  String get noCustomerReviewsYet => 'No reviews yet.';

  @override
  String get reviewsCouldNotLoad =>
      'Reviews couldn’t load. Try opening this screen again.';

  @override
  String get similarRestaurantsSectionTitle => 'SIMILAR RESTAURANTS';

  @override
  String get availableOffersSectionTitle => 'AVAILABLE OFFERS';

  @override
  String get loadingRestaurant => 'Loading restaurant…';

  @override
  String get searchMenuItemsHint => 'Search menu items…';

  @override
  String copiedCodeMessage(String code) {
    return 'Copied $code';
  }

  @override
  String get defaultLocationPlaceholder => 'City center';

  @override
  String get defaultRestaurantCategoryTagline => 'Fast food • Pizza';

  @override
  String get restaurantsInThisCategory => 'Restaurants in this category';

  @override
  String get discoverOrderBestSubtitle => 'Discover & order from the best';

  @override
  String get superAdminPayments => 'Super Admin Payments';

  @override
  String get viewFullPaymentDetails => 'View full payment details';

  @override
  String get completeRawResponsePayload => 'Complete raw response payload';

  @override
  String get unknownEntity => 'Unknown';

  @override
  String get labelRestaurantId => 'Restaurant ID';

  @override
  String get driverProfileAndSettings => 'Profile & Settings';

  @override
  String get profileUpdatedSuccess => 'Profile updated';

  @override
  String get saveChanges => 'Save changes';

  @override
  String orderUpdatedToStatus(String orderNumber, String status) {
    return 'Order $orderNumber updated to $status';
  }

  @override
  String orderUpdatedShort(String orderNumber) {
    return 'Order $orderNumber updated';
  }

  @override
  String get restaurantDashboard => 'Restaurant dashboard';

  @override
  String get recentOrders => 'Recent orders';

  @override
  String get noRecentOrdersYet => 'No recent orders yet.';

  @override
  String get leaveReview => 'Leave review';

  @override
  String get viewDetails => 'View details';

  @override
  String get leaveAReview => 'Leave a review';

  @override
  String get browseToReorderFromRestaurant =>
      'Browse restaurants to order again from this restaurant';

  @override
  String get reorder => 'Reorder';

  @override
  String get cancelOrderAction => 'Cancel order';

  @override
  String get active => 'Active';

  @override
  String get available => 'Available';

  @override
  String get specialOfferDealsTab => 'Special offer (Deals tab)';

  @override
  String get specialOfferDealsSubtitle =>
      'Requires a discounted price below regular price';

  @override
  String get listUnderDeals => 'List under Deals';

  @override
  String get listUnderDealsSubtitle =>
      'Restaurant must be active; discount dates apply if set';

  @override
  String get enterDiscountedPricePositive =>
      'Enter a discounted price greater than zero.';

  @override
  String specialOfferForItem(String itemName) {
    return 'Special offer: $itemName';
  }

  @override
  String get menuManagement => 'Menu management';

  @override
  String get noMenuCategoriesYet => 'No menu categories yet';

  @override
  String get createFirstCategoryHint =>
      'Start by creating your first category to organize your menu.';

  @override
  String get createFirstCategory => 'Create first category';

  @override
  String itemsCountInCategory(String count) {
    return '$count items';
  }

  @override
  String get noItemsInCategory => 'No items in this category yet.';

  @override
  String get restaurantSettingsUpdated => 'Restaurant settings updated';

  @override
  String get restaurantSettingsTitle => 'Restaurant settings';

  @override
  String get acceptCashOnDelivery => 'Accept cash on delivery';

  @override
  String get acceptOnlinePayment => 'Accept online payment';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get restaurantOrdersTitle => 'Restaurant orders';

  @override
  String get noOrdersForFilter => 'No orders found for this filter.';

  @override
  String get orderActionConfirm => 'Confirm';

  @override
  String get orderActionStartPreparing => 'Start preparing';

  @override
  String get orderActionMarkReady => 'Mark ready';

  @override
  String driverWithName(String name) {
    return 'Driver: $name';
  }

  @override
  String get myEarningsTitle => 'My earnings';

  @override
  String get payoutRequested => 'Payout requested';

  @override
  String get requestPayout => 'Request payout';

  @override
  String get offersDealsTitle => 'Offers & deals';

  @override
  String get offersDealsEmptyHint =>
      'Restaurants can add special offers on menu items; they will appear here.';

  @override
  String get closeTicketTitle => 'Close ticket?';

  @override
  String get closeTicketMessage =>
      'You can reopen it later if your issue persists.';

  @override
  String get closeAction => 'Close';

  @override
  String get ticketClosedSuccess => 'Ticket closed.';

  @override
  String get ticketReopenedSuccess => 'Ticket reopened.';

  @override
  String get ticketScreenTitle => 'Ticket';

  @override
  String get sendReply => 'Send reply';

  @override
  String get reopenIfPersists => 'Reopen if your issue persists';

  @override
  String failedToSendMessage(String error) {
    return 'Failed to send: $error';
  }

  @override
  String get deleteAddressTitle => 'Delete address?';

  @override
  String deleteAddressMessage(String label) {
    return 'Remove “$label”? This cannot be undone.';
  }

  @override
  String get deleteAction => 'Delete';

  @override
  String get addressRemovedSuccess => 'Address removed';

  @override
  String get editAction => 'Edit';

  @override
  String get removeAllNotificationsConfirm =>
      'Remove all notifications from this device list?';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get orderHistoryTitle => 'Order history';

  @override
  String get pleaseSelectCity => 'Please select a city';

  @override
  String get citiesStillLoading =>
      'Cities are still loading. Try again in a moment.';

  @override
  String get turnOnLocationServices =>
      'Turn on location services to use this option.';

  @override
  String get locationPermissionRequired =>
      'Location permission is required to detect your address.';

  @override
  String get couldNotResolveAddress =>
      'Could not resolve an address from your location.';

  @override
  String get cityNotDetectedChoose =>
      'City not detected automatically — please choose your city below.';

  @override
  String get locationAppliedReviewSave =>
      'Location applied. Review the fields and tap Save.';

  @override
  String couldNotGetLocation(String error) {
    return 'Could not get location: $error';
  }

  @override
  String get setAsDefaultAddress => 'Set as default address';

  @override
  String get openRestaurantNotAvailable =>
      'Open restaurant not available for this item';

  @override
  String get hesabPayTitle => 'HesabPay';

  @override
  String get paymentNotCompleted => 'Payment was not completed.';

  @override
  String get paymentSuccessfulConfirmed =>
      'Payment successful. Order confirmed.';

  @override
  String get paymentFailedOrCancelled => 'Payment failed or was cancelled.';

  @override
  String get paymentProcessingCheckOrders =>
      'Payment is still processing. Check My orders shortly.';

  @override
  String get payOnlineSecurely => 'Pay online securely';

  @override
  String get acceptOrder => 'Accept order';

  @override
  String get navEarnings => 'Earnings';

  @override
  String get navRestaurantMenu => 'Menu';

  @override
  String get orderCancelledRefundHint =>
      'Order cancelled. Refund will be processed if applicable.';

  @override
  String failedToCancelOrder(String error) {
    return 'Failed to cancel: $error';
  }

  @override
  String get cancelOrderTitle => 'Cancel order';

  @override
  String get keepOrder => 'Keep order';

  @override
  String get cancelOrderConfirmTitle => 'Are you sure you want to cancel?';

  @override
  String get cancelOrderConfirmBody =>
      'This action cannot be undone. If you have already paid, a refund will be processed.';

  @override
  String get cancelReasonSectionTitle => 'Please tell us why';

  @override
  String get cancelAdditionalDetailsLabel => 'Additional details (optional)';

  @override
  String get cancelReasonChangedMind => 'Changed my mind';

  @override
  String get cancelReasonWrongOrder => 'Wrong order placed';

  @override
  String get cancelReasonFoundElsewhere => 'Found food elsewhere';

  @override
  String get cancelReasonDeliveryLong => 'Delivery time too long';

  @override
  String get cancelReasonPriceIssue => 'Price or payment issue';

  @override
  String get cancelReasonOther => 'Other';

  @override
  String get cancelReasonHint => 'Help us improve by sharing more details…';

  @override
  String get pleaseRateRestaurantAndFood =>
      'Please rate the restaurant and food (1–5 stars).';

  @override
  String get orderReviewScreenSubtitle =>
      'How was your experience with this order?';

  @override
  String get orderReviewRateRestaurantTitle => 'Rate the restaurant';

  @override
  String get orderReviewRateFoodTitle => 'Rate the food';

  @override
  String get orderReviewRateDeliveryTitle => 'Rate the delivery';

  @override
  String get orderReviewAddPhotosSectionTitle => 'Add photos (optional)';

  @override
  String get thankYouReviewSubmitted =>
      'Thank you! Your review has been submitted.';

  @override
  String failedSubmitReview(String error) {
    return 'Failed to submit review: $error';
  }

  @override
  String get addPhotos => 'Add photos';

  @override
  String get submitReview => 'Submit review';

  @override
  String get reviewDeliveryHint => 'Share your experience with the delivery…';

  @override
  String get reviewRestaurantHint =>
      'Share your experience with the food and restaurant…';

  @override
  String get addressLabelHint => 'e.g. Home, Work';

  @override
  String get addressAreaHint => 'e.g. Karte-e-Char';

  @override
  String get addressStreetHint => 'Street name and number';

  @override
  String get addressNotesHint => 'e.g. Ring doorbell, call on arrival';

  @override
  String get ticketReplyHint => 'Type your reply here…';

  @override
  String get dateHintExampleStart => 'e.g. 2026-03-28 00:00:00';

  @override
  String get dateHintExampleEnd => 'e.g. 2026-04-01 23:59:59';

  @override
  String get optionalStartLabel => 'Start (optional)';

  @override
  String get optionalEndLabel => 'End (optional)';

  @override
  String get isoDateHint => 'ISO or Y-m-d H:i';

  @override
  String get restaurantNameField => 'Restaurant name';

  @override
  String get restaurantNameDariField => 'Restaurant name (Dari)';

  @override
  String get verifyOtpAppBar => 'Verify OTP';

  @override
  String orderStatusTimeSeparator(String status, String time) {
    return '$status • $time';
  }

  @override
  String get ticketCategoryRestaurant => 'Restaurant';

  @override
  String get restaurantSampleOfferTitle => '20% off burgers';

  @override
  String get restaurantSampleOfferSubtitle =>
      'Get 20% off on all burgers. Min order \$15.';

  @override
  String get restaurantDeliveryOfferTitle => 'Delivery offer';

  @override
  String get restaurantOfferFreeDeliveryNext =>
      'Free delivery on your next order. No minimum.';

  @override
  String restaurantOfferFreeDeliveryOverAmount(String amount) {
    return 'Free delivery on orders over $amount.';
  }

  @override
  String get restaurantOfferLimitedDeliverySavings =>
      'Limited-time delivery savings.';

  @override
  String get backToOrders => 'Back to orders';

  @override
  String get ticketCategoryOrderIssue => 'Order issue';

  @override
  String get ticketCategoryPayment => 'Payment';

  @override
  String get ticketCategoryDelivery => 'Delivery';

  @override
  String get ticketCategoryAccount => 'Account';

  @override
  String get ticketCategoryOther => 'Other';

  @override
  String get ticketStatusOpen => 'Open';

  @override
  String get ticketStatusInProgress => 'In progress';

  @override
  String get ticketStatusWaiting => 'Waiting';

  @override
  String get ticketStatusResolved => 'Resolved';

  @override
  String get ticketStatusClosed => 'Closed';

  @override
  String get ticketPriorityLow => 'Low';

  @override
  String get ticketPriorityMedium => 'Medium';

  @override
  String get ticketPriorityHigh => 'High';

  @override
  String get ticketPriorityUrgent => 'Urgent';

  @override
  String get fieldRequired => 'Required';

  @override
  String ticketRelatedOrderOption(String orderId, String restaurant) {
    return '#$orderId — $restaurant';
  }

  @override
  String get tapViewDetailsForItems => 'Tap View details for items';

  @override
  String get orderDetailLoadError => 'Could not load order details.';

  @override
  String get orderItemsTitle => 'Order items';

  @override
  String get noItemsInOrder => 'No items';

  @override
  String get orderTimelineTitle => 'Order timeline';

  @override
  String get deliveryDetailsTitle => 'Delivery details';

  @override
  String get paymentSummaryDetailTitle => 'Payment summary';

  @override
  String get deliveryFeeShort => 'Delivery fee';

  @override
  String get paymentStatusPendingGeneric => 'Pending';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusFailed => 'Failed';

  @override
  String get paymentMethodOnline => 'Online payment';

  @override
  String orderItemQtyTimesPrice(String qty, String price) {
    return '$qty × $price';
  }

  @override
  String get emptyValueDash => '—';

  @override
  String get trackOrder => 'Track order';

  @override
  String get restaurantSectionTitle => 'Restaurant';

  @override
  String get detailRowAddress => 'Address';

  @override
  String get paymentStatusDetail => 'Payment status';

  @override
  String ticketReplyCount(String count) {
    return '$count replies';
  }

  @override
  String get checkoutLoadingAddresses => 'Loading addresses…';

  @override
  String get offersLoadFailed => 'Could not load offers.';

  @override
  String get offersNoDealsNow => 'No active deals right now';

  @override
  String get about => 'About';

  @override
  String get aboutDocumentTitle => 'About us';

  @override
  String get aboutHero => 'Delivering happiness, one meal at a time';

  @override
  String get aboutHeroSubtitle =>
      'Your favourite local restaurants, delivered fast and fresh.';

  @override
  String get aboutStoryTitle => 'Our story';

  @override
  String get aboutStoryDesc =>
      'Loqma connects hungry customers with trusted local restaurants. We built this platform to make ordering food simple, transparent, and enjoyable—whether you are at home, at work, or on the go.';

  @override
  String get aboutMissionTitle => 'Our mission';

  @override
  String get aboutMissionDesc =>
      'To empower communities by making quality food accessible to everyone through technology and reliable delivery.';

  @override
  String get aboutVisionTitle => 'Our vision';

  @override
  String get aboutVisionDesc =>
      'To become the most loved food delivery experience in the region—known for speed, fairness, and the restaurants we serve.';

  @override
  String get aboutValuesTitle => 'Our core values';

  @override
  String get aboutValue1Title => 'Customer first';

  @override
  String get aboutValue1Desc =>
      'Every feature starts with what diners and partners need.';

  @override
  String get aboutValue2Title => 'Quality';

  @override
  String get aboutValue2Desc =>
      'We champion great food and dependable service.';

  @override
  String get aboutValue3Title => 'Partnership';

  @override
  String get aboutValue3Desc => 'Restaurants are partners; we grow together.';

  @override
  String get aboutValue4Title => 'Innovation';

  @override
  String get aboutValue4Desc =>
      'We keep improving routes, payments, and your in-app experience.';

  @override
  String get aboutWhyTitle => 'Why choose us';

  @override
  String get aboutWhy1 => 'Fast, reliable delivery you can track in real time.';

  @override
  String get aboutWhy2 =>
      'A curated selection of popular and local restaurants.';

  @override
  String get aboutWhy3 => 'Clear pricing and secure checkout.';

  @override
  String get aboutWhy4 => 'Support when you need it.';

  @override
  String get aboutWhy5 => 'Built for the communities we serve.';

  @override
  String get aboutWhy6 => 'Continuous updates and new features.';

  @override
  String get aboutStatsTitle => 'Loqma by the numbers';

  @override
  String get aboutStat1Num => '500+';

  @override
  String get aboutStat1Label => 'Restaurant partners';

  @override
  String get aboutStat2Num => '50K+';

  @override
  String get aboutStat2Label => 'Orders delivered';

  @override
  String get aboutStat3Num => '24/7';

  @override
  String get aboutStat3Label => 'Customer support';

  @override
  String get aboutStat4Num => '100%';

  @override
  String get aboutStat4Label => 'Commitment to you';

  @override
  String get aboutCoverageTitle => 'Service coverage';

  @override
  String get aboutCoverageDesc =>
      'We are expanding across cities and neighbourhoods. Enter your address in the app to see restaurants available near you.';

  @override
  String get aboutCtaTitle => 'Have a question?';

  @override
  String get aboutCtaBtn => 'Contact us';

  @override
  String get contactUs => 'Contact us';

  @override
  String get contactDocumentTitle => 'Contact us';

  @override
  String get contactHero => 'We are here to help';

  @override
  String get contactSubtitle =>
      'Reach our team by phone, email, or the form below.';

  @override
  String get contactNavReachTooltip => 'Phone, email, and office locations';

  @override
  String get contactNavFormTooltip => 'Message form';

  @override
  String get contactNavFaqTooltip => 'Common questions';

  @override
  String get contactNavOverviewTooltip => 'Contact details and form';

  @override
  String get contactCallTitle => 'Call us';

  @override
  String get contactCallOffice => 'Office';

  @override
  String get contactCallMobile => 'Mobile';

  @override
  String get contactEmailTitle => 'Email';

  @override
  String get contactEmailGeneral => 'General inquiries';

  @override
  String get contactEmailSupport => 'Support';

  @override
  String get contactVisitTitle => 'Visit us';

  @override
  String get contactVisitMazarLabel => 'Mazar-e-Sharif';

  @override
  String get contactVisitMazarBody =>
      'Mazar intersection, Zinat Plaza (Azizi Bank Central), 4th floor, Salayan Company, Mazar-e-Sharif.';

  @override
  String get contactVisitKabulLabel => 'Kabul';

  @override
  String get contactVisitKabulBody =>
      'Shahr-e-Naw, next to Atoma Company, Clock Tower, 5th floor, Salayan Company, Kabul.';

  @override
  String get contactFollowTitle => 'Follow us';

  @override
  String get contactHoursTitle => 'Business hours';

  @override
  String get contactHoursDays => 'Monday – Saturday';

  @override
  String get contactHoursTime => '8:00 AM – 8:00 PM';

  @override
  String get contactHoursNote => 'Hours may vary on public holidays.';

  @override
  String get contactFormTitle => 'Send us a message';

  @override
  String get contactFormName => 'Full name';

  @override
  String get contactFormEmail => 'Email';

  @override
  String get contactFormPhone => 'Phone';

  @override
  String get contactFormSubject => 'Subject';

  @override
  String get contactFormSubjectHint => 'Select a topic';

  @override
  String get contactFormSubjectGeneral => 'General inquiry';

  @override
  String get contactFormSubjectSupport => 'Customer support';

  @override
  String get contactFormSubjectPartnership => 'Restaurant / partnership';

  @override
  String get contactFormSubjectDriver => 'Driver inquiry';

  @override
  String get contactFormSubjectComplaint => 'Complaint';

  @override
  String get contactFormSubjectFeedback => 'Feedback';

  @override
  String get contactFormSubjectOther => 'Other';

  @override
  String get contactFormMessage => 'Message';

  @override
  String get contactFormSubmit => 'Send message';

  @override
  String get contactFormSuccessSnackbar =>
      'Thank you! Your email app should open with your message.';

  @override
  String get contactFormSubjectError => 'Please choose a subject.';

  @override
  String get contactFormRequired => 'This field is required.';

  @override
  String get contactFormEmailInvalid => 'Enter a valid email address.';

  @override
  String get contactEmailSubjectPrefix => 'Contact';

  @override
  String get contactSocialSoon => 'Social link coming soon.';

  @override
  String get contactFaqTitle => 'Frequently asked questions';

  @override
  String get contactFaq1Q => 'How do I track my order?';

  @override
  String get contactFaq1A =>
      'Open Orders in the app and select your order to see live status and delivery updates.';

  @override
  String get contactFaq2Q => 'How do I change my delivery address?';

  @override
  String get contactFaq2A =>
      'Before checkout you can pick a saved address or add a new one. After ordering, contact support as soon as possible.';

  @override
  String get contactFaq3Q => 'What payment methods are supported?';

  @override
  String get contactFaq3A =>
      'Available options are shown at checkout and may include cash on delivery and online payment where enabled.';

  @override
  String get contactFaq4Q => 'How do I partner as a restaurant?';

  @override
  String get contactFaq4A =>
      'Choose “Restaurant / partnership” in the form and our team will follow up with onboarding details.';

  @override
  String get contactFaq5Q => 'How quickly will you respond?';

  @override
  String get contactFaq5A =>
      'We aim to reply within one business day. For urgent order issues, call the support number listed above.';

  @override
  String get totalEarningsLabel => 'Total earnings';

  @override
  String get pendingPayoutLabel => 'Pending payout';

  @override
  String get totalDeliveriesLabel => 'Total deliveries';

  @override
  String get ratingStatLabel => 'Rating';

  @override
  String get todaysEarningsLabel => 'Today\'s earnings';

  @override
  String get thisWeekLabel => 'This week';

  @override
  String get driverOfflineTitle => 'You are offline';

  @override
  String get driverActiveDeliveriesTitle => 'You have active deliveries';

  @override
  String get driverNoOrdersReadyTitle => 'No orders ready for pickup';

  @override
  String get clearAllTooltip => 'Clear all';

  @override
  String get reopenAction => 'Reopen';

  @override
  String get refreshTooltip => 'Refresh';

  @override
  String get addressSavedSuccess => 'Address saved';

  @override
  String get addressUpdatedSuccess => 'Address updated';

  @override
  String get basicInformation => 'Basic information';

  @override
  String get deliveryAndPayment => 'Delivery and payment';

  @override
  String get locationSection => 'Location';

  @override
  String get operatingHours => 'Operating hours';

  @override
  String get todayOrdersLabel => 'Today orders';

  @override
  String get todayRevenueLabel => 'Today revenue';

  @override
  String get pendingOrdersLabel => 'Pending orders';

  @override
  String get tapOpenSupportTicket => 'Tap to open support ticket';

  @override
  String get tapViewOrderNotification => 'Tap to view order';

  @override
  String get noLineItems => 'No line items';

  @override
  String get pleaseWaitProcessing => 'Please wait…';

  @override
  String get districtHint => 'e.g. Karte-e-Char';

  @override
  String get streetHint => 'Street name and number';

  @override
  String get deliveryNotesHint => 'e.g. Ring doorbell, call on arrival';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get driverDashboardTitle => 'Driver dashboard';

  @override
  String get driverVehicleInformation => 'Vehicle information';

  @override
  String get vehicleTypeLabel => 'Vehicle type (e.g., motorcycle, car)';

  @override
  String get vehicleModelLabel => 'Vehicle model';

  @override
  String get vehicleColorLabel => 'Vehicle color';

  @override
  String get licensePlateLabel => 'License plate';

  @override
  String driverMinimumPayoutMessage(String amount) {
    return 'Minimum payout amount is $amount. Keep delivering to reach the threshold!';
  }

  @override
  String get driverReadyForPayoutTitle => 'Ready for payout!';

  @override
  String driverPayoutAvailableMessage(String amount) {
    return 'You have $amount available for withdrawal.';
  }

  @override
  String get driverEarningLabel => 'earning';

  @override
  String reviewsCountLabel(String count) {
    return '$count reviews';
  }

  @override
  String get driverActiveDeliveriesSectionTitle => 'Active deliveries';

  @override
  String get driverEarningPrefix => 'Earning:';

  @override
  String get driverAvailableOrdersSectionTitle => 'Available orders';

  @override
  String get driverOfflineBody =>
      'Go online to start receiving delivery requests.';

  @override
  String get driverBusyDeliveriesBody =>
      'Complete your current deliveries to receive new orders.';

  @override
  String get driverNoOrdersReadyBody =>
      'Orders will appear here when restaurants mark them as ready.';

  @override
  String get driverUpcomingOrdersTitle => 'Upcoming orders';

  @override
  String get driverUpcomingOrdersHint =>
      'These orders will be available for pickup once restaurants mark them as ready.';

  @override
  String get recentDeliveriesSectionTitle => 'Recent deliveries';

  @override
  String get restaurantOpenAcceptingOrders =>
      'Your restaurant is currently accepting orders.';

  @override
  String get restaurantCurrentlyClosedNotice =>
      'Your restaurant is currently closed.';

  @override
  String get restaurantPendingApprovalNotice =>
      'Your application is under review. Complete your settings and wait for approval.';

  @override
  String get restaurantApplicationRejectedNotice =>
      'Your restaurant application was rejected. Update your details in settings and contact support if needed.';

  @override
  String get restaurantNewOrdersSectionTitle => 'New orders';

  @override
  String get restaurantActiveOrdersSectionTitle => 'Active orders';

  @override
  String get restaurantNoPendingOrdersSubtitle =>
      'No pending orders right now.';

  @override
  String get restaurantNoActiveOrdersSubtitle => 'No active orders right now.';

  @override
  String get rejectOrderAction => 'Reject';

  @override
  String get partnerAccountStatusActive => 'Active partner account';

  @override
  String get partnerAccountStatusPending => 'Pending approval';

  @override
  String get partnerAccountStatusRejected => 'Rejected';

  @override
  String get adminHesabPayLoadError => 'Could not load HesabPay payments.';

  @override
  String get adminNoHesabPayPayments => 'No HesabPay payments found yet.';

  @override
  String hesabPayPaymentOrderHeader(String order) {
    return 'HesabPay payment $order';
  }

  @override
  String get paymentImageLabel => 'Payment image';

  @override
  String get summaryAmountLabel => 'Amount';

  @override
  String get summaryCustomerLabel => 'Customer';

  @override
  String get summaryCreatedAtLabel => 'Created at';

  @override
  String get summaryTransactionRefLabel => 'Transaction ref';

  @override
  String get ticketReplySectionTitle => 'Reply';

  @override
  String get ticketMessagesEmptyHint => 'No messages yet.';

  @override
  String ticketAssignedTo(String name) {
    return 'Assigned to: $name';
  }

  @override
  String get ticketClosedStateMessage => 'This ticket is closed.';

  @override
  String get hoursOpenLabel => 'Open';

  @override
  String get hoursCloseLabel => 'Close';

  @override
  String get deliveryFeeFieldLabel => 'Delivery fee';

  @override
  String get minimumOrderFieldLabel => 'Minimum order';

  @override
  String get freeDeliveryAboveFieldLabel => 'Free delivery above';

  @override
  String get averagePrepTimeFieldLabel => 'Average preparation time';

  @override
  String coordinatesSavedHint(String lat, String lng) {
    return 'Coordinates saved with this address: $lat, $lng';
  }

  @override
  String get useCurrentLocationAction => 'Use current location';

  @override
  String get gettingLocationEllipsis => 'Getting location…';

  @override
  String get deliveryInstructionsLabel => 'Delivery instructions';

  @override
  String get addressLabelShort => 'Label';

  @override
  String get cityRequiredLabel => 'City *';

  @override
  String get requiredFieldIndicator => '*';

  @override
  String get streetAddressRequiredLabel => 'Street address *';

  @override
  String get streetAddressHint => 'Street name and number';

  @override
  String get buildingFieldLabel => 'Building';

  @override
  String get floorFieldLabel => 'Floor';

  @override
  String get apartmentFieldLabel => 'Apartment';

  @override
  String get areaFieldLabel => 'Area';

  @override
  String get editAddressScreenTitle => 'Edit address';

  @override
  String get updateAddressButton => 'Update address';

  @override
  String get saveAddressButton => 'Save address';

  @override
  String get addressChooseCityTitle => 'Choose your city';

  @override
  String get addressChooseCitySubtitle =>
      'We currently deliver in these cities.';

  @override
  String get addressChooseDistrictTitle => 'Choose your district';

  @override
  String addressChooseDistrictSubtitle(String city) {
    return 'Select a district in $city.';
  }

  @override
  String get addressStreetDetailsTitle => 'Street details';

  @override
  String addressStreetDetailsSubtitle(String district, String city) {
    return 'Add your street and house number in $district, $city.';
  }

  @override
  String get addressStreetNameLabel => 'Street name & number';

  @override
  String get addressStreetNameHint => 'e.g. Street 5, block 12';

  @override
  String get addressHouseNumberLabel => 'House / office number';

  @override
  String get addressHouseNumberHint => 'e.g. House 24 or Office 3';

  @override
  String get addressStreetRequired => 'Please enter your street name.';

  @override
  String get addressHouseNumberRequired =>
      'Please enter your house or office number.';

  @override
  String get addressNoCitiesAvailable =>
      'No delivery cities are available right now.';

  @override
  String get addressNoDistrictsAvailable => 'No districts found for this city.';

  @override
  String get addressProfileNamePhoneRequired =>
      'Your profile name and phone are required to save an address.';

  @override
  String get addItemTooltip => 'Add item';

  @override
  String get addCategoryTooltip => 'Add category';

  @override
  String get newCategoryDialogTitle => 'New category';

  @override
  String get editCategoryDialogTitle => 'Edit category';

  @override
  String get categoryNameFaLabel => 'Name (Dari)';

  @override
  String get newMenuItemTitle => 'New menu item';

  @override
  String get editMenuItemTitle => 'Edit menu item';

  @override
  String get foodCategoryDropdownLabel => 'Category';

  @override
  String get discountedPriceFieldLabel => 'Discounted price';

  @override
  String get preparationTimeMinutesLabel => 'Preparation time';

  @override
  String get menuItemHasSizesLabel =>
      'Offer sizes (Kids, Small, Medium, Large, Family)';

  @override
  String get menuItemSmallPriceHint =>
      'Enter a price only for sizes you offer. Leave blank to skip — Small is not selected by default.';

  @override
  String get menuItemKidsPriceLabel => 'Kids price (optional)';

  @override
  String get menuItemSmallPriceLabel => 'Small price (optional)';

  @override
  String get menuItemMediumPriceLabel => 'Medium price (optional)';

  @override
  String get menuItemLargePriceLabel => 'Large price (optional)';

  @override
  String get menuItemFamilyPriceLabel => 'Family Size price (optional)';

  @override
  String get menuItemSizesAvailable => 'Sizes available';

  @override
  String get offerLabelOptionalField => 'Offer label (optional)';

  @override
  String get discountStartOptionalField => 'Discount start (optional)';

  @override
  String get discountEndOptionalField => 'Discount end (optional)';

  @override
  String get discountedPriceCurrencyHint => 'Discounted price (AFN)';

  @override
  String get labelOptionalField => 'Label (optional)';

  @override
  String discountedMustBeBelowRegular(String regular) {
    return 'Discounted price must be less than regular price ($regular).';
  }

  @override
  String specialOfferDialogTitle(String itemName) {
    return 'Special offer: $itemName';
  }

  @override
  String get specialOfferTooltip => 'Special offer';

  @override
  String get descriptionFieldLabel => 'Description';

  @override
  String get defaultLocationStreetFallback => 'Current location';

  @override
  String get coordinateLatitudeLabel => 'Latitude';

  @override
  String get coordinateLongitudeLabel => 'Longitude';

  @override
  String get restaurantStatusOpen => 'OPEN';

  @override
  String get restaurantStatusClosed => 'CLOSED';

  @override
  String prepTimeRange(String low, String high) {
    return '$low–$high min';
  }

  @override
  String get prepTimeDefault => '35–45 min';

  @override
  String cartFabWithCount(int count) {
    return 'Cart, $count items';
  }

  @override
  String get mainNavHome => 'Home tab';

  @override
  String get mainNavOffers => 'Offers tab';

  @override
  String get mainNavFavorites => 'Favorites tab';

  @override
  String get mainNavOrders => 'Orders tab';

  @override
  String cartQtyLine(int quantity) {
    return 'Qty: $quantity';
  }

  @override
  String get tax => 'Tax';

  @override
  String get discount => 'Discount';

  @override
  String cartFromRestaurant(String name) {
    return 'From $name';
  }

  @override
  String get adminSuperPaymentsTitle => 'Super Admin Payments';

  @override
  String get adminRefresh => 'Refresh';

  @override
  String get adminCouldNotLoadPayments => 'Could not load HesabPay payments.';

  @override
  String adminHesabPayPaymentOrder(String order) {
    return 'HesabPay payment $order';
  }

  @override
  String get adminRestaurant => 'Restaurant';

  @override
  String get adminCustomer => 'Customer';

  @override
  String get adminAmount => 'Amount';

  @override
  String get adminPaymentStatus => 'Payment status';

  @override
  String get adminViewPaymentDetails => 'View full payment details';

  @override
  String get adminOrderId => 'Order ID';

  @override
  String get adminCreatedAt => 'Created';

  @override
  String get adminPaymentDetails => 'Payment details';

  @override
  String get ordersTabFilterTooltip => 'Filter orders';

  @override
  String get ordersTabShowOrders => 'Show orders';

  @override
  String get ordersTabFilterAll => 'All orders';

  @override
  String get ordersTabFilterActive => 'Active only';

  @override
  String get ordersTabFilterCompleted => 'Completed';

  @override
  String get ordersTabFilterCancelled => 'Cancelled';

  @override
  String get ordersTabSectionActive => 'ACTIVE ORDERS';

  @override
  String get ordersTabSectionCompleted => 'COMPLETED ORDERS';

  @override
  String get ordersTabSectionCancelled => 'CANCELLED';

  @override
  String ordersTabReviewsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders need your review',
      one: '1 order needs your review',
    );
    return '$_temp0';
  }

  @override
  String ordersTabPlacedRelative(String time) {
    return 'Placed $time';
  }

  @override
  String get ordersTabDefaultDeliveryWindow => '35-45 min';

  @override
  String get ordersTabMapLegendRestaurant => 'Rest.';

  @override
  String get ordersTabMapLegendDestination => 'You';

  @override
  String get relativeTimeJustNow => 'Just now';

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count hr ago';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String relativeTimeWeeksAgo(int count) {
    return '$count w ago';
  }

  @override
  String relativeTimeMonthsAgo(int count) {
    return '$count mo ago';
  }

  @override
  String relativeTimeYearsAgo(int count) {
    return '$count y ago';
  }

  @override
  String get restaurantMenuEmpty => 'No menu items available yet.';

  @override
  String get restaurantMenuSearchNoResults =>
      'No menu items match your search.';

  @override
  String get restaurantDetailsLoadFailed => 'Could not load this restaurant.';

  @override
  String get reviewAnonymousCustomer => 'Customer';

  @override
  String get menuItemAddToCart => 'Add to cart';

  @override
  String get menuItemOptionsLabel => 'Options';

  @override
  String get menuItemAddonsLabel => 'Add-ons';

  @override
  String get menuItemQuantityLabel => 'Quantity';

  @override
  String get profileTabEditHint => 'View and edit your profile';

  @override
  String get profileTabOpenAccount => 'Edit profile';

  @override
  String get profileTabNavDashboard => 'Open dashboard';

  @override
  String get profileTabNavOrders => 'Open orders';

  @override
  String get profileTabNavAddresses => 'Open saved addresses';

  @override
  String get profileTabNavFavorites => 'Open favorites';

  @override
  String get profileTabNavNotifications => 'Open notifications';

  @override
  String get profileTabNavSettings => 'Open settings';

  @override
  String get profileTabNavLogout => 'Sign out';

  @override
  String get restaurantDetailsSignInForFavorites =>
      'Please sign in to save restaurants to your favorites.';

  @override
  String get restaurantDetailsFavoritesSnackbarTitle => 'Favorites';

  @override
  String get favoritesRemovedMessage => 'Removed from favorites';

  @override
  String get favoritesRemoveTooltip => 'Remove from favorites';

  @override
  String get authEmailOrPhoneHint => 'Email or phone number';

  @override
  String get authEnterEmailOrPhone => 'Enter your email or phone number';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authCompleteProfileTitle => 'Complete your profile';

  @override
  String get authCompleteProfileSubtitle =>
      'Add your name and phone number to continue.';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email and we will send a 6-digit reset code.';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authEnterResetCode => 'Enter the 6-digit code sent to';

  @override
  String get authResendCode => 'Resend code';

  @override
  String authResendCodeInSeconds(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get authPasswordMinEight => 'Password must be at least 8 characters';

  @override
  String get authSendResetCode => 'Send reset code';

  @override
  String get authSixDigitCodeHint => '000000';

  @override
  String get authSetNewPassword => 'Set new password';

  @override
  String get authPasswordResetSuccess =>
      'Password updated. Sign in with your new password.';

  @override
  String get authResetCodeSent => 'Reset code sent';

  @override
  String get authYourLocation => 'Your location';

  @override
  String get authRegisterLocationHint =>
      'Use GPS or type your delivery address manually.';

  @override
  String get authAddressHint => 'Street, area, city';

  @override
  String get authLocationRequired =>
      'Enter your delivery address (at least 5 characters).';

  @override
  String get authEnterSixDigitCode => 'Enter the 6-digit code.';

  @override
  String get authInvalidSixDigitCode => 'Enter a valid 6-digit code.';

  @override
  String get couldNotDetectLocation =>
      'Could not detect your location. Enter your address manually.';

  @override
  String get authOrDivider => 'or';

  @override
  String get authPleaseEnterPassword => 'Please enter your password';

  @override
  String get authRegisterSubtitle =>
      'Create your Loqma account to start ordering.';

  @override
  String get authPhoneFieldHint => '07X XXX XXXX';

  @override
  String get authHaveAccountSignIn => 'Sign in';

  @override
  String get authLoginStepPhoneHint => 'Enter your phone number to continue.';

  @override
  String get authLoginStepPasswordHint => 'Enter your password to sign in.';

  @override
  String get authRegisterStepNameHint =>
      'Tell us your name so restaurants know who you are.';

  @override
  String get authRegisterStepPhoneHint =>
      'We\'ll use this number for delivery updates.';

  @override
  String get authRegisterStepPasswordHint =>
      'Choose a password with at least 8 characters.';

  @override
  String get authRegisterStepConfirmHint =>
      'Re-enter your password to confirm.';

  @override
  String get authForgotPasswordAdminSubtitle =>
      'Enter your name and phone number. An admin will assign a temporary password for you.';

  @override
  String get authRequestPasswordReset => 'Request password reset';

  @override
  String get authPasswordResetRequestSentTitle => 'Request sent';

  @override
  String get authPasswordResetRequestSentBody =>
      'Your request was sent to the admin panel. Once they set a temporary password, sign in with it and change your password.';

  @override
  String get authAdminDefaultPasswordTitle => 'Temporary password assigned';

  @override
  String get authAdminDefaultPasswordBody =>
      'Your password is a default password assigned by the admin. Please change it now to keep your account secure.';

  @override
  String get authThisIsYourNewPasswordTitle => 'This is your new password';

  @override
  String get authThisIsYourNewPasswordBody =>
      'An admin assigned this temporary password for you. Sign in with it, then change it to something only you know.';

  @override
  String get authUseThisPassword => 'Use this password';

  @override
  String get authTemporaryPassword => 'Temporary password';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authPasswordUpdatedTitle => 'Password updated';

  @override
  String get authPasswordUpdatedBody =>
      'Your new password is set. You can continue ordering.';

  @override
  String get authInvalidCredentials =>
      'That email/phone or password is incorrect. Please try again.';

  @override
  String get authCheckPasswordAgain =>
      'Double-check your password and try again.';

  @override
  String get authEmailAlreadyRegistered =>
      'This email is already registered. Sign in instead.';

  @override
  String get authPhoneAlreadyRegistered =>
      'This phone number is already registered. Sign in instead.';

  @override
  String get authValidationFixFields =>
      'Please fix the highlighted fields and try again.';

  @override
  String get authTooManyAttempts =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get authGoogleCancelled => 'Google sign-in was cancelled.';

  @override
  String get authGoogleFailed =>
      'Could not sign in with Google. Please try again.';

  @override
  String get authGoogleNotConfigured =>
      'Google Sign-In is not set up yet. Add the app SHA-1 and a Web client ID in Firebase / Google Cloud, then try again.';

  @override
  String get authGoogleNoIdToken =>
      'Google Sign-In could not get an ID token. Add a Web OAuth client ID (serverClientId) and the app SHA-1 fingerprint in Firebase.';

  @override
  String get authSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get authNoInternet =>
      'No internet connection. Check your network and try again.';

  @override
  String get authServerSlow =>
      'The server is taking too long. Please try again.';

  @override
  String get authServerUnavailable =>
      'Server is temporarily unavailable. Please try again shortly.';
}
