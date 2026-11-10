import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/wallet_recharge_modal.dart';

class WalletInfoWidget extends StatefulWidget {
  final VoidCallback? onBalanceUpdated;

  const WalletInfoWidget({
    super.key,
    this.onBalanceUpdated,
  });

  @override
  State<WalletInfoWidget> createState() => _WalletInfoWidgetState();
}

class _WalletInfoWidgetState extends State<WalletInfoWidget> {
  double walletBalance = 0.0;
  // Keep the app bar interactive even if the profile request is slow.
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final user = await SupabaseService.instance
          .getCurrentUser()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (mounted) {
        setState(() {
          walletBalance = user?.walletBalance ?? 0.0;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _openRechargeModal() async {
    await showDialog(
      context: context,
      builder: (_) => WalletRechargeModal(
        currentBalance: walletBalance,
        onSuccess: () {
          _loadWalletBalance();
          widget.onBalanceUpdated?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: GestureDetector(
        onTap: _openRechargeModal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EDFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6200EE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: Color(0xFF6200EE),
              ),
              const SizedBox(width: 6),
              Text(
                '${walletBalance.toStringAsFixed(2)} TND',
                style: const TextStyle(
                  color: Color(0xFF6200EE),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.add_circle_outline,
                size: 14,
                color: Color(0xFF6200EE),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
