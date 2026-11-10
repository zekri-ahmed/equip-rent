class Rental {
  const Rental({
    required this.id,
    required this.itemId,
    required this.renterId,
    this.ownerId,
    required this.itemTitle,
    this.renterName = '',
    this.renterPhone = '',
    required this.startDate,
    required this.endDate,
    required this.total,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String itemId;
  final String renterId;
  final String? ownerId;
  final String itemTitle;
  final String renterName;
  final String renterPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double total;
  final String status;
  final DateTime? createdAt;

  factory Rental.fromJson(Map<String, dynamic> json) => Rental(
        id: '${json['id'] ?? ''}',
        itemId: '${json['item_id'] ?? json['itemId'] ?? ''}',
        renterId: '${json['renter_id'] ?? json['renterId'] ?? ''}',
        ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString(),
        itemTitle: '${json['item_title'] ?? json['items']?['title'] ?? json['item']?['title'] ?? 'Equipment booking'}',
        renterName: '${json['renter_name'] ?? json['users']?['full_name'] ?? json['renter']?['full_name'] ?? 'Renter'}',
        renterPhone: '${json['renter_phone'] ?? json['users']?['phone'] ?? json['renter']?['phone'] ?? ''}',
        startDate: DateTime.tryParse('${json['start_date'] ?? json['startDate']}') ?? DateTime.now(),
        endDate: DateTime.tryParse('${json['end_date'] ?? json['endDate']}') ?? DateTime.now(),
        total: (json['total_price'] as num?)?.toDouble() ?? (json['total'] as num?)?.toDouble() ?? 0,
        status: '${json['status'] ?? 'pending'}',
        createdAt: json['created_at'] != null ? DateTime.tryParse('${json['created_at']}') : null,
      );
}

