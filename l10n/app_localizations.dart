import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @languageName.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageName;

  /// No description provided for @explore.
  ///
  /// In ar, this message translates to:
  /// **'استكشف'**
  String get explore;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get account;

  /// No description provided for @owner.
  ///
  /// In ar, this message translates to:
  /// **'مالك'**
  String get owner;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @addEquipment.
  ///
  /// In ar, this message translates to:
  /// **'أضف معدة جديدة'**
  String get addEquipment;

  /// No description provided for @addEquipmentShort.
  ///
  /// In ar, this message translates to:
  /// **'أضف معدة'**
  String get addEquipmentShort;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن أي معدة، أدوات، آلات، أو تجهيزات...'**
  String get searchHint;

  /// No description provided for @searchPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن أي معدة، أدوات، آلات، أو تجهيزات...'**
  String get searchPlaceholder;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'ابحث'**
  String get search;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @allRegions.
  ///
  /// In ar, this message translates to:
  /// **'كل المناطق'**
  String get allRegions;

  /// No description provided for @region.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة'**
  String get region;

  /// No description provided for @availableEquipment.
  ///
  /// In ar, this message translates to:
  /// **'معدات متاحة'**
  String get availableEquipment;

  /// No description provided for @availableForRent.
  ///
  /// In ar, this message translates to:
  /// **'متوفر للكراء'**
  String get availableForRent;

  /// No description provided for @noEquipment.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معدات متاحة حالياً'**
  String get noEquipment;

  /// No description provided for @addFirstEquipment.
  ///
  /// In ar, this message translates to:
  /// **'كن أول من يضيف معدة جديدة للتأجير'**
  String get addFirstEquipment;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profile;

  /// No description provided for @personalInformation.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInformation;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @cityRegion.
  ///
  /// In ar, this message translates to:
  /// **'المدينة / المنطقة'**
  String get cityRegion;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @saveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get saveChanges;

  /// No description provided for @saving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ...'**
  String get saving;

  /// No description provided for @myEquipment.
  ///
  /// In ar, this message translates to:
  /// **'معداتي'**
  String get myEquipment;

  /// No description provided for @noPublishedEquipment.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معدات منشورة بعد.'**
  String get noPublishedEquipment;

  /// No description provided for @noFavorites.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معدات في المفضلة حالياً'**
  String get noFavorites;

  /// No description provided for @savedEquipmentDescription.
  ///
  /// In ar, this message translates to:
  /// **'المعدات التي قمت بحفظها للرجوع إليها لاحقاً'**
  String get savedEquipmentDescription;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In ar, this message translates to:
  /// **'الفرنسية'**
  String get french;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get english;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @confirmLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get confirmLogout;

  /// No description provided for @logoutDescription.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج من التطبيق؟'**
  String get logoutDescription;

  /// No description provided for @addEquipmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف معدة جديدة للتأجير'**
  String get addEquipmentTitle;

  /// No description provided for @addImages.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صور'**
  String get addImages;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'حساب جديد'**
  String get register;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استأجر معداتك أو ابدأ مشروعك بسهولة'**
  String get loginSubtitle;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get createAccount;

  /// No description provided for @welcomeBonus.
  ///
  /// In ar, this message translates to:
  /// **'مبروك! تحصّلت على 10 د.ت رصيد مجاني لتجربة الخدمة'**
  String get welcomeBonus;

  /// No description provided for @registerBonus.
  ///
  /// In ar, this message translates to:
  /// **'ستحصل على 10 د.ت رصيد مجاني عند التسجيل'**
  String get registerBonus;

  /// No description provided for @enterFullName.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال الاسم الكامل'**
  String get enterFullName;

  /// No description provided for @enterPhone.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الهاتف'**
  String get enterPhone;

  /// No description provided for @validEmail.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get validEmail;

  /// No description provided for @passwordLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل، مع حرف كبير ورقم ورمز خاص'**
  String get passwordLength;

  /// No description provided for @operationFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذر إتمام العملية'**
  String get operationFailed;

  /// No description provided for @directContact.
  ///
  /// In ar, this message translates to:
  /// **'اتصال مباشر'**
  String get directContact;

  /// No description provided for @directCall.
  ///
  /// In ar, this message translates to:
  /// **'اتصال مباشر'**
  String get directCall;

  /// No description provided for @whatsappContact.
  ///
  /// In ar, this message translates to:
  /// **'تواصل عبر واتساب'**
  String get whatsappContact;

  /// No description provided for @ownerEquipment.
  ///
  /// In ar, this message translates to:
  /// **'مالك المعدة'**
  String get ownerEquipment;

  /// No description provided for @ownerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المالك'**
  String get ownerName;

  /// No description provided for @verifiedOwner.
  ///
  /// In ar, this message translates to:
  /// **'مالك معتمد في Rento'**
  String get verifiedOwner;

  /// No description provided for @directPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف المباشر'**
  String get directPhone;

  /// No description provided for @loadingPhone.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل الرقم...'**
  String get loadingPhone;

  /// No description provided for @unavailable.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر'**
  String get unavailable;

  /// No description provided for @detailsAndSpecifications.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل ومواصفات المعدة'**
  String get detailsAndSpecifications;

  /// No description provided for @perDay.
  ///
  /// In ar, this message translates to:
  /// **'في اليوم'**
  String get perDay;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'د.ت'**
  String get currency;

  /// No description provided for @noPhone.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم هاتف للمعلن'**
  String get noPhone;

  /// No description provided for @phoneOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح التطبيق للهاتف'**
  String get phoneOpenFailed;

  /// No description provided for @noWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد رقم واتساب للمعلن'**
  String get noWhatsapp;

  /// No description provided for @whatsappOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح واتساب'**
  String get whatsappOpenFailed;

  /// No description provided for @messages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get messages;

  /// No description provided for @analytics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get analytics;

  /// No description provided for @category.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get category;

  /// No description provided for @homeBannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأجير كافة أنواع المعدات في تونس'**
  String get homeBannerTitle;

  /// No description provided for @homeBannerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ابحث، قارن، واستأجر أي معدة بسهولة وأمان بالقرب منك'**
  String get homeBannerSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'هل نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get sendCode;

  /// No description provided for @codeSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز التحقق'**
  String get codeSent;

  /// No description provided for @resetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// No description provided for @verificationCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get verificationCode;

  /// No description provided for @verificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من حسابك'**
  String get verificationTitle;

  /// No description provided for @verificationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المرسل إلى {email}'**
  String verificationSubtitle(Object email);

  /// No description provided for @verify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال خلال {seconds} ث'**
  String resendIn(Object seconds);

  /// No description provided for @passwordRequirements.
  ///
  /// In ar, this message translates to:
  /// **'متطلبات كلمة المرور'**
  String get passwordRequirements;

  /// No description provided for @passwordMinLength.
  ///
  /// In ar, this message translates to:
  /// **'8 أحرف على الأقل'**
  String get passwordMinLength;

  /// No description provided for @passwordUppercase.
  ///
  /// In ar, this message translates to:
  /// **'حرف إنجليزي كبير واحد'**
  String get passwordUppercase;

  /// No description provided for @passwordNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم واحد'**
  String get passwordNumber;

  /// No description provided for @passwordSpecial.
  ///
  /// In ar, this message translates to:
  /// **'رمز خاص واحد'**
  String get passwordSpecial;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get passwordsDoNotMatch;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز تحقق صالحاً'**
  String get invalidVerificationCode;

  /// No description provided for @verificationComplete.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل التحقق'**
  String get verificationComplete;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
