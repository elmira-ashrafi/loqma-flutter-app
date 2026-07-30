# -*- coding: utf-8 -*-
"""Trilingual (en / fa Dari / ps Pashto) tuples for privacy policy JSON: (en, fa, ps).

Edit tuples here, then from the Flutter package root run:
  python tool/generate_privacy_assets.py
to refresh assets/privacy/en.json, fa.json, and ps.json.
"""

# Type alias: each field is (en, fa, ps)
Tri = tuple[str, str, str]
Bullet = tuple[Tri, Tri]  # (title triple, purpose triple)


def t(en: str, fa: str, ps: str) -> Tri:
    return (en, fa, ps)


# --- 1. Introduction ---
INTRO_TITLE = t("1. Introduction", "۱. مقدمه", "۱. پېژنتنه")
INTRO_PARAS: list[Tri] = [
    t(
        'Loqma ("we," "us," "our," or "Company") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our food delivery platform, including our website and mobile application (collectively, the "Service").',
        "لوقما («ما»، «مطابق ما»، «شرکت») به حریم خصوصی شما احترام می‌گذارد و متعهد به حفاظت از داده‌های شخصی شماست. این سیاست حریم خصوصی توضیح می‌دهد که هنگام استفاده از پلتفرم تحویل غذا، از جمله وب‌سایت و اپلیکیشن موبایل ما (به‌طور جمع «خدمات»)، اطلاعات شما را چگونه جمع‌آوری، استفاده، افشا و محافظت می‌کنیم.",
        "لوقما («موږ»، «زموږ»، یا «شرکت») ستاسو محرمیت درناوی او ستاسو شخصي معلوماتو ساتلو ته ژمن دی. دا محرمیت پالیسي ښيي چې ستاسو معلومات موږ څنګه راټولوو، کاروو، خپروو او ساتو کله چې تاسو زموږ د خواړو تحویلي پلیټ فارم، ویب پاڼې او موبایل اپلیکیشن (ټولګې «خدمت») کاروئ.",
    ),
    t(
        "Please read this Privacy Policy carefully. If you do not agree with our policies and practices, please do not use our Service. Your use of the Service indicates your acceptance of this Privacy Policy.",
        "لطفاً این سیاست حریم خصوصی را با دقت بخوانید. اگر با سیاست‌ها و شیوه‌های ما موافق نیستید، از خدمات ما استفاده نکنید. استفاده شما از خدمات به‌منزله پذیرش این سیاست حریم خصوصی است.",
        "مهرباني وکړئ دا محرمیت پالیسي په دقت ولولئ. که تاسو زموږ د سیاستونو او کړنو سره موافق نه یاست، مهرباني وکړئ زموږ خدمت مه کاروئ. د خدمت کارول د دې محرمیت پالیسۍ منلو په معنی دی.",
    ),
]

COLLECT_TITLE = t(
    "2. Information We Collect",
    "۲. معلوماتی که جمع‌آوری می‌کنیم",
    "۲. هغه معلومات چې موږ راټولوو",
)

# Subsections: (accent, title_tri, intro_tri|None, list[Bullet])


def b(en_t: str, fa_t: str, ps_t: str, en_p: str, fa_p: str, ps_p: str) -> Bullet:
    return (t(en_t, fa_t, ps_t), t(en_p, fa_p, ps_p))


