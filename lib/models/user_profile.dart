class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName = '',
    this.phone = '',
    this.avatarUrl,
    this.city = '',
    this.role = 'renter',
    this.walletBalance = 10.0,
  });

  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final String city;
  final String role;
  final double walletBalance;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: '${json['id'] ?? ''}',
        email: '${json['email'] ?? ''}',
        fullName: '${json['full_name'] ?? json['fullName'] ?? ''}',
        phone: '${json['phone'] ?? ''}',
        avatarUrl: json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
        city: '${json['city'] ?? ''}',
        role: '${json['role'] ?? 'renter'}',
        walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 10.0,
      );

  bool get isAdmin =>
      email.trim().toLowerCase() == 'ahmedzekri20666202@gmail.com' ||
      role == 'admin';

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
        'city': city,
        'role': role,
        'wallet_balance': walletBalance,
      };
}


