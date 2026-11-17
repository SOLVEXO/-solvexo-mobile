import 'package:get/get.dart';

/// English / Urdu strings for the buyer app (docs §3 "Language").
///
/// Keys are the English text itself, so `'Home'.tr` shows "Home" until an
/// Urdu entry exists — a missing translation never shows a raw key. Add new
/// UI strings here as screens move to `.tr`. Product, store and other
/// user-generated text is never translated.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': const {},
        'ur_PK': _ur,
      };

  static const Map<String, String> _ur = {
    // Navigation
    'Home': 'ہوم',
    'Browse': 'تلاش',
    'Cart': 'کارٹ',
    'Library': 'لائبریری',
    'Account': 'اکاؤنٹ',

    // Common states
    'Try again': 'دوبارہ کوشش کریں',
    'Retry': 'دوبارہ کوشش کریں',
    'Something went wrong. Please try again.':
        'کچھ غلط ہو گیا۔ براہ کرم دوبارہ کوشش کریں۔',
    'No internet connection': 'انٹرنیٹ کنکشن نہیں ہے',
    'Loading…': 'لوڈ ہو رہا ہے…',
    'Sign in': 'سائن اِن',
    'Sign in to continue': 'جاری رکھنے کے لیے سائن اِن کریں',
    'Cancel': 'منسوخ کریں',
    'Delete': 'حذف کریں',
    'Save': 'محفوظ کریں',
    'Close': 'بند کریں',

    // Maintenance
    'We’ll be right back': 'ہم جلد واپس آئیں گے',
    'Edudeen is being updated. Please check back shortly.':
        'ایجودین اپ ڈیٹ ہو رہا ہے۔ تھوڑی دیر بعد دوبارہ دیکھیں۔',
    'Expected back': 'متوقع واپسی',
    'Scheduled maintenance': 'طے شدہ مینٹیننس',
    'Some features are being updated.': 'کچھ فیچرز اپ ڈیٹ ہو رہے ہیں۔',

    // Library
    'Files': 'فائلیں',
    'Courses': 'کورسز',
    'Download': 'ڈاؤن لوڈ',
    'Preparing…': 'تیار ہو رہا ہے…',
    'Your library is empty': 'آپ کی لائبریری خالی ہے',
    'Digital files and courses you buy or avail for free appear here.':
        'آپ کی خریدی یا مفت حاصل کی گئی ڈیجیٹل فائلیں اور کورسز یہاں نظر آئیں گے۔',
    'No courses yet': 'ابھی کوئی کورس نہیں',
    'Online courses you enrol in appear here.':
        'جن آن لائن کورسز میں آپ داخلہ لیں گے وہ یہاں نظر آئیں گے۔',
    'Continue learning': 'سیکھنا جاری رکھیں',
    'Start course': 'کورس شروع کریں',
    'Browse resources': 'وسائل دیکھیں',
    'Sign in to see your library': 'اپنی لائبریری دیکھنے کے لیے سائن اِن کریں',
    'complete': 'مکمل',
    'Last 30 days': 'پچھلے 30 دن',
    'Awaiting payment': 'ادائیگی کا انتظار',

    // Account menu
    'My Orders': 'میرے آرڈرز',
    'My Library': 'میری لائبریری',
    'Wishlist': 'پسندیدہ',
    'Edit Profile': 'پروفائل میں ترمیم',
    'My Addresses': 'میرے پتے',
    'Change Password': 'پاس ورڈ تبدیل کریں',
    'Notification Preferences': 'اطلاعات کی ترجیحات',
    'Language': 'زبان',
    'Help & Support': 'مدد اور سپورٹ',
    'Chat with Edudeen': 'ایجودین سے چیٹ کریں',
    'Help Center': 'ہیلپ سینٹر',
    'Contact Us': 'ہم سے رابطہ کریں',
    'Privacy Policy': 'پرائیویسی پالیسی',
    'About App': 'ایپ کے بارے میں',
    'Sell on Edudeen': 'ایجودین پر فروخت کریں',
    'Logout': 'لاگ آؤٹ',
    'Delete Account': 'اکاؤنٹ حذف کریں',

    // Support chat
    'Edudeen Help': 'ایجودین مدد',
    'Type your question…': 'اپنا سوال لکھیں…',
    'Send': 'بھیجیں',
    'Edudeen team': 'ایجودین ٹیم',
    'Hi! How can we help you today?': 'السلام علیکم! ہم آپ کی کیا مدد کر سکتے ہیں؟',
    'So we can reply, share your name and an email or phone number.':
        'تاکہ ہم جواب دے سکیں، اپنا نام اور ای میل یا فون نمبر بتائیں۔',
    'Your name': 'آپ کا نام',
    'This is your seller account': 'یہ آپ کا سیلر اکاؤنٹ ہے',
    'Buying needs your buyer account. Switch to it to continue.': 'خریداری کے لیے خریدار اکاؤنٹ چاہیے۔ جاری رکھنے کے لیے اس پر سوئچ کریں۔',
    'Switch to your buyer account': 'اپنے خریدار اکاؤنٹ پر جائیں',
    'Could not switch account.': 'اکاؤنٹ تبدیل نہیں ہو سکا۔',
    'Open your seller account?': 'اپنا سیلر اکاؤنٹ کھولیں؟',
    'Start selling on Edudeen?': 'ایجودین پر فروخت شروع کریں؟',
    'You will switch to your seller account. You can switch back any time.': 'آپ اپنے سیلر اکاؤنٹ پر چلے جائیں گے۔ آپ کبھی بھی واپس آ سکتے ہیں۔',
    'A seller account will be made with this email and password. Then set up your store.': 'اسی ای میل اور پاس ورڈ سے سیلر اکاؤنٹ بنے گا۔ پھر اپنا اسٹور سیٹ کریں۔',
    'Continue': 'جاری رکھیں',
    'Access ended': 'رسائی ختم ہو گئی',
    'Email or phone': 'ای میل یا فون',
    'Please enter your name.': 'براہ کرم اپنا نام لکھیں۔',
    'Enter a valid email or phone number.': 'درست ای میل یا فون نمبر لکھیں۔',
    'Send to Edudeen team': 'ایجودین ٹیم کو بھیجیں',

    // Delete account
    'Type DELETE to confirm': 'تصدیق کے لیے DELETE لکھیں',
    'Password (if your account has one)': 'پاس ورڈ (اگر آپ کے اکاؤنٹ میں ہے)',
    'This permanently deletes your Edudeen account. Orders that are still open must be finished first.':
        'یہ آپ کا ایجودین اکاؤنٹ مستقل طور پر حذف کر دے گا۔ کھلے آرڈرز پہلے مکمل ہونے چاہئیں۔',
  };
}
