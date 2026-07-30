# -*- coding: utf-8 -*-
"""Trilingual (en / fa / ps) tuples for Terms of Service JSON. Run: python tool/generate_terms_assets.py"""

from __future__ import annotations

Tri = tuple[str, str, str]


def t(en: str, fa: str, ps: str) -> Tri:
    return (en, fa, ps)


def pick(tri: Tri, lang_idx: int) -> str:
    return tri[lang_idx]


# --- Nav / overview ---
NAV_OVERVIEW = t("Overview", "نمای کلی", "لنځیز")
OVERVIEW_TEXT = t(
    'These Terms of Service ("Terms") govern your use of the Loqma platform. By accessing our website or mobile application, you agree to be bound by these Terms. If you disagree with any part of these Terms, you may not use our Service.',
    "این شرایط استفاده از خدمات («شرایط») استفاده شما از پلتفرم لوقما را تنظیم می‌کند. با دسترسی به وب‌سایت یا اپلیکیشن موبایل ما، می‌پذیرید که به این شرایط متعهد باشید. در صورت عدم موافقت با هر بخش، نباید از خدمات ما استفاده کنید.",
    "د خدمتونو د کارولو شرایط («شرایط») د لوقما پلیټ فارم ستاسو کارول تنظيموي. د ویب پاڼې یا موبایل اپلیکیشن لاسرسي سره تاسو منئ چې پدې شرایطو پابند یاست. که د شرایطو له هرې برخې سره موافق نه یاست، مهرباني وکړئ زموږ خدمت مه کاروئ.",
)

# --- 1. User accounts ---
T_ACCOUNTS = t("1. User Accounts", "۱. حساب‌های کاربری", "۱. کارن حسابونه")
H_11 = t("1.1 Account Creation", "۱.۱ ایجاد حساب", "۱.۱ د حساب جوړول")
P_11 = t(
    "To use our Service, you must create an account. You agree to:",
    "برای استفاده از خدمات، باید حساب ایجاد کنید. شما موافقت می‌کنید که:",
    "د خدمت لپاره تاسو باید حساب جوړ کړئ. تاسو منئ چې:",
)
B_11_1 = t("Provide accurate, complete, and current information", "اطلاعات دقیق، کامل و به‌روز ارائه دهید", "سمو، بشپړ او تازه معلومات ورکړئ")
B_11_2 = t("Maintain confidentiality of your password", "محرمانگی رمز عبور خود را حفظ کنید", "د خپل پټنوم محرمیت وساتئ")
B_11_3 = t("Be responsible for all activities under your account", "مسئول تمام فعالیت‌های زیر حساب خود باشید", "د خپل حساب لاندې ټولو فعالیتونو مسئول اوسئ")
B_11_4 = t("Notify us immediately of unauthorized access", "در صورت دسترسی غیرمجاز فوراً ما را مطلع کنید", "د غیرمجاز لاسرسي په صورت کې سمدستي موږ خبر کړئ")

H_12 = t("1.2 Account Eligibility", "۱.۲ واجد شرایط بودن حساب", "۱.۲ د حساب وړتیا")
P_12 = t(
    "You must be at least 18 years old and have the legal capacity to enter into contracts. Users who are minors may use the Service only with parental or guardian consent.",
    "باید حداقل ۱۸ سال داشته باشید و اهلیت قانونی برای انعقاد قرارداد داشته باشید. افرادی که زیر سن قانونی هستند تنها با رضایت والدین یا سرپرست می‌توانند از خدمات استفاده کنند.",
    "تاسو باید لږتره ۱۸ کاله یاست او د قراردادونو لپاره قانوني وړتیا ولرئ. لږ عمر کاروونکي یوازې د والدینو یا سرپرست اجازې سره خدمت کارولی شي.",
)

H_13 = t("1.3 Account Termination", "۱.۳ فسخ حساب", "۱.۳ د حساب پای")
P_13 = t(
    "We reserve the right to terminate or suspend your account immediately, without notice, for conduct that violates these Terms or is harmful to other users or our platform.",
    "ما حق داریم حساب شما را فوراً و بدون اطلاع قبلی در صورت نقض این شرایط یا آسیب به دیگران یا پلتفرم تعلیق یا خاتمه دهیم.",
    "موږ حق لرو چې ستاسو حساب سمدستي او پرته له خبرتیا څخه د دې شرایطو د سرغړونې یا د نورو یا پلیټ فارم زیان لپاره وځنډوو یا پای ته ورسوو.",
)