SUBSECTIONS: list[tuple[str, Tri, Tri | None, list[Bullet]]] = [
    (
        "blue",
        t("Account Registration Information", "اطلاعات ثبت‌نام حساب کاربری", "د حساب ثبت معلومات"),
        t(
            "When you create an account, we collect:",
            "هنگام ایجاد حساب، موارد زیر را جمع‌آوری می‌کنیم:",
            "کله چې حساب جوړوئ، لاندې معلومات راټولوو:",
        ),
        [
            b(
                "Full Name",
                "نام کامل",
                "بشپړ نوم",
                "PURPOSE: Customer identification and order personalization — used to address you by name and confirm orders are delivered to the correct person.",
                "هدف: شناسایی مشتری و شخصی‌سازی سفارش — برای خطاب با نام شما و اطمینان از تحویل سفارش به فرد درست.",
                "موخه: د پیرودونکي پیژندنه او د امر شخصي کول — ستاسو په نوم خطاب او د امر سم کس ته تحویلول.",
            ),
            b(
                "Email Address",
                "آدرس ایمیل",
                "بریښنالیک",
                "PURPOSE: Account authentication and communication — used for login, password recovery, order confirmations, and important platform notifications.",
                "هدف: احراز هویت و ارتباطات حساب — ورود، بازیابی رمز عبور، تأیید سفارش‌ها و اعلان‌های مهم پلتفرم.",
                "موخه: د حساب تصدیق او اړیکې — ننوتل، پټنوم بیرته ترلاسه کول، د امرونو تایید او مهم خبرتیاوې.",
            ),
            b(
                "Phone Number",
                "شماره تلفن",
                "د تلیفون شمېره",
                "PURPOSE: Order delivery coordination and support — allows drivers to contact you for delivery updates and enables our support team to reach you with order-related information.",
                "هدف: هماهنگی تحویل و پشتیبانی — راننده برای به‌روزرسانی تحویل با شما تماس می‌گیرد و تیم پشتیبانی اطلاعات مرتبط با سفارش را ارائه می‌دهد.",
                "موخه: د تحویل همغږي او ملاتړ — چلوونکی د تحویل په اړه اړیکه نیسي او ملاتړي ټیم د امر معلومات درکوي.",
            ),
            b(
                "Password (One-way encrypted)",
                "رمز عبور (رمزنگاری یک‌طرفه)",
                "پټنوم (یو اړخیز کوډ شوی)",
                "PURPOSE: Account security — securely hashed and stored to authenticate users and prevent unauthorized account access.",
                "هدف: امنیت حساب — به‌صورت امن هش و ذخیره می‌شود تا کاربران احراز هویت شوند و دسترسی غیرمجاز جلوگیری شود.",
                "موخه: د حساب امنیت — په خوندي ډول هش او زیرمه کیږي ترڅو کاروونکي تصدیق شي او غیرمجاز لاسرسی مخه ونیول شي.",
            ),
            b(
                "Profile Picture/Avatar",
                "تصویر پروفایل / آواتار",
                "د پروفایل انځور / آواتار",
                "PURPOSE: Profile personalization and restaurant reviews — helps personalize your profile and is displayed alongside any reviews or feedback you leave.",
                "هدف: شخصی‌سازی پروفایل و نظرات رستوران — پروفایل شما شخصی‌تر می‌شود و کنار نظرات یا بازخوردهای شما نمایش داده می‌شود.",
                "موخه: د پروفایل شخصي کول او د رستورانت نظرونه — ستاسو پروفایل شخصي کیږي او ستاسو نظرونو سره ښودل کیږي.",
            ),
            b(
                "Language Preference",
                "زبان ترجیحی",
                "د ژبې غوره توب",
                "PURPOSE: User experience localization — enables the platform to display content in your preferred language (English, Dari, or Pashto).",
                "هدف: بومی‌سازی تجربه کاربری — محتوا را به زبان ترجیحی شما (انگلیسی، دری یا پشتو) نمایش می‌دهد.",
                "موخه: د کارونکي تجربې ځایی کول — منځپانګه په ستاسو غوره ژبه (انګلیسي، دري یا پښتو) ښيي.",
            ),
        ],
    ),
    (
        "green",
        t("Delivery Address Information", "اطلاعات آدرس تحویل", "د تحویل پته معلومات"),
        t(
            "For each delivery address, we collect:",
            "برای هر آدرس تحویل، موارد زیر را جمع‌آوری می‌کنیم:",
            "د هرې تحویلي پتې لپاره لاندې راټولوو:",
        ),
        [
            b(
                "Recipient Name",
                "نام گیرنده",
                "د اخیستونکي نوم",
                "PURPOSE: Delivery verification — ensures food is delivered to the correct recipient.",
                "هدف: تأیید تحویل — اطمینان از تحویل غذا به گیرنده درست.",
                "موخه: د تحویل تایید — خواړه سم اخیستونکي ته ورکړل شي.",
            ),
            b(
                "Recipient Phone Number",
                "شماره تلفن گیرنده",
                "د اخیستونکي تلیفون",
                "PURPOSE: Driver-customer communication — allows the delivery driver to contact the recipient about delivery arrival time and location.",
                "هدف: ارتباط راننده و مشتری — راننده می‌تواند درباره زمان و محل تحویل با گیرنده تماس بگیرد.",
                "موخه: د چلوونکي او پیرودونکي اړیکه — چلوونکی د رارسېدو وخت او ځای په اړه اړیکه نیسي.",
            ),
            b(
                "Complete Address Details",
                "جزئیات کامل آدرس",
                "د پتې بشپړ جزئیات",
                "PURPOSE: Order delivery — includes city, area, street name, building number, floor, apartment number — critical for accurate food delivery to your location.",
                "هدف: تحویل سفارش — شهر، منطقه، نام کوچه، شماره ساختمان، طبقه، شماره واحد — برای تحویل دقیق غذا ضروری است.",
                "موخه: د امر تحویل — ښار، سیمه، کوڅه، ودانۍ، منزل، اپارتمان — د سم تحویل لپاره اړین دی.",
            ),
            b(
                "Precise GPS Coordinates",
                "مختصات دقیق GPS",
                "د GPS سمې همغږي",
                "PURPOSE: Real-time tracking and navigation — latitude and longitude data used for accurate mapping, real-time order tracking, and driver navigation.",
                "هدف: ردیابی و مسیریابی بلادرنگ — عرض و طول جغرافیایی برای نقشه دقیق، ردیابی سفارش و مسیریابی راننده.",
                "موخه: ریل وخت تعقیب او لارښود — د سم نقشې، امر تعقیب او چلوونکي لارښود لپاره.",
            ),
            b(
                "Delivery Instructions",
                "دستورالعمل تحویل",
                "د تحویل لارښوونې",
                "PURPOSE: Special delivery handling — for gate codes, access instructions, or specific delivery preferences to ensure successful delivery.",
                "هدف: مدیریت ویژه تحویل — کد درب، دستورالعمل دسترسی یا ترجیحات خاص برای تحویل موفق.",
                "موخه: ځانګړې تحویل چلند — د دروازې کوډ، لاسرسي لارښوونې یا غوره توبونه ترڅو تحویل بریالی شي.",
            ),
        ],
    ),
    (
        "orange",
        t("Payment & Transaction Information", "اطلاعات پرداخت و تراکنش", "د تادیې او معاملې معلومات"),
        t(
            "When processing orders, we collect:",
            "هنگام پردازش سفارش‌ها، موارد زیر را جمع‌آوری می‌کنیم:",
            "د امرونو په پروسس کولو کې لاندې راټولوو:",
        ),
        [
            b(
                "Payment Method",
                "روش پرداخت",
                "د تادیې طریقه",
                "PURPOSE: Payment processing — recorded whether you pay (cash, card, or wallet) for order reconciliation and service optimization.",
                "هدف: پردازش پرداخت — نحوه پرداخت (نقد، کارت یا کیف پول) برای تسویه سفارش و بهینه‌سازی خدمات ثبت می‌شود.",
                "موخه: د تادیې پروسس — نغدي، کارت یا بټوه د امر سمون او خدمت ښه کولو لپاره ثبتیږي.",
            ),
            b(
                "Transaction ID",
                "شناسه تراکنش",
                "د معاملې پېژند",
                "PURPOSE: Payment verification and fraud prevention — uniquely identifies each transaction for security and audit purposes.",
                "هدف: تأیید پرداخت و پیشگیری از تقلب — هر تراکنش را به‌صورت یکتا برای امنیت و حسابرسی شناسایی می‌کند.",
                "موخه: د تادیې تایید او درغلي مخنیوی — هر معامله یوازې د امنیت او حساب لپاره.",
            ),
            b(
                "Order Amounts",
                "مبالغ سفارش",
                "د امر مقدارونه",
                "PURPOSE: Business operations — subtotal, delivery fees, taxes, discounts, and final total recorded for accounting, analytics, and personalized recommendations.",
                "هدف: عملیات تجاری — جمع جزء، هزینه ارسال، مالیات، تخفیف و جمع نهایی برای حسابداری، تحلیل و پیشنهادهای شخصی‌سازی‌شده.",
                "موخه: سوداګریز عملیات — فرعي، تحویلي فیس، مالیات، تخفیف او ټولیز د حساب، تحلیل او شخصي وړاندیزونو لپاره.",
            ),
            b(
                "Tip Amount",
                "مبلغ انعام",
                "د انعام مقدار",
                "PURPOSE: Driver compensation — optional tip information collected and transferred to drivers as appreciation for service.",
                "هدف: جبران راننده — انعام اختیاری جمع‌آوری و به رانندگان به‌عنوان قدردانی از خدمت منتقل می‌شود.",
                "موخه: د چلوونکي معلومول — اختیاري بخښنه راټولېږي او چلوونکو ته د خدمت مننې په توګه لیږدول کیږي.",
            ),
        ],
    ),
    (
        "purple",
        t("Location & Device Information", "اطلاعات مکان و دستگاه", "د ځای او وسیلې معلومات"),
        t(
            "We collect location data when enabled:",
            "وقتی فعال باشد، داده‌های مکانی را جمع‌آوری می‌کنیم:",
            "کله چې فعال وي، د ځای معلومات راټولوو:",
        ),
        [
            b(
                "Real-time GPS Location (For Drivers)",
                "موقعیت GPS بلادرنگ (برای رانندگان)",
                "د GPS ریل وخت ځای (د چلوونکو لپاره)",
                "PURPOSE: Order tracking and delivery optimization — continuously collected from drivers to enable real-time delivery tracking for customers and route optimization.",
                "هدف: ردیابی سفارش و بهینه‌سازی تحویل — به‌صورت مداوم از رانندگان برای ردیابی بلادرنگ و بهینه‌سازی مسیر جمع‌آوری می‌شود.",
                "موخه: د امر تعقیب او تحویل ښه کول — له چلوونکو څخه دوامداره د پیرودونکو لپاره ریل وخت تعقیب او لار ښه کولو لپاره.",
            ),
            b(
                "Last Login IP Address",
                "آدرس IP آخرین ورود",
                "د وروستي ننوتنې IP پته",
                "PURPOSE: Security monitoring — recorded for fraud detection and account security analysis.",
                "هدف: پایش امنیتی — برای تشخیص تقلب و تحلیل امنیت حساب ثبت می‌شود.",
                "موخه: امنیتي څارنه — د درغلي کشف او د حساب امنیت تحلیل لپاره.",
            ),
            b(
                "FCM Push Notification Token",
                "توکن اعلان فش FCM",
                "د FCM فش خبرتیا ټوکن",
                "PURPOSE: Real-time notifications — enables us to send order updates, promotions, and important notifications to your device.",
                "هدف: اعلان‌های بلادرنگ — به‌روزرسانی سفارش، پیشنهادها و اعلان‌های مهم را به دستگاه شما می‌فرستد.",
                "موخه: ریل وخت خبرتیاوې — د امر تازه معلومات، وړاندیزونه او مهم خبرتیاوې وسیلې ته لیږي.",
            ),
        ],
    ),
    (
        "red",
        t("Order & Behavioral Data", "داده‌های سفارش و رفتار", "د امر او چلند معلومات"),
        t(
            "We store complete order information:",
            "اطلاعات کامل سفارش را ذخیره می‌کنیم:",
            "د امر بشپړ معلومات موږ ساتو:",
        ),
        [
            b(
                "Order History",
                "تاریخچه سفارش‌ها",
                "د امرونو تاریخ",
                "PURPOSE: Service improvement and personalization — detailed record of what you order helps us improve recommendations and understand your preferences.",
                "هدف: بهبود خدمات و شخصی‌سازی — ثبت جزئیات سفارش‌ها به بهبود پیشنهادها و درک ترجیحات شما کمک می‌کند.",
                "موخه: د خدمت ښه کول او شخصي کول — ستاسو د امرونو جزئیات زموږ وړاندیزونو او غوره توبونو درک ته مرسته کوي.",
            ),
            b(
                "Restaurant Preferences",
                "ترجیحات رستوران",
                "د رستورانت غوره توبونه",
                "PURPOSE: Personalized experience — tracks your favorite and frequently ordered restaurants to show relevant recommendations.",
                "هدف: تجربه شخصی‌سازی‌شده — رستوران‌های مورد علاقه و پرتکرار شما را دنبال می‌کند تا پیشنهادهای مرتبط نشان دهد.",
                "موخه: شخصي تجربه — ستاسو غوره او ډېر امر شوي رستورانت تعقیبوي ترڅو اړوند وړاندیزونه ښيي.",
            ),
            b(
                "Search History",
                "تاریخچه جستجو",
                "د لټون تاریخ",
                "PURPOSE: Platform analytics — helps us understand what foods and restaurants are popular and improve search functionality.",
                "هدف: تحلیل پلتفرم — به درک محبوبیت غذاها و رستوران‌ها و بهبود جستجو کمک می‌کند.",
                "موخه: د پلیټ فارم تحلیل — مشهور خواړه او رستورانت درک او لټون ښه کول.",
            ),
            b(
                "Special Instructions",
                "دستورالعمل‌های ویژه",
                "ځانګړې لارښوونې",
                "PURPOSE: Accurate order fulfillment — dietary restrictions, allergies, or special preparation requests are shared with restaurants to ensure safe delivery.",
                "هدف: اجرای دقیق سفارش — محدودیت‌های غذایی، حساسیت یا درخواست‌های ویژه با رستوران‌ها برای تحویل ایمن به اشتراک گذاشته می‌شود.",
                "موخه: د امر سم پلي کول — غذایي بندیز، حساسیت یا ځانګړې غوښتنې رستورانتونو سره د خوندي تحویل لپاره شريکېږي.",
            ),
        ],
    ),
    (
        "yellow",
        t("Reviews & Feedback", "نظرات و بازخورد", "نظرونه او بیرته راګرځونه"),
        t(
            "When you submit reviews, we collect:",
            "هنگام ارسال نظرات، موارد زیر را جمع‌آوری می‌کنیم:",
            "کله چې نظرونه وسپارئ، لاندې راټولوو:",
        ),
        [
            b(
                "Service Ratings",
                "امتیازات خدمات",
                "د خدمت درجې",
                "PURPOSE: Service quality assessment — ratings for restaurant, food quality, and delivery service help us identify areas for improvement.",
                "هدف: ارزیابی کیفیت خدمات — امتیاز رستوران، کیفیت غذا و تحویل به شناسایی زمینه‌های بهبود کمک می‌کند.",
                "موخه: د خدمت کیفیت ارزونه — رستورانت، خواړه او تحویل درجې د ښه کولو ساحو پیژندلو ته.",
            ),
            b(
                "Written Reviews & Comments",
                "نظرات و توضیحات نوشتاری",
                "لیکل شوي نظرونه او تبصرې",
                "PURPOSE: Community feedback — detailed reviews help other customers make informed decisions and help restaurants improve service.",
                "هدف: بازخورد جامعه — نظرات تفصیلی به تصمیم‌گیری مشتریان دیگر و بهبود خدمات رستوران‌ها کمک می‌کند.",
                "موخه: ټولنې بیرته راګرځونه — جزئي نظرونه نورو پیرودونکو او رستورانتونو ته مرسته کوي.",
            ),
            b(
                "Review Images/Photos",
                "تصاویر نظرات",
                "د نظر انځورونه",
                "PURPOSE: Visual feedback — photos of food and packaging helps other customers and restaurants assess quality.",
                "هدف: بازخورد تصویری — تصاویر غذا و بسته‌بندی به ارزیابی کیفیت توسط دیگران کمک می‌کند.",
                "موخه: لیدونکې بیرته راګرځونه — د خواړو او بسته‌بندۍ انځورونه کیفیت ارزونې ته.",
            ),
        ],
    ),
    (
        "cyan",
        t("Driver Specific Information (Drivers Only)", "اطلاعات ویژه رانندگان (فقط رانندگان)", "د چلوونکو ځانګړې معلومات (یوازې چلوونکي)"),
        t(
            "Delivery drivers provide additional information for verification:",
            "رانندگان تحویل برای تأیید هویت اطلاعات تکمیلی ارائه می‌دهند:",
            "تحویل چلوونکي د تصدیق لپاره اضافي معلومات ورکوي:",
        ),
        [
            b(
                "National ID & Biometric Data",
                "تذکره ملی و داده‌های بیومتریک",
                "ملي تذکره او بایومتریک معلومات",
                "PURPOSE: Driver verification and fraud prevention — Afghan government ID verified through document capture (front & back photos) to ensure driver legitimacy.",
                "هدف: تأیید راننده و پیشگیری از تقلب — تذکره دولتی افغانستان از طریق تصویر جلو و پشت سند تأیید می‌شود.",
                "موخه: د چلوونکي تصدیق او درغلي مخنیوی — د افغانستان دولتي تذکره د مخ او شا انځورونو له لارې تاییدیږي.",
            ),
            b(
                "Date of Birth",
                "تاریخ تولد",
                "د زیږون نیټه",
                "PURPOSE: Compliance verification — verify driver is of legal working age and cross-reference with national ID.",
                "هدف: تأیید انطباق — سن قانونی کار و تطابق با تذکره ملی.",
                "موخه: د مطابقت تایید — قانوني کار عمر او د ملي تذکرې سره تطبیق.",
            ),
            b(
                "Vehicle Information",
                "اطلاعات وسیله نقلیه",
                "د موټر معلومات",
                "PURPOSE: Route planning and safety — vehicle type, license plate, model, color, and photos recorded for identification and customer safety.",
                "هدف: برنامه‌ریزی مسیر و ایمنی — نوع وسیله، پلاک، مدل، رنگ و تصاویر برای شناسایی و ایمنی مشتری ثبت می‌شود.",
                "موخه: لار پلان او خوندیتوب — د موټر ډول، پلیټ، ماډل، رنګ او انځورونه د پیژندنې او پیرودونکي خوندیتوب لپاره.",
            ),
            b(
                "Driver License Details",
                "جزئیات گواهینامه رانندگی",
                "د چلولو جواز جزئیات",
                "PURPOSE: Legal compliance — license number, expiry date, and photos verified to ensure authorized operation.",
                "هدف: انطباق قانونی — شماره، تاریخ انقضا و تصاویر گواهینامه برای اطمینان از مجاز بودن فعالیت.",
                "موخه: قانوني مطابقت — شمېره، پای نیټه او انځورونه د قانوني فعالیت لپاره.",
            ),
            b(
                "Bank/Mobile Wallet Information",
                "اطلاعات بانک / کیف پول موبایل",
                "د بانک / موبایل بټوه معلومات",
                "PURPOSE: Driver payment processing — bank account details for salary transfers and mobile wallet for instant payouts.",
                "هدف: پرداخت راننده — جزئیات حساب بانکی برای انتقال حقوق و کیف پول موبایل برای پرداخت فوری.",
                "موخه: د چلوونکي تادیه — د معاش لیږد لپاره بانکي حساب او فوري تادیې لپاره موبایل بټوه.",
            ),
            b(
                "Continuous GPS Tracking",
                "ردیابی مداوم GPS",
                "دوامداره GPS تعقیب",
                "PURPOSE: Order dispatch and customer safety — real-time location updates tracked while driver is online and delivering orders.",
                "هدف: اعزام سفارش و ایمنی مشتری — به‌روزرسانی مکان بلادرنگ هنگام آنلاین بودن و تحویل سفارش‌ها.",
                "موخه: د امر لیږد او پیرودونکي خوندیتوب — آنلاین او د امرونو په تحویل کولو کې ریل وخت ځای.",
            ),
        ],
    ),
    (
        "indigo",
        t("Referral & Loyalty Program Data", "داده‌های معرفی و برنامه وفاداری", "د معرفي او وفاداري پروګرام معلومات"),
        None,
        [
            b(
                "Referral Code & Network",
                "کد معرفی و شبکه",
                "د معرفي کوډ او شبکه",
                "PURPOSE: Referral rewards — tracks referral relationships to credit bonuses and rewards for both referrer and new customer.",
                "هدف: پاداش معرفی — روابط معرفی را دنبال می‌کند تا پاداش به معرف و مشتری جدید تعلق گیرد.",
                "موخه: د معرفي انعامونه — د معرفي اړیکې تعقیبوي ترڅو معرف او نوي پیرودونکي دواړو ته انعام ورکړل شي.",
            ),
            b(
                "Loyalty Points & Wallet Balance",
                "امتیاز وفاداری و موجودی کیف پول",
                "د وفاداري نمرې او د بټوې بیلانس",
                "PURPOSE: Rewards program — tracks accumulated points, credits, and wallet balance for discounts and incentives.",
                "هدف: برنامه پاداش — امتیاز، اعتبار و موجودی کیف پول را برای تخفیف و مشوق‌ها دنبال می‌کند.",
                "موخه: انعام پروګرام — راټل شوي نمرې، کریډیټ او بټوه بیلانس د تخفیفونو او هڅونو لپاره تعقیبوي.",
            ),
        ],
    ),
]

