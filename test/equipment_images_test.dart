import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:equip_rent_app/models/equipment.dart';

void main() {
  test('loads every image from a JSON image_url array', () {
    final images = <String>[
      'https://cdn.example.com/equipment-1.jpg',
      'data:image/png;base64,Zmlyc3Q=',
      'https://cdn.example.com/equipment-3.jpg',
      'data:image/jpeg;base64,c2Vjb25k',
      'https://cdn.example.com/equipment-5.jpg',
    ];

    final item = EquipmentItem.fromJson({
      'id': 'item-1',
      'title': 'حفارة',
      'category': 'آلات ثقيلة',
      'location': 'تونس',
      'price_per_day': 150,
      'is_available': true,
      'image_url': jsonEncode(images),
    });

    expect(item.allImages, images);
    expect(item.imageUrl, images.first);
    expect(item.imageUrls, images);
  });

  test('serializes all image sources into the sole image_url column', () {
    const images = [
      'https://cdn.example.com/equipment-1.jpg',
      'data:image/png;base64,Zmlyc3Q=',
      'https://cdn.example.com/equipment-3.jpg',
      'https://cdn.example.com/equipment-4.jpg',
      'https://cdn.example.com/equipment-5.jpg',
    ];
    final item = EquipmentItem(
      id: 'item-1',
      title: 'حفارة',
      category: 'آلات ثقيلة',
      location: 'تونس',
      price: 150,
      imageUrls: images,
    );

    final payload = item.toInsertJson('owner-1');
    expect(payload.containsKey('image_urls'), isFalse);
    expect(jsonDecode(payload['image_url'] as String), images);
  });
}
