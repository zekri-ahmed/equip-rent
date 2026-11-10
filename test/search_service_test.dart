import 'package:flutter_test/flutter_test.dart';

import 'package:equip_rent_app/services/search_service.dart';

void main() {
  test('normalizes Arabic letter variants, diacritics, and punctuation', () {
    expect(SearchNormalizer.normalize('  إِكْرَاء،  معدات!  '), 'اكراء معدات');
    expect(SearchNormalizer.normalize('أريانة'), SearchNormalizer.normalize('اريانه'));
  });

  test('matches governorates through Arabic, transliteration, and abbreviations', () {
    expect(SearchNormalizer.matches('benzart', ['بنزرت']), isTrue);
    expect(SearchNormalizer.matches('tn', ['تونس']), isTrue);
    expect(SearchNormalizer.matches('sfx', ['صفاقس']), isTrue);
    expect(SearchNormalizer.matches('le kef', ['الكاف']), isTrue);
  });

  test('matches equipment aliases across searchable fields', () {
    expect(SearchNormalizer.matches('trax', ['معدات بناء', 'جرافة']), isTrue);
    expect(SearchNormalizer.matches('cam', ['كاميرا مراقبة']), isTrue);
    expect(SearchNormalizer.matches('pelle', ['معدة حفر']), isTrue);
    expect(SearchNormalizer.matches('haut-parleur', ['معدات صوت']), isTrue);
  });
}