import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('ar'), Locale('fr'), Locale('en')];

  static const delegate = _AppLocalizationsDelegate();

    static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      const AppLocalizations(Locale('ar'));

  String get languageName => tr('languageName');
  String get explore => tr('explore');
  String get favorites => tr('favorites');
  String get account => tr('account');
  String get owner => tr('owner');
  String get settings => tr('settings');
  String get logout => tr('logout');
  String get addEquipment => tr('addEquipment');
  String get addEquipmentShort => tr('addEquipmentShort');
  String get searchHint => tr('searchHint');
  String get refresh => tr('refresh');
  String get allRegions => tr('allRegions');
  String get region => tr('region');
  String get availableEquipment => tr('availableEquipment');
  String get noEquipment => tr('noEquipment');
  String get addFirstEquipment => tr('addFirstEquipment');
  String get profile => tr('profile');
  String get personalInformation => tr('personalInformation');
  String get fullName => tr('fullName');
  String get phoneNumber => tr('phoneNumber');
  String get cityRegion => tr('cityRegion');
  String get email => tr('email');
  String get saveChanges => tr('saveChanges');
  String get saving => tr('saving');
  String get myEquipment => tr('myEquipment');
  String get noPublishedEquipment => tr('noPublishedEquipment');
  String get language => tr('language');
  String get arabic => tr('arabic');
  String get french => tr('french');
  String get english => tr('english');
  String get cancel => tr('cancel');
  String get delete => tr('delete');
  String get confirmLogout => tr('confirmLogout');
  String get logoutDescription => tr('logoutDescription');
  String get addEquipmentTitle => tr('addEquipmentTitle');
  String get addImages => tr('addImages');
  String get login => tr('login');
  String get register => tr('register');
  String get loginSubtitle => tr('loginSubtitle');
  String get password => tr('password');
  String get signIn => tr('signIn');
  String get createAccount => tr('createAccount');
  String get welcomeBonus => tr('welcomeBonus');
  String get registerBonus => tr('registerBonus');
  String get enterFullName => tr('enterFullName');
  String get enterPhone => tr('enterPhone');
  String get validEmail => tr('validEmail');
  String get passwordLength => tr('passwordLength');
  String get operationFailed => tr('operationFailed');
  String get directContact => tr('directContact');
  String get whatsappContact => tr('whatsappContact');
  String get ownerEquipment => tr('ownerEquipment');
  String get verifiedOwner => tr('verifiedOwner');
  String get detailsAndSpecifications => tr('detailsAndSpecifications');
  String get perDay => tr('perDay');
  String get noPhone => tr('noPhone');
  String get phoneOpenFailed => tr('phoneOpenFailed');
  String get noWhatsapp => tr('noWhatsapp');
  String get whatsappOpenFailed => tr('whatsappOpenFailed');
  String get messages => tr('messages');
  String get analytics => tr('analytics');
  String get directCall => tr('directCall');
  String get homeBannerTitle => tr('homeBannerTitle');
  String get homeBannerSubtitle => tr('homeBannerSubtitle');
  String get searchPlaceholder => tr('searchPlaceholder');
  String get search => tr('search');
  String get availableForRent => tr('availableForRent');
  String get ownerName => tr('ownerName');
  String get directPhone => tr('directPhone');
  String get loadingPhone => tr('loadingPhone');
  String get unavailable => tr('unavailable');
  String get noFavorites => tr('noFavorites');
  String get savedEquipmentDescription => tr('savedEquipmentDescription');
  String get category => tr('category');
  String get currency => tr('currency');
  String get forgotPassword => tr('forgotPassword');
  String get forgotPasswordTitle => tr('forgotPasswordTitle');
  String get forgotPasswordSubtitle => tr('forgotPasswordSubtitle');
  String get sendCode => tr('sendCode');
  String get codeSent => tr('codeSent');
  String get resetPassword => tr('resetPassword');
  String get newPassword => tr('newPassword');
  String get confirmPassword => tr('confirmPassword');
  String get verificationCode => tr('verificationCode');
  String get verificationTitle => tr('verificationTitle');
  String verificationSubtitle(String email) => tr('verificationSubtitle').replaceAll('{email}', email);
  String get verify => tr('verify');
  String get resendCode => tr('resendCode');
  String resendIn(int seconds) => tr('resendIn').replaceAll('{seconds}', '$seconds');
  String get passwordRequirements => tr('passwordRequirements');
  String get passwordMinLength => tr('passwordMinLength');
  String get passwordUppercase => tr('passwordUppercase');
  String get passwordNumber => tr('passwordNumber');
  String get passwordSpecial => tr('passwordSpecial');
  String get passwordsDoNotMatch => tr('passwordsDoNotMatch');
  String get invalidVerificationCode => tr('invalidVerificationCode');
  String get verificationComplete => tr('verificationComplete');

  String tr(String key) => _translations[locale.languageCode]?[key] ??
      _securityTranslations[locale.languageCode]?[key] ??
      _translations['ar']![key] ??
      _securityTranslations['ar']![key] ??
      key;

  static const _securityTranslations = <String, Map<String, String>>{
    'en': {
      'forgotPassword': 'Forgot password?', 'forgotPasswordTitle': 'Reset your password',
      'forgotPasswordSubtitle': 'Enter your email and we will send you a verification code.',
      'sendCode': 'Send code', 'codeSent': 'Verification code sent', 'resetPassword': 'Reset password',
      'newPassword': 'New password', 'confirmPassword': 'Confirm password', 'verificationCode': 'Verification code',
      'verificationTitle': 'Verify your account', 'verificationSubtitle': 'Enter the code sent to {email}',
      'verify': 'Verify', 'resendCode': 'Resend code', 'resendIn': 'Resend in {seconds}s',
      'passwordRequirements': 'Password requirements', 'passwordMinLength': 'At least 8 characters',
      'passwordUppercase': 'One uppercase letter', 'passwordNumber': 'One number',
      'passwordSpecial': 'One special character', 'passwordsDoNotMatch': 'Passwords do not match',
      'invalidVerificationCode': 'Enter a valid verification code', 'verificationComplete': 'Verification complete',
    },
    'fr': {
      'forgotPassword': 'Mot de passe oublié ?', 'forgotPasswordTitle': 'Réinitialiser votre mot de passe',
      'forgotPasswordSubtitle': 'Saisissez votre e-mail pour recevoir un code de vérification.',
      'sendCode': 'Envoyer le code', 'codeSent': 'Code de vérification envoyé', 'resetPassword': 'Réinitialiser le mot de passe',
      'newPassword': 'Nouveau mot de passe', 'confirmPassword': 'Confirmer le mot de passe', 'verificationCode': 'Code de vérification',
      'verificationTitle': 'Vérifiez votre compte', 'verificationSubtitle': 'Saisissez le code envoyé à {email}',
      'verify': 'Vérifier', 'resendCode': 'Renvoyer le code', 'resendIn': 'Renvoyer dans {seconds}s',
      'passwordRequirements': 'Exigences du mot de passe', 'passwordMinLength': 'Au moins 8 caractères',
      'passwordUppercase': 'Une lettre majuscule', 'passwordNumber': 'Un chiffre',
      'passwordSpecial': 'Un caractère spécial', 'passwordsDoNotMatch': 'Les mots de passe ne correspondent pas',
      'invalidVerificationCode': 'Saisissez un code de vérification valide', 'verificationComplete': 'Vérification terminée',
    },
    'ar': {
      'forgotPassword': '\u0647\u0644 \u0646\u0633\u064a\u062a \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631\u061f',
      'forgotPasswordTitle': '\u0625\u0639\u0627\u062f\u0629 \u062a\u0639\u064a\u064a\u0646 \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631',
      'forgotPasswordSubtitle': '\u0623\u062f\u062e\u0644 \u0628\u0631\u064a\u062f\u0643 \u0627\u0644\u0625\u0644\u0643\u062a\u0631\u0648\u0646\u064a \u0648\u0633\u0646\u0631\u0633\u0644 \u0644\u0643 \u0631\u0645\u0632 \u0627\u0644\u062a\u062d\u0642\u0642.',
      'sendCode': '\u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0631\u0645\u0632', 'codeSent': '\u062a\u0645 \u0625\u0631\u0633\u0627\u0644 \u0631\u0645\u0632 \u0627\u0644\u062a\u062d\u0642\u0642',
      'resetPassword': '\u0625\u0639\u0627\u062f\u0629 \u062a\u0639\u064a\u064a\u0646 \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631', 'newPassword': '\u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631 \u0627\u0644\u062c\u062f\u064a\u062f\u0629',
      'confirmPassword': '\u062a\u0623\u0643\u064a\u062f \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631', 'verificationCode': '\u0631\u0645\u0632 \u0627\u0644\u062a\u062d\u0642\u0642',
      'verificationTitle': '\u062a\u062d\u0642\u0642 \u0645\u0646 \u062d\u0633\u0627\u0628\u0643', 'verificationSubtitle': '\u0623\u062f\u062e\u0644 \u0627\u0644\u0631\u0645\u0632 \u0627\u0644\u0645\u0631\u0633\u0644 \u0625\u0644\u0649 {email}',
      'verify': '\u062a\u062d\u0642\u0642', 'resendCode': '\u0625\u0639\u0627\u062f\u0629 \u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0631\u0645\u0632', 'resendIn': '\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0625\u0631\u0633\u0627\u0644 \u062e\u0644\u0627\u0644 {seconds} \u062b',
      'passwordRequirements': '\u0645\u062a\u0637\u0644\u0628\u0627\u062a \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631', 'passwordMinLength': '8 \u0623\u062d\u0631\u0641 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644',
      'passwordUppercase': '\u062d\u0631\u0641 \u0625\u0646\u062c\u0644\u064a\u0632\u064a \u0643\u0628\u064a\u0631 \u0648\u0627\u062d\u062f', 'passwordNumber': '\u0631\u0642\u0645 \u0648\u0627\u062d\u062f', 'passwordSpecial': '\u0631\u0645\u0632 \u062e\u0627\u0635 \u0648\u0627\u062d\u062f',
      'passwordsDoNotMatch': '\u0643\u0644\u0645\u062a\u0627 \u0627\u0644\u0645\u0631\u0648\u0631 \u063a\u064a\u0631 \u0645\u062a\u0637\u0627\u0628\u0642\u062a\u064a\u0646', 'invalidVerificationCode': '\u0623\u062f\u062e\u0644 \u0631\u0645\u0632 \u062a\u062d\u0642\u0642 \u0635\u0627\u0644\u062d\u0627', 'verificationComplete': '\u0627\u0643\u062a\u0645\u0644 \u0627\u0644\u062a\u062d\u0642\u0642',
    },
  };

  static const _translations = <String, Map<String, String>>{
    'ar': {
      'languageName': '\u0627\u0644\u0639\u0631\u0628\u064A\u0629', 'explore': '\u0627\u0633\u062A\u0643\u0634\u0641', 'favorites': '\u0627\u0644\u0645\u0641\u0636\u0644\u0629',
      'account': '\u062D\u0633\u0627\u0628\u064A', 'owner': '\u0645\u0627\u0644\u0643', 'settings': '\u0627\u0644\u0625\u0639\u062F\u0627\u062F\u0627\u062A',
      'logout': '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C', 'addEquipment': '\u0623\u0636\u0641 \u0645\u0639\u062F\u0629 \u062C\u062F\u064A\u062F\u0629',
      'addEquipmentShort': '\u0623\u0636\u0641 \u0645\u0639\u062F\u0629',
      'searchHint': '\u0627\u0628\u062D\u062B \u0639\u0646 \u0623\u064A \u0645\u0639\u062F\u0629\u060C \u0623\u062F\u0648\u0627\u062A\u060C \u0622\u0644\u0627\u062A\u060C \u0623\u0648 \u062A\u062C\u0647\u064A\u0632\u0627\u062A...',
      'refresh': '\u062A\u062D\u062F\u064A\u062B', 'allRegions': '\u0643\u0644 \u0627\u0644\u0645\u0646\u0627\u0637\u0642', 'region': '\u0627\u0644\u0645\u0646\u0637\u0642\u0629',
      'availableEquipment': '\u0645\u0639\u062F\u0627\u062A \u0645\u062A\u0627\u062D\u0629', 'noEquipment': '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u0639\u062F\u0627\u062A \u0645\u062A\u0627\u062D\u0629 \u062D\u0627\u0644\u064A\u0627\u064B',
      'addFirstEquipment': '\u0643\u0646 \u0623\u0648\u0644 \u0645\u0646 \u064A\u0636\u064A\u0641 \u0645\u0639\u062F\u0629 \u062C\u062F\u064A\u062F\u0629 \u0644\u0644\u062A\u0623\u062C\u064A\u0631', 'profile': '\u062D\u0633\u0627\u0628\u064A',
      'personalInformation': '\u0627\u0644\u0645\u0639\u0644\u0648\u0645\u0627\u062A \u0627\u0644\u0634\u062E\u0635\u064A\u0629', 'fullName': '\u0627\u0644\u0627\u0633\u0645 \u0627\u0644\u0643\u0627\u0645\u0644',
      'phoneNumber': '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062A\u0641', 'cityRegion': '\u0627\u0644\u0645\u062F\u064A\u0646\u0629 / \u0627\u0644\u0645\u0646\u0637\u0642\u0629',
      'email': '\u0627\u0644\u0628\u0631\u064A\u062F \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A', 'saveChanges': '\u062D\u0641\u0638 \u0627\u0644\u062A\u063A\u064A\u064A\u0631\u0627\u062A',
      'saving': '\u062C\u0627\u0631\u064D \u0627\u0644\u062D\u0641\u0638...', 'myEquipment': '\u0645\u0639\u062F\u0627\u062A\u064A',
      'noPublishedEquipment': '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u0639\u062F\u0627\u062A \u0645\u0646\u0634\u0648\u0631\u0629 \u0628\u0639\u062F.', 'language': '\u0627\u0644\u0644\u063A\u0629',
      'arabic': '\u0627\u0644\u0639\u0631\u0628\u064A\u0629', 'french': '\u0627\u0644\u0641\u0631\u0646\u0633\u064A\u0629', 'english': '\u0627\u0644\u0625\u0646\u062C\u0644\u064A\u0632\u064A\u0629',
      'cancel': '\u0625\u0644\u063A\u0627\u0621', 'delete': '\u062D\u0630\u0641', 'confirmLogout': '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C',
      'logoutDescription': '\u0647\u0644 \u0623\u0646\u062A \u0645\u062A\u0623\u0643\u062F \u0645\u0646 \u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C \u0645\u0646 \u0627\u0644\u062A\u0637\u0628\u064A\u0642\u061F',
      'addEquipmentTitle': '\u0623\u0636\u0641 \u0645\u0639\u062F\u0629 \u062C\u062F\u064A\u062F\u0629 \u0644\u0644\u062A\u0623\u062C\u064A\u0631', 'addImages': '\u0625\u0636\u0627\u0641\u0629 \u0635\u0648\u0631',
      'login': '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062F\u062E\u0648\u0644', 'register': '\u062D\u0633\u0627\u0628 \u062C\u062F\u064A\u062F',
      'loginSubtitle': '\u0627\u0633\u062A\u0623\u062C\u0631 \u0645\u0639\u062F\u0627\u062A\u0643 \u0623\u0648 \u0627\u0628\u062F\u0623 \u0645\u0634\u0631\u0648\u0639\u0643 \u0628\u0633\u0647\u0648\u0644\u0629', 'password': '\u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631',
      'signIn': '\u062F\u062E\u0648\u0644', 'createAccount': '\u0625\u0646\u0634\u0627\u0621 \u0627\u0644\u062D\u0633\u0627\u0628',
      'welcomeBonus': '🎁 \u0645\u0628\u0631\u0648\u0643! \u062A\u062D\u0635\u0651\u0644\u062A \u0639\u0644\u0649 10 \u062F.\u062A \u0631\u0635\u064A\u062F \u0645\u062C\u0627\u0646\u064A \u0644\u062A\u062C\u0631\u0628\u0629 \u0627\u0644\u062E\u062F\u0645\u0629',
      'registerBonus': '🎁 \u0633\u062A\u062D\u0635\u0644 \u0639\u0644\u0649 10 \u062F.\u062A \u0631\u0635\u064A\u062F \u0645\u062C\u0627\u0646\u064A \u0639\u0646\u062F \u0627\u0644\u062A\u0633\u062C\u064A\u0644',
      'enterFullName': '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0627\u0644\u0627\u0633\u0645 \u0627\u0644\u0643\u0627\u0645\u0644', 'enterPhone': '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062A\u0641',
      'validEmail': '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0628\u0631\u064A\u062F \u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A \u0635\u062D\u064A\u062D',
      'passwordLength': '\u064A\u062C\u0628 \u0623\u0646 \u062A\u062D\u062A\u0648\u064A \u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631 \u0639\u0644\u0649 8 \u0623\u062D\u0631\u0641 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644\u060c \u0645\u0639 \u062D\u0631\u0641 \u0643\u0628\u064A\u0631 \u0648\u0631\u0642\u0645 \u0648\u0631\u0645\u0632 \u062E\u0627\u0635',
      'operationFailed': '\u062A\u0639\u0630\u0631 \u0625\u062A\u0645\u0627\u0645 \u0627\u0644\u0639\u0645\u0644\u064A\u0629',
      'directContact': '\u0627\u062A\u0635\u0627\u0644 \u0645\u0628\u0627\u0634\u0631', 'whatsappContact': '\u062A\u0648\u0627\u0635\u0644 \u0639\u0628\u0631 \u0648\u0627\u062A\u0633\u0627\u0628',
      'ownerEquipment': '\u0645\u0627\u0644\u0643 \u0627\u0644\u0645\u0639\u062F\u0629', 'verifiedOwner': '\u0645\u0627\u0644\u0643 \u0645\u0639\u062A\u0645\u062F \u0641\u064A Rento',
      'detailsAndSpecifications': '\u062A\u0641\u0627\u0635\u064A\u0644 \u0648\u0645\u0648\u0627\u0635\u0641\u0627\u062A \u0627\u0644\u0645\u0639\u062F\u0629', 'perDay': '\u0641\u064A \u0627\u0644\u064A\u0648\u0645',
      'noPhone': '\u0644\u0627 \u064A\u0648\u062C\u062F \u0631\u0642\u0645 \u0647\u0627\u062A\u0641 \u0644\u0644\u0645\u0639\u0644\u0646', 'phoneOpenFailed': '\u062A\u0639\u0630\u0651\u0631 \u0641\u062A\u062D \u0627\u0644\u062A\u0637\u0628\u064A\u0642 \u0644\u0644\u0647\u0627\u062A\u0641',
      'noWhatsapp': '\u0644\u0627 \u064A\u0648\u062C\u062F \u0631\u0642\u0645 \u0648\u0627\u062A\u0633\u0627\u0628 \u0644\u0644\u0645\u0639\u0644\u0646', 'whatsappOpenFailed': '\u062A\u0639\u0630\u0651\u0631 \u0641\u062A\u062D \u0648\u0627\u062A\u0633\u0627\u0628',
      'messages': '\u0627\u0644\u0631\u0633\u0627\u0626\u0644', 'analytics': '\u0627\u0644\u0625\u062D\u0635\u0627\u0626\u064A\u0627\u062A',
      'directCall': '\u0627\u062A\u0635\u0627\u0644 \u0645\u0628\u0627\u0634\u0631', 'homeBannerTitle': '\u062A\u0623\u062C\u064A\u0631 \u0643\u0627\u0641\u0629 \u0623\u0646\u0648\u0627\u0639 \u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0641\u064A \u062A\u0648\u0646\u0633',
      'homeBannerSubtitle': '\u0627\u0628\u062D\u062B\u060C \u0642\u0627\u0631\u0646\u060C \u0648\u0627\u0633\u062A\u0623\u062C\u0631 \u0623\u064A \u0645\u0639\u062F\u0629 \u0628\u0633\u0647\u0648\u0644\u0629 \u0648\u0623\u0645\u0627\u0646 \u0628\u0627\u0644\u0642\u0631\u0628 \u0645\u0646\u0643',
      'searchPlaceholder': '\u0627\u0628\u062D\u062B \u0639\u0646 \u0623\u064A \u0645\u0639\u062F\u0629\u060C \u0623\u062F\u0648\u0627\u062A\u060C \u0622\u0644\u0627\u062A\u060C \u0623\u0648 \u062A\u062C\u0647\u064A\u0632\u0627\u062A...', 'search': '\u0627\u0628\u062D\u062B',
      'availableForRent': '\u0645\u062A\u0648\u0641\u0631 \u0644\u0644\u0643\u0631\u0627\u0621', 'ownerName': '\u0627\u0633\u0645 \u0627\u0644\u0645\u0627\u0644\u0643',
      'directPhone': '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062A\u0641 \u0627\u0644\u0645\u0628\u0627\u0634\u0631', 'loadingPhone': '\u062C\u0627\u0631\u064D \u062A\u062D\u0645\u064A\u0644 \u0627\u0644\u0631\u0642\u0645...',
      'unavailable': '\u063A\u064A\u0631 \u0645\u062A\u0648\u0641\u0631', 'noFavorites': '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u0639\u062F\u0627\u062A \u0641\u064A \u0627\u0644\u0645\u0641\u0636\u0644\u0629 \u062D\u0627\u0644\u064A\u0627\u064B',
      'savedEquipmentDescription': '\u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0627\u0644\u062A\u064A \u0642\u0645\u062A \u0628\u062D\u0641\u0638\u0647\u0627 \u0644\u0644\u0631\u062C\u0648\u0639 \u0625\u0644\u064A\u0647\u0627 \u0644\u0627\u062D\u0642\u0627\u064B',
      'category': '\u0627\u0644\u0641\u0626\u0629', 'currency': '\u062F.\u062A',
    },
    'fr': {
      'languageName': 'Français', 'explore': 'Explorer', 'favorites': 'Favoris',
      'account': 'Mon compte', 'owner': 'Propriétaire', 'settings': 'Paramètres',
      'logout': 'Déconnexion', 'addEquipment': 'Ajouter un équipement',
      'addEquipmentShort': 'Ajouter',
      'searchHint': 'Rechercher un équipement, outil, machine ou matériel...',
      'refresh': 'Actualiser', 'allRegions': 'Toutes les régions', 'region': 'Région',
      'availableEquipment': 'équipements disponibles', 'noEquipment': 'Aucun équipement disponible',
      'addFirstEquipment': 'Soyez le premier à ajouter un équipement à louer', 'profile': 'Mon compte',
      'personalInformation': 'Informations personnelles', 'fullName': 'Nom complet',
      'phoneNumber': 'Numéro de téléphone', 'cityRegion': 'Ville / région',
      'email': 'E-mail', 'saveChanges': 'Enregistrer', 'saving': 'Enregistrement...',
      'myEquipment': 'Mes équipements', 'noPublishedEquipment': 'Aucun équipement publié.',
      'language': 'Langue', 'arabic': 'Arabe', 'french': 'Français', 'english': 'Anglais',
      'cancel': 'Annuler', 'delete': 'Supprimer', 'confirmLogout': 'Déconnexion',
      'logoutDescription': 'Voulez-vous vraiment vous déconnecter ?',
      'addEquipmentTitle': 'Ajouter un équipement à louer', 'addImages': 'Ajouter des images',
      'login': 'Se connecter', 'register': 'Créer un compte',
      'loginSubtitle': 'Louez votre équipement ou démarrez votre projet facilement',
      'password': 'Mot de passe', 'signIn': 'Connexion', 'createAccount': 'Créer le compte',
      'welcomeBonus': '🎁 Félicitations ! Vous recevez 10 TND offerts pour essayer le service',
      'registerBonus': '🎁 Recevez 10 TND offerts lors de votre inscription',
      'enterFullName': 'Veuillez saisir le nom complet', 'enterPhone': 'Veuillez saisir le numéro de téléphone',
      'validEmail': 'Veuillez saisir une adresse e-mail valide',
      'passwordLength': 'Le mot de passe doit contenir au moins 8 caractères, avec une majuscule, un chiffre et un caractère spécial',
      'operationFailed': 'Impossible de terminer l’opération',
      'directContact': 'Contact direct', 'whatsappContact': 'Contacter via WhatsApp',
      'ownerEquipment': 'Propriétaire de l’équipement', 'verifiedOwner': 'Propriétaire vérifié sur Rento',
      'detailsAndSpecifications': 'Détails et spécifications', 'perDay': 'par jour',
      'noPhone': 'Aucun numéro de téléphone pour l’annonceur', 'phoneOpenFailed': 'Impossible d’ouvrir l’application téléphone',
      'noWhatsapp': 'Aucun numéro WhatsApp pour l’annonceur', 'whatsappOpenFailed': 'Impossible d’ouvrir WhatsApp',
      'messages': 'Messages', 'analytics': 'Statistiques',
      'directCall': 'Contact direct', 'homeBannerTitle': 'Louez tous types d’équipements en Tunisie',
      'homeBannerSubtitle': 'Recherchez, comparez et louez facilement et en toute sécurité près de chez vous',
      'searchPlaceholder': 'Rechercher un équipement, outil, machine ou matériel...', 'search': 'Rechercher',
      'availableForRent': 'Disponible à la location', 'ownerName': 'Nom du propriétaire',
      'directPhone': 'Numéro de téléphone direct', 'loadingPhone': 'Chargement du numéro...',
      'unavailable': 'Indisponible', 'noFavorites': 'Aucun équipement dans vos favoris',
      'savedEquipmentDescription': 'Les équipements que vous avez enregistrés pour les consulter plus tard',
      'category': 'Catégorie', 'currency': 'TND',
    },
    'en': {
      'languageName': 'English', 'explore': 'Explore', 'favorites': 'Favorites',
      'account': 'Account', 'owner': 'Owner', 'settings': 'Settings',
      'logout': 'Log out', 'addEquipment': 'Add equipment', 'addEquipmentShort': 'Add',
      'searchHint': 'Search for equipment, tools, machines, or supplies...',
      'refresh': 'Refresh', 'allRegions': 'All regions', 'region': 'Region',
      'availableEquipment': 'equipment available', 'noEquipment': 'No equipment available',
      'addFirstEquipment': 'Be the first to add equipment for rent', 'profile': 'Account',
      'personalInformation': 'Personal information', 'fullName': 'Full name',
      'phoneNumber': 'Phone number', 'cityRegion': 'City / region', 'email': 'Email',
      'saveChanges': 'Save changes', 'saving': 'Saving...', 'myEquipment': 'My equipment',
      'noPublishedEquipment': 'No published equipment yet.', 'language': 'Language',
      'arabic': 'Arabic', 'french': 'French', 'english': 'English', 'cancel': 'Cancel',
      'delete': 'Delete', 'confirmLogout': 'Log out',
      'logoutDescription': 'Are you sure you want to log out?',
      'addEquipmentTitle': 'Add equipment for rent', 'addImages': 'Add images',
      'login': 'Log in', 'register': 'Create account',
      'loginSubtitle': 'Rent equipment or start your project with ease',
      'password': 'Password', 'signIn': 'Log in', 'createAccount': 'Create account',
      'welcomeBonus': '🎁 Congratulations! You received 10 TND credit to try the service',
      'registerBonus': '🎁 Receive 10 TND credit when you register',
      'enterFullName': 'Please enter your full name', 'enterPhone': 'Please enter your phone number',
      'validEmail': 'Please enter a valid email address',
      'passwordLength': 'Password must contain at least 8 characters, including an uppercase letter, a number, and a special character',
      'operationFailed': 'Could not complete the operation',
      'directContact': 'Direct contact', 'whatsappContact': 'Contact via WhatsApp',
      'ownerEquipment': 'Equipment owner', 'verifiedOwner': 'Verified Rento owner',
      'detailsAndSpecifications': 'Details and specifications', 'perDay': 'per day',
      'noPhone': 'The advertiser has no phone number', 'phoneOpenFailed': 'Could not open the phone app',
      'noWhatsapp': 'The advertiser has no WhatsApp number', 'whatsappOpenFailed': 'Could not open WhatsApp',
      'messages': 'Messages', 'analytics': 'Analytics',
      'directCall': 'Direct call', 'homeBannerTitle': 'Rent all types of equipment in Tunisia',
      'homeBannerSubtitle': 'Search, compare, and rent equipment easily and safely near you',
      'searchPlaceholder': 'Search for equipment, tools, machines, or supplies...', 'search': 'Search',
      'availableForRent': 'Available for rent', 'ownerName': 'Owner name',
      'directPhone': 'Direct phone number', 'loadingPhone': 'Loading number...',
      'unavailable': 'Unavailable', 'noFavorites': 'No equipment in favorites',
      'savedEquipmentDescription': 'Equipment you saved to view later', 'category': 'Category', 'currency': 'TND',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((item) => item.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}