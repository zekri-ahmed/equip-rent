enum WalletTransactionType {
  topup,
  unlock,
  refund,
  admin;

  String get label {
    switch (this) {
      case WalletTransactionType.topup:
        return 'Wallet top-up';
      case WalletTransactionType.unlock:
        return 'Contact unlock';
      case WalletTransactionType.refund:
        return 'Refund';
      case WalletTransactionType.admin:
        return 'Administrative transaction';
    }
  }
}

enum PaymentMethod {
  d17,
  voucherRecharge,
  runpay,
  welcome;

  String get label {
    switch (this) {
      case PaymentMethod.d17:
        return 'D17 / Sobflous / Flouci';
      case PaymentMethod.voucherRecharge:
        return 'Cash recharge cards';
      case PaymentMethod.runpay:
        return 'Fast transfer (RunPay)';
      case PaymentMethod.welcome:
        return 'Welcome credit';
    }
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.paymentMethod = PaymentMethod.welcome,
    this.reference = '',
    this.description = '',
    this.itemId,
  });

  final String id;
  final String userId;
  final WalletTransactionType type;
  final double amount;
  final DateTime createdAt;
  final PaymentMethod paymentMethod;
  final String reference;
  final String description;
  final String? itemId;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final typeStr = '${json['type'] ?? 'topup'}'.toLowerCase();
    final methodStr = '${json['payment_method'] ?? 'welcome'}'.toLowerCase();

    return WalletTransaction(
      id: '${json['id'] ?? ''}',
      userId: '${json['user_id'] ?? ''}',
      type: WalletTransactionType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr,
        orElse: () => WalletTransactionType.topup,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse('${json['created_at'] ?? DateTime.now()}'),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name.toLowerCase() == methodStr,
        orElse: () => PaymentMethod.welcome,
      ),
      reference: '${json['reference'] ?? ''}',
      description: '${json['description'] ?? ''}',
      itemId: json['item_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'amount': amount,
        'created_at': createdAt.toIso8601String(),
        'payment_method': paymentMethod.name,
        'reference': reference,
        'description': description,
        'item_id': itemId,
      };
}