# --- 2 Acceptable use ---
T_USE = t("2. Acceptable Use Policy", "۲. سیاست استفاده مجاز", "۲. د منلو کارونې پالیسي")
LEAD_USE = t("Users agree NOT to:", "کاربران موافقت می‌کنند که این کارها را انجام ندهند:", "کاروونکي مني چې نه کوي:")
# ... (rest of the code remains the same)

# --- 4 Delivery ---
T_DEL = t("4. Delivery & Liability", "۴. تحویل و مسئولیت", "۴. تحویل او مسؤلیت")
H_41 = t("4.1 Delivery Times", "۴.۱ زمان تحویل", "۴.۱ د تحویل وختونه")
P_41 = t(
    "Estimated delivery times are provided for convenience but not guaranteed. We are not liable for delays caused by traffic, weather, or circumstances beyond our control. Typical delivery is 30-45 minutes from restaurant acceptance.",
    "زمان تخمینی تحویل برای راحتی است و تضمین نمی‌شود. تأخیر ناشی از ترافیک، آب‌وهوا یا شرایط خارج از کنترل ما مسئولیت ما نیست. معمولاً ۳۰ تا ۴۵ دقیقه پس از پذیرش رستوران است.",
    "د تحویل اټکل شوی وخت اسانۍ لپاره دی او ضمانت نه دی. د ترافیک، موسم یا زموږ له کنترول بهر حالاتو لپاره موږ مسؤل نه یو. معمولاً د رستورانت د منلو وروسته ۳۰–۴۵ دقیقې.",
)
H_42 = t("4.2 Delivery Address Requirements", "۴.۲ الزامات آدرس تحویل", "۴.۲ د تحویل پتې اړتیاوې")
P_42 = t(
    "You must provide a valid, accurate delivery address. We are not responsible for:",
    "باید آدرس تحویل معتبر و دقیق ارائه دهید. ما مسئول نیستیم برای:",
    "تاسو باید سمه تحویلي پته ورکړئ. موږ مسؤل نه یو د:",
)
D_42_1 = t(
    "Orders delivered to incorrect addresses due to customer error",
    "تحویل به آدرس اشتباه به دلیل خطای مشتری",
    "د پیرودونکي تېروتنې له امله غلط پتې ته تحویل",
)
D_42_2 = t(
    "Drivers being unable to access locked buildings without access codes",
    "عدم دسترسی راننده به ساختمان‌های قفل بدون کد",
    "د لاسرسي کوډ پرته قفل ودانۍ ته د چلوونکي نه رسېدل",
)
D_42_3 = t(
    "Deliveries refused by building security",
    "رد تحویل توسط نگهبانی ساختمان",
    "د ودانۍ امنیت له خوا د تحویل ردول",
)
H_43 = t("4.3 Food Quality & Safety", "۴.۳ کیفیت و ایمنی غذا", "۴.۳ د خواړو کیفیت او خوندیتوب")
P_43 = t(
    "Restaurants are responsible for food quality and safety. If you receive:",
    "رستوران مسئول کیفیت و ایمنی غذا است. اگر دریافت کنید:",
    "د خواړو کیفیت او خوندیتوب د رستورانت مسؤلیت دی. که ترلاسه کړئ:",
)
D_43_1 = t(
    "Incorrect or incomplete orders: Contact us within 30 minutes for resolution",
    "سفارش نادرست یا ناقص: ظرف ۳۰ دقیقه تماس بگیرید",
    "ناسم یا نیمګړ امر: په ۳۰ دقیقو کې اړیکه ونیسئ",
)
D_43_2 = t(
    "Contaminated or unsafe food: Contact us immediately for full refund",
    "غذای آلوده یا ناامن: فوراً تماس بگیرید برای بازپرداخت کامل",
    "ککړ یا ناامن خواړه: سمدستي اړیکه — بشپړه بیرته ورکړه",
)
D_43_3 = t(
    "Cold or damaged food: File complaint within 2 hours of delivery",
    "غذای سرد یا آسیب‌دیده: شکایت ظرف ۲ ساعت پس از تحویل",
    "سړ یا زیانمن خواړه: د تحویل له ۲ ساعتو څخه دننه شکایت",
)
H_44 = t("4.4 Liability Limitation", "۴.۴ محدودیت مسئولیت", "۴.۴ د مسؤلیت محدودیت")
P_44 = t(
    "To the fullest extent permitted by law, Loqma is not liable for indirect, incidental, or consequential damages. Our total liability is limited to the value of your order.",
    "در حداکثر مجاز قانونی، لوقما مسئول خسارات غیرمستقیم، اتفاقی یا تبعی نیست. مسئولیت ما محدود به ارزش سفارش شماست.",
    "په قانوني اجازه شوي حد کې لوقما غیرمستقیم، ناڅاپي یا پایلې زیانونو لپاره مسؤل نه دی. ټوله مسؤلیت ستاسو د امر ارزښت ته محدوده ده.",
)