USE_TITLE = t(
    "3. How We Use Your Information",
    "۳. چگونه از اطلاعات شما استفاده می‌کنیم",
    "۳. موږ ستاسو معلومات څنګه کاروو",
)
USE_CASES: list[tuple[Tri, Tri]] = [
    (
        t("Service Delivery", "ارائه خدمات", "خدمت وړاندې کول"),
        t(
            "Process orders, manage payments, and coordinate deliveries.",
            "پردازش سفارش‌ها، مدیریت پرداخت‌ها و هماهنگی تحویل‌ها.",
            "امرونه پروسس کول، تادیې مدیریت او تحویلونه همغږي کول.",
        ),
    ),
    (
        t("Communication", "ارتباطات", "اړیکې"),
        t(
            "Send order updates, promotional offers, and customer support.",
            "ارسال به‌روزرسانی سفارش، پیشنهادهای تبلیغاتی و پشتیبانی مشتری.",
            "د امر تازه معلومات، تبلیغاتي وړاندیزونه او پیرودونکي ملاتړ لیږل.",
        ),
    ),
    (
        t("Analytics & Improvement", "تحلیل و بهبود", "تحلیل او ښه کول"),
        t(
            "Understand user behavior, improve features, and personalize experience.",
            "درک رفتار کاربر، بهبود امکانات و شخصی‌سازی تجربه.",
            "د کارونکي چلند درک، ځانګړتیاوې ښه کول او تجربه شخصي کول.",
        ),
    ),
    (
        t("Fraud Prevention", "پیشگیری از تقلب", "د درغلي مخنیوی"),
        t(
            "Detect and prevent fraudulent activities and unauthorized access.",
            "شناسایی و جلوگیری از فعالیت‌های تقلبی و دسترسی غیرمجاز.",
            "درغلي فعالیتونو او غیرمجاز لاسرسي کشف او مخنیوی.",
        ),
    ),
    (
        t("Regulatory Compliance", "انطباق مقرراتی", "قانوني مطابقت"),
        t(
            "Meet legal requirements and government regulations.",
            "رعایت الزامات قانونی و مقررات دولتی.",
            "قانوني اړتیاوې او دولتي مقرراتو ته درناوی.",
        ),
    ),
]

