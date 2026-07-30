// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Pushto Pashto (`ps`).
class AppLocalizationsPs extends AppLocalizations {
  AppLocalizationsPs([String locale = 'ps']) : super(locale);

  @override
  String get appTitle => 'لقمه';

  @override
  String get foodDelivery => 'د خوراک وړاندې کول';

  @override
  String get deliveryTo => 'تحویلي ته';

  @override
  String get searchHint => 'خوندور خوراک لټوئ...';

  @override
  String get categories => 'کټګورۍ';

  @override
  String get viewAll => 'ټول وګورئ';

  @override
  String get restaurants => 'رستورانونه';

  @override
  String get clear => 'پاک کړئ';

  @override
  String get topRestaurants => 'غوره رستورانونه';

  @override
  String get seeAll => 'ټول وګورئ';

  @override
  String get freeDelivery => 'وړیا تحویلي';

  @override
  String get featured => 'ټاکل شوي';

  @override
  String get all => 'ټول';

  @override
  String get retry => 'بیا هڅه وکړئ';

  @override
  String get freeDeliveryLabel => 'وړیا تحویلي';

  @override
  String deliveryFeeLabel(String amount) {
    return '$amount د تحویلي فیس';
  }

  @override
  String minLabel(String minutes) {
    return '$minutes دقیقې';
  }

  @override
  String minRangeLabel(String low, String high) {
    return '$low–$high دقیقې';
  }

  @override
  String get restaurantOpenBadge => 'خلاص';

  @override
  String get restaurantClosedBadge => 'تړل';

  @override
  String get orderNow => 'اوس امر وکړئ';

  @override
  String get loadingEllipsis => '…';

  @override
  String get ordersFilterTitle => 'امرونه وښایاست';

  @override
  String get ordersFilterAll => 'ټول امرونه';

  @override
  String get ordersFilterActiveOnly => 'یوازې فعال';

  @override
  String get ordersFilterCompleted => 'بشپړ شوي';

  @override
  String get ordersFilterCancelled => 'لغوه شوي';

  @override
  String get ordersFilterTooltip => 'امرونه فلټر کړئ';

  @override
  String get ordersSectionActive => 'فعال امرونه';

  @override
  String get ordersSectionCompleted => 'بشپړ شوي امرونه';

  @override
  String get ordersSectionCancelled => 'لغوه شوي';

  @override
  String orderPlacedAt(String when) {
    return 'ځای پر ځای شوی $when';
  }

  @override
  String get orderRelativeJustNow => 'همدا اوس';

  @override
  String orderRelativeMinutesAgo(String count) {
    return '$count دقیقې وړاندې';
  }

  @override
  String orderRelativeHoursAgo(String count) {
    return '$count ساعته وړاندې';
  }

  @override
  String orderRelativeDaysAgo(String count) {
    return '$count ورځې وړاندې';
  }

  @override
  String get orderStatusActiveGeneric => 'فعال';

  @override
  String get orderCallRider => 'چلوونکي ته زنګ ووهئ';

  @override
  String get orderMapLegendRestaurant => 'رست.';

  @override
  String get orderMapLegendYou => 'تاسو';

  @override
  String get ordersReviewBannerOne => '۱ امر ستاسو بیاکتنې ته اړتیا لري';

  @override
  String ordersReviewBannerMany(String count) {
    return '$count امرونه ستاسو بیاکتنې ته اړتیا لري';
  }

  @override
  String qtyWithCount(String label, String count) {
    return '$label: $count';
  }

  @override
  String get navOffers => 'وړاندیزونه';

  @override
  String get navFavs => 'خوښې';

  @override
  String get home => 'کور';

  @override
  String get orders => 'امرونه';

  @override
  String get profile => 'پروفایل';

  @override
  String get cart => 'کارټ';

  @override
  String get cartBadgeMax => '۹۹+';

  @override
  String get cartFabTooltip => 'کارټ';

  @override
  String get signIn => 'ننوتل';

  @override
  String get signUp => 'نوم لیکنه';

  @override
  String get createAccount => 'حساب جوړ کړئ';

  @override
  String get email => 'بریښنالیک';

  @override
  String get password => 'پاسورډ';

  @override
  String get name => 'نوم';

  @override
  String get phone => 'تلیفون';

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get addresses => 'پتې';

  @override
  String get favorites => 'غوره';

  @override
  String get notifications => 'خبرتیاوې';

  @override
  String get settings => 'ترتیبونه';

  @override
  String get settingsHeroSubtitle => 'بڼه، ژبه او قانوني معلومات.';

  @override
  String get settingsNavDisplay => 'ښودنه او غوره توبونه';

  @override
  String get settingsNavLanguage => 'ژبه';

  @override
  String get settingsNavAbout => 'په اړه او قوانین';

  @override
  String get logout => 'وتل';

  @override
  String get myOrders => 'زما امرونه';

  @override
  String get browseRestaurants => 'رستورانونه وګورئ';

  @override
  String get cartEmpty => 'کارټ خالي دی';

  @override
  String get goBack => 'شاته';

  @override
  String get subtotal => 'فرعي مجموعه';

  @override
  String get delivery => 'تحویلي';

  @override
  String get total => 'ټولټال';

  @override
  String get qty => 'مقدار';

  @override
  String get viewCartCheckout => 'کارټ وګورئ او تادیه';

  @override
  String get checkout => 'تادیه';

  @override
  String get deliveryAddress => 'د تحویلي پته';

  @override
  String get selectOrAddAddress => 'پته غوره یا اضافه کړئ';

  @override
  String get deliveryLocationPromptTitle => 'خپله د سپارنې پته اضافه کړئ';

  @override
  String get deliveryLocationPromptSubtitle =>
      'خپل ښار او سیمه وټاکئ ترڅو نږدې رستورانتونه وګورئ او سفارش ستاسو کور ته ورسېږي.';

  @override
  String get deliveryLocationPromptAction => 'پته اضافه کړئ';

  @override
  String get paymentMethod => 'د تادیې طریقه';

  @override
  String get cashOnDelivery => 'په تحویلي کې نغدي';

  @override
  String get card => 'کارت';

  @override
  String get orderSummary => 'د امر لنډیز';

  @override
  String get orderPlacedSnackbar => 'ستاسو امر په بریالیتوب سره ثبت شو.';

  @override
  String itemAddedToCart(String item) {
    return '$item کارټ ته اضافه شو';
  }

  @override
  String cartDifferentRestaurantMessage(String restaurant) {
    return 'ستاسو کارټ کې د $restaurant توکي دي. مهرباني وکړئ لومړی هغه امر بشپړ کړئ یا کارټ پاک کړئ، بیا له بل رستورانت څخه امر وکړئ.';
  }

  @override
  String get darkMode => 'تیاره حالت';

  @override
  String get useDarkTheme => 'تیاره تمه وکاروئ';

  @override
  String get notificationsSetting => 'خبرتیاوې';

  @override
  String get pushAndInApp => 'پش او اپ کې';

  @override
  String get language => 'ژبه';

  @override
  String get appLanguage => 'د اپ ژبه';

  @override
  String get languageSelectionTitle => 'خپله ژبه وټاکئ';

  @override
  String get languageSelectionSubtitle =>
      'هغه ژبه وټاکئ چې غواړئ په اپ کې یې وکاروئ.';

  @override
  String get privacy => 'محرمیت';

  @override
  String get privacyPolicy => 'د محرمیت پالیسي';

  @override
  String get privacyPolicyHeroSubtitle =>
      'زموږ په پلیټ فارم کې ستاسو معلومات څنګه راټولوو، کاروو او ساتو.';

  @override
  String get terms => 'شرایط';

  @override
  String get termsOfService => 'د خدمت شرایط';

  @override
  String get termsHeroSubtitle =>
      'د افغان فود، امرونو، تحویل او حساب کارونې قوانین.';

  @override
  String get deleteAccountTitle => 'حساب ړنګول';

  @override
  String get deleteAccountSettingsSubtitle =>
      'د تل لپاره د حساب د لرې کولو غوښتنه';

  @override
  String get deleteAccountIntro =>
      'ستاسو غوښتنه به زموږ ټیم وڅیړي. که تایید شي، ستاسو پروفایل، پته‌ګانې، خوښې او ننوتل به لرې شي. د امرونو تاریخښت ممکن د قانوني مقرراتو لپاره وساتل شي.';

  @override
  String get deleteAccountWebPolicyLink => 'د حساب د حذف پالیسي آنلاین وګورئ';

  @override
  String get deleteAccountReasonLabel => 'دلیل (اختیاري)';

  @override
  String get deleteAccountReasonHint => 'ولې غواړئ خپل حساب ړنګ کړئ ووایاست';

  @override
  String get deleteAccountSubmit => 'د ړنګولو غوښتنه';

  @override
  String get deleteAccountConfirmTitle => 'خپل حساب ړنګ کړئ؟';

  @override
  String get deleteAccountConfirmBody =>
      'ستاسو غوښتنه به د تایید لپاره زموږ ټیم ته واستول شي. وروسته له تایید دا عمل بیرته نشي کیدی.';

  @override
  String get deleteAccountSubmitted =>
      'د ړنګولو غوښتنه واستول شوه. وروسته له کتنې به تاسو ته خبر درکړل شي.';

  @override
  String get deleteAccountCancelled => 'د ړنګولو غوښتنه لغوه شوه.';

  @override
  String get deleteAccountCancelRequest => 'غوښتنه لغوه کړئ';

  @override
  String get deleteAccountCurrentStatus => 'د اوسنۍ غوښتنې حالت';

  @override
  String get deleteAccountStatusPending => 'د ادمین د تایید په تمه';

  @override
  String get deleteAccountStatusApproved => 'تایید شو — ستاسو حساب ړنګ شو';

  @override
  String get deleteAccountStatusRejected => 'رد شو';

  @override
  String get deleteAccountStatusCancelled => 'لغوه شو';