# --- 5 Drivers ---
T_DRV = t("5. Driver Partners", "۵. شرکای راننده", "۵. د چلوونکو ملګري")
H_51 = t("5.1 Independent Contractors", "۵.۱ پیمانکاران مستقل", "۵.۱ خپلواک قراردادیان")
P_51 = t(
    "Drivers are independent contractors, not employees. They are responsible for their vehicle maintenance, insurance, and compliance with traffic laws.",
    "رانندگان پیمانکار مستقل هستند، نه کارمند. آن‌ها مسئول نگهداری وسیله، بیمه و رعایت قوانین رانندگی هستند.",
    "چلوونکي خپلواک قراردادیان دي، کارمند نه. د موټر ساتنه، بیمه او د ترافیک قوانینو مراعت د دوی مسؤلیت دی.",
)
H_52 = t("5.2 Driver Conduct & Safety", "۵.۲ رفتار و ایمنی راننده", "۵.۲ د چلوونکي چلند او خوندیتوب")
P_52 = t("All drivers must:", "همه رانندگان باید:", "ټول چلوونکي باید:")
DRV52_1 = t(
    "Maintain valid driver's license and insurance",
    "گواهینامه و بیمه معتبر داشته باشند",
    "د اعتبار ولېږد او بیمه ولري",
)
DRV52_2 = t("Follow all traffic laws and regulations", "تمام قوانین رانندگی را رعایت کنند", "ټول د ترافیک قوانین تعقیب کړي")
DRV52_3 = t("Treat customers with respect", "با مشتریان با احترام رفتار کنند", "د پیرودونکو درناوی وکړي")
DRV52_4 = t("Secure food items properly during delivery", "اقلام غذا را در حین تحویل به‌درستی ایمن کنند", "په تحویل کې خواړه سم خوندي کړي")
DRV52_5 = t("Never consume customer food or beverages", "هرگز غذا یا نوشیدنی مشتری مصرف نکنند", "د پیرودونکي خواړه یا څښاک مه خورئ")

H_53 = t("5.3 Driver Verification", "۵.۳ تأیید هویت راننده", "۵.۳ د چلوونکي تصدیق")
P_53 = t(
    "All drivers undergo background checks and document verification. However, we cannot guarantee complete absence of risk. Report unsafe driver behavior immediately.",
    "همه رانندگان بررسی سوابق و تأیید مدارک می‌شوند. با این حال نمی‌توانیم عدم خطر را تضمین کنیم. رفتار ناامن را فوراً گزارش دهید.",
    "ټول چلوونکي پوښتنه او اسناد تصدیق کیږي. بیا هم بشپړه د خطر نشتوالی ضمانت نشي. ناامن چلند سمدستي راپور کړئ.",
)

# --- 6 Restaurants ---
T_RST = t("6. Restaurant Partners", "۶. شرکای رستوران", "۶. د رستورانت ملګري")
H_61 = t("6.1 Restaurant Responsibility", "۶.۱ مسئولیت رستوران", "۶.۱ د رستورانت مسؤلیت")
P_61 = t("Restaurants are responsible for:", "رستوران‌ها مسئول هستند برای:", "رستورانتونه مسؤل دي د:")
RST61_1 = t("Food quality and hygiene standards", "کیفیت غذا و استانداردهای بهداشتی", "د خواړو کیفیت او روغتیا معیارونه")
RST61_2 = t("Accurate menu descriptions and allergen information", "توضیحات دقیق منو و اطلاعات آلرژن", "د منو سم تشریح او د حساسیت معلومات")
RST61_3 = t("Timely order preparation", "آماده‌سازی به‌موقع سفارش", "په وخت د امر چمتو کول")
RST61_4 = t("Compliance with food safety regulations", "رعایت مقررات ایمنی غذا", "د خواړو د خوندیتوب مقرراتو تعقیب")