SECURITY_TITLE = t("4. Data Security", "۴. امنیت داده‌ها", "۴. د معلوماتو امنیت")
SECURITY_INTRO = t(
    "We implement comprehensive security measures to protect your personal information:",
    "برای حفاظت از اطلاعات شخصی شما اقدامات امنیتی جامع اعمال می‌کنیم:",
    "ستاسو شخصي معلوماتو ساتلو لپاره بشپړ امنیتي اقدامات پلي کوو:",
)
SECURITY_BULLETS: list[Tri] = [
    t(
        "End-to-end encryption for sensitive data transmission",
        "رمزنگاری سرتاسری برای انتقال داده‌های حساس",
        "د حساس معلوماتو لیږد لپاره پای ته پای کوډ کول",
    ),
    t(
        "Password hashing and secure storage",
        "هش رمز عبور و ذخیره‌سازی امن",
        "د پټنوم هش او خوندي زیرمه کول",
    ),
    t(
        "Regular security audits and penetration testing",
        "ممیزی امنیتی منظم و تست نفوذ",
        "منظم امنیتي ممیزي او نفوذ ازموینه",
    ),
    t(
        "Restricted access to personal information (staff only as needed)",
        "دسترسی محدود به اطلاعات شخصی (فقط پرسنل در صورت نیاز)",
        "شخصي معلوماتو محدود لاسرسی (یوازې اړین کارکوونکي)",
    ),
    t(
        "Secure backups and disaster recovery procedures",
        "پشتیبان‌گیری امن و رویه‌های بازیابی پس از حادثه",
        "خوندي بیکاپ او د پیښو رغونې کړنلارې",
    ),
]