  @override
  String get deleteAccountWhatHappens => 'څه شیان به لرې شي';

  @override
  String get deleteAccountMayBeKept => 'ممکن وساتل شي';

  @override
  String get deleteAccountDangerZone => 'د خطر ساحه';

  @override
  String get deleteAccountRemovedProfile => 'پروفایل، تلیفون او خوندي پته‌ګانې';

  @override
  String get deleteAccountRemovedFavorites => 'خوښې او د خبرتیا تنظیمات';

  @override
  String get deleteAccountRemovedAccess => 'په لقمه اپ کې د ننوتلو لاسرسی';

  @override
  String get deleteAccountKeptOrders => 'د امرونو تاریخچه (قانوني مقررات)';

  @override
  String get deleteAccountKeptPayments => 'د تادیې ریکارډونه که قانون وغواړي';

  @override
  String get deleteAccountRedirectingToLogin =>
      'حساب ړنګ شو. د ننوتلو پاڼې ته لیږدول کیږي…';

  @override
  String get deleteAccountSessionEnded =>
      'ستاسو حساب ړنګ شو. مهرباني وکړئ بیا د خپل تلیفون شمېرې سره ننوځئ.';

  @override
  String get signInRequired => 'ننوتل اړین دي';

  @override
  String get support => 'مرستې';

  @override
  String get supportTickets => 'د مرستې ټکټونه';

  @override
  String get createTicketHelp => 'د مرستې لپاره ټکټ جوړ کړئ';

  @override
  String get newTicket => 'نوی ټکټ';

  @override
  String get supportTrackManage => 'خپل د مرستې غوښتنې تعقیب او اداره کړئ';

  @override
  String get supportNoTicketsTitle => 'هیڅ ټکټ ونه موندل شو';

  @override
  String get supportNoTicketsSubtitle => 'د مرستې لپاره ټکټ جوړ کړئ';

  @override
  String get ticketFormTitle => 'د مرستې غوښتنه واستوئ';

  @override
  String get ticketFormSubtitle =>
      'خپل ستونزه تشریح کړئ، ژر تر ژره به له تاسو سره اړیکه ونیسو.';

  @override
  String get ticketSubjectLabel => 'موضوع *';

  @override
  String get ticketSubjectHint => 'ستاسو د ستونزې لنډ توضیح';

  @override
  String get ticketCategoryLabel => 'کټګوري *';

  @override
  String get ticketPriorityLabel => 'لومړیتوب *';

  @override
  String get ticketRelatedOrderLabel => 'اړوند امر (اختیاري)';

  @override
  String get ticketRelatedOrderNone => 'له کوم ځانګړي امر سره تړاو نه لري';

  @override
  String get ticketMessageLabel => 'پیغام *';

  @override
  String get ticketMessageHint =>
      'مهرباني وکړئ خپله ستونزه په تفصیل سره تشریح کړئ...';

  @override
  String get ticketMessageMinCharsHint => 'تر لږه لږه ۲۰ توري';

  @override
  String get ticketCancel => 'لغوه کول';

  @override
  String get ticketSubmit => 'ټکټ واستوئ';

  @override
  String get ticketSubmitted =>
      'ستاسو ټکټ ثبت شو. ژر تر ژره به له تاسو سره اړیکه ونیسو.';

  @override
  String get ticketMessageTooShort => 'پیغام باید لږ تر لږه ۲۰ توري ولري';

  @override
  String ticketSubmitFailed(String error) {
    return 'ناکام شو: $error';
  }

  @override
  String get noSavedAddresses => 'خوندي شوې پتې نشته';

  @override
  String get addAddressHint => 'د ګړندۍ تادیې لپاره پته اضافه کړئ';

  @override
  String get addAddress => 'پته اضافه کړئ';

  @override
  String get noFavoritesYet => 'تر اوسه غوره نشته';

  @override
  String get favoritesHint =>
      'هغه رستورانونه به دلته راښکاره شي چې تاسو یې خوښوئ';

  @override
  String get noNotifications => 'خبرتیا نشته';

  @override
  String get newNotificationReceived => 'تاسو نوې خبرتیا ترلاسه کړه';

  @override
  String get gotIt => 'سمه ده';

  @override
  String get fcmChannelName => 'امرونه او خبرتیاوې';

  @override
  String get fcmChannelDescription => 'د تحویلي او حساب خبرتیاوې';

  @override
  String get notificationDefaultTitle => 'لقمه';

  @override
  String get notificationFallbackTitle => 'خبرتیا';

  @override
  String get pleaseSignInToViewNotifications => 'د خبرتیاوو لیدو لپاره ننوځئ.';

  @override
  String get notificationOrderConfirmedTitle => 'امر تایید شو';

  @override
  String get notificationOrderPreparingTitle => 'ستاسو خواړه چمتو کېږي';

  @override
  String get notificationOrderReadyTitle => 'امر د اخیستلو لپاره چمتو دی';

  @override
  String get notificationOrderPickedUpTitle => 'چلوونکي ستاسو امر واخیست';

  @override
  String get notificationOrderOnTheWayTitle => 'ستاسو امر په لار کې دی';

  @override
  String get notificationOrderDeliveredTitle => 'امر تحویل شو';

  @override
  String get notificationOrderCancelledTitle => 'امر لغوه شو';

  @override
  String get notificationOrderUpdateTitle => 'د امر تازه معلومات';

  @override
  String notificationOrderConfirmedMessage(
    String orderNumber,
    String restaurant,
  ) {
    return 'ستاسو امر #$orderNumber له $restaurant څخه تایید شو او به ډیر ژر چمتو شي.';
  }

  @override
  String notificationOrderPreparingMessage(
    String orderNumber,
    String restaurant,
  ) {
    return 'ستاسو امر #$orderNumber اوس په $restaurant کې چمتو کېږي.';
  }

  @override
  String notificationOrderReadyMessage(String orderNumber) {
    return 'ستاسو امر #$orderNumber چمتو دی! ډیر ژر به یو چلوونکی یې واخلي.';
  }

  @override
  String notificationOrderPickedUpMessage(String orderNumber, String driver) {
    return 'ستاسو امر #$orderNumber د $driver لخوا واخیستل شو.';
  }

  @override
  String notificationOrderOnTheWayMessage(String orderNumber, String driver) {
    return 'ستاسو امر #$orderNumber په لار کې دی! $driver ستاسو خواړه راوړي.';
  }

  @override
  String notificationOrderDeliveredMessage(String orderNumber) {
    return 'ستاسو امر #$orderNumber تحویل شو. نوش جان!';
  }

  @override
  String notificationOrderCancelledMessage(String orderNumber) {
    return 'ستاسو امر #$orderNumber لغوه شو.';
  }

  @override
  String notificationOrderUpdateMessage(String orderNumber, String status) {
    return 'د امر #$orderNumber حالت $status ته تازه شو.';
  }

  @override
  String get allCaughtUp => 'تاسو ټول تازه یئ';

  @override
  String get editProfile => 'پروفایل سمون';

  @override
  String get profileUpdatedSnackbar => 'پروفایل تازه شو (API سره وصل کړئ)';

  @override
  String get noOrdersYet => 'تر اوسه امرونه نشته';

  @override
  String get add => 'اضافه کړئ';

  @override
  String get viewCart => 'کارټ وګورئ';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePashto => 'پښتو';

  @override
  String get languageDari => 'دری';

  @override
  String get welcomeBack => 'بیرته ښه راغلاست';

  @override
  String get signInToContinue => 'د امر کولو لپاره ننوځئ';

  @override
  String get dontHaveAccount => 'حساب نلرئ؟ ';

  @override
  String get alreadyHaveAccount => 'دمخه حساب لرئ؟ ';

  @override
  String get fullName => 'بشپړ نوم';

  @override
  String get phoneNumber => 'د تلیفون نمبر';

  @override
  String get confirmPassword => 'پاسورډ تایید کړئ';

  @override
  String get passwordMinLength => 'پاسورډ لږ تر لږه 6 توري ولري';

  @override
  String get passwordsDoNotMatch => 'پاسورډونه سره مطابقت نلري';

  @override
  String get pleaseEnterName => 'مهرباني وکړئ خپل نوم ولیکئ';

  @override
  String get authNameTooShort => 'د خپل نوم لپاره لږ تر لږه ۲ توري ولیکئ.';

  @override
  String get authNameTooLong => 'نوم ډېر اوږد دی (زیات له ۸۰ تورو).';

  @override
  String get authNameLooksLikePhoneNumber =>
      'دا د تلیفون نمبر ته ورته دی. نوم د نوم په ډګر کې ولیکئ.';

  @override
  String get authNameMustContainLetters =>
      'د تورو سره نوم ولیکئ (نه یوازې عددونه یا نښې).';

  @override
  String get pleaseEnterEmail => 'مهرباني وکړئ خپل بریښنالیک ولیکئ';

  @override
  String get signInToViewProfile => 'د پروفایل لیدو لپاره ننوتل';

  @override
  String get save => 'خوندي کړئ';

  @override
  String get proceedToCheckout => 'تادیه ته لاړ شئ';

  @override
  String get cartEmptyHint => 'د پیل لپاره له رستوران څخه توکي اضافه کړئ';

  @override
  String get cannotReachServer => 'سرور ته رسیدل نشي';

  @override
  String get orderHistoryHint => 'ستاسو د امر تاریخ به دلته ښکاره شي';

  @override
  String get placeOrder => 'امر وړاندې کړئ';

  @override
  String get pullToRefreshOrRetry => 'تازه کولو یا بیا هڅه لپاره ښکته کش کړئ';

  @override
  String get dashboard => 'ډشبورډ';

  @override
  String get customerDashboardSubtitle => 'نن ستاسو د حساب وضعیت.';

  @override
  String get customerDashboardTotalOrders => 'ټول امرونه';

  @override
  String get customerDashboardActiveOrders => 'فعال امرونه';

  @override
  String get customerDashboardTotalSpent => 'ټول لګښت';