H_62 = t("6.2 Commission & Fees", "۶.۲ کمیسیون و کارمزد", "۶.۲ کمیشن او فیس")
P_62 = t(
    "Restaurants agree to pay agreed-upon commission rates. Commission is calculated on total order value including delivery fee.",
    "رستوران‌ها با نرخ کمیسیون توافقی موافقت می‌کنند. کمیسیون بر اساس کل ارزش سفارش شامل هزینه ارسال محاسبه می‌شود.",
    "رستورانتونه د کمیشن په اړه موافقه کوي. کمیشن د تحویل فیس سره په ټولیز امر ارزښت محاسبه کیږي.",
)

# --- 7 IP ---
T_IP = t("7. Intellectual Property Rights", "۷. حقوق مالکیت فکری", "۷. د فکري ملکیت حقونه")
P_IP1 = t(
    "All content on our platform, including logos, text, graphics, and software, is our property or licensed to us. You may not:",
    "تمام محتوای پلتفرم از جمله لوگو، متن، گرافیک و نرم‌افزار متعلق به ماست یا مجوز داریم. شما نباید:",
    "ټول منځپانګه لکه نښه، متن، ګرافیک او سافټویر زموږ دی یا موږ ته جواز شوی. تاسو نه شئ کولی:",
)
IPB1 = t("Copy or reproduce content without permission", "کپی یا تکثیر بدون اجازه", "پرته له اجازې کاپي یا تکرار")
IPB2 = t("Modify or create derivative works", "تغییر یا آثار مشتق", "بدلون یا مشتق کارونه")
IPB3 = t("Use our logo or branding without authorization", "استفاده از لوگو بدون مجوز", "پرته له اجازې زموږ نښه کارول")

P_IP2 = t("User-Generated Content:", "محتوای تولیدشده توسط کاربر:", "د کارونکي جوړ شوې منځپانګه:")
P_IP3 = t(
    "By posting reviews, photos, or feedback, you grant us a royalty-free, perpetual license to use, display, and distribute this content. You remain the owner and responsible for your content.",
    "با انتشار نظر، عکس یا بازخورد، مجوز دائمی و بدون حق امتیاز برای استفاده، نمایش و توزیع می‌دهید. مالکیت با شماست و مسئول محتوای خود هستید.",
    "د نظر، انځور یا بیرته راګرځونې سره تاسو موږ ته د تل لپاره، پرته له فیس څخه، کارولو، ښودلو او خپرولو اجازه ورکوئ. مالکیت ستاسو دی او تاسو مسؤل یاست.",
)

# --- 8 Law ---
T_LAW = t("8. Governing Law & Dispute Resolution", "۸. قانون حاکم و حل اختلاف", "۸. حاکم قانون او شخړه حلول")
H_81 = t("8.1 Governing Law", "۸.۱ قانون حاکم", "۸.۱ حاکم قانون")
P_81 = t(
    "These Terms are governed by the laws of Afghanistan. Any disputes shall be subject to the jurisdiction of Afghan courts.",
    "این شرایط تابع قوانین افغانستان است. اختلافات در صلاحیت محاکم افغانستان است.",
    "دا شرایط د افغانستان قانون تابع دي. شخړې د افغان محکمو واک لاندې دي.",
)
H_82 = t("8.2 Dispute Resolution", "۸.۲ حل اختلاف", "۸.۲ شخړه حلول")
P_82 = t("In case of disputes:", "در صورت اختلاف:", "د شخړو په صورت کې:")
L82_1 = t("Contact our support team within 7 days", "تماس با پشتیبانی ظرف ۷ روز", "په ۷ ورځو کې ملاتړ ته اړیکه")
L82_2 = t("Provide complete documentation of the issue", "ارائه مدارک کامل موضوع", "د مسلې بشپړ اسناد ورکړل")
L82_3 = t("We will investigate and respond within 14 days", "بررسی و پاسخ ظرف ۱۴ روز", "په ۱۴ ورځو کې څېړنه او ځواب")
L82_4 = t("If unresolved, escalate to our management team", "در صورت عدم حل، ارجاع به مدیریت", "نه حل کېدلو سره مدیریت ته")

