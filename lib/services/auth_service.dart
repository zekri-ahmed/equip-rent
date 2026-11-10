import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_transaction.dart';
import 'supabase_service.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();
  SupabaseClient? get client => SupabaseService.instance.client;

  Future<void> signIn(String email, String password) async {
    if (client == null) throw Exception('Supabase is not connected');
    await client!.auth.signInWithPassword(email: email.trim(), password: password);
    await SupabaseService.instance.ensureCurrentUserProfile();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    if (client == null) throw Exception('Supabase is not connected');
    final normalizedEmail = email.trim();

    try {
      final response = await client!.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'full_name': fullName.trim(),
          'phone': phone.trim(),
        },
      );

      // Supabase may return no session when email confirmation is enabled.
      final user = response.user ?? client!.auth.currentUser;
      if (user != null) {
        await SupabaseService.instance.ensureCurrentUserProfile(
          fullName: fullName,
          phone: phone,
        );

        try {
          await client!.from('wallet_transactions').insert({
            'user_id': user.id,
            'type': WalletTransactionType.topup.name,
            'amount': 10.0,
            'payment_method': PaymentMethod.welcome.name,
            'reference': 'welcome-bonus-signup',
            'description': 'Welcome credit on registration',
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (_) {
          // Profile creation remains successful if transaction logging fails.
        }
      }
      return response.session != null;
    } catch (error) {
      if (_isRateLimitError(error)) {
        throw Exception('Please wait a few seconds before trying again');
      }
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (client == null) throw Exception('Supabase is not connected');
    await client!.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> sendVerificationCode(String email) async {
    if (client == null) throw Exception('Supabase is not connected');
    await client!.auth.signInWithOtp(email: email.trim(), shouldCreateUser: false);
  }

  Future<void> verifyCode({required String email, required String token}) async {
    if (client == null) throw Exception('Supabase is not connected');
    await client!.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.email,
    );
  }

  Future<void> verifyRecoveryCode({required String email, required String token}) async {
    if (client == null) throw Exception('Supabase is not connected');
    await client!.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.recovery,
    );
  }

  Future<void> updatePassword(String password) async {
    if (client == null) throw Exception('Supabase is not connected');
    await client!.auth.updateUser(UserAttributes(password: password));
  }

  bool _isRateLimitError(Object error) {
    if (error is AuthException && error.statusCode == '429') return true;
    final text = error.toString().toLowerCase();
    return text.contains('429') ||
        text.contains('rate limit') ||
        text.contains('too many requests');
  }

  Future<void> signOut() async => client?.auth.signOut();
}
