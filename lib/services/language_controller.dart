import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static final instance = LanguageController();
  static const _preferenceKey = 'selected_language';
  static const supportedLanguageCodes = ['ar', 'fr', 'en'];

  String _languageCode = 'ar';

  String get languageCode => _languageCode;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguage = preferences.getString(_preferenceKey);
    if (savedLanguage != null && supportedLanguageCodes.contains(savedLanguage)) {
      _languageCode = savedLanguage;
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode) ||
        languageCode == _languageCode) {
      return;
    }
    _languageCode = languageCode;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, languageCode);
  }
}