# --- 9 Disclaimers ---
T_DIS = t("9. Disclaimers", "۹. سلب مسئولیت", "۹. مسؤلیت ردول")
P_DIS = t(
    'The Service is provided "AS IS" without warranties. We do not guarantee:',
    'خدمات «همان‌گونه که هست» بدون ضمانت ارائه می‌شود. ما تضمین نمی‌کنیم:',
    'خدمت «په هغه ډول چې دی» پرته له ضمانتونو. موږ ضمانت نه کوو:',
)
DISB1 = t("Uninterrupted service availability", "دسترسی بی‌وقفه به خدمات", "بې وقفه خدمت شتون")
DISB2 = t("Absence of errors or defects", "نبود خطا یا نقص", "د تېروتنو یا نقص نشتوالی")
DISB3 = t("Security from unauthorized access", "امنیت در برابر دسترسی غیرمجاز", "د غیرمجاز لاسرسي څخه امنیت")
DISB4 = t("Specific delivery times", "زمان تحویل مشخص", "ځانګړي تحویل وختونه")
DISB5 = t("Third-party service performance", "عملکرد خدمات شخص ثالث", "دریمې خواوې خدمت فعالیت")

# --- 10 Changes ---
T_CHG = t("10. Changes to Terms", "۱۰. تغییرات شرایط", "۱۰. د شرایطو بدلونونه")
P_CHG = t(
    "We may modify these Terms at any time. We will notify you of significant changes via email or in-app notification. Continued use of the Service after changes indicates your acceptance of the new Terms.",
    "ما می‌توانیم این شرایط را هر زمان تغییر دهیم. تغییرات مهم را از طریق ایمیل یا اعلان در اپ اطلاع می‌دهیم. ادامه استفاده پس از تغییر به‌منزله پذیرش شرایط جدید است.",
    "موږ کولی شو دا شرایط هر وخت بدل کړو. مهمو بدلونو ته بریښنالیک یا په اپ کې خبرتیا ورکوو. بدلون وروسته دوامداره کارول نوي شرایط منل دي.",
)

# --- 11 Contact ---
T_CON = t("11. Contact Us", "۱۱. تماس با ما", "۱۱. زموږ سره اړیکه")
P_CON = t(
    "If you have questions about these Terms, please contact:",
    "در صورت پرسش درباره این شرایط، تماس بگیرید:",
    "د دې شرایطو په اړه پوښتنې لرئ، اړیکه ونیسئ:",
)
TEAM = t("Loqma Legal Team", "تیم حقوقی لوقما", "د لوقما قانوني ټیم")
EMAIL = "legal@afghanfood.af"
PHONE = "0202250507"
ACK = t(
    "By using Loqma, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.",
    "با استفاده از لوقما تأیید می‌کنید که این شرایط را خوانده، فهمیده و می‌پذیرید.",
    "د لوقما په کارولو سره تاسو منئ چې دا شرایط لوستلي، پوه شوي او منئ.",
)


def _callout(accent: str, paragraphs: list[str] | None = None, title: str | None = None, bullets: list[str] | None = None) -> dict:
    d: dict = {"accent": accent}
    if title:
        d["title"] = title
    if paragraphs:
        d["paragraphs"] = paragraphs
    if bullets:
        d["bullets"] = bullets
    return d


