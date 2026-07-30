// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'لقمه';

  @override
  String get foodDelivery => 'تحویل غذا';

  @override
  String get deliveryTo => 'تحویل به';

  @override
  String get searchHint => 'غذای خوشمزه جستجو کنید...';

  @override
  String get categories => 'دسته‌ها';

  @override
  String get viewAll => 'مشاهده همه';

  @override
  String get restaurants => 'رستوران‌ها';

  @override
  String get clear => 'پاک کردن';

  @override
  String get topRestaurants => 'بهترین رستوران‌ها';

  @override
  String get seeAll => 'مشاهده همه';

  @override
  String get freeDelivery => 'تحویل رایگان';

  @override
  String get featured => 'ویژه';

  @override
  String get all => 'همه';

  @override
  String get retry => 'تلاش مجدد';

  @override
  String get freeDeliveryLabel => 'تحویل رایگان';

  @override
  String deliveryFeeLabel(String amount) {
    return 'هزینه تحویل $amount';
  }

  @override
  String minLabel(String minutes) {
    return '$minutes دقیقه';
  }

  @override
  String minRangeLabel(String low, String high) {
    return '$low–$high دقیقه';
  }

  @override
  String get restaurantOpenBadge => 'باز';

  @override
  String get restaurantClosedBadge => 'بسته';

  @override
  String get orderNow => 'همین حالا سفارش';

  @override
  String get loadingEllipsis => '…';

  @override
  String get ordersFilterTitle => 'نمایش سفارش‌ها';

  @override
  String get ordersFilterAll => 'همه سفارش‌ها';

  @override
  String get ordersFilterActiveOnly => 'فقط فعال';

  @override
  String get ordersFilterCompleted => 'تکمیل‌شده';

  @override
  String get ordersFilterCancelled => 'لغوشده';

  @override
  String get ordersFilterTooltip => 'فیلتر سفارش‌ها';

  @override
  String get ordersSectionActive => 'سفارش‌های فعال';

  @override
  String get ordersSectionCompleted => 'سفارش‌های تکمیل‌شده';

  @override
  String get ordersSectionCancelled => 'لغوشده';

  @override
  String orderPlacedAt(String when) {
    return 'ثبت $when';
  }

  @override
  String get orderRelativeJustNow => 'همین الان';

  @override
  String orderRelativeMinutesAgo(String count) {
    return '$count دقیقه پیش';
  }

  @override
  String orderRelativeHoursAgo(String count) {
    return '$count ساعت پیش';
  }

  @override
  String orderRelativeDaysAgo(String count) {
    return '$count روز پیش';
  }

  @override
  String get orderStatusActiveGeneric => 'فعال';

  @override
  String get orderCallRider => 'تماس با پیک';

  @override
  String get orderMapLegendRestaurant => 'رست.';

  @override
  String get orderMapLegendYou => 'شما';

  @override
  String get ordersReviewBannerOne => '۱ سفارش نیاز به نظر شما دارد';

  @override
  String ordersReviewBannerMany(String count) {
    return '$count سفارش نیاز به نظر شما دارد';
  }

  @override
  String qtyWithCount(String label, String count) {
    return '$label: $count';
  }

  @override
  String get navOffers => 'پیشنهادها';

  @override
  String get navFavs => 'علاقه‌مندی‌ها';

  @override
  String get home => 'خانه';

  @override
  String get orders => 'سفارش‌ها';

  @override
  String get profile => 'پروفایل';

  @override
  String get cart => 'سبد خرید';

  @override
  String get cartBadgeMax => '۹۹+';

  @override
  String get cartFabTooltip => 'سبد خرید';

  @override
  String get signIn => 'ورود';

  @override
  String get signUp => 'ثبت‌نام';

  @override
  String get createAccount => 'ایجاد حساب';

  @override
  String get email => 'ایمیل';

  @override
  String get password => 'رمز عبور';

  @override
  String get name => 'نام';

  @override
  String get phone => 'تلفن';

  @override
  String get profileTitle => 'پروفایل';

  @override
  String get addresses => 'آدرس‌ها';

  @override
  String get favorites => 'مورد علاقه';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get settings => 'تنظیمات';

  @override
  String get settingsHeroSubtitle => 'ظاهر، زبان و اطلاعات حقوقی.';

  @override
  String get settingsNavDisplay => 'نمایش و ترجیحات';

  @override
  String get settingsNavLanguage => 'زبان';

  @override
  String get settingsNavAbout => 'درباره و قوانین';

  @override
  String get logout => 'خروج';

  @override
  String get myOrders => 'سفارش‌های من';

  @override
  String get browseRestaurants => 'مرور رستوران‌ها';

  @override
  String get cartEmpty => 'سبد خرید خالی است';

  @override
  String get goBack => 'بازگشت';

  @override
  String get subtotal => 'جمع جزء';

  @override
  String get delivery => 'تحویل';

  @override
  String get total => 'مجموع';

  @override
  String get qty => 'تعداد';

  @override
  String get viewCartCheckout => 'مشاهده سبد و پرداخت';

  @override
  String get checkout => 'پرداخت';

  @override
  String get deliveryAddress => 'آدرس تحویل';

  @override
  String get selectOrAddAddress => 'انتخاب یا افزودن آدرس';

  @override
  String get deliveryLocationPromptTitle => 'آدرس تحویل خود را اضافه کنید';

  @override
  String get deliveryLocationPromptSubtitle =>
      'شهر و ناحیه خود را انتخاب کنید تا رستوران‌های نزدیک را ببینید و سفارش به در خانه‌تان برسد.';

  @override
  String get deliveryLocationPromptAction => 'افزودن آدرس';

  @override
  String get paymentMethod => 'روش پرداخت';

  @override
  String get cashOnDelivery => 'پرداخت در محل';

  @override
  String get card => 'کارت';

  @override
  String get orderSummary => 'خلاصه سفارش';

  @override
  String get orderPlacedSnackbar => 'سفارش شما با موفقیت ثبت شد.';

  @override
  String itemAddedToCart(String item) {
    return '$item به سبد اضافه شد';
  }

  @override
  String cartDifferentRestaurantMessage(String restaurant) {
    return 'سبد خرید شما از $restaurant آیتم دارد. لطفاً ابتدا آن سفارش را تکمیل کنید یا سبد را خالی کنید، سپس از رستوران دیگر سفارش دهید.';
  }

  @override
  String get darkMode => 'حالت تاریک';

  @override
  String get useDarkTheme => 'استفاده از تم تاریک';

  @override
  String get notificationsSetting => 'اعلان‌ها';

  @override
  String get pushAndInApp => 'پوش و درون برنامه';

  @override
  String get language => 'زبان';

  @override
  String get appLanguage => 'زبان برنامه';

  @override
  String get languageSelectionTitle => 'زبان خود را انتخاب کنید';

  @override
  String get languageSelectionSubtitle =>
      'زبانی را که می‌خواهید در برنامه استفاده کنید انتخاب نمایید.';

  @override
  String get privacy => 'حریم خصوصی';

  @override
  String get privacyPolicy => 'سیاست حریم خصوصی';

  @override
  String get privacyPolicyHeroSubtitle =>
      'نحوه جمع‌آوری، استفاده و حفاظت از اطلاعات شما در پلتفرم ما.';

  @override
  String get terms => 'شرایط';

  @override
  String get termsOfService => 'شرایط خدمات';

  @override
  String get termsHeroSubtitle =>
      'قوانین استفاده از افغان فود، سفارش‌ها، تحویل و حساب شما.';

  @override
  String get deleteAccountTitle => 'حذف حساب';

  @override
  String get deleteAccountSettingsSubtitle => 'درخواست حذف دائمی حساب';

  @override
  String get deleteAccountIntro =>
      'درخواست شما توسط تیم ما بررسی می‌شود. در صورت تأیید، پروفایل، آدرس‌ها، علاقه‌مندی‌ها و دسترسی ورود شما حذف می‌شود. سابقه سفارش‌ها ممکن است برای الزامات قانونی نگهداری شود.';

  @override
  String get deleteAccountWebPolicyLink => 'مشاهده سیاست حذف حساب آنلاین';

  @override
  String get deleteAccountReasonLabel => 'دلیل (اختیاری)';

  @override
  String get deleteAccountReasonHint =>
      'بگویید چرا می‌خواهید حساب خود را حذف کنید';

  @override
  String get deleteAccountSubmit => 'درخواست حذف';

  @override
  String get deleteAccountConfirmTitle => 'حساب خود را حذف می‌کنید؟';

  @override
  String get deleteAccountConfirmBody =>
      'درخواست شما برای تأیید به تیم ما ارسال می‌شود. پس از تأیید، این عمل قابل بازگشت نیست.';

  @override
  String get deleteAccountSubmitted =>
      'درخواست حذف ارسال شد. پس از بررسی به شما اطلاع داده می‌شود.';

  @override
  String get deleteAccountCancelled => 'درخواست حذف لغو شد.';

  @override
  String get deleteAccountCancelRequest => 'لغو درخواست';

  @override
  String get deleteAccountCurrentStatus => 'وضعیت فعلی درخواست';

  @override
  String get deleteAccountStatusPending => 'در انتظار تأیید مدیر';

  @override
  String get deleteAccountStatusApproved => 'تأیید شد — حساب شما حذف شده است';

  @override
  String get deleteAccountStatusRejected => 'رد شد';

  @override
  String get deleteAccountStatusCancelled => 'لغو شد';

  @override
  String get deleteAccountWhatHappens => 'چه چیزهایی حذف می‌شود';

  @override
  String get deleteAccountMayBeKept => 'ممکن است نگهداری شود';

  @override
  String get deleteAccountDangerZone => 'منطقه خطر';

  @override
  String get deleteAccountRemovedProfile =>
      'پروفایل، تلفن و آدرس‌های ذخیره‌شده';

  @override
  String get deleteAccountRemovedFavorites => 'علاقه‌مندی‌ها و تنظیمات اعلان';

  @override
  String get deleteAccountRemovedAccess => 'دسترسی ورود به اپ لقمه';

  @override
  String get deleteAccountKeptOrders => 'سابقه سفارش‌ها (الزامات قانونی)';

  @override
  String get deleteAccountKeptPayments => 'سوابق پرداخت در صورت الزام قانونی';

  @override
  String get deleteAccountRedirectingToLogin =>
      'حساب حذف شد. در حال انتقال به صفحه ورود…';

  @override
  String get deleteAccountSessionEnded =>
      'حساب شما حذف شده است. لطفاً دوباره با شماره تلفن وارد شوید.';

  @override
  String get signInRequired => 'ورود لازم است';

  @override
  String get support => 'پشتیبانی';

  @override
  String get supportTickets => 'تیکت‌های پشتیبانی';

  @override
  String get createTicketHelp => 'برای کمک تیکت ایجاد کنید';

  @override
  String get newTicket => 'تیکت جدید';

  @override
  String get supportTrackManage =>
      'تیکت‌های پشتیبانی خود را مدیریت و پیگیری کنید';

  @override
  String get supportNoTicketsTitle => 'تیکتی یافت نشد';

  @override
  String get supportNoTicketsSubtitle => 'برای کمک تیکت ایجاد کنید';

  @override
  String get ticketFormTitle => 'ارسال درخواست پشتیبانی';

  @override
  String get ticketFormSubtitle =>
      'مشکل خود را توضیح دهید تا در اسرع وقت با شما تماس بگیریم.';

  @override
  String get ticketSubjectLabel => 'موضوع *';

  @override
  String get ticketSubjectHint => 'توضیح کوتاه درباره مشکل شما';

  @override
  String get ticketCategoryLabel => 'دسته‌بندی *';

  @override
  String get ticketPriorityLabel => 'اولویت *';

  @override
  String get ticketRelatedOrderLabel => 'سفارش مرتبط (اختیاری)';

  @override
  String get ticketRelatedOrderNone => 'مربوط به سفارش خاصی نیست';

  @override
  String get ticketMessageLabel => 'پیام *';

  @override
  String get ticketMessageHint => 'لطفاً مشکل خود را با جزئیات توضیح دهید...';

  @override
  String get ticketMessageMinCharsHint => 'حداقل ۲۰ کاراکتر';

  @override
  String get ticketCancel => 'انصراف';

  @override
  String get ticketSubmit => 'ارسال تیکت';

  @override
  String get ticketSubmitted =>
      'تیکت شما ثبت شد. به زودی با شما تماس می‌گیریم.';

  @override
  String get ticketMessageTooShort => 'پیام باید حداقل ۲۰ کاراکتر باشد';

  @override
  String ticketSubmitFailed(String error) {
    return 'ناموفق: $error';
  }

  @override
  String get noSavedAddresses => 'آدرس ذخیره‌ای ندارید';

  @override
  String get addAddressHint => 'برای پرداخت سریع‌تر آدرس اضافه کنید';

  @override
  String get addAddress => 'افزودن آدرس';

  @override
  String get noFavoritesYet => 'هنوز مورد علاقه‌ای ندارید';

  @override
  String get favoritesHint =>
      'رستوران‌های مورد علاقه شما اینجا نمایش داده می‌شوند';

  @override
  String get noNotifications => 'اعلانی ندارید';

  @override
  String get newNotificationReceived => 'اعلان جدید دریافت کردید';

  @override
  String get gotIt => 'متوجه شدم';

  @override
  String get fcmChannelName => 'سفارش‌ها و هشدارها';

  @override
  String get fcmChannelDescription => 'اعلان‌های تحویل و حساب کاربری';

  @override
  String get notificationDefaultTitle => 'لقمه';

  @override
  String get notificationFallbackTitle => 'اعلان';

  @override
  String get pleaseSignInToViewNotifications => 'برای دیدن اعلان‌ها وارد شوید.';

  @override
  String get notificationOrderConfirmedTitle => 'سفارش تأیید شد';

  @override
  String get notificationOrderPreparingTitle =>
      'غذای شما در حال آماده‌سازی است';

  @override
  String get notificationOrderReadyTitle => 'سفارش آماده تحویل است';

  @override
  String get notificationOrderPickedUpTitle => 'راننده سفارش شما را برداشت';

  @override
  String get notificationOrderOnTheWayTitle => 'سفارش شما در راه است';

  @override
  String get notificationOrderDeliveredTitle => 'سفارش تحویل شد';

  @override
  String get notificationOrderCancelledTitle => 'سفارش لغو شد';

  @override
  String get notificationOrderUpdateTitle => 'به‌روزرسانی سفارش';

  @override
  String notificationOrderConfirmedMessage(
    String orderNumber,
    String restaurant,
  ) {
    return 'سفارش شماره $orderNumber از $restaurant تأیید شد و به‌زودی آماده می‌شود.';
  }

  @override
  String notificationOrderPreparingMessage(
    String orderNumber,
    String restaurant,
  ) {
    return 'سفارش شماره $orderNumber اکنون در $restaurant در حال آماده‌سازی است.';
  }

  @override
  String notificationOrderReadyMessage(String orderNumber) {
    return 'سفارش شماره $orderNumber آماده است! به‌زودی راننده آن را برمی‌دارد.';
  }

  @override
  String notificationOrderPickedUpMessage(String orderNumber, String driver) {
    return 'سفارش شماره $orderNumber توسط $driver برداشت شد.';
  }

  @override
  String notificationOrderOnTheWayMessage(String orderNumber, String driver) {
    return 'سفارش شماره $orderNumber در راه است! $driver غذای شما را می‌آورد.';
  }

  @override
  String notificationOrderDeliveredMessage(String orderNumber) {
    return 'سفارش شماره $orderNumber تحویل شد. نوش جان!';
  }

  @override
  String notificationOrderCancelledMessage(String orderNumber) {
    return 'سفارش شماره $orderNumber لغو شد.';
  }

  @override
  String notificationOrderUpdateMessage(String orderNumber, String status) {
    return 'وضعیت سفارش شماره $orderNumber به $status به‌روز شد.';
  }

  @override
  String get allCaughtUp => 'همه را دیدید';

  @override
  String get editProfile => 'ویرایش پروفایل';

  @override
  String get profileUpdatedSnackbar => 'پروفایل به‌روز شد (با API وصل کنید)';

  @override
  String get noOrdersYet => 'هنوز سفارشی ندارید';

  @override
  String get add => 'افزودن';

  @override
  String get viewCart => 'مشاهده سبد';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePashto => 'پښتو';

  @override
  String get languageDari => 'دری';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get signInToContinue => 'برای ادامه سفارش وارد شوید';

  @override
  String get dontHaveAccount => 'حساب ندارید؟ ';

  @override
  String get alreadyHaveAccount => 'قبلاً حساب دارید؟ ';

  @override
  String get fullName => 'نام کامل';

  @override
  String get phoneNumber => 'شماره تلفن';

  @override
  String get confirmPassword => 'تأیید رمز عبور';

  @override
  String get passwordMinLength => 'رمز عبور حداقل ۶ کاراکتر باشد';

  @override
  String get passwordsDoNotMatch => 'رمزها مطابقت ندارند';

  @override
  String get pleaseEnterName => 'لطفاً نام خود را وارد کنید';

  @override
  String get authNameTooShort => 'حداقل ۲ نویسه برای نام وارد کنید.';

  @override
  String get authNameTooLong => 'نام خیلی بلند است (حداکثر ۸۰ نویسه).';

  @override
  String get authNameLooksLikePhoneNumber =>
      'این شبیه شماره تلفن است. نام را در فیلد نام وارد کنید.';

  @override
  String get authNameMustContainLetters =>
      'نامی با حروف وارد کنید (نه فقط عدد یا نماد).';

  @override
  String get pleaseEnterEmail => 'لطفاً ایمیل خود را وارد کنید';

  @override
  String get signInToViewProfile => 'برای مشاهده پروفایل وارد شوید';

  @override
  String get save => 'ذخیره';

  @override
  String get proceedToCheckout => 'ادامه به پرداخت';

  @override
  String get cartEmptyHint => 'برای شروع از رستوران آیتم اضافه کنید';

  @override
  String get cannotReachServer => 'اتصال به سرور برقرار نشد';

  @override
  String get orderHistoryHint =>
      'تاریخچه سفارش‌های شما اینجا نمایش داده می‌شود';

  @override
  String get placeOrder => 'ثبت سفارش';

  @override
  String get pullToRefreshOrRetry =>
      'برای به‌روزرسانی یا تلاش مجدد به پایین بکشید';

  @override
  String get dashboard => 'داشبورد';

  @override
  String get customerDashboardSubtitle => 'وضعیت حساب شما در امروز.';

  @override
  String get customerDashboardTotalOrders => 'مجموع سفارش‌ها';

  @override
  String get customerDashboardActiveOrders => 'سفارش‌های فعال';

  @override
  String get customerDashboardTotalSpent => 'مجموع هزینه‌ها';

  @override
  String get customerDashboardOpenTickets => 'تیکت‌های باز';

  @override
  String get customerDashboardOrderFood => 'سفارش غذا';

  @override
  String customerDashboardOrderMeta(String placed, String items) {
    return '$placed · $items';
  }

  @override
  String get orderStatusRefunded => 'بازپرداخت شده';

  @override
  String get discountCode => 'کد تخفیف';

  @override
  String get supportTicket => 'تیکت پشتیبانی';

  @override
  String get search => 'جستجو';

  @override
  String get foods => 'غذاها';

  @override
  String get searchAllHint => 'جستجوی رستوران و غذا...';

  @override
  String get noResults => 'نتیجه‌ای یافت نشد';

  @override
  String get tryDifferentKeywords => 'کلمات دیگری را امتحان کنید';

  @override
  String get allRestaurants => 'همه رستوران‌ها';

  @override
  String get specialDeals => 'پیشنهادهای ویژه';

  @override
  String get orderSummaryCaps => 'خلاصه سفارش';

  @override
  String get sizeLabel => 'سایز';

  @override
  String get promoCodeCopied => 'کد تخفیف کپی شد';

  @override
  String freeDeliveryAboveDeal(String amount) {
    return 'ارسال رایگان برای سفارش بالای $amount';
  }

  @override
  String deliveryFeeDeal(String amount) {
    return 'هزینه ارسال: $amount';
  }

  @override
  String get welcomeToLoqma => 'به لقمه خوش آمدید';

  @override
  String get signInWithPhoneWhatsAppOtp =>
      'با شماره تلفن وارد شوید. کد یک‌بارمصرف از طریق پیام ارسال می‌شود.';

  @override
  String get sendOtp => 'ارسال کد تأیید';

  @override
  String get continueAction => 'ادامه';

  @override
  String get sendRegistrationOtp => 'ارسال کد ثبت‌نام';

  @override
  String get pleaseEnterPhoneNumber => 'لطفاً شماره تلفن خود را وارد کنید.';

  @override
  String get invalidAfghanPhone =>
      'شماره موبایل افغانی معتبر وارد کنید (۰۷ یا +۹۳۷، سپس ۰–۴ یا ۶–۹، مثلاً ۰۷۲ ۱۲۳ ۴۵۶۷).';

  @override
  String get testOtpTitle => 'کد آزمایشی';

  @override
  String testOtpUseCode(String code) {
    return 'از کد $code استفاده کنید';
  }

  @override
  String get verifyOtpTitle => 'تأیید کد';

  @override
  String get otpEnterCodeWhatsApp =>
      'کد ۳ رقمی ارسال‌شده به پیام را وارد کنید.';

  @override
  String get otpTestModeDescription =>
      'حالت آزمایشی فعال است. می‌توانید از کد زیر استفاده کنید.';

  @override
  String otpTestModeBanner(String code) {
    return 'حالت آزمایشی: کد $code';
  }

  @override
  String get otpCodeLabel => 'کد تأیید';

  @override
  String get otpCodeHint => '123456';

  @override
  String get verifyAndContinue => 'تأیید و ادامه';

  @override
  String get resendOtp => 'ارسال مجدد کد';

  @override
  String get otpEnterSixDigits => 'کد ۳ رقمی را وارد کنید.';

  @override
  String get otpIncompleteCode => 'هر ۳ رقم کد را وارد کنید.';

  @override
  String get otpInvalidCode => 'یک کد ۳ رقمی معتبر (فقط عدد) وارد کنید.';

  @override
  String get otpSentAgain => 'کد دوباره ارسال شد';

  @override
  String otpSentAgainTest(String code) {
    return 'کد دوباره ارسال شد. کد آزمایشی: $code';
  }

  @override
  String get authWhatsYourName => 'نام شما چیست؟';

  @override
  String get authEnterPhoneNumber => 'شماره تلفن را وارد کنید';

  @override
  String get authContinue => 'ادامه';

  @override
  String get authSendCode => 'ارسال کد';

  @override
  String get authPhoneVerifyHint => 'برای تأیید هویت، کد ۳ رقمی ارسال می‌شود.';

  @override
  String get authVerification => 'تأیید';

  @override
  String get authEnterCodeSentTo => 'کد ارسال‌شده به';

  @override
  String get authVerifyAccount => 'تأیید حساب';

  @override
  String get authResendVerificationCodeUpper => 'ارسال مجدد کد تأیید';

  @override
  String get nameHintExample => 'احمد کریمی';

  @override
  String get updateAvailableTitle => 'به‌روزرسانی موجود است';

  @override
  String get updateAvailableMessageDefault => 'نسخه جدید برنامه در دسترس است.';

  @override
  String get later => 'بعداً';

  @override
  String get updateNow => 'به‌روزرسانی';

  @override
  String get updateInstallPermissionMessage =>
      'برای ادامه، نصب برنامه از این منبع یا «نصب برنامه‌های ناشناس» را مجاز کنید.';

  @override
  String get updateCouldNotOpenInstaller => 'باز کردن نصب‌کننده ممکن نشد.';

  @override
  String get updateDownloadFailed => 'دانلود ناموفق بود.';

  @override
  String get backToOrderDetails => 'بازگشت به جزئیات سفارش';

  @override
  String get couldNotLoadTracking => 'بارگذاری رهگیری ممکن نشد.';

  @override
  String get restaurantDefaultName => 'رستوران';

  @override
  String get yourLocation => 'موقعیت شما';

  @override
  String get mapMarkerRestaurant => 'رستوران';

  @override
  String get mapMarkerDelivery => 'تحویل';

  @override
  String get mapMarkerDriver => 'پیک';

  @override
  String orderTrackDistanceKm(String distance) {
    return '$distance کیلومتر';
  }

  @override
  String orderTrackEtaApprox(String minutes) {
    return '~$minutes دقیقه';
  }

  @override
  String orderTrackEtaScheduled(String time) {
    return '$time';
  }

  @override
  String get orderTrackCenterMap => 'نمایش مسیر';

  @override
  String get orderTrackZoomIn => 'بزرگ‌نمایی';

  @override
  String get orderTrackZoomOut => 'کوچک‌نمایی';

  @override
  String get orderTrackDirections => 'مسیریابی';

  @override
  String get orderTrackDirectionsCouldNotOpen => 'نقشه باز نشد.';

  @override
  String orderNumberLabel(String orderId) {
    return 'سفارش #$orderId';
  }

  @override
  String get estimatedDeliveryTime => 'زمان تقریبی تحویل';

  @override
  String get routeFromLabel => 'از';

  @override
  String get routeToLabel => 'به';

  @override
  String get callDriver => 'تماس با پیک';

  @override
  String get vehicleDefault => 'وسیله نقلیه';

  @override
  String get lookingForDriver => 'در حال یافتن پیک…';

  @override
  String get deliveryAddressSection => 'آدرس تحویل';

  @override
  String get yourDriver => 'پیک شما';

  @override
  String get trackDriverLive => 'زنده';

  @override
  String get trackStatusPending => 'سفارش ثبت شد';

  @override
  String get trackStatusConfirmed => 'تأیید شد';

  @override
  String get trackStatusPreparing => 'در حال آماده‌سازی';

  @override
  String get trackStatusReady => 'آماده';

  @override
  String get trackStatusPickedUp => 'تحویل گرفته شد';

  @override
  String get trackStatusOnTheWay => 'در مسیر';

  @override
  String get trackStatusDelivered => 'تحویل داده شد';

  @override
  String get orderStatusCancelled => 'لغو شده';

  @override
  String get menuSectionTitle => 'منو';

  @override
  String get customerReviewsSectionTitle => 'نظرات مشتریان';

  @override
  String get noCustomerReviewsYet => 'هنوز نظری ثبت نشده است.';

  @override
  String get reviewsCouldNotLoad =>
      'بارگذاری نظرها ناموفق بود. دوباره این صفحه را باز کنید.';

  @override
  String get similarRestaurantsSectionTitle => 'رستوران‌های مشابه';

  @override
  String get availableOffersSectionTitle => 'پیشنهادهای موجود';

  @override
  String get loadingRestaurant => 'در حال بارگذاری رستوران…';

  @override
  String get searchMenuItemsHint => 'جستجوی اقلام منو…';

  @override
  String copiedCodeMessage(String code) {
    return '$code کپی شد';
  }

  @override
  String get defaultLocationPlaceholder => 'مرکز شهر';

  @override
  String get defaultRestaurantCategoryTagline => 'فست‌فود • پیتزا';

  @override
  String get restaurantsInThisCategory => 'رستوران‌های این دسته';

  @override
  String get discoverOrderBestSubtitle => 'کشف و سفارش از بهترین‌ها';

  @override
  String get superAdminPayments => 'پرداخت‌های سوپر ادمین';

  @override
  String get viewFullPaymentDetails => 'مشاهده جزئیات کامل پرداخت';

  @override
  String get completeRawResponsePayload => 'پاسخ خام کامل';

  @override
  String get unknownEntity => 'نامشخص';

  @override
  String get labelRestaurantId => 'شناسه رستوران';

  @override
  String get driverProfileAndSettings => 'پروفایل و تنظیمات';

  @override
  String get profileUpdatedSuccess => 'پروفایل به‌روز شد';

  @override
  String get saveChanges => 'ذخیره تغییرات';

  @override
  String orderUpdatedToStatus(String orderNumber, String status) {
    return 'سفارش $orderNumber به $status به‌روز شد';
  }

  @override
  String orderUpdatedShort(String orderNumber) {
    return 'سفارش $orderNumber به‌روز شد';
  }

  @override
  String get restaurantDashboard => 'داشبورد رستوران';

  @override
  String get recentOrders => 'سفارش‌های اخیر';

  @override
  String get noRecentOrdersYet => 'هنوز سفارش اخیری نیست.';

  @override
  String get leaveReview => 'ثبت نظر';

  @override
  String get viewDetails => 'مشاهده جزئیات';

  @override
  String get leaveAReview => 'ثبت نظر';

  @override
  String get browseToReorderFromRestaurant =>
      'برای سفارش مجدد از این رستوران، رستوران‌ها را مرور کنید';

  @override
  String get reorder => 'سفارش مجدد';

  @override
  String get cancelOrderAction => 'لغو سفارش';

  @override
  String get active => 'فعال';

  @override
  String get available => 'موجود';

  @override
  String get specialOfferDealsTab => 'پیشنهاد ویژه (زبانه تخفیف‌ها)';

  @override
  String get specialOfferDealsSubtitle =>
      'نیاز به قیمت تخفیف‌خورده کمتر از قیمت عادی دارد';

  @override
  String get listUnderDeals => 'نمایش در تخفیف‌ها';

  @override
  String get listUnderDealsSubtitle =>
      'رستوران باید فعال باشد؛ تاریخ‌های تخفیف در صورت تنظیم اعمال می‌شود';

  @override
  String get enterDiscountedPricePositive =>
      'قیمت تخفیف‌خورده بزرگ‌تر از صفر وارد کنید.';

  @override
  String specialOfferForItem(String itemName) {
    return 'پیشنهاد ویژه: $itemName';
  }

  @override
  String get menuManagement => 'مدیریت منو';

  @override
  String get noMenuCategoriesYet => 'هنوز دسته منویی نیست';

  @override
  String get createFirstCategoryHint =>
      'با ایجاد اولین دسته، منوی خود را مرتب کنید.';

  @override
  String get createFirstCategory => 'ایجاد اولین دسته';

  @override
  String itemsCountInCategory(String count) {
    return '$count قلم';
  }

  @override
  String get noItemsInCategory => 'هنوز قلمی در این دسته نیست.';

  @override
  String get restaurantSettingsUpdated => 'تنظیمات رستوران به‌روز شد';

  @override
  String get restaurantSettingsTitle => 'تنظیمات رستوران';

  @override
  String get acceptCashOnDelivery => 'پذیرش پرداخت در محل';

  @override
  String get acceptOnlinePayment => 'پذیرش پرداخت آنلاین';

  @override
  String get saveSettings => 'ذخیره تنظیمات';

  @override
  String get restaurantOrdersTitle => 'سفارش‌های رستوران';

  @override
  String get noOrdersForFilter => 'با این فیلتر سفارشی یافت نشد.';

  @override
  String get orderActionConfirm => 'تأیید';

  @override
  String get orderActionStartPreparing => 'شروع آماده‌سازی';

  @override
  String get orderActionMarkReady => 'علامت آماده';

  @override
  String driverWithName(String name) {
    return 'پیک: $name';
  }

  @override
  String get myEarningsTitle => 'درآمدهای من';

  @override
  String get payoutRequested => 'درخواست تسویه ثبت شد';

  @override
  String get requestPayout => 'درخواست تسویه';

  @override
  String get offersDealsTitle => 'پیشنهادها و تخفیف‌ها';

  @override
  String get offersDealsEmptyHint =>
      'رستوران‌ها می‌توانند روی اقلام منو تخفیف بگذارند؛ اینجا نمایش داده می‌شود.';

  @override
  String get closeTicketTitle => 'بستن تیکت؟';

  @override
  String get closeTicketMessage =>
      'در صورت نیاز می‌توانید بعداً دوباره باز کنید.';

  @override
  String get closeAction => 'بستن';

  @override
  String get ticketClosedSuccess => 'تیکت بسته شد.';

  @override
  String get ticketReopenedSuccess => 'تیکت دوباره باز شد.';

  @override
  String get ticketScreenTitle => 'تیکت';

  @override
  String get sendReply => 'ارسال پاسخ';

  @override
  String get reopenIfPersists => 'در صورت ادامه مشکل دوباره باز کنید';

  @override
  String failedToSendMessage(String error) {
    return 'ارسال ناموفق: $error';
  }

  @override
  String get deleteAddressTitle => 'حذف آدرس؟';

  @override
  String deleteAddressMessage(String label) {
    return '«$label» حذف شود؟ این کار برگشت‌ناپذیر است.';
  }

  @override
  String get deleteAction => 'حذف';

  @override
  String get addressRemovedSuccess => 'آدرس حذف شد';

  @override
  String get editAction => 'ویرایش';

  @override
  String get removeAllNotificationsConfirm =>
      'همه اعلان‌ها از این فهرست دستگاه حذف شوند؟';

  @override
  String get markAllRead => 'علامت‌گذاری همه به‌عنوان خوانده‌شده';

  @override
  String get orderHistoryTitle => 'تاریخچه سفارش‌ها';

  @override
  String get pleaseSelectCity => 'لطفاً یک شهر انتخاب کنید';

  @override
  String get citiesStillLoading =>
      'شهرها هنوز بارگذاری می‌شوند. لحظاتی بعد دوباره تلاش کنید.';

  @override
  String get turnOnLocationServices =>
      'برای این گزینه سرویس موقعیت را روشن کنید.';

  @override
  String get locationPermissionRequired =>
      'برای تشخیص آدرس، مجوز موقعیت لازم است.';

  @override
  String get couldNotResolveAddress => 'از موقعیت شما آدرسی یافت نشد.';

  @override
  String get cityNotDetectedChoose =>
      'شهر به‌صورت خودکار تشخیص داده نشد — لطفاً از پایین انتخاب کنید.';

  @override
  String get locationAppliedReviewSave =>
      'موقعیت اعمال شد. فیلدها را بررسی و ذخیره را بزنید.';

  @override
  String couldNotGetLocation(String error) {
    return 'دریافت موقعیت ناموفق: $error';
  }

  @override
  String get setAsDefaultAddress => 'تنظیم به‌عنوان آدرس پیش‌فرض';

  @override
  String get openRestaurantNotAvailable =>
      'باز کردن رستوران برای این قلم ممکن نیست';

  @override
  String get hesabPayTitle => 'حساب‌پی';

  @override
  String get paymentNotCompleted => 'پرداخت تکمیل نشد.';

  @override
  String get paymentSuccessfulConfirmed => 'پرداخت موفق. سفارش تأیید شد.';

  @override
  String get paymentFailedOrCancelled => 'پرداخت ناموفق یا لغو شد.';

  @override
  String get paymentProcessingCheckOrders =>
      'پرداخت در حال پردازش است. به‌زودی «سفارش‌های من» را ببینید.';

  @override
  String get payOnlineSecurely => 'پرداخت امن آنلاین';

  @override
  String get acceptOrder => 'پذیرش سفارش';

  @override
  String get navEarnings => 'درآمد';

  @override
  String get navRestaurantMenu => 'منو';

  @override
  String get orderCancelledRefundHint =>
      'سفارش لغو شد. در صورت امکان بازپرداخت انجام می‌شود.';

  @override
  String failedToCancelOrder(String error) {
    return 'لغو ناموفق: $error';
  }

  @override
  String get cancelOrderTitle => 'لغو سفارش';

  @override
  String get keepOrder => 'نگه‌داشتن سفارش';

  @override
  String get cancelOrderConfirmTitle => 'مطمئنید می‌خواهید سفارش را لغو کنید؟';

  @override
  String get cancelOrderConfirmBody =>
      'این عمل قابل بازگشت نیست. اگر پرداخت کرده‌اید، در صورت امکان بازپرداخت انجام می‌شود.';

  @override
  String get cancelReasonSectionTitle => 'دلیل را بنویسید';

  @override
  String get cancelAdditionalDetailsLabel => 'جزئیات بیشتر (اختیاری)';

  @override
  String get cancelReasonChangedMind => 'نظرم عوض شد';

  @override
  String get cancelReasonWrongOrder => 'سفارش اشتباه ثبت شد';

  @override
  String get cancelReasonFoundElsewhere => 'جای دیگری غذا گرفتم';

  @override
  String get cancelReasonDeliveryLong => 'زمان تحویل طولانی بود';

  @override
  String get cancelReasonPriceIssue => 'مشکل قیمت یا پرداخت';

  @override
  String get cancelReasonOther => 'سایر';

  @override
  String get cancelReasonHint => 'با جزئیات بیشتر به ما کمک کنید…';

  @override
  String get pleaseRateRestaurantAndFood =>
      'لطفاً به رستوران و غذا (۱ تا ۵ ستاره) امتیاز دهید.';

  @override
  String get orderReviewScreenSubtitle => 'تجربه‌تان از این سفارش چطور بود؟';

  @override
  String get orderReviewRateRestaurantTitle => 'امتیاز به رستوران';

  @override
  String get orderReviewRateFoodTitle => 'امتیاز به غذا';

  @override
  String get orderReviewRateDeliveryTitle => 'امتیاز به تحویل';

  @override
  String get orderReviewAddPhotosSectionTitle => 'افزودن عکس (اختیاری)';

  @override
  String get thankYouReviewSubmitted => 'متشکریم! نظر شما ثبت شد.';

  @override
  String failedSubmitReview(String error) {
    return 'ثبت نظر ناموفق: $error';
  }

  @override
  String get addPhotos => 'افزودن عکس';

  @override
  String get submitReview => 'ارسال نظر';

  @override
  String get reviewDeliveryHint => 'تجربه خود از تحویل را بنویسید…';

  @override
  String get reviewRestaurantHint => 'تجربه خود از غذا و رستوران را بنویسید…';

  @override
  String get addressLabelHint => 'مثلاً خانه، محل کار';

  @override
  String get addressAreaHint => 'مثلاً کارت‌چهار';

  @override
  String get addressStreetHint => 'نام و شماره خیابان';

  @override
  String get addressNotesHint => 'مثلاً زنگ در، تماس هنگام رسیدن';

  @override
  String get ticketReplyHint => 'پاسخ خود را اینجا بنویسید…';

  @override
  String get dateHintExampleStart => 'مثلاً 2026-03-28 00:00:00';

  @override
  String get dateHintExampleEnd => 'مثلاً 2026-04-01 23:59:59';

  @override
  String get optionalStartLabel => 'شروع (اختیاری)';

  @override
  String get optionalEndLabel => 'پایان (اختیاری)';

  @override
  String get isoDateHint => 'ISO یا Y-m-d H:i';

  @override
  String get restaurantNameField => 'نام رستوران';

  @override
  String get restaurantNameDariField => 'نام رستوران (دری)';

  @override
  String get verifyOtpAppBar => 'تأیید کد';

  @override
  String orderStatusTimeSeparator(String status, String time) {
    return '$status • $time';
  }

  @override
  String get ticketCategoryRestaurant => 'رستوران';

  @override
  String get restaurantSampleOfferTitle => '۲۰٪ تخفیف برگر';

  @override
  String get restaurantSampleOfferSubtitle =>
      '۲۰٪ تخفیف روی همه برگرها. حداقل سفارش ۱۵ دلار.';

  @override
  String get restaurantDeliveryOfferTitle => 'پیشنهاد تحویل';

  @override
  String get restaurantOfferFreeDeliveryNext =>
      'تحویل رایگان برای سفارش بعدی — بدون حداقل مبلغ.';

  @override
  String restaurantOfferFreeDeliveryOverAmount(String amount) {
    return 'تحویل رایگان برای سفارش‌های بالاتر از $amount.';
  }

  @override
  String get restaurantOfferLimitedDeliverySavings =>
      'تخفیف محدود روی هزینهٔ تحویل.';

  @override
  String get backToOrders => 'بازگشت به سفارش‌ها';

  @override
  String get ticketCategoryOrderIssue => 'مشکل سفارش';

  @override
  String get ticketCategoryPayment => 'پرداخت';

  @override
  String get ticketCategoryDelivery => 'تحویل';

  @override
  String get ticketCategoryAccount => 'حساب کاربری';

  @override
  String get ticketCategoryOther => 'سایر';

  @override
  String get ticketStatusOpen => 'باز';

  @override
  String get ticketStatusInProgress => 'در حال بررسی';

  @override
  String get ticketStatusWaiting => 'در انتظار پاسخ';

  @override
  String get ticketStatusResolved => 'حل‌شده';

  @override
  String get ticketStatusClosed => 'بسته';

  @override
  String get ticketPriorityLow => 'کم';

  @override
  String get ticketPriorityMedium => 'متوسط';

  @override
  String get ticketPriorityHigh => 'بالا';

  @override
  String get ticketPriorityUrgent => 'فوری';

  @override
  String get fieldRequired => 'الزامی';

  @override
  String ticketRelatedOrderOption(String orderId, String restaurant) {
    return '#$orderId — $restaurant';
  }

  @override
  String get tapViewDetailsForItems => 'برای اقلام، «مشاهده جزئیات» را بزنید';

  @override
  String get orderDetailLoadError => 'جزئیات سفارش بارگذاری نشد.';

  @override
  String get orderItemsTitle => 'اقلام سفارش';

  @override
  String get noItemsInOrder => 'قلمی نیست';

  @override
  String get orderTimelineTitle => 'زمان‌بندی سفارش';

  @override
  String get deliveryDetailsTitle => 'جزئیات تحویل';

  @override
  String get paymentSummaryDetailTitle => 'خلاصه پرداخت';

  @override
  String get deliveryFeeShort => 'هزینه تحویل';

  @override
  String get paymentStatusPendingGeneric => 'در انتظار';

  @override
  String get paymentStatusPaid => 'پرداخت شده';

  @override
  String get paymentStatusFailed => 'ناموفق';

  @override
  String get paymentMethodOnline => 'پرداخت آنلاین';

  @override
  String orderItemQtyTimesPrice(String qty, String price) {
    return '$qty × $price';
  }

  @override
  String get emptyValueDash => '—';

  @override
  String get trackOrder => 'پیگیری سفارش';

  @override
  String get restaurantSectionTitle => 'رستوران';

  @override
  String get detailRowAddress => 'آدرس';

  @override
  String get paymentStatusDetail => 'وضعیت پرداخت';

  @override
  String ticketReplyCount(String count) {
    return '$count پاسخ';
  }

  @override
  String get checkoutLoadingAddresses => 'در حال بارگذاری آدرس‌ها…';

  @override
  String get offersLoadFailed => 'بارگذاری پیشنهادها ناموفق بود.';

  @override
  String get offersNoDealsNow => 'فعلاً تخفیف فعالی نیست';

  @override
  String get about => 'درباره';

  @override
  String get aboutDocumentTitle => 'درباره ما';

  @override
  String get aboutHero => 'شادی را وعده غذا به خانه شما می‌آوریم';

  @override
  String get aboutHeroSubtitle => 'رستوران‌های محبوب شما، سریع و تازه.';

  @override
  String get aboutStoryTitle => 'داستان ما';

  @override
  String get aboutStoryDesc =>
      'لقمه مشتریان را به رستوران‌های محلی مورد اعتماد وصل می‌کند. این پلتفرم را ساختیم تا سفارش غذا ساده، شفاف و لذت‌بخش باشد—در خانه، محل کار یا هر جا که هستید.';

  @override
  String get aboutMissionTitle => 'ماموریت ما';

  @override
  String get aboutMissionDesc =>
      'توانمندسازی جامعه با دسترسی همه به غذای باکیفیت از طریق فناوری و تحویل مطمئن.';

  @override
  String get aboutVisionTitle => 'چشم‌انداز ما';

  @override
  String get aboutVisionDesc =>
      'تبدیل شدن به محبوب‌ترین تجربه سفارش غذا در منطقه—با سرعت، انصاف و حمایت از رستوران‌هایی که با ما هستند.';

  @override
  String get aboutValuesTitle => 'ارزش‌های اصلی ما';

  @override
  String get aboutValue1Title => 'مشتری در اولویت';

  @override
  String get aboutValue1Desc =>
      'هر ویژگی از نیاز مشتریان و شریکان ما آغاز می‌شود.';

  @override
  String get aboutValue2Title => 'کیفیت';

  @override
  String get aboutValue2Desc =>
      'غذای عالی و خدمات قابل اعتماد را پشتیبانی می‌کنیم.';

  @override
  String get aboutValue3Title => 'شراکت';

  @override
  String get aboutValue3Desc => 'رستوران‌ها شریک مایند؛ با هم رشد می‌کنیم.';

  @override
  String get aboutValue4Title => 'نوآوری';

  @override
  String get aboutValue4Desc =>
      'مسیرها، پرداخت‌ها و تجربه درون‌برنامه را مدام بهبود می‌دهیم.';

  @override
  String get aboutWhyTitle => 'چرا ما را انتخاب کنید';

  @override
  String get aboutWhy1 => 'تحویل سریع و قابل پیگیری لحظه‌ای.';

  @override
  String get aboutWhy2 => 'انتخابی از رستوران‌های محبوب و محلی.';

  @override
  String get aboutWhy3 => 'قیمت‌گذاری شفاف و پرداخت امن.';

  @override
  String get aboutWhy4 => 'پشتیبانی هنگام نیاز.';

  @override
  String get aboutWhy5 => 'ساخته‌شده برای جامعه‌ای که در آن خدمت می‌کنیم.';

  @override
  String get aboutWhy6 => 'به‌روزرسانی‌های مداوم و ویژگی‌های جدید.';

  @override
  String get aboutStatsTitle => 'لقمه در یک نگاه';

  @override
  String get aboutStat1Num => '۵۰۰+';

  @override
  String get aboutStat1Label => 'شریک رستوران';

  @override
  String get aboutStat2Num => '۵۰هزار+';

  @override
  String get aboutStat2Label => 'سفارش تحویل‌شده';

  @override
  String get aboutStat3Num => '۲۴/۷';

  @override
  String get aboutStat3Label => 'پشتیبانی مشتری';

  @override
  String get aboutStat4Num => '۱۰۰٪';

  @override
  String get aboutStat4Label => 'تعهد به شما';

  @override
  String get aboutCoverageTitle => 'پوشش سرویس';

  @override
  String get aboutCoverageDesc =>
      'در حال گسترش در شهرها و محله‌ها هستیم. آدرس خود را در اپ وارد کنید تا رستوران‌های نزدیک را ببینید.';

  @override
  String get aboutCtaTitle => 'سؤالی دارید؟';

  @override
  String get aboutCtaBtn => 'تماس با ما';

  @override
  String get contactUs => 'تماس با ما';

  @override
  String get contactDocumentTitle => 'تماس با ما';

  @override
  String get contactHero => 'در خدمت شما هستیم';

  @override
  String get contactSubtitle =>
      'از طریق تلفن، ایمیل یا فرم زیر با ما در ارتباط باشید.';

  @override
  String get contactNavReachTooltip => 'تلفن، ایمیل و آدرس دفاتر';

  @override
  String get contactNavFormTooltip => 'فرم پیام';

  @override
  String get contactNavFaqTooltip => 'پرسش‌های متداول';

  @override
  String get contactNavOverviewTooltip => 'اطلاعات تماس و فرم';

  @override
  String get contactCallTitle => 'تماس تلفنی';

  @override
  String get contactCallOffice => 'دفتر';

  @override
  String get contactCallMobile => 'همراه';

  @override
  String get contactEmailTitle => 'ایمیل';

  @override
  String get contactEmailGeneral => 'پرسش‌های عمومی';

  @override
  String get contactEmailSupport => 'پشتیبانی';

  @override
  String get contactVisitTitle => 'آدرس دفاتر';

  @override
  String get contactVisitMazarLabel => 'مزارشریف';

  @override
  String get contactVisitMazarBody =>
      'چهارراهی مخابرات، زینت پلازا (عزیزی بانک مرکزی)، منزل چهارم، شرکت صلایان، مزارشریف.';

  @override
  String get contactVisitKabulLabel => 'کابل';

  @override
  String get contactVisitKabulBody =>
      'شهرنو، جوار شرکت اتوما، برج ساعت، منزل پنجم، شرکت صلایان، کابل.';

  @override
  String get contactFollowTitle => 'شبکه‌های اجتماعی';

  @override
  String get contactHoursTitle => 'ساعات کاری';

  @override
  String get contactHoursDays => 'دوشنبه تا شنبه';

  @override
  String get contactHoursTime => '۸:۰۰ تا ۲۰:۰۰';

  @override
  String get contactHoursNote => 'در تعطیلات رسمی ممکن است تغییر کند.';

  @override
  String get contactFormTitle => 'پیام بفرستید';

  @override
  String get contactFormName => 'نام کامل';

  @override
  String get contactFormEmail => 'ایمیل';

  @override
  String get contactFormPhone => 'تلفن';

  @override
  String get contactFormSubject => 'موضوع';

  @override
  String get contactFormSubjectHint => 'یک مورد انتخاب کنید';

  @override
  String get contactFormSubjectGeneral => 'پرسش عمومی';

  @override
  String get contactFormSubjectSupport => 'پشتیبانی مشتری';

  @override
  String get contactFormSubjectPartnership => 'رستوران / همکاری';

  @override
  String get contactFormSubjectDriver => 'پرسش راننده';

  @override
  String get contactFormSubjectComplaint => 'شکایت';

  @override
  String get contactFormSubjectFeedback => 'بازخورد';

  @override
  String get contactFormSubjectOther => 'سایر';

  @override
  String get contactFormMessage => 'متن پیام';

  @override
  String get contactFormSubmit => 'ارسال پیام';

  @override
  String get contactFormSuccessSnackbar =>
      'متشکریم! برنامه ایمیل شما با پیام آماده باز می‌شود.';

  @override
  String get contactFormSubjectError => 'لطفاً موضوع را انتخاب کنید.';

  @override
  String get contactFormRequired => 'این فیلد الزامی است.';

  @override
  String get contactFormEmailInvalid => 'ایمیل معتبر وارد کنید.';

  @override
  String get contactEmailSubjectPrefix => 'تماس';

  @override
  String get contactSocialSoon => 'لینک شبکه اجتماعی به‌زودی.';

  @override
  String get contactFaqTitle => 'سوالات متداول';

  @override
  String get contactFaq1Q => 'چگونه سفارش را پیگیری کنم؟';

  @override
  String get contactFaq1A =>
      'در اپ بخش سفارش‌ها را باز کنید و سفارش را برای وضعیت زنده انتخاب کنید.';

  @override
  String get contactFaq2Q => 'چگونه آدرس تحویل را عوض کنم؟';

  @override
  String get contactFaq2A =>
      'قبل از پرداخت آدرس را عوض کنید. پس از سفارش سریع با پشتیبانی تماس بگیرید.';

  @override
  String get contactFaq3Q => 'چه روش‌های پرداختی هست؟';

  @override
  String get contactFaq3A =>
      'گزینه‌ها در تسویه نمایش داده می‌شوند؛ نقد یا آنلاین بسته به منطقه.';

  @override
  String get contactFaq4Q => 'چگونه رستوران همکار شوم؟';

  @override
  String get contactFaq4A =>
      'در فرم «رستوران / همکاری» را انتخاب کنید تا با شما تماس بگیریم.';

  @override
  String get contactFaq5Q => 'چه زمانی پاسخ می‌دهید؟';

  @override
  String get contactFaq5A =>
      'معمولاً ظرف یک روز کاری. برای امر فوری با شماره پشتیبانی تماس بگیرید.';

  @override
  String get totalEarningsLabel => 'کل درآمد';

  @override
  String get pendingPayoutLabel => 'پرداخت معلق';

  @override
  String get totalDeliveriesLabel => 'کل تحویل‌ها';

  @override
  String get ratingStatLabel => 'امتیاز';

  @override
  String get todaysEarningsLabel => 'درآمد امروز';

  @override
  String get thisWeekLabel => 'این هفته';

  @override
  String get driverOfflineTitle => 'شما آفلاین هستید';

  @override
  String get driverActiveDeliveriesTitle => 'تحویل‌های فعال دارید';

  @override
  String get driverNoOrdersReadyTitle => 'سفارشی برای تحویل آماده نیست';

  @override
  String get clearAllTooltip => 'پاک کردن همه';

  @override
  String get reopenAction => 'بازگشایی';

  @override
  String get refreshTooltip => 'تازه‌سازی';

  @override
  String get addressSavedSuccess => 'آدرس ذخیره شد';

  @override
  String get addressUpdatedSuccess => 'آدرس به‌روز شد';

  @override
  String get basicInformation => 'اطلاعات پایه';

  @override
  String get deliveryAndPayment => 'تحویل و پرداخت';

  @override
  String get locationSection => 'موقعیت';

  @override
  String get operatingHours => 'ساعات کاری';

  @override
  String get todayOrdersLabel => 'سفارش‌های امروز';

  @override
  String get todayRevenueLabel => 'درآمد امروز';

  @override
  String get pendingOrdersLabel => 'سفارش‌های معلق';

  @override
  String get tapOpenSupportTicket => 'برای باز کردن تیکت پشتیبانی ضربه بزنید';

  @override
  String get tapViewOrderNotification => 'برای مشاهده سفارش ضربه بزنید';

  @override
  String get noLineItems => 'آیتمی وجود ندارد';

  @override
  String get pleaseWaitProcessing => 'لطفاً صبر کنید…';

  @override
  String get districtHint => 'مثلاً: کارته چهار';

  @override
  String get streetHint => 'نام و شماره خیابان';

  @override
  String get deliveryNotesHint => 'مثلاً: زنگ بزنید، هنگام رسیدن تماس بگیرید';

  @override
  String get statusOnline => 'آنلاین';

  @override
  String get statusOffline => 'آفلاین';

  @override
  String get driverDashboardTitle => 'داشبورد راننده';

  @override
  String get driverVehicleInformation => 'اطلاعات وسیله نقلیه';

  @override
  String get vehicleTypeLabel => 'نوع وسیله (مثلاً موتور، خودرو)';

  @override
  String get vehicleModelLabel => 'مدل وسیله';

  @override
  String get vehicleColorLabel => 'رنگ وسیله';

  @override
  String get licensePlateLabel => 'پلاک';

  @override
  String driverMinimumPayoutMessage(String amount) {
    return 'حداقل مبلغ تسویه $amount است. برای رسیدن به آن به تحویل ادامه دهید!';
  }

  @override
  String get driverReadyForPayoutTitle => 'آماده تسویه!';

  @override
  String driverPayoutAvailableMessage(String amount) {
    return 'مبلغ $amount برای برداشت در دسترس است.';
  }

  @override
  String get driverEarningLabel => 'درآمد';

  @override
  String reviewsCountLabel(String count) {
    return '$count نظر';
  }

  @override
  String get driverActiveDeliveriesSectionTitle => 'تحویل‌های فعال';

  @override
  String get driverEarningPrefix => 'درآمد:';

  @override
  String get driverAvailableOrdersSectionTitle => 'سفارش‌های در دسترس';

  @override
  String get driverOfflineBody => 'برای دریافت درخواست تحویل، آنلاین شوید.';

  @override
  String get driverBusyDeliveriesBody =>
      'برای دریافت سفارش جدید، تحویل‌های فعال را تمام کنید.';

  @override
  String get driverNoOrdersReadyBody =>
      'وقتی رستوران سفارش را آماده کند، اینجا نمایش داده می‌شود.';

  @override
  String get driverUpcomingOrdersTitle => 'سفارش‌های آینده';

  @override
  String get driverUpcomingOrdersHint =>
      'پس از آماده شدن توسط رستوران، برای تحویل در دسترس می‌شوند.';

  @override
  String get recentDeliveriesSectionTitle => 'تحویل‌های اخیر';

  @override
  String get restaurantOpenAcceptingOrders =>
      'رستوران شما در حال پذیرش سفارش است.';

  @override
  String get restaurantCurrentlyClosedNotice =>
      'رستوران شما در حال حاضر بسته است.';

  @override
  String get restaurantPendingApprovalNotice =>
      'درخواست شما در حال بررسی است. تنظیمات را تکمیل کنید و منتظر تأیید بمانید.';

  @override
  String get restaurantApplicationRejectedNotice =>
      'درخواست رستوران رد شد. جزئیات را در تنظیمات به‌روز کنید و در صورت نیاز با پشتیبانی تماس بگیرید.';

  @override
  String get restaurantNewOrdersSectionTitle => 'سفارش‌های جدید';

  @override
  String get restaurantActiveOrdersSectionTitle => 'سفارش‌های فعال';

  @override
  String get restaurantNoPendingOrdersSubtitle => 'فعلاً سفارش معلقی نیست.';

  @override
  String get restaurantNoActiveOrdersSubtitle => 'فعلاً سفارش فعالی نیست.';

  @override
  String get rejectOrderAction => 'رد';

  @override
  String get partnerAccountStatusActive => 'حساب همکار فعال';

  @override
  String get partnerAccountStatusPending => 'در انتظار تأیید';

  @override
  String get partnerAccountStatusRejected => 'رد شده';

  @override
  String get adminHesabPayLoadError => 'بارگذاری پرداخت‌های HesabPay ممکن نشد.';

  @override
  String get adminNoHesabPayPayments => 'هنوز پرداخت حساب‌پی ثبت نشده است.';

  @override
  String hesabPayPaymentOrderHeader(String order) {
    return 'پرداخت HesabPay $order';
  }

  @override
  String get paymentImageLabel => 'تصویر پرداخت';

  @override
  String get summaryAmountLabel => 'مبلغ';

  @override
  String get summaryCustomerLabel => 'مشتری';

  @override
  String get summaryCreatedAtLabel => 'زمان ایجاد';

  @override
  String get summaryTransactionRefLabel => 'مرجع تراکنش';

  @override
  String get ticketReplySectionTitle => 'پاسخ';

  @override
  String get ticketMessagesEmptyHint => 'هنوز پیامی نیست.';

  @override
  String ticketAssignedTo(String name) {
    return 'مسئول: $name';
  }

  @override
  String get ticketClosedStateMessage => 'این تیکت بسته است.';

  @override
  String get hoursOpenLabel => 'باز';

  @override
  String get hoursCloseLabel => 'بسته';

  @override
  String get deliveryFeeFieldLabel => 'هزینه ارسال';

  @override
  String get minimumOrderFieldLabel => 'حداقل سفارش';

  @override
  String get freeDeliveryAboveFieldLabel => 'ارسال رایگان از مبلغ';

  @override
  String get averagePrepTimeFieldLabel => 'میانگین زمان آماده‌سازی';

  @override
  String coordinatesSavedHint(String lat, String lng) {
    return 'مختصات با این آدرس ذخیره شد: $lat، $lng';
  }

  @override
  String get useCurrentLocationAction => 'استفاده از موقعیت فعلی';

  @override
  String get gettingLocationEllipsis => 'در حال دریافت موقعیت…';

  @override
  String get deliveryInstructionsLabel => 'دستورالعمل تحویل';

  @override
  String get addressLabelShort => 'برچسب';

  @override
  String get cityRequiredLabel => 'شهر *';

  @override
  String get requiredFieldIndicator => '*';

  @override
  String get streetAddressRequiredLabel => 'آدرس خیابان *';

  @override
  String get streetAddressHint => 'نام و شماره خیابان';

  @override
  String get buildingFieldLabel => 'ساختمان';

  @override
  String get floorFieldLabel => 'طبقه';

  @override
  String get apartmentFieldLabel => 'واحد';

  @override
  String get areaFieldLabel => 'منطقه';

  @override
  String get editAddressScreenTitle => 'ویرایش آدرس';

  @override
  String get updateAddressButton => 'به‌روزرسانی آدرس';

  @override
  String get saveAddressButton => 'ذخیره آدرس';

  @override
  String get addressChooseCityTitle => 'شهر خود را انتخاب کنید';

  @override
  String get addressChooseCitySubtitle =>
      'در حال حاضر در این شهرها تحویل می‌دهیم.';

  @override
  String get addressChooseDistrictTitle => 'ناحیه خود را انتخاب کنید';

  @override
  String addressChooseDistrictSubtitle(String city) {
    return 'یک ناحیه در $city انتخاب کنید.';
  }

  @override
  String get addressStreetDetailsTitle => 'جزئیات خیابان';

  @override
  String addressStreetDetailsSubtitle(String district, String city) {
    return 'نام خیابان و شماره خانه را در $district، $city وارد کنید.';
  }

  @override
  String get addressStreetNameLabel => 'نام و شماره خیابان';

  @override
  String get addressStreetNameHint => 'مثلاً سرک ۵، کوچه ۱۲';

  @override
  String get addressHouseNumberLabel => 'شماره خانه / دفتر';

  @override
  String get addressHouseNumberHint => 'مثلاً خانه ۲۴ یا دفتر ۳';

  @override
  String get addressStreetRequired => 'لطفاً نام خیابان را وارد کنید.';

  @override
  String get addressHouseNumberRequired =>
      'لطفاً شماره خانه یا دفتر را وارد کنید.';

  @override
  String get addressNoCitiesAvailable => 'فعلاً شهری برای تحویل در دسترس نیست.';

  @override
  String get addressNoDistrictsAvailable => 'برای این شهر ناحیه‌ای یافت نشد.';

  @override
  String get addressProfileNamePhoneRequired =>
      'برای ذخیره آدرس، نام و شماره تلفن پروفایل لازم است.';

  @override
  String get addItemTooltip => 'افزودن آیتم';

  @override
  String get addCategoryTooltip => 'افزودن دسته';

  @override
  String get newCategoryDialogTitle => 'دسته جدید';

  @override
  String get editCategoryDialogTitle => 'ویرایش دسته';

  @override
  String get categoryNameFaLabel => 'نام (دری)';

  @override
  String get newMenuItemTitle => 'آیتم منوی جدید';

  @override
  String get editMenuItemTitle => 'ویرایش آیتم منو';

  @override
  String get foodCategoryDropdownLabel => 'دسته';

  @override
  String get discountedPriceFieldLabel => 'قیمت با تخفیف';

  @override
  String get preparationTimeMinutesLabel => 'زمان آماده‌سازی';

  @override
  String get menuItemHasSizesLabel =>
      'سایزها (کودک، کوچک، متوسط، بزرگ، خانوادگی)';

  @override
  String get menuItemSmallPriceHint =>
      'فقط برای سایزهایی که دارید قیمت بگذارید. خالی بگذارید تا اضافه نشود — کوچک به‌صورت پیش‌فرض انتخاب نمی‌شود.';

  @override
  String get menuItemKidsPriceLabel => 'قیمت کودک (اختیاری)';

  @override
  String get menuItemSmallPriceLabel => 'قیمت کوچک (اختیاری)';

  @override
  String get menuItemMediumPriceLabel => 'قیمت متوسط (اختیاری)';

  @override
  String get menuItemLargePriceLabel => 'قیمت بزرگ (اختیاری)';

  @override
  String get menuItemFamilyPriceLabel => 'قیمت خانوادگی (اختیاری)';

  @override
  String get menuItemSizesAvailable => 'سایزها موجود است';

  @override
  String get offerLabelOptionalField => 'برچسب پیشنهاد (اختیاری)';

  @override
  String get discountStartOptionalField => 'شروع تخفیف (اختیاری)';

  @override
  String get discountEndOptionalField => 'پایان تخفیف (اختیاری)';

  @override
  String get discountedPriceCurrencyHint => 'قیمت با تخفیف (افغانی)';

  @override
  String get labelOptionalField => 'برچسب (اختیاری)';

  @override
  String discountedMustBeBelowRegular(String regular) {
    return 'قیمت با تخفیف باید کمتر از قیمت عادی ($regular) باشد.';
  }

  @override
  String specialOfferDialogTitle(String itemName) {
    return 'پیشنهاد ویژه: $itemName';
  }

  @override
  String get specialOfferTooltip => 'پیشنهاد ویژه';

  @override
  String get descriptionFieldLabel => 'توضیحات';

  @override
  String get defaultLocationStreetFallback => 'موقعیت فعلی';

  @override
  String get coordinateLatitudeLabel => 'عرض جغرافیایی';

  @override
  String get coordinateLongitudeLabel => 'طول جغرافیایی';

  @override
  String get restaurantStatusOpen => 'باز';

  @override
  String get restaurantStatusClosed => 'بسته';

  @override
  String prepTimeRange(String low, String high) {
    return '$low–$high دقیقه';
  }

  @override
  String get prepTimeDefault => '۳۵–۴۵ دقیقه';

  @override
  String cartFabWithCount(int count) {
    return 'سبد خرید، $count قلم';
  }

  @override
  String get mainNavHome => 'زبانه خانه';

  @override
  String get mainNavOffers => 'زبانه پیشنهادها';

  @override
  String get mainNavFavorites => 'زبانه علاقه‌مندی‌ها';

  @override
  String get mainNavOrders => 'زبانه سفارش‌ها';

  @override
  String cartQtyLine(int quantity) {
    return 'تعداد: $quantity';
  }

  @override
  String get tax => 'مالیات';

  @override
  String get discount => 'تخفیف';

  @override
  String cartFromRestaurant(String name) {
    return 'از $name';
  }

  @override
  String get adminSuperPaymentsTitle => 'پرداخت‌های ادمین';

  @override
  String get adminRefresh => 'تازه‌سازی';

  @override
  String get adminCouldNotLoadPayments =>
      'بارگذاری پرداخت‌های حساب‌پی ممکن نشد.';

  @override
  String adminHesabPayPaymentOrder(String order) {
    return 'پرداخت حساب‌پی $order';
  }

  @override
  String get adminRestaurant => 'رستورانت';

  @override
  String get adminCustomer => 'مشتری';

  @override
  String get adminAmount => 'مبلغ';

  @override
  String get adminPaymentStatus => 'وضعیت پرداخت';

  @override
  String get adminViewPaymentDetails => 'جزئیات کامل پرداخت';

  @override
  String get adminOrderId => 'شناسه سفارش';

  @override
  String get adminCreatedAt => 'تاریخ';

  @override
  String get adminPaymentDetails => 'جزئیات پرداخت';

  @override
  String get ordersTabFilterTooltip => 'فیلتر سفارش‌ها';

  @override
  String get ordersTabShowOrders => 'نمایش سفارش‌ها';

  @override
  String get ordersTabFilterAll => 'همه سفارش‌ها';

  @override
  String get ordersTabFilterActive => 'فقط فعال';

  @override
  String get ordersTabFilterCompleted => 'تکمیل‌شده';

  @override
  String get ordersTabFilterCancelled => 'لغو‌شده';

  @override
  String get ordersTabSectionActive => 'سفارش‌های فعال';

  @override
  String get ordersTabSectionCompleted => 'سفارش‌های تکمیل‌شده';

  @override
  String get ordersTabSectionCancelled => 'لغو‌شده';

  @override
  String ordersTabReviewsNeeded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سفارش نیاز به نظر شما دارند',
      one: '۱ سفارش نیاز به نظر شما دارد',
    );
    return '$_temp0';
  }

  @override
  String ordersTabPlacedRelative(String time) {
    return 'ثبت $time';
  }

  @override
  String get ordersTabDefaultDeliveryWindow => '۳۵–۴۵ دقیقه';

  @override
  String get ordersTabMapLegendRestaurant => 'رست.';

  @override
  String get ordersTabMapLegendDestination => 'شما';

  @override
  String get relativeTimeJustNow => 'همین الان';

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count دقیقه پیش';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count ساعت پیش';
  }

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count روز پیش';
  }

  @override
  String relativeTimeWeeksAgo(int count) {
    return '$count هفته پیش';
  }

  @override
  String relativeTimeMonthsAgo(int count) {
    return '$count ماه پیش';
  }

  @override
  String relativeTimeYearsAgo(int count) {
    return '$count سال پیش';
  }

  @override
  String get restaurantMenuEmpty => 'فعلاً آیتمی در منو نیست.';

  @override
  String get restaurantMenuSearchNoResults => 'موردی با جستجوی شما پیدا نشد.';

  @override
  String get restaurantDetailsLoadFailed => 'بارگذاری این رستوران ممکن نشد.';

  @override
  String get reviewAnonymousCustomer => 'مشتری';

  @override
  String get menuItemAddToCart => 'افزودن به سبد';

  @override
  String get menuItemOptionsLabel => 'گزینه‌ها';

  @override
  String get menuItemAddonsLabel => 'افزودنی‌ها';

  @override
  String get menuItemQuantityLabel => 'تعداد';

  @override
  String get profileTabEditHint => 'مشاهده و ویرایش پروفایل';

  @override
  String get profileTabOpenAccount => 'ویرایش پروفایل';

  @override
  String get profileTabNavDashboard => 'باز کردن داشبورد';

  @override
  String get profileTabNavOrders => 'باز کردن سفارش‌ها';

  @override
  String get profileTabNavAddresses => 'باز کردن آدرس‌های ذخیره‌شده';

  @override
  String get profileTabNavFavorites => 'باز کردن علاقه‌مندی‌ها';

  @override
  String get profileTabNavNotifications => 'باز کردن اعلان‌ها';

  @override
  String get profileTabNavSettings => 'باز کردن تنظیمات';

  @override
  String get profileTabNavLogout => 'خروج از حساب';

  @override
  String get restaurantDetailsSignInForFavorites =>
      'برای ذخیره رستوران در علاقه‌مندی‌ها وارد شوید.';

  @override
  String get restaurantDetailsFavoritesSnackbarTitle => 'علاقه‌مندی‌ها';

  @override
  String get favoritesRemovedMessage => 'از علاقه‌مندی‌ها حذف شد';

  @override
  String get favoritesRemoveTooltip => 'حذف از علاقه‌مندی‌ها';

  @override
  String get authEmailOrPhoneHint => 'ایمیل یا شماره تلفن';

  @override
  String get authEnterEmailOrPhone => 'ایمیل یا شماره تلفن خود را وارد کنید';

  @override
  String get authForgotPassword => 'رمز عبور را فراموش کرده‌اید؟';

  @override
  String get authContinueWithGoogle => 'ادامه با گوگل';

  @override
  String get authCompleteProfileTitle => 'تکمیل پروفایل';

  @override
  String get authCompleteProfileSubtitle =>
      'برای ادامه نام و شماره تلفن خود را اضافه کنید.';

  @override
  String get authForgotPasswordSubtitle =>
      'ایمیل خود را وارد کنید تا کد ۶ رقمی بازنشانی را ارسال کنیم.';

  @override
  String get authResetPasswordTitle => 'بازنشانی رمز عبور';

  @override
  String get authEnterResetCode => 'کد ۶ رقمی ارسال‌شده را وارد کنید';

  @override
  String get authResendCode => 'ارسال مجدد کد';

  @override
  String authResendCodeInSeconds(int seconds) {
    return 'ارسال مجدد تا $seconds ثانیه';
  }

  @override
  String get authPasswordMinEight => 'رمز عبور باید حداقل ۸ نویسه باشد';

  @override
  String get authSendResetCode => 'ارسال کد بازنشانی';

  @override
  String get authSixDigitCodeHint => '۰۰۰۰۰۰';

  @override
  String get authSetNewPassword => 'تنظیم رمز جدید';

  @override
  String get authPasswordResetSuccess =>
      'رمز به‌روز شد. با رمز جدید وارد شوید.';

  @override
  String get authResetCodeSent => 'کد بازنشانی ارسال شد';

  @override
  String get authYourLocation => 'موقعیت شما';

  @override
  String get authRegisterLocationHint =>
      'از GPS استفاده کنید یا آدرس تحویل را دستی وارد کنید.';

  @override
  String get authAddressHint => 'خیابان، ناحیه، شهر';

  @override
  String get authLocationRequired => 'آدرس تحویل را وارد کنید (حداقل ۵ نویسه).';

  @override
  String get authEnterSixDigitCode => 'کد ۶ رقمی را وارد کنید.';

  @override
  String get authInvalidSixDigitCode => 'یک کد ۶ رقمی معتبر وارد کنید.';

  @override
  String get couldNotDetectLocation =>
      'موقعیت تشخیص داده نشد. آدرس را دستی وارد کنید.';

  @override
  String get authOrDivider => 'یا';

  @override
  String get authPleaseEnterPassword => 'لطفاً رمز عبور را وارد کنید';

  @override
  String get authRegisterSubtitle => 'حساب لقمه بسازید و سفارش را شروع کنید.';

  @override
  String get authPhoneFieldHint => '07X XXX XXXX';

  @override
  String get authHaveAccountSignIn => 'ورود';

  @override
  String get authLoginStepPhoneHint =>
      'برای ادامه شماره تلفن خود را وارد کنید.';

  @override
  String get authLoginStepPasswordHint =>
      'برای ورود رمز عبور خود را وارد کنید.';

  @override
  String get authRegisterStepNameHint =>
      'نام خود را وارد کنید تا رستوران‌ها شما را بشناسند.';

  @override
  String get authRegisterStepPhoneHint =>
      'از این شماره برای اطلاع‌رسانی تحویل استفاده می‌کنیم.';

  @override
  String get authRegisterStepPasswordHint =>
      'رمزی با حداقل ۸ نویسه انتخاب کنید.';

  @override
  String get authRegisterStepConfirmHint => 'رمز عبور را دوباره وارد کنید.';

  @override
  String get authForgotPasswordAdminSubtitle =>
      'نام و شماره تلفن خود را وارد کنید. ادمین یک رمز موقت برای شما تعیین می‌کند.';

  @override
  String get authRequestPasswordReset => 'درخواست بازیابی رمز';

  @override
  String get authPasswordResetRequestSentTitle => 'درخواست ارسال شد';

  @override
  String get authPasswordResetRequestSentBody =>
      'درخواست شما به پنل ادمین ارسال شد. پس از تعیین رمز موقت، با همان رمز وارد شوید و رمز خود را تغییر دهید.';

  @override
  String get authAdminDefaultPasswordTitle => 'رمز موقت تعیین شد';

  @override
  String get authAdminDefaultPasswordBody =>
      'رمز شما یک رمز پیش‌فرض است که توسط ادمین تعیین شده. لطفاً همین حالا آن را تغییر دهید تا حساب‌تان امن بماند.';

  @override
  String get authThisIsYourNewPasswordTitle => 'این رمز جدید شماست';

  @override
  String get authThisIsYourNewPasswordBody =>
      'ادمین این رمز موقت را برای شما تعیین کرده. با آن وارد شوید و سپس رمز خود را تغییر دهید.';

  @override
  String get authUseThisPassword => 'از این رمز استفاده کن';

  @override
  String get authTemporaryPassword => 'رمز موقت';

  @override
  String get authNewPassword => 'رمز جدید';

  @override
  String get authPasswordUpdatedTitle => 'رمز به‌روز شد';

  @override
  String get authPasswordUpdatedBody =>
      'رمز جدید تنظیم شد. می‌توانید سفارش دهید.';

  @override
  String get authInvalidCredentials =>
      'ایمیل/شماره یا رمز عبور اشتباه است. دوباره تلاش کنید.';

  @override
  String get authCheckPasswordAgain => 'رمز عبور را دوباره بررسی کنید.';

  @override
  String get authEmailAlreadyRegistered =>
      'این ایمیل قبلاً ثبت شده. وارد شوید.';

  @override
  String get authPhoneAlreadyRegistered =>
      'این شماره قبلاً ثبت شده. وارد شوید.';

  @override
  String get authValidationFixFields => 'لطفاً فیلدهای مشخص‌شده را اصلاح کنید.';

  @override
  String get authTooManyAttempts =>
      'تلاش‌های زیاد. کمی صبر کنید و دوباره امتحان کنید.';

  @override
  String get authGoogleCancelled => 'ورود با گوگل لغو شد.';

  @override
  String get authGoogleFailed => 'ورود با گوگل ممکن نشد. دوباره تلاش کنید.';

  @override
  String get authGoogleNotConfigured =>
      'ورود با گوگل هنوز راه‌اندازی نشده. SHA-1 اپ و Web Client ID را در Firebase تنظیم کنید.';

  @override
  String get authGoogleNoIdToken =>
      'گوگل توکن شناسایی نداد. Web OAuth Client ID و اثر انگشت SHA-1 را در Firebase اضافه کنید.';

  @override
  String get authSomethingWentWrong => 'مشکلی پیش آمد. دوباره تلاش کنید.';

  @override
  String get authNoInternet => 'اتصال اینترنت نیست. شبکه را بررسی کنید.';

  @override
  String get authServerSlow => 'پاسخ سرور طول کشید. دوباره تلاش کنید.';

  @override
  String get authServerUnavailable =>
      'سرور موقتاً در دسترس نیست. کمی بعد دوباره تلاش کنید.';
}