RETENTION_TITLE = t("5. Data Retention", "۵. نگهداری داده‌ها", "۵. د معلوماتو ساتل")
RETENTION_CARDS: list[tuple[Tri, Tri]] = [
    (
        t("Active Account Data", "داده‌های حساب فعال", "فعال حساب معلومات"),
        t(
            "Maintained while your account is active or for legal requirement duration.",
            "تا زمانی که حساب فعال است یا مدت الزام قانونی نگهداری می‌شود.",
            "تر هغه چې حساب فعال وي یا د قانون له مخې وخت پورې ساتل کیږي.",
        ),
    ),
    (
        t("Order History", "تاریخچه سفارش", "د امر تاریخ"),
        t(
            "Retained for 7 years for tax and legal compliance purposes.",
            "به مدت ۷ سال برای اهداف مالیاتی و انطباق قانونی نگهداری می‌شود.",
            "د مالیات او قانوني مطابقت لپاره ۷ کاله ساتل کیږي.",
        ),
    ),
    (
        t("Deleted Account Data", "داده‌های حساب حذف‌شده", "ړنګ شوي حساب معلومات"),
        t(
            "Deleted after 30 days, subject to legal holds or disputes.",
            "پس از ۳۰ روز حذف می‌شود، مشروط به توقف قانونی یا اختلافات.",
            "د ۳۰ ورځو وروسته ړنګیږي، قانوني بند یا شخړو ته په پام کې نیولو سره.",
        ),
    ),
]