  @override
  String get customerDashboardOpenTickets => 'خلاص ټکټونه';

  @override
  String get customerDashboardOrderFood => 'خواړه امر کړئ';

  @override
  String customerDashboardOrderMeta(String placed, String items) {
    return '$placed · $items';
  }

  @override
  String get orderStatusRefunded => 'بیرته ورکړل شوی';

  @override
  String get discountCode => 'د تخفیف کوډ';

  @override
  String get supportTicket => 'د ملاتړ ټکټ';

  @override
  String get search => 'لټون';

  @override
  String get foods => 'خواړه';

  @override
  String get searchAllHint => 'رستورانونه او خواړه ولټوئ...';

  @override
  String get noResults => 'پایله نشته';

  @override
  String get tryDifferentKeywords => 'بلې کلیمې وازمایئ';

  @override
  String get allRestaurants => 'ټول رستورانونه';

  @override
  String get specialDeals => 'ځانګړي معاملات';

  @override
  String get orderSummaryCaps => 'د امر لنډیز';

  @override
  String get sizeLabel => 'کچه';

  @override
  String get promoCodeCopied => 'د پرومو کوډ کاپي شو';

  @override
  String freeDeliveryAboveDeal(String amount) {
    return 'په امرونو کې وړیا تحویلي له $amount پورته';
  }

  @override
  String deliveryFeeDeal(String amount) {
    return 'د تحویلي فیس: $amount';
  }

  @override
  String get welcomeToLoqma => 'لقمې ته ښه راغلاست';

  @override
  String get signInWithPhoneWhatsAppOtp =>
      'د خپل تلیفون نمبر سره ننوځئ. موږ به پیغام OTP درولېږو.';

  @override
  String get sendOtp => 'OTP ولېږئ';

  @override
  String get continueAction => 'ادامه';

  @override
  String get sendRegistrationOtp => 'د نوم لیکنې OTP ولېږئ';

  @override
  String get pleaseEnterPhoneNumber => 'مهرباني وکړئ خپل تلیفون نمبر ولیکئ.';

  @override
  String get invalidAfghanPhone =>
      'سم افغاني موبایل نمبر ولیکئ (۰۷ یا +۹۳۷، بیا ۰–۴ یا ۶–۹، لکه ۰۷۲ ۱۲۳ ۴۵۶۷).';

  @override
  String get testOtpTitle => 'ازمایښتي OTP';

  @override
  String testOtpUseCode(String code) {
    return 'کوډ $code وکاروئ';
  }

  @override
  String get verifyOtpTitle => 'OTP تایید کړئ';

  @override
  String get otpEnterCodeWhatsApp =>
      'هغه ۳ عددي کوډ ولیکئ چې ستاسو پیام ته لیږل شوی.';

  @override
  String get otpTestModeDescription =>
      'ازمایښتي حالت فعال دی. تاسو کولی شئ لاندې کوډ مستقیم وکاروئ.';

  @override
  String otpTestModeBanner(String code) {
    return 'ازمایښتي حالت: OTP $code';
  }

  @override
  String get otpCodeLabel => 'د OTP کوډ';

  @override
  String get otpCodeHint => '123456';

  @override
  String get verifyAndContinue => 'تایید او دوام';

  @override
  String get resendOtp => 'OTP بیا ولېږئ';

  @override
  String get otpEnterSixDigits => '۳ عددي OTP ولیکئ.';

  @override
  String get otpIncompleteCode => 'د کوډ هرې درې عددونه ولیکئ.';

  @override
  String get otpInvalidCode => 'سم ۳ عددي کوډ ولیکئ (یوازې عددونه).';

  @override
  String get otpSentAgain => 'OTP بیا ولېږل شو';

  @override
  String otpSentAgainTest(String code) {
    return 'OTP بیا ولېږل شو. ازمایښتي کوډ: $code';
  }

  @override
  String get authWhatsYourName => 'ستاسو نوم څه دی؟';

  @override
  String get authEnterPhoneNumber => 'د تلیفون نمبر ولیکئ';

  @override
  String get authContinue => 'دوام';

  @override
  String get authSendCode => 'کوډ ولېږئ';

  @override
  String get authPhoneVerifyHint => 'د پېژندنې لپاره به موږ ۳ عددي کوډ واستوو.';

  @override
  String get authVerification => 'تایید';

  @override
  String get authEnterCodeSentTo => 'لیږل شوی کوډ ولیکئ';

  @override
  String get authVerifyAccount => 'حساب تایید کړئ';

  @override
  String get authResendVerificationCodeUpper => 'د تایید کوډ بیا لیږل';

  @override
  String get nameHintExample => 'احمد کریمی';

  @override
  String get updateAvailableTitle => 'تازه‌کاری شته';

  @override
  String get updateAvailableMessageDefault => 'د اپ نوی نسخه شته.';

  @override
  String get later => 'وروسته';

  @override
  String get updateNow => 'اوس تازه کړئ';

  @override
  String get updateInstallPermissionMessage =>
      'د دې سرچینې څخه د اپ نصب اجازه ورکړئ (یا نامعلوم اپونه) دوام لپاره.';

  @override
  String get updateCouldNotOpenInstaller => 'نصب کوونکی پرانیستل نشو.';

  @override
  String get updateDownloadFailed => 'ډاونلوډ ناکام شو.';

  @override
  String get backToOrderDetails => 'د امر جزئیاتو ته شاته';

  @override
  String get couldNotLoadTracking => 'تعقیب پورته کول نشو.';

  @override
  String get restaurantDefaultName => 'رستوران';

  @override
  String get yourLocation => 'ستاسو ځای';

  @override
  String get mapMarkerRestaurant => 'رستوران';

  @override
  String get mapMarkerDelivery => 'تحویلي';

  @override
  String get mapMarkerDriver => 'موټر چلوونکی';

  @override
  String orderTrackDistanceKm(String distance) {
    return '$distance km';
  }

  @override
  String orderTrackEtaApprox(String minutes) {
    return '~$minutes دقیقې';
  }

  @override
  String orderTrackEtaScheduled(String time) {
    return '$time';
  }

  @override
  String get orderTrackCenterMap => 'لاره ښکاره کړه';

  @override
  String get orderTrackZoomIn => 'غټ کړه';

  @override
  String get orderTrackZoomOut => 'وړ کړه';

  @override
  String get orderTrackDirections => 'لارښود';

  @override
  String get orderTrackDirectionsCouldNotOpen => 'نقشه پرانیستل نه شول.';

  @override
  String orderNumberLabel(String orderId) {
    return 'امر #$orderId';
  }

  @override
  String get estimatedDeliveryTime => 'اټکل شوې د تحویلي وخت';

  @override
  String get routeFromLabel => 'له';

  @override
  String get routeToLabel => 'ته';

  @override
  String get callDriver => 'موټر چلوونکي ته زنګ ووهئ';

  @override
  String get vehicleDefault => 'موټر';

  @override
  String get lookingForDriver => 'موټر چلوونکی لټوو…';

  @override
  String get deliveryAddressSection => 'د تحویلي پته';

  @override
  String get yourDriver => 'ستاسو موټر چلوونکی';

  @override
  String get trackDriverLive => 'ژوندی';

  @override
  String get trackStatusPending => 'امر ثبت شو';

  @override
  String get trackStatusConfirmed => 'تایید شو';

  @override
  String get trackStatusPreparing => 'چمتو کېږي';

  @override
  String get trackStatusReady => 'چمتو';

  @override
  String get trackStatusPickedUp => 'اخیستل شو';

  @override
  String get trackStatusOnTheWay => 'په لار کې';

  @override
  String get trackStatusDelivered => 'تحویل شو';

  @override
  String get orderStatusCancelled => 'لغو شوی';

  @override
  String get menuSectionTitle => 'مینو';

  @override
  String get customerReviewsSectionTitle => 'د پیرودونو نظرونه';

  @override
  String get noCustomerReviewsYet => 'تر اوسه نظر نشته.';

  @override
  String get reviewsCouldNotLoad => 'نظرونه بار نشول. دا مخ بیا پرانیزئ.';

  @override
  String get similarRestaurantsSectionTitle => 'ورته رستورانونه';

  @override
  String get availableOffersSectionTitle => 'شته وړاندیزونه';

  @override
  String get loadingRestaurant => 'رستوران بار کېږي…';

  @override
  String get searchMenuItemsHint => 'د مینو توکي لټوئ…';

  @override
  String copiedCodeMessage(String code) {
    return '$code کاپي شو';
  }

  @override
  String get defaultLocationPlaceholder => 'د ښار مرکز';

  @override
  String get defaultRestaurantCategoryTagline => 'فست فوډ • پیزا';

  @override
  String get restaurantsInThisCategory => 'په دې کټګورۍ کې رستورانونه';

  @override
  String get discoverOrderBestSubtitle => 'غوره رستورانونه ومومئ او امر وکړئ';

  @override
  String get superAdminPayments => 'د سوپر ادمین تادیې';

  @override
  String get viewFullPaymentDetails => 'بشپړ تادیه جزئیات وګورئ';

  @override
  String get completeRawResponsePayload => 'بشپړ خام ځواب';

  @override
  String get unknownEntity => 'نامعلوم';

  @override
  String get labelRestaurantId => 'د رستوران پېژند';

  @override
  String get driverProfileAndSettings => 'پروفایل او ترتیبونه';

  @override
  String get profileUpdatedSuccess => 'پروفایل تازه شو';

  @override
  String get saveChanges => 'بدلونونه خوندي کړئ';

  @override
  String orderUpdatedToStatus(String orderNumber, String status) {
    return 'امر $orderNumber ته $status تازه شو';
  }

  @override
  String orderUpdatedShort(String orderNumber) {
    return 'امر $orderNumber تازه شو';
  }

  @override
  String get restaurantDashboard => 'د رستوران ډشبورډ';

  @override
  String get recentOrders => 'تازه امرونه';

