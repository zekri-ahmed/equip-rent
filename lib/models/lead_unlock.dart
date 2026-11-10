class LeadUnlock {
  const LeadUnlock({
    required this.id,
    required this.renterId,
    required this.itemId,
    required this.unlockedAt,
    this.ownerName = '',
    this.ownerPhone = '',
    this.ownerWhatsapp = '',
  });

  final String id;
  final String renterId;
  final String itemId;
  final DateTime unlockedAt;
  final String ownerName;
  final String ownerPhone;
  final String ownerWhatsapp;

  factory LeadUnlock.fromJson(Map<String, dynamic> json) => LeadUnlock(
        id: '${json['id'] ?? ''}',
        renterId: '${json['renter_id'] ?? ''}',
        itemId: '${json['item_id'] ?? ''}',
        unlockedAt: DateTime.parse('${json['unlocked_at'] ?? DateTime.now()}'),
        ownerName: '${json['owner_name'] ?? ''}',
        ownerPhone: '${json['owner_phone'] ?? ''}',
        ownerWhatsapp: '${json['owner_whatsapp'] ?? ''}',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'renter_id': renterId,
        'item_id': itemId,
        'unlocked_at': unlockedAt.toIso8601String(),
        'owner_name': ownerName,
        'owner_phone': ownerPhone,
        'owner_whatsapp': ownerWhatsapp,
      };
}