def build_sections(i: int) -> list[dict]:
    return [
        {
            "id": "overview",
            "navTitle": pick(NAV_OVERVIEW, i),
            "callout": _callout("blue", paragraphs=[pick(OVERVIEW_TEXT, i)]),
        },
        {
            "id": "accounts",
            "title": pick(T_ACCOUNTS, i),
            "blocks": [
                {
                    "heading": pick(H_11, i),
                    "paragraph": pick(P_11, i),
                    "bullets": [pick(B_11_1, i), pick(B_11_2, i), pick(B_11_3, i), pick(B_11_4, i)],
                },
                {"heading": pick(H_12, i), "paragraph": pick(P_12, i)},
                {"heading": pick(H_13, i), "paragraph": pick(P_13, i)},
            ],
        },
        {
            "id": "acceptable",
            "title": pick(T_USE, i),
            "lead": pick(LEAD_USE, i),
            "prohibited": [
                {"title": pick(PR01_T, i), "body": pick(PR01_B, i)},
                {"title": pick(PR02_T, i), "body": pick(PR02_B, i)},
                {"title": pick(PR03_T, i), "body": pick(PR03_B, i)},
                {"title": pick(PR04_T, i), "body": pick(PR04_B, i)},
                {"title": pick(PR05_T, i), "body": pick(PR05_B, i)},
                {"title": pick(PR06_T, i), "body": pick(PR06_B, i)},
                {"title": pick(PR07_T, i), "body": pick(PR07_B, i)},
            ],
        },
        {
            "id": "orders",
            "title": pick(T_ORD, i),
            "blocks": [
                {"heading": pick(H_31, i), "paragraph": pick(P_31, i)},
                {
                    "heading": pick(H_32, i),
                    "paragraph": pick(P_32, i),
                    "callout": _callout(
                        "yellow",
                        title=pick(FEES_TITLE, i),
                        bullets=[pick(FEE_1, i), pick(FEE_2, i), pick(FEE_3, i), pick(FEE_4, i)],
                    ),
                },
                {"heading": pick(H_33, i), "paragraph": pick(P_33, i)},
                {
                    "heading": pick(H_34, i),
                    "paragraph": pick(P_34, i),
                    "callout": _callout(
                        "green",
                        bullets=[pick(R_1, i), pick(R_2, i), pick(R_3, i), pick(R_4, i)],
                    ),
                },
            ],
        },
        {
            "id": "delivery",
            "title": pick(T_DEL, i),
            "blocks": [
                {"heading": pick(H_41, i), "paragraph": pick(P_41, i)},
                {
                    "heading": pick(H_42, i),
                    "paragraph": pick(P_42, i),
                    "bullets": [pick(D_42_1, i), pick(D_42_2, i), pick(D_42_3, i)],
                },
                {
                    "heading": pick(H_43, i),
                    "paragraph": pick(P_43, i),
                    "bullets": [pick(D_43_1, i), pick(D_43_2, i), pick(D_43_3, i)],
                },
                {"heading": pick(H_44, i), "paragraph": pick(P_44, i)},
            ],
        },
        {
            "id": "drivers",
            "title": pick(T_DRV, i),
            "blocks": [
                {"heading": pick(H_51, i), "paragraph": pick(P_51, i)},
                {
                    "heading": pick(H_52, i),
                    "paragraph": pick(P_52, i),
                    "bullets": [pick(DRV52_1, i), pick(DRV52_2, i), pick(DRV52_3, i), pick(DRV52_4, i), pick(DRV52_5, i)],
                },
                {"heading": pick(H_53, i), "paragraph": pick(P_53, i)},
            ],
        },
        {
            "id": "restaurants",
            "title": pick(T_RST, i),
            "blocks": [
                {
                    "heading": pick(H_61, i),
                    "paragraph": pick(P_61, i),
                    "bullets": [pick(RST61_1, i), pick(RST61_2, i), pick(RST61_3, i), pick(RST61_4, i)],
                },
                {"heading": pick(H_62, i), "paragraph": pick(P_62, i)},
            ],
        },
        {
            "id": "ip",
            "title": pick(T_IP, i),
            "blocks": [
                {"paragraph": pick(P_IP1, i), "bullets": [pick(IPB1, i), pick(IPB2, i), pick(IPB3, i)]},
                {"paragraph": pick(P_IP2, i)},
                {"paragraph": pick(P_IP3, i)},
            ],
        },
        {
            "id": "law",
            "title": pick(T_LAW, i),
            "blocks": [
                {"heading": pick(H_81, i), "paragraph": pick(P_81, i)},
                {
                    "heading": pick(H_82, i),
                    "paragraph": pick(P_82, i),
                    "orderedList": [pick(L82_1, i), pick(L82_2, i), pick(L82_3, i), pick(L82_4, i)],
                },
            ],
        },
        {
            "id": "disclaimers",
            "title": pick(T_DIS, i),
            "callout": _callout(
                "orange",
                paragraphs=[pick(P_DIS, i)],
                bullets=[pick(DISB1, i), pick(DISB2, i), pick(DISB3, i), pick(DISB4, i), pick(DISB5, i)],
            ),
        },
        {
            "id": "changes",
            "title": pick(T_CHG, i),
            "blocks": [{"paragraph": pick(P_CHG, i)}],
        },
        {
            "id": "contact",
            "title": pick(T_CON, i),
            "blocks": [{"paragraph": pick(P_CON, i)}],
            "contactTeam": pick(TEAM, i),
            "contactEmail": EMAIL,
            "contactPhone": PHONE,
            "closingNote": pick(ACK, i),
        },
    ]