  @override
  String get noRecentOrdersYet => 'لا نور امر نشته.';

  @override
  String get leaveReview => 'نظر ورکړئ';

  @override
  String get viewDetails => 'جزئیات وګورئ';

  @override
  String get leaveAReview => 'نظر ورکړئ';

  @override
  String get browseToReorderFromRestaurant =>
      'بیا د دې رستوران څخه د امر لپاره رستورانونه وګورئ';

  @override
  String get reorder => 'بیا امر';

  @override
  String get cancelOrderAction => 'امر لغوه کړئ';

  @override
  String get active => 'فعال';

  @override
  String get available => 'شته';

  @override
  String get specialOfferDealsTab => 'ځانګړی وړاندیز (د معاملو ټاب)';

  @override
  String get specialOfferDealsSubtitle =>
      'د معمولي قیمت څخه لاندې تخفیف شوې بیه پکار ده';

  @override
  String get listUnderDeals => 'په معاملو کې لیست کړئ';

  @override
  String get listUnderDealsSubtitle =>
      'رستوران باید فعال وي؛ د تخفیف نیټې پلي کېږي که تنظیم شوي وي';

  @override
  String get enterDiscountedPricePositive =>
      'د صفر څخه لوړه تخفیف شوې بیه ولیکئ.';

  @override
  String specialOfferForItem(String itemName) {
    return 'ځانګړی وړاندیز: $itemName';
  }

  @override
  String get menuManagement => 'د مینو مدیریت';

  @override
  String get noMenuCategoriesYet => 'لا د مینو کټګوري نشته';

  @override
  String get createFirstCategoryHint =>
      'لومړۍ کټګوري جوړه کړئ ترڅو مینو تنظیم کړئ.';

  @override
  String get createFirstCategory => 'لومړۍ کټګوري جوړه کړئ';

  @override
  String itemsCountInCategory(String count) {
    return '$count توکي';
  }

  @override
  String get noItemsInCategory => 'په دې کټګورۍ کې لا توکي نشته.';

  @override
  String get restaurantSettingsUpdated => 'د رستوران ترتیبونه تازه شول';

  @override
  String get restaurantSettingsTitle => 'د رستوران ترتیبونه';

  @override
  String get acceptCashOnDelivery => 'په تحویلي کې نغدي منل';

  @override
  String get acceptOnlinePayment => 'آنلاین تادیه منل';

  @override
  String get saveSettings => 'ترتیبونه خوندي کړئ';

  @override
  String get restaurantOrdersTitle => 'د رستوران امرونه';

  @override
  String get noOrdersForFilter => 'په دې فلټر کې هیڅ امر ونه موندل شو.';

  @override
  String get orderActionConfirm => 'تایید';

  @override
  String get orderActionStartPreparing => 'چمتو کول پیل کړئ';

  @override
  String get orderActionMarkReady => 'چمتو نښه کړئ';

  @override
  String driverWithName(String name) {
    return 'موټر چلوونکی: $name';
  }

  @override
  String get myEarningsTitle => 'زما عایدات';

  @override
  String get payoutRequested => 'د تادیې غوښتنه ثبت شوه';

  @override
  String get requestPayout => 'تادیه غواړئ';

  @override
  String get offersDealsTitle => 'وړاندیزونه او معاملې';

  @override
  String get offersDealsEmptyHint =>
      'رستورانونه کولی شي په مینو توکو کې تخفیفونه اضافه کړي؛ دلته به ښکاري.';

  @override
  String get closeTicketTitle => 'ټکټ وتړئ؟';

  @override
  String get closeTicketMessage => 'که اړتیا وي وروسته بیا پرانیزلی شي.';

  @override
  String get closeAction => 'تړل';

  @override
  String get ticketClosedSuccess => 'ټکټ وتړل شو.';

  @override
  String get ticketReopenedSuccess => 'ټکټ بیا پرانیستل شو.';

  @override
  String get ticketScreenTitle => 'ټکټ';

  @override
  String get sendReply => 'ځواب واستوئ';

  @override
  String get reopenIfPersists => 'که ستونزه دوام لري بیا پرانیزئ';

  @override
  String failedToSendMessage(String error) {
    return 'استول ناکام: $error';
  }

  @override
  String get deleteAddressTitle => 'پته ړنګه کړئ؟';

  @override
  String deleteAddressMessage(String label) {
    return '«$label» ړنګه شي؟ دا بیرته نه شي کیدی.';
  }

  @override
  String get deleteAction => 'ړنګول';

  @override
  String get addressRemovedSuccess => 'پته لرې شوه';

  @override
  String get editAction => 'سمول';

  @override
  String get removeAllNotificationsConfirm =>
      'ټولې خبرتیاوې له دې لیست څخه لرې شي؟';

  @override
  String get markAllRead => 'ټول لوستل شوي نښه کړئ';

  @override
  String get orderHistoryTitle => 'د امرونو تاریخ';

  @override
  String get pleaseSelectCity => 'مهرباني وکړئ ښار وټاکئ';

  @override
  String get citiesStillLoading =>
      'ښارونه لا بارېږي. یو څه وروسته بیا هڅه وکړئ.';

  @override
  String get turnOnLocationServices =>
      'د دې اختیار لپاره ځای خدمتونه چالان کړئ.';

  @override
  String get locationPermissionRequired =>
      'ستاسو پته موندلو لپاره د ځای اجازه پکار ده.';

  @override
  String get couldNotResolveAddress => 'ستاسو ځای څخه پته ونه موندل شوه.';

  @override
  String get cityNotDetectedChoose =>
      'ښار په اتوماتیک ډول ونه موندل شو — لاندې یې وټاکئ.';

  @override
  String get locationAppliedReviewSave =>
      'ځای پلي شو. ساحې وګورئ او خوندي کړئ.';

  @override
  String couldNotGetLocation(String error) {
    return 'ځای ترلاسه ناکام: $error';
  }

  @override
  String get setAsDefaultAddress => 'د ډیفالټ پتې په توګه تنظیم کړئ';

  @override
  String get openRestaurantNotAvailable =>
      'د دې توکي لپاره رستوران نشي پرانیستلی';

  @override
  String get hesabPayTitle => 'حساب‌پی';

  @override
  String get paymentNotCompleted => 'تادیه بشپړه نه شوه.';

  @override
  String get paymentSuccessfulConfirmed => 'تادیه بریالۍ. امر تایید شو.';

  @override
  String get paymentFailedOrCancelled => 'تادیه ناکامه یا لغوه شوه.';

  @override
  String get paymentProcessingCheckOrders =>
      'تادیه لا پروسېږي. ژر «زما امرونه» وګورئ.';

  @override
  String get payOnlineSecurely => 'په خوندي ډول آنلاین تادیه';

  @override
  String get acceptOrder => 'امر ومنئ';

  @override
  String get navEarnings => 'عایدات';

  @override
  String get navRestaurantMenu => 'مینو';

  @override
  String get orderCancelledRefundHint =>
      'امر لغوه شو. که اړتیا وي بیرته ورکړنه به کېږي.';

  @override
  String failedToCancelOrder(String error) {
    return 'لغوه ناکامه: $error';
  }

  @override
  String get cancelOrderTitle => 'امر لغوه کړئ';

  @override
  String get keepOrder => 'امر وساتئ';

  @override
  String get cancelOrderConfirmTitle => 'په ډاډه یاست چې امر لغوه کړئ؟';

  @override
  String get cancelOrderConfirmBody =>
      'دا کار بیرته نشي. که تادیه مو کړې وي، بیرته ورکړنه به ترسره شي که اړتیا وي.';

  @override
  String get cancelReasonSectionTitle => 'دلیل ولیکئ';

  @override
  String get cancelAdditionalDetailsLabel => 'نور جزئیات (اختیاري)';

  @override
  String get cancelReasonChangedMind => 'فکر مې بدل شو';

  @override
  String get cancelReasonWrongOrder => 'غلط امر شوی و';

  @override
  String get cancelReasonFoundElsewhere => 'بل ځای خواړه وموندل';

  @override
  String get cancelReasonDeliveryLong => 'د تحویل وخت اوږد و';

  @override
  String get cancelReasonPriceIssue => 'د بیې یا تادیې ستونزه';

  @override
  String get cancelReasonOther => 'نور';

  @override
  String get cancelReasonHint => 'د ښه کېدو لپاره نور جزئیات ولیکئ…';

  @override
  String get pleaseRateRestaurantAndFood =>
      'مهرباني وکړئ رستوران او خواړه (۱–۵ ستوري) درجه کړئ.';

  @override
  String get orderReviewScreenSubtitle => 'ستاسو د دې امر تجربه څنګه وه؟';

  @override
  String get orderReviewRateRestaurantTitle => 'رستوران ته درجه ورکړئ';

  @override
  String get orderReviewRateFoodTitle => 'خواړو ته درجه ورکړئ';

  @override
  String get orderReviewRateDeliveryTitle => 'تحویل ته درجه ورکړئ';

  @override
  String get orderReviewAddPhotosSectionTitle => 'انځورونه اضافه کړئ (اختیاري)';

  @override
  String get thankYouReviewSubmitted => 'مننه! ستاسو نظر ثبت شو.';

  @override
  String failedSubmitReview(String error) {
    return 'د نظر ثبت ناکام: $error';
  }

  @override
  String get addPhotos => 'انځورونه اضافه کړئ';

  @override
  String get submitReview => 'نظر واستوئ';

  @override
  String get reviewDeliveryHint => 'د تحویلي تجربه ولیکئ…';

  @override
  String get reviewRestaurantHint => 'د خواړو او رستوران تجربه ولیکئ…';

  @override
  String get addressLabelHint => 'لکه کور، د کار ځای';

  @override
  String get addressAreaHint => 'لکه کارتې چار';

  @override
  String get addressStreetHint => 'د سړک نوم او شمېره';

  @override
  String get addressNotesHint => 'لکه زنګ، د رسېدو پر مهال زنګ';

  @override
  String get ticketReplyHint => 'خپل ځواب دلته ولیکئ…';

  @override
  String get dateHintExampleStart => 'لکه 2026-03-28 00:00:00';

  @override
  String get dateHintExampleEnd => 'لکه 2026-04-01 23:59:59';

  @override
  String get optionalStartLabel => 'پیل (اختیاري)';

  @override
  String get optionalEndLabel => 'پای (اختیاري)';

  @override
  String get isoDateHint => 'ISO یا Y-m-d H:i';

  @override
  String get restaurantNameField => 'د رستوران نوم';

  @override
  String get restaurantNameDariField => 'د رستوران نوم (دری)';

  @override
  String get verifyOtpAppBar => 'OTP تایید';

  @override
  String orderStatusTimeSeparator(String status, String time) {
    return '$status • $time';
  }

  @override
  String get ticketCategoryRestaurant => 'رستوران';

  @override
  String get restaurantSampleOfferTitle => '۲۰٪ تخفیف برګر';

  @override
  String get restaurantSampleOfferSubtitle =>
      'په ټولو برګرونو ۲۰٪ تخفیف. لږترلږ امر ۱۵ ډالر.';

  @override
  String get restaurantDeliveryOfferTitle => 'د تحویلي وړاندیز';

  @override
  String get restaurantOfferFreeDeliveryNext =>
      'په راتلونکي امر کې وړیا سپارنه — پرته له لږترلږه مقدار.';

  @override
  String restaurantOfferFreeDeliveryOverAmount(String amount) {
    return 'په امرونو چې له $amount څخه زیات وي وړیا سپارنه.';
  }

  @override
  String get restaurantOfferLimitedDeliverySavings =>
      'د سپارنې پر لګښت محدود تخفیف.';

  @override
  String get backToOrders => 'بیرته امرونو ته';

  @override
  String get ticketCategoryOrderIssue => 'د امر ستونزه';

  @override
  String get ticketCategoryPayment => 'تادیه';

  @override
  String get ticketCategoryDelivery => 'تحویلي';

  @override
  String get ticketCategoryAccount => 'حساب';

  @override
  String get ticketCategoryOther => 'نور';

  @override
  String get ticketStatusOpen => 'خلاص';

  @override
  String get ticketStatusInProgress => 'د پروسې کې';

  @override
  String get ticketStatusWaiting => 'د ځواب انتظار';

  @override
  String get ticketStatusResolved => 'حل شوی';

  @override
  String get ticketStatusClosed => 'تړل شوی';

  @override
  String get ticketPriorityLow => 'ټیټ';

  @override
  String get ticketPriorityMedium => 'منځنی';

  @override
  String get ticketPriorityHigh => 'لوړ';

  @override
  String get ticketPriorityUrgent => 'عاجل';

  @override
  String get fieldRequired => 'اړین';

  @override
  String ticketRelatedOrderOption(String orderId, String restaurant) {
    return '#$orderId — $restaurant';
  }

  @override
  String get tapViewDetailsForItems => 'د توکو لپاره «جزئیات وګورئ» ووهئ';

  @override
  String get orderDetailLoadError => 'د امر جزئیات بار نشول.';

  @override
  String get orderItemsTitle => 'د امر توکي';

  @override
  String get noItemsInOrder => 'توکي نشته';

  @override
  String get orderTimelineTitle => 'د امر مهالویش';

  @override
  String get deliveryDetailsTitle => 'د تحویلي جزئیات';

  @override
  String get paymentSummaryDetailTitle => 'د تادیې لنډیز';

  @override
  String get deliveryFeeShort => 'د تحویلي فیس';

  @override
  String get paymentStatusPendingGeneric => 'په تمه';

  @override
  String get paymentStatusPaid => 'تادیه شوی';

  @override
  String get paymentStatusFailed => 'ناکام';

  @override
  String get paymentMethodOnline => 'آنلاین تادیه';

  @override
  String orderItemQtyTimesPrice(String qty, String price) {
    return '$qty × $price';
  }

  @override
  String get emptyValueDash => '—';

  @override
  String get trackOrder => 'امر تعقیب کړئ';

  @override
  String get restaurantSectionTitle => 'رستوران';

  @override
  String get detailRowAddress => 'پته';

  @override
  String get paymentStatusDetail => 'د تادیې حالت';

  @override
  String ticketReplyCount(String count) {
    return '$count ځوابونه';
  }

  @override
  String get checkoutLoadingAddresses => 'پتې بارېږي…';

  @override
  String get offersLoadFailed => 'وړاندیزونه بار نشول.';

  @override
  String get offersNoDealsNow => 'اوس فعال معاملې نشته';

  @override
  String get about => 'په اړه';

  @override
  String get aboutDocumentTitle => 'زموږ په اړه';

  @override
  String get aboutHero => 'هر ډوډۍ سره خوښي، یو ځل';

  @override
  String get aboutHeroSubtitle => 'ستاسو محلي غوره رستورانونه، چټک او تازه.';

  @override
  String get aboutStoryTitle => 'زموږ کیسه';

  @override
  String get aboutStoryDesc =>
      'لقمه لوږ مشتریان د باور وړ محلي رستورانونو سره نښلوي. موږ دا پلیټ فارم جوړ کړ چې د خواړو امر ساده، روښانه او خوښونکی وي—کور، دنده یا هرچیرې.';

  @override
  String get aboutMissionTitle => 'زموږ ماموریت';

  @override
  String get aboutMissionDesc =>
      'ټکنالوجي او باور وړ تحویل له لارې ټولو ته د ښه خواړو لاسرسي پیاوړتیا.';

  @override
  String get aboutVisionTitle => 'زموږ لید';

  @override
  String get aboutVisionDesc =>
      'په سیمه کې ترټولو محبوب د خواړو تحویل تجربه کېدل—د چټکتیا، انصاف او هغو رستورانونو لپاره چې موږ یې ملاتړ کوو.';

  @override
  String get aboutValuesTitle => 'زموږ اصلي ارزښتونه';

  @override
  String get aboutValue1Title => 'مشتری لومړی';

  @override
  String get aboutValue1Desc =>
      'هر ځانګړتیا د پیرودونکو او ملګرو اړتیاوو څخه پیلېږي.';

  @override
  String get aboutValue2Title => 'کیفیت';

  @override
  String get aboutValue2Desc => 'غوره خواړو او باور وړ خدمت ملاتړ کوو.';

  @override
  String get aboutValue3Title => 'ملګرتیا';

  @override
  String get aboutValue3Desc => 'رستورانونه ملګري دي؛ موږ سره وده کوو.';

  @override
  String get aboutValue4Title => 'نوښت';

  @override
  String get aboutValue4Desc => 'لارې، تادیې او اپ کې ستاسو تجربه ښه کوو.';

  @override
  String get aboutWhyTitle => 'ولې موږ غوره کړئ';

  @override
  String get aboutWhy1 => 'چټک تحویل چې په وخت کې تعقیبولی شي.';

  @override
  String get aboutWhy2 => 'د محلي او مشهور رستورانونو غوره شوی لیست.';

  @override
  String get aboutWhy3 => 'روښانه نرخونه او خوندي تادیه.';

  @override
  String get aboutWhy4 => 'کله چې اړتیا وي ملاتړ.';

  @override
  String get aboutWhy5 => 'د هغه ټولنې لپاره چې پکې خدمت کوو.';

  @override
  String get aboutWhy6 => 'دوامداره تازه کول او نوې ځانګړتیاوې.';

  @override
  String get aboutStatsTitle => 'لقمه په شمېر';

  @override
  String get aboutStat1Num => '۵۰۰+';

  @override
  String get aboutStat1Label => 'د رستوران ملګري';

  @override
  String get aboutStat2Num => '۵۰ زره+';

  @override
  String get aboutStat2Label => 'تحویل شوي امرونه';

  @override
  String get aboutStat3Num => '۲۴/۷';

  @override
  String get aboutStat3Label => 'د پیرودونکي ملاتړ';

  @override
  String get aboutStat4Num => '۱۰۰٪';

  @override
  String get aboutStat4Label => 'ستاسو ته ژمنه';

  @override
  String get aboutCoverageTitle => 'د خدمت پوښښ';

  @override
  String get aboutCoverageDesc =>
      'موږ په ښارونو او سیمو کې پراخېږو. په اپ کې خپله پته ولیکئ ترڅو نږدې رستورانونه وګورئ.';

  @override
  String get aboutCtaTitle => 'پوښتنه لرئ؟';

  @override
  String get aboutCtaBtn => 'زموږ سره اړیکه';

  @override
  String get contactUs => 'زموږ سره اړیکه';

  @override
  String get contactDocumentTitle => 'اړیکه';

  @override
  String get contactHero => 'موږ ستاسو لپاره حاضر یو';

  @override
  String get contactSubtitle =>
      'د تلیفون، بریښنالیک یا لاندې فورم له لارې راشئ.';

  @override
  String get contactNavReachTooltip => 'تلیفون، بریښنالیک او دفترونه';

  @override
  String get contactNavFormTooltip => 'د پیغام فورم';

  @override
  String get contactNavFaqTooltip => 'ډېرې پوښتل شوې پوښتنې';

  @override
  String get contactNavOverviewTooltip => 'د اړیکو جزئیات او فورم';

  @override
  String get contactCallTitle => 'زنګ ووهئ';

  @override
  String get contactCallOffice => 'دفتر';

  @override
  String get contactCallMobile => 'موبایل';

  @override
  String get contactEmailTitle => 'بریښنالیک';

  @override
  String get contactEmailGeneral => 'عمومي پوښتنې';

  @override
  String get contactEmailSupport => 'ملاتړ';

  @override
  String get contactVisitTitle => 'زموږ پته';

  @override
  String get contactVisitMazarLabel => 'مزار شریف';

