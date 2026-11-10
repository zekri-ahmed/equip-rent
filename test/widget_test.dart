// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:equip_rent_app/models/equipment.dart';
import 'package:equip_rent_app/screens/item_details_modal.dart';

void main() {
  testWidgets('equipment details show direct contact actions without booking flow',
      (WidgetTester tester) async {
    final item = EquipmentItem(
      id: 'item-1',
      title: 'حفارة كهربائية',
      category: 'معدات',
      location: 'تونس',
      price: 25,
      description: 'معدة ممتازة',
      ownerId: 'owner-1',
      imageUrl: 'https://example.com/item.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ItemDetailsModal(item: item),
      ),
    );

    expect(find.text('حفارة كهربائية'), findsWidgets);
    expect(find.text('اتصال مباشر'), findsOneWidget);
    expect(find.text('تواصل عبر واتساب'), findsOneWidget);
    expect(find.text('إكراء الآن'), findsNothing);
    expect(find.text('تأكيد وإرسال الطلب'), findsNothing);
  });
}
