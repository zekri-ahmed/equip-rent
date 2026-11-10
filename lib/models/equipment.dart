import 'dart:convert';

import 'package:flutter/material.dart';

class EquipmentItem {
  const EquipmentItem({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.price,
    this.description = '',
    this.ownerId,
    this.ownerPhone,
    this.imageUrl,
    this.imageUrls = const [],
    this.available = true,
    this.createdAt,
    this.icon = Icons.construction,
  });

  final String id;
  final String title;
  final String category;
  final String location;
  final double price;
  final String description;
  final String? ownerId;
  final String? ownerPhone;
  final String? imageUrl;
  final List<String> imageUrls;
  final bool available;
  final DateTime? createdAt;
  final IconData icon;

  List<String> get allImages {
    final images = <String>[];

    void addImage(String? value) {
      final image = value?.trim();
      if (image != null && image.isNotEmpty && !images.contains(image)) {
        images.add(image);
      }
    }

    for (final image in imageUrls) {
      addImage(image);
    }
    addImage(imageUrl);
    return images;
  }

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price_per_day'] ?? 0;
    final bool rawAvailable = json['is_available'] as bool? ?? true;

    final singleUrl = json['image_url']?.toString();
    final urlsList = _decodeStoredImages(singleUrl);
    final ownerPhoneValue = (
      json['owner_phone'] ??
      json['user_phone'] ??
      json['ownerPhone'] ??
      json['userPhone'] ??
      json['owner']?['phone'] ??
      json['owner']?['phone_number'] ??
      json['users']?['phone'] ??
      json['user']?['phone']
    )?.toString();

    return EquipmentItem(
      id: '${json['id'] ?? ''}',
      title: '${json['title'] ?? json['name'] ?? 'Rental equipment'}',
      category: '${json['category'] ?? json['category_name'] ?? 'Equipment'}',
      location: '${json['location'] ?? json['city'] ?? '\u062a\u0648\u0646\u0633'}',
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse('$rawPrice') ?? 0,
      description: '${json['description'] ?? ''}',
      ownerId: json['owner_id']?.toString() ?? json['user_id']?.toString(),
      ownerPhone: ownerPhoneValue,
      imageUrl: urlsList.isNotEmpty ? urlsList.first : singleUrl,
      imageUrls: urlsList,
      available: rawAvailable,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
    );
  }

  static List<String> _decodeStoredImages(String? value) {
    final source = value?.trim();
    if (source == null || source.isEmpty) return const [];

    if (source.startsWith('[')) {
      try {
        final decoded = jsonDecode(source);
        if (decoded is List) {
          return _cleanImages(decoded.map((image) => '$image'));
        }
      } on FormatException {
        // Treat malformed legacy data as a single image below.
      }
    }

    // Base64 data URLs contain a comma after the MIME header, so they must
    // remain intact. Legacy multiple URLs are separated before a new URL.
    if (source.startsWith('data:')) return [source];
    return _cleanImages(source.split(RegExp(r',(?=(?:https?://|data:))')));
  }

  static List<String> _cleanImages(Iterable<String> values) {
    final images = <String>[];
    for (final value in values) {
      final image = value.trim();
      if (image.isNotEmpty && !images.contains(image)) images.add(image);
    }
    return images;
  }

  Map<String, dynamic> toInsertJson(String userId) {
    final images = allImages;
    return {
      'title': title,
      'category': category,
      'location': location,
      'price_per_day': price,
      'description': description,
      'owner_id': userId,
      'image_url': images.isNotEmpty ? jsonEncode(images) : null,
      'is_available': available,
    };
  }
}