  @override
  String get contactVisitMazarBody =>
      'د مخابراتو څلورلارې، زینت پلازا (د عزیزي بانک مرکزي)، څلورم منزل، صلایان شرکت، مزار شریف.';

  @override
  String get contactVisitKabulLabel => 'کابل';

  @override
  String get contactVisitKabulBody =>
      'شهرنو، د اتوما شرکت څنګ، د ساعت برج، پنځم منزل، صلایان شرکت، کابل.';

  @override
  String get contactFollowTitle => 'موږ تعقیب کړئ';

  @override
  String get contactHoursTitle => 'د کار ساعتونه';

  @override
  String get contactHoursDays => 'دوشنبه تر شنبې';

  @override
  String get contactHoursTime => '۸:۰۰ څخه تر ۲۰:۰۰';

  @override
  String get contactHoursNote => 'په رسمي رخصتیو کې ممکن بدلون وشي.';

  @override
  String get contactFormTitle => 'پیغام واستوئ';

  @override
  String get contactFormName => 'بشپړ نوم';

  @override
  String get contactFormEmail => 'بریښنالیک';

  @override
  String get contactFormPhone => 'تلیفون';

  @override
  String get contactFormSubject => 'موضوع';

  @override
  String get contactFormSubjectHint => 'موضوع وټاکئ';

  @override
  String get contactFormSubjectGeneral => 'عمومي پوښتنه';

  @override
  String get contactFormSubjectSupport => 'د پیرودونکي ملاتړ';

  @override
  String get contactFormSubjectPartnership => 'رستوران / ملګرتیا';

  @override
  String get contactFormSubjectDriver => 'د موټر چلوونکي پوښتنه';

  @override
  String get contactFormSubjectComplaint => 'شکایت';

  @override
  String get contactFormSubjectFeedback => 'بیرته راګرځونه';

  @override
  String get contactFormSubjectOther => 'نور';

  @override
  String get contactFormMessage => 'پیغام';

  @override
  String get contactFormSubmit => 'پیغام واستوئ';

  @override
  String get contactFormSuccessSnackbar =>
      'مننه! ستاسو بریښنالیک اپلیکیشن به پیغام سره پرانیزي.';

  @override
  String get contactFormSubjectError => 'مهرباني وکړئ موضوع وټاکئ.';

  @override
  String get contactFormRequired => 'دا ساحه اړینه ده.';

  @override
  String get contactFormEmailInvalid => 'د بریښنالیک سم بڼه ولیکئ.';

  @override
  String get contactEmailSubjectPrefix => 'اړیکه';

  @override
  String get contactSocialSoon => 'د ټولنیزو رسنیو لینک ژر راځي.';

  @override
  String get contactFaqTitle => 'ډېرې پوښتل شوې پوښتنې';

  @override
  String get contactFaq1Q => 'امر څنګه تعقیب کړم؟';

  @override
  String get contactFaq1A =>
      'په اپ کې امرونه خلاص کړئ او امر غوره کړئ ترڅو حالت وګورئ.';

  @override
  String get contactFaq2Q => 'د تحویلي پته څنګه بدله کړم؟';

  @override
  String get contactFaq2A =>
      'د تادیې دمخه پته بدل کړئ. وروسته ژر له ملاتړ سره اړیکه ونیسئ.';

  @override
  String get contactFaq3Q => 'کوم تادیې شته؟';

  @override
  String get contactFaq3A => 'په تسویه کې ښودل کیږي؛ نغدي یا آنلاین.';

  @override
  String get contactFaq4Q => 'رستوران ملګری څنګه شم؟';

  @override
  String get contactFaq4A => 'په فورم کې «رستوران / ملګرتیا» وټاکئ.';

  @override
  String get contactFaq5Q => 'کله ځواب ورکوئ؟';

  @override
  String get contactFaq5A =>
      'معمولاً په یو کاري ورځ کې. د بیړني امر لپاره ملاتړي شمېره ووهئ.';

  @override
  String get totalEarningsLabel => 'ټول عاید';

  @override
  String get pendingPayoutLabel => 'پاتې تادیه';

  @override
  String get totalDeliveriesLabel => 'ټولې تحویلۍ';

  @override
  String get ratingStatLabel => 'درجه';

  @override
  String get todaysEarningsLabel => 'نن ورځ عاید';

  @override
  String get thisWeekLabel => 'دا اونۍ';

  @override
  String get driverOfflineTitle => 'تاسو آفلاین یاست';

  @override
  String get driverActiveDeliveriesTitle => 'فعالې تحویلۍ لرئ';

  @override
  String get driverNoOrdersReadyTitle => 'د اخیستلو لپاره امر نشته';

  @override
  String get clearAllTooltip => 'ټول پاک کړئ';

  @override
  String get reopenAction => 'بیا پرانیزئ';

  @override
  String get refreshTooltip => 'تازه کړئ';

  @override
  String get addressSavedSuccess => 'پته خوندي شوه';

  @override
  String get addressUpdatedSuccess => 'پته تازه شوه';

  @override
  String get basicInformation => 'بنسټیز معلومات';

  @override
  String get deliveryAndPayment => 'تحویلي او تادیه';

  @override
  String get locationSection => 'موقعیت';

  @override
  String get operatingHours => 'د کار ساعتونه';

  @override
  String get todayOrdersLabel => 'نن ورځ امرونه';

  @override
  String get todayRevenueLabel => 'نن ورځ عاید';

  @override
  String get pendingOrdersLabel => 'پاتې امرونه';

  @override
  String get tapOpenSupportTicket => 'د ملاتړ ټکټ پرانیزلو لپاره ټک وکړئ';

  @override
  String get tapViewOrderNotification => 'امر لیدو لپاره ټک وکړئ';

  @override
  String get noLineItems => 'توکي نشته';

  @override
  String get pleaseWaitProcessing => 'مهرباني وکړئ انتظار وکړئ…';

  @override
  String get districtHint => 'لکه: کارته چار';

  @override
  String get streetHint => 'سړک او شمېره';

  @override
  String get deliveryNotesHint => 'لکه: زنګ ووهئ، د رسېدو پر مهال';

  @override
  String get statusOnline => 'آنلاین';

  @override
  String get statusOffline => 'آفلاین';

  @override
  String get driverDashboardTitle => 'د موټر چلوونکي ډاشبورد';

  @override
  String get driverVehicleInformation => 'د وسایط معلومات';

  @override
  String get vehicleTypeLabel => 'د وسیلې ډول (لومړی موټرسایکل یا موټر)';

  @override
  String get vehicleModelLabel => 'د وسیلې ماډل';

  @override
  String get vehicleColorLabel => 'رنګ';

  @override
  String get licensePlateLabel => 'پلیټ';

  @override
  String driverMinimumPayoutMessage(String amount) {
    return 'لږ تر لږه تادیې اندازه $amount ده. نورې تحویلۍ ته دوام ورکړئ!';
  }

  @override
  String get driverReadyForPayoutTitle => 'تادیې لپاره چمتو!';

  @override
  String driverPayoutAvailableMessage(String amount) {
    return 'تاسو $amount د ایستلو لپاره لرئ.';
  }

  @override
  String get driverEarningLabel => 'عاید';

  @override
  String reviewsCountLabel(String count) {
    return '$count بېرونه';
  }

  @override
  String get driverActiveDeliveriesSectionTitle => 'فعال تحویلۍ';

  @override
  String get driverEarningPrefix => 'عاید:';

  @override
  String get driverAvailableOrdersSectionTitle => 'شته امرونه';

  @override
  String get driverOfflineBody => 'د تحویلی غوښتنو لپاره آنلاین شئ.';

  @override
  String get driverBusyDeliveriesBody =>
      'نوی امر ترلاسه لپاره اوسنی تحویلۍ پای ته ورسوئ.';

  @override
  String get driverNoOrdersReadyBody =>
      'کله چې رستوران چمتو کړي، دلته به ښکاره شي.';

  @override
  String get driverUpcomingOrdersTitle => 'راتلونکي امرونه';

  @override
  String get driverUpcomingOrdersHint =>
      'د رستوران چمتو کېدو وروسته د اخیستلو لپاره شته کیږي.';

  @override
  String get recentDeliveriesSectionTitle => 'وروستي تحویلۍ';

  @override
  String get restaurantOpenAcceptingOrders => 'ستاسو رستوران امرونه مني.';

  @override
  String get restaurantCurrentlyClosedNotice => 'ستاسو رستوران اوس تړلی دی.';

  @override
  String get restaurantPendingApprovalNotice =>
      'ستاسو غوښتنه تر بیاکتنې لاندې ده. تنظیمات تکمیل او انتظار وکړئ.';

  @override
  String get restaurantApplicationRejectedNotice =>
      'ستاسو رستوران غوښتنه رد شوه. جزئیات تازه او پشتیباني اړیکه ونیسئ.';

  @override
  String get restaurantNewOrdersSectionTitle => 'نوي امرونه';

  @override
  String get restaurantActiveOrdersSectionTitle => 'فعال امرونه';

  @override
  String get restaurantNoPendingOrdersSubtitle => 'اوس مهال پاتې امر نشته.';

  @override
  String get restaurantNoActiveOrdersSubtitle => 'اوس مهال فعال امر نشته.';

  @override
  String get rejectOrderAction => 'ردول';

  @override
  String get partnerAccountStatusActive => 'فعال ملګری حساب';

  @override
  String get partnerAccountStatusPending => 'د تائید په تمه';

  @override
  String get partnerAccountStatusRejected => 'رد شوی';

  @override
  String get adminHesabPayLoadError => 'HesabPay تادیې پورته نشوې.';

  @override
  String get adminNoHesabPayPayments => 'تر اوسه حساب‌پی تادیات نشته.';

  @override
  String hesabPayPaymentOrderHeader(String order) {
    return 'HesabPay تادیه $order';
  }

  @override
  String get paymentImageLabel => 'د تادیې انځور';

  @override
  String get summaryAmountLabel => 'مبلغ';

  @override
  String get summaryCustomerLabel => 'پیرودونکی';

  @override
  String get summaryCreatedAtLabel => 'جوړېدو وخت';

  @override
  String get summaryTransactionRefLabel => 'د معاملې حواله';

  @override
  String get ticketReplySectionTitle => 'ځواب';

  @override
  String get ticketMessagesEmptyHint => 'لا پیغام نشته.';

  @override
  String ticketAssignedTo(String name) {
    return 'مسئول: $name';
  }

  @override
  String get ticketClosedStateMessage => 'دا ټیکټ تړلی دی.';

  @override
  String get hoursOpenLabel => 'خلاص';

  @override
  String get hoursCloseLabel => 'بند';

  @override
  String get deliveryFeeFieldLabel => 'تحویلي کرایه';

  @override
  String get minimumOrderFieldLabel => 'لږ تر لږه امر';

  @override
  String get freeDeliveryAboveFieldLabel => 'پورته وړیا تحویل';

  @override
  String get averagePrepTimeFieldLabel => 'اوسط چمتو کول وخت';

  @override
  String coordinatesSavedHint(String lat, String lng) {
    return 'دې پته سره مختصات خوندي شول: $lat، $lng';
  }

  @override
  String get useCurrentLocationAction => 'اوسني ځای وکاروئ';

  @override
  String get gettingLocationEllipsis => 'ځای ترلاسه کېږي…';

  @override
  String get deliveryInstructionsLabel => 'د تحویلې لارښوونې';

  @override
  String get addressLabelShort => 'نام';

  @override
  String get cityRequiredLabel => 'ښار *';

  @override
  String get requiredFieldIndicator => '*';

  @override
  String get streetAddressRequiredLabel => 'د سړک پته *';

  @override
  String get streetAddressHint => 'سړک او شمېره';

  @override
  String get buildingFieldLabel => 'ودانۍ';

  @override
  String get floorFieldLabel => 'طبقه';

  @override
  String get apartmentFieldLabel => 'اپارتمان';

  @override
  String get areaFieldLabel => 'سيمه';

  @override
  String get editAddressScreenTitle => 'پته سمول';

  @override
  String get updateAddressButton => 'پته تازه کړئ';

  @override
  String get saveAddressButton => 'پته خوندي کړئ';

  @override
  String get addressChooseCityTitle => 'خپل ښار وټاکئ';

  @override
  String get addressChooseCitySubtitle =>
      'موږ اوس په دغو ښارونو کې سپارنه کوو.';

  @override
  String get addressChooseDistrictTitle => 'خپله ناحیه وټاکئ';

  @override
  String addressChooseDistrictSubtitle(String city) {
    return 'په $city کې یوه ناحیه وټاکئ.';
  }

  @override
  String get addressStreetDetailsTitle => 'د کوڅې جزئیات';

  @override
  String addressStreetDetailsSubtitle(String district, String city) {
    return 'په $district، $city کې د کوڅې نوم او د کور شمېره ولیکئ.';
  }

  @override
  String get addressStreetNameLabel => 'د کوڅې نوم او شمېره';

  @override
  String get addressStreetNameHint => 'لکه سرک ۵، کوڅه ۱۲';

  @override
  String get addressHouseNumberLabel => 'د کور / دفتر شمېره';

  @override
  String get addressHouseNumberHint => 'لکه کور ۲۴ یا دفتر ۳';

  @override
  String get addressStreetRequired => 'مهرباني وکړئ د کوڅې نوم ولیکئ.';

  @override
  String get addressHouseNumberRequired =>
      'مهرباني وکړئ د کور یا دفتر شمېره ولیکئ.';

  @override
  String get addressNoCitiesAvailable => 'اوس هیڅ تحویلي ښار نشته.';

  @override
  String get addressNoDistrictsAvailable =>
      'د دې ښار لپاره ناحیه ونه موندل شوه.';

  @override
  String get addressProfileNamePhoneRequired =>
      'د پتې خوندي کولو لپاره د پروفایل نوم او تلیفون اړین دی.';

  @override
  String get addItemTooltip => 'توکی اضافه کړئ';

  @override
  String get addCategoryTooltip => 'کټه ګوری اضافه کړئ';

  @override
  String get newCategoryDialogTitle => 'نوې کټه ګوری';

  @override
  String get editCategoryDialogTitle => 'کټه ګوری سمول';

  @override
  String get categoryNameFaLabel => 'نوم (دری)';

  @override
  String get newMenuItemTitle => 'نوې منوز توکه';

  @override
  String get editMenuItemTitle => 'منوز توکه سمول';

  @override
  String get foodCategoryDropdownLabel => 'کټه ګوری';

  @override
  String get discountedPriceFieldLabel => 'تخفیفی نرخ';

  @override
  String get preparationTimeMinutesLabel => 'د چمتو کولو وخت';

  @override
  String get menuItemHasSizesLabel => 'کچه (ماشوم، وړ، منځنی، لوی، کورنۍ)';

  @override
  String get menuItemSmallPriceHint =>
      'یوازې هغو کچو ته قیمت ورکړئ چې وړاندې کوئ. خالي پرېږدئ ترڅو ونه زیاته شي — وړ په ډیفالټ نه غوره کیږي.';

  @override
  String get menuItemKidsPriceLabel => 'د ماشوم کچې قیمت (اختیاري)';

  @override
  String get menuItemSmallPriceLabel => 'د وړ کچې قیمت (اختیاري)';

  @override
  String get menuItemMediumPriceLabel => 'د منځني کچې قیمت (اختیاري)';

  @override
  String get menuItemLargePriceLabel => 'د لوی کچې قیمت (اختیاري)';

  @override
  String get menuItemFamilyPriceLabel => 'د کورنۍ کچې قیمت (اختیاري)';

  @override
  String get menuItemSizesAvailable => 'کچې شتون لري';

  @override
  String get offerLabelOptionalField => 'د وړاندیز لیبل (اختیاري)';

  @override
  String get discountStartOptionalField => 'د تخفیف پیل (اختیاري)';

  @override
  String get discountEndOptionalField => 'د تخفیف پای (اختیاري)';

  @override
  String get discountedPriceCurrencyHint => 'تخفیفی نرخ (افغانۍ)';

  @override
  String get labelOptionalField => 'لیبل (اختیاري)';

  @override
  String discountedMustBeBelowRegular(String regular) {
    return 'تخفیفی نرخ باید له عادي نرخ ($regular) لږ وي.';
  }

  @override
  String specialOfferDialogTitle(String itemName) {
    return 'ځانګړی وړاندیز: $itemName';
  }

  @override
  String get specialOfferTooltip => 'ځانګړی وړاندیز';

  @override
  String get descriptionFieldLabel => 'تفصیل';

  @override
  String get defaultLocationStreetFallback => 'اوسنی ځای';

  @override
  String get coordinateLatitudeLabel => 'پراخت';

  @override
  String get coordinateLongitudeLabel => 'اوړ';

  @override
  String get restaurantStatusOpen => 'خلاص';

  @override
  String get restaurantStatusClosed => 'تړ';

  @override
  String prepTimeRange(String low, String high) {
    return '$low–$high دقیقې';
  }

  @override
  String get prepTimeDefault => '۳۵–۴۵ دقیقې';

  @override
  String cartFabWithCount(int count) {
    return 'کارټ، $count توکي';
  }

  @override
  String get mainNavHome => 'کور ټب';

  @override
  String get mainNavOffers => 'وړاندیزونه ټب';

  @override
  String get mainNavFavorites => 'خوښې ټب';

  @override
  String get mainNavOrders => 'امرونه ټب';

  @override
  String cartQtyLine(int quantity) {
    return 'مقدار: $quantity';
  }

  @override
  String get tax => 'مالیه';

  @override
  String get discount => 'تخفیف';

  @override
  String cartFromRestaurant(String name) {
    return 'له $name';
  }

  @override
  String get adminSuperPaymentsTitle => 'د ادمین تادیات';

  @override
  String get adminRefresh => 'تازه کول';

  @override
  String get adminCouldNotLoadPayments => 'د حساب‌پی تادیات پورته نشول.';

  @override
  String adminHesabPayPaymentOrder(String order) {
    return 'حساب‌پی تادیه $order';
  }

  @override
  String get adminRestaurant => 'رستورانت';

  @override
  String get adminCustomer => 'پیرودونکی';

  @override
  String get adminAmount => 'مبلغ';

  @override
  String get adminPaymentStatus => 'د تادیې حالت';

  @override
  String get adminViewPaymentDetails => 'بشپړ تادیې جزئیات';

  @override
  String get adminOrderId => 'د امر پېژند';

  @override
  String get adminCreatedAt => 'نیټه';

  @override
  String get adminPaymentDetails => 'د تادیې جزئیات';

  @override
  String get ordersTabFilterTooltip => 'امرونه فلټر کړئ';

  @override
  String get ordersTabShowOrders => 'امرونه وښایاست';

  @override
  String get ordersTabFilterAll => 'ټول امرونه';

  @override
  String get ordersTabFilterActive => 'یوازې فعال';

  @override
  String get ordersTabFilterCompleted => 'بشپړ شوي';

  @override
  String get ordersTabFilterCancelled => 'لغو شوي';

  @override
  String get ordersTabSectionActive => 'فعال امرونه';

  @override
  String get ordersTabSectionCompleted => 'بشپړ شوي امرونه';

  @override
  String get ordersTabSectionCancelled => 'لغو شوي';

  @override
  String ordersTabReviewsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count امرونه ستاسو بیاکتنې ته اړتیا لري',
      one: '۱ امر ستاسو بیاکتنې ته اړتیا لري',
    );
    return '$_temp0';
  }

  @override
  String ordersTabPlacedRelative(String time) {
    return 'ثبت $time';
  }

  @override
  String get ordersTabDefaultDeliveryWindow => '۳۵–۴۵ دقیقې';

  @override
  String get ordersTabMapLegendRestaurant => 'رست.';

  @override
  String get ordersTabMapLegendDestination => 'تاسو';

  @override
  String get relativeTimeJustNow => 'همدا اوس';

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count دقیقې وړاندې';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count ساعته وړاندې';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count ورځې وړاندې';
  }

  @override
  String relativeTimeWeeksAgo(int count) {
    return '$count اونۍ وړاندې';
  }

  @override
  String relativeTimeMonthsAgo(int count) {
    return '$count میاشتې وړاندې';
  }

  @override
  String relativeTimeYearsAgo(int count) {
    return '$count کال وړاندې';
  }

  @override
  String get restaurantMenuEmpty => 'تر اوسه په مینو کې توکي نشته.';

  @override
  String get restaurantMenuSearchNoResults =>
      'ستاسو پلټنې سره هیڅ توکی نه دی موندل شوی.';

  @override
  String get restaurantDetailsLoadFailed => 'دا رستورانت پورته نشو.';

  @override
  String get reviewAnonymousCustomer => 'پیرودونکی';

  @override
  String get menuItemAddToCart => 'کارټ ته اضافه کړئ';

  @override
  String get menuItemOptionsLabel => 'انتخابونه';

  @override
  String get menuItemAddonsLabel => 'اضافي توکي';

  @override
  String get menuItemQuantityLabel => 'شمېر';

  @override
  String get profileTabEditHint => 'پروفایل وګورئ او سمون ورکړئ';

  @override
  String get profileTabOpenAccount => 'پروفایل سمون';

  @override
  String get profileTabNavDashboard => 'ډشبورډ خلاص کړئ';

  @override
  String get profileTabNavOrders => 'امرونه خلاص کړئ';

  @override
  String get profileTabNavAddresses => 'خوندي پتې خلاص کړئ';

  @override
  String get profileTabNavFavorites => 'خوښې خلاص کړئ';

  @override
  String get profileTabNavNotifications => 'خبرتیاوې خلاص کړئ';

  @override
  String get profileTabNavSettings => 'تنظیمات خلاص کړئ';

  @override
  String get profileTabNavLogout => 'وتل';

  @override
  String get restaurantDetailsSignInForFavorites =>
      'د خوښو رستورانونو خوندي کولو لپاره ننوځئ.';

  @override
  String get restaurantDetailsFavoritesSnackbarTitle => 'خوښې';

  @override
  String get favoritesRemovedMessage => 'له خوښو څخه لرې شو';

  @override
  String get favoritesRemoveTooltip => 'له خوښو څخه لرې کړئ';

  @override
  String get authEmailOrPhoneHint => 'برېښنالیک یا تلیفون شمېره';

  @override
  String get authEnterEmailOrPhone => 'خپل برېښنالیک یا تلیفون شمېره داخل کړئ';

  @override
  String get authForgotPassword => 'پټنوم مو هیر دی؟';

  @override
  String get authContinueWithGoogle => 'د ګوګل سره دوام';

  @override
  String get authCompleteProfileTitle => 'خپل پروفایل بشپړ کړئ';

  @override
  String get authCompleteProfileSubtitle =>
      'د دوام لپاره خپل نوم او تلیفون شمېره اضافه کړئ.';

  @override
  String get authForgotPasswordSubtitle =>
      'خپل برېښنالیک داخل کړئ او موږ به ۶ عددي کود واستوو.';

  @override
  String get authResetPasswordTitle => 'پټنوم بیا تنظیم';

  @override
  String get authEnterResetCode => 'لېږل شوی ۶ عددي کود داخل کړئ';

  @override
  String get authResendCode => 'کود بیا واستوئ';

  @override
  String authResendCodeInSeconds(int seconds) {
    return 'بیا لیږل تر $seconds ثانیو';
  }

  @override
  String get authPasswordMinEight => 'پټنوم باید لږ تر لږه ۸ توري وي';

  @override
  String get authSendResetCode => 'د بیا تنظیم کود واستوئ';

  @override
  String get authSixDigitCodeHint => '۰۰۰۰۰۰';

  @override
  String get authSetNewPassword => 'نوی پټنوم وټاکئ';

  @override
  String get authPasswordResetSuccess =>
      'پټنوم تازه شو. د نوي پټنوم سره ننوځئ.';

  @override
  String get authResetCodeSent => 'د بیا تنظیم کود ولیږل شو';

  @override
  String get authYourLocation => 'ستاسو موقعیت';

  @override
  String get authRegisterLocationHint =>
      'GPS وکاروئ یا خپل د سپارنې پته لاسي ولیکئ.';

  @override
  String get authAddressHint => 'کوڅه، سیمه، ښار';

  @override
  String get authLocationRequired => 'د سپارنې پته ولیکئ (لږ تر لږه ۵ توري).';

  @override
  String get authEnterSixDigitCode => '۶ عددي کود داخل کړئ.';

  @override
  String get authInvalidSixDigitCode => 'د اعتبار وړ ۶ عددي کود داخل کړئ.';

  @override
  String get couldNotDetectLocation => 'موقعیت ونه موندل شو. پته لاسي ولیکئ.';

  @override
  String get authOrDivider => 'یا';

  @override
  String get authPleaseEnterPassword => 'مهرباني وکړئ پټنوم داخل کړئ';

  @override
  String get authRegisterSubtitle => 'د لقمه حساب جوړ کړئ او سفارش پیل کړئ.';

  @override
  String get authPhoneFieldHint => '07X XXX XXXX';

  @override
  String get authHaveAccountSignIn => 'ننوتل';

  @override
  String get authLoginStepPhoneHint => 'د دوام لپاره خپل تلیفون شمېره ولیکئ.';

  @override
  String get authLoginStepPasswordHint => 'د ننوتلو لپاره خپل پټنوم ولیکئ.';

  @override
  String get authRegisterStepNameHint =>
      'خپل نوم ولیکئ ترڅو رستورانتونه تاسو وپیژني.';

  @override
  String get authRegisterStepPhoneHint =>
      'دا شمېره به د سپارنې خبرتیاوو لپاره وکاروو.';

  @override
  String get authRegisterStepPasswordHint =>
      'لږ تر لږه ۸ توري لرونکی پټنوم غوره کړئ.';

  @override
  String get authRegisterStepConfirmHint => 'خپل پټنوم بیا ولیکئ.';

  @override
  String get authForgotPasswordAdminSubtitle =>
      'خپل نوم او تلیفون شمېره ولیکئ. اډمین به تاسو ته موقتي پټنوم وټاکي.';

  @override
  String get authRequestPasswordReset => 'د پټنوم بیا تنظیم غوښتنه';

  @override
  String get authPasswordResetRequestSentTitle => 'غوښتنه ولېږل شوه';

  @override
  String get authPasswordResetRequestSentBody =>
      'ستاسو غوښتنه اډمین ته لاړه. کله چې موقتي پټنوم وټاکل شي، پرې ننوځئ او خپل پټنوم بدل کړئ.';

  @override
  String get authAdminDefaultPasswordTitle => 'موقتي پټنوم وټاکل شو';

  @override
  String get authAdminDefaultPasswordBody =>
      'ستاسو پټنوم د اډمین لخوا ټاکل شوی اصلي/موقتي پټنوم دی. مهرباني وکړئ همدا اوس یې بدل کړئ.';

  @override
  String get authThisIsYourNewPasswordTitle => 'دا ستاسو نوی پټنوم دی';

  @override
  String get authThisIsYourNewPasswordBody =>
      'اډمین دا موقتي پټنوم تاسو ته ټاکلی. پرې ننوځئ او بیا یې په خپل پټنوم بدل کړئ.';

  @override
  String get authUseThisPassword => 'دا پټنوم وکاروئ';

  @override
  String get authTemporaryPassword => 'موقتي پټنوم';

  @override
  String get authNewPassword => 'نوی پټنوم';

  @override
  String get authPasswordUpdatedTitle => 'پټنوم تازه شو';

  @override
  String get authPasswordUpdatedBody =>
      'نوی پټنوم تنظیم شو. اوس کولی شئ سفارش وکړئ.';

  @override
  String get authInvalidCredentials =>
      'برېښنالیک/تلیفون یا پټنوم غلط دی. بیا هڅه وکړئ.';

  @override
  String get authCheckPasswordAgain => 'خپل پټنوم بیا وګورئ.';

  @override
  String get authEmailAlreadyRegistered => 'دا برېښنالیک مخکې ثبت دی. ننوځئ.';

  @override
  String get authPhoneAlreadyRegistered =>
      'دا تلیفون شمېره مخکې ثبت ده. ننوځئ.';

  @override
  String get authValidationFixFields => 'مهرباني وکړئ روښانه شوې برخې سمې کړئ.';

  @override
  String get authTooManyAttempts =>
      'ډېرې هڅې شوې. لږ صبر وکړئ او بیا هڅه وکړئ.';

  @override
  String get authGoogleCancelled => 'د ګوګل ننوتل لغو شو.';

  @override
  String get authGoogleFailed => 'د ګوګل سره ننوتل ونشول. بیا هڅه وکړئ.';

  @override
  String get authGoogleNotConfigured =>
      'د ګوګل ننوتل لا نه دی تنظیم شوی. په Firebase کې SHA-1 او Web Client ID اضافه کړئ.';

  @override
  String get authGoogleNoIdToken =>
      'ګوګل ID token و نه کړ. Web OAuth Client ID او SHA-1 په Firebase کې اضافه کړئ.';

  @override
  String get authSomethingWentWrong => 'ستونزه وشوه. بیا هڅه وکړئ.';

  @override
  String get authNoInternet => 'انټرنیټ نشته. شبکه وګورئ.';

  @override
  String get authServerSlow => 'سرور ځواب ورو ورکوي. بیا هڅه وکړئ.';

  @override
  String get authServerUnavailable =>
      'سرور اوس نه دی چمتو. لږ وروسته بیا هڅه وکړئ.';
}
