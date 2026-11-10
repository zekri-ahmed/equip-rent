import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:equip_rent_app/l10n/app_localizations.dart';

void main() {
  test('supports Arabic, French, and English catalogs', () {
    expect(AppLocalizations.supportedLocales.map((locale) => locale.languageCode),
        containsAll(<String>['ar', 'fr', 'en']));
    expect(const AppLocalizations(Locale('fr')).addEquipment, 'Ajouter un équipement');
    expect(const AppLocalizations(Locale('en')).searchHint, contains('Search'));
    expect(const AppLocalizations(Locale('ar')).language, 'اللغة');
  });
}