RIGHTS_TITLE = t("6. Your Privacy Rights", "۶. حقوق حریم خصوصی شما", "۶. ستاسو د محرمیت حقونه")
RIGHTS_CARDS: list[tuple[Tri, Tri]] = [
    (
        t("Right to Access", "حق دسترسی", "د لاسرسي حق"),
        t(
            "Request a copy of all personal data we hold about you.",
            "درخواست رونوشت از تمام داده‌های شخصی که درباره شما نگهداری می‌کنیم.",
            "زموږ لخوا ستاسو په اړه ساتل شوي ټولو شخصي معلوماتو کاپي غوښتنه.",
        ),
    ),
    (
        t("Right to Correct", "حق اصلاح", "د سمون حق"),
        t(
            "Request correction of inaccurate or incomplete data.",
            "درخواست اصلاح داده‌های نادرست یا ناقص.",
            "د ناسمو یا نیمګړو معلوماتو سمون غوښتنه.",
        ),
    ),
    (
        t("Right to Delete", "حق حذف", "د ړنګولو حق"),
        t(
            "Request deletion of your personal data (subject to legal requirements).",
            "درخواست حذف داده‌های شخصی شما (مشروط به الزامات قانونی).",
            "د شخصي معلوماتو ړنګول غوښتنه (د قانوني اړتیاوو په چوکاټ کې).",
        ),
    ),
    (
        t("Right to Withdraw", "حق لغو رضایت", "د رضایت بیرته اخیستلو حق"),
        t(
            "Withdraw consent for data processing at any time.",
            "در هر زمان رضایت پردازش داده را پس بگیرید.",
            "هر وخت د معلوماتو پروسس لپاره رضایت بیرته واخلئ.",
        ),
    ),
]
RIGHTS_FOOTER = t(
    "To exercise any of these rights, please contact us at privacy@afghanfood.af",
    "برای اعمال هر یک از این حقوق، با privacy@afghanfood.af تماس بگیرید.",
    "د دې حقونو د کارولو لپاره له privacy@afghanfood.af سره اړیکه ونیسئ.",
)

CONTACT_TITLE = t("7. Contact Us", "۷. تماس با ما", "۷. زموږ سره اړیکه")
CONTACT_PARA = t(
    "If you have privacy concerns or questions about this policy, please contact:",
    "اگر نگرانی حریم خصوصی یا پرسشی درباره این سیاست دارید، تماس بگیرید:",
    "که محرمیت اندیښنې یا د دې پالیسې په اړه پوښتنې لرئ، اړیکه ونیسئ:",
)
CONTACT_TEAM = t("Loqma Privacy Team", "تیم حریم خصوصی لوقما", "د لوقما محرمیت ټیم")
CONTACT_EMAIL = "privacy@afghanfood.af"
CONTACT_PHONE = "0202250507"
