import 'package:flutter/material.dart';
import '../models/wallet_transaction.dart';
import '../services/supabase_service.dart';

class WalletRechargeModal extends StatefulWidget {
  final double currentBalance;
  final VoidCallback onSuccess;

  const WalletRechargeModal({
    super.key,
    required this.currentBalance,
    required this.onSuccess,
  });

  @override
  State<WalletRechargeModal> createState() => _WalletRechargeModalState();
}

class _WalletRechargeModalState extends State<WalletRechargeModal> {
  int selectedTabIndex = 0;
  double selectedAmount = 10.0;
  bool isLoading = false;

  final d17Controller = TextEditingController();
  final voucherController = TextEditingController();
  final referenceController = TextEditingController();
  final customAmountController = TextEditingController();

  static const List<double> quickAmounts = [10.0, 20.0, 50.0, 100.0];

  @override
  void dispose() {
    d17Controller.dispose();
    voucherController.dispose();
    referenceController.dispose();
    customAmountController.dispose();
    super.dispose();
  }

  Future<void> _processRecharge(PaymentMethod method, String reference) async {
    if (selectedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u064A\u0631\u062C\u0649 \u062A\u062D\u062F\u064A\u062F \u0645\u0628\u0644\u063A \u0635\u062D\u064A\u062D \u0644\u0634\u062D\u0646 \u0627\u0644\u0631\u0635\u064A\u062F')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await SupabaseService.instance.addToWallet(
        amount: selectedAmount,
        paymentMethod: method,
        reference: reference,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 \u062A\u0645 \u0634\u062D\u0646 \u0627\u0644\u0631\u0635\u064A\u062F \u0628\u0646\u062C\u0627\u062D \u0641\u064A \u0645\u062D\u0641\u0638\u062A\u0643!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\u062E\u0637\u0623 \u0641\u064A \u0627\u0644\u0639\u0645\u0644\u064A\u0629: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modern Header
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // Amount Selection Section
                  _buildAmountSelector(),
                  const SizedBox(height: 24),

                  // Payment Method Section
                  _buildPaymentMethodsSection(),
                  const SizedBox(height: 20),

                  // Value Proposition Card
                  _buildValueProposition(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EDFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFF6200EE),
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\u0634\u062D\u0646 \u0631\u0635\u064A\u062F \u0627\u0644\u0645\u062D\u0641\u0638\u0629',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '\u0627\u0644\u0631\u0635\u064A\u062F \u0627\u0644\u062D\u0627\u0644\u064A: ${widget.currentBalance.toStringAsFixed(2)} \u062F.\u062A',
                  style: const TextStyle(
                    color: Color(0xFF6200EE),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.grey),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. \u0627\u062E\u062A\u0631 \u0642\u064A\u0645\u0629 \u0627\u0644\u0634\u062D\u0646',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
          ),
          itemCount: quickAmounts.length,
          itemBuilder: (context, index) {
            final amount = quickAmounts[index];
            final isSelected = selectedAmount == amount && customAmountController.text.isEmpty;

            return InkWell(
              onTap: () {
                setState(() {
                  selectedAmount = amount;
                  customAmountController.clear();
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0EDFF) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6200EE) : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6200EE).withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Color(0xFF6200EE),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        '${amount.toStringAsFixed(0)} \u062F.\u062A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFF6200EE) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: customAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '\u0623\u0648 \u0623\u062F\u062E\u0644 \u0645\u0628\u0644\u063A\u0627\u064B \u0645\u062E\u0635\u0635\u0627\u064B (\u0645\u062B\u0627\u0644: 35)',
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF6200EE), width: 1.5),
            ),
            prefixIcon: const Icon(Icons.edit_note, size: 20, color: Color(0xFF6200EE)),
            suffixText: '\u062F.\u062A ',
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6200EE)),
          ),
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null && parsed > 0) {
              setState(() => selectedAmount = parsed);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. \u0627\u062E\u062A\u0631 \u0637\u0631\u064A\u0642\u0629 \u0627\u0644\u062F\u0641\u0639',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  onTap: (index) => setState(() => selectedTabIndex = index),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  labelColor: const Color(0xFF6200EE),
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_android, size: 16),
                          SizedBox(width: 4),
                          Text('D17 / Flouci'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.confirmation_number_outlined, size: 16),
                          SizedBox(width: 4),
                          Text('\u0643\u0627\u0631\u062A \u0634\u062D\u0646'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt, size: 16),
                          SizedBox(width: 4),
                          Text('RunPay'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentDetailsCard(selectedTabIndex),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsCard(int tabIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: _buildPaymentMethodContent(tabIndex),
    );
  }

  Widget _buildPaymentMethodContent(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: d17Controller,
              decoration: InputDecoration(
                labelText: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062A\u0641 \u0623\u0648 \u0627\u0644\u0628\u0631\u064A\u062F \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A (D17/Flouci)',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: '\u0631\u0642\u0645 \u0645\u0631\u062C\u0639 \u0627\u0644\u062A\u062D\u0648\u064A\u0644 (Reference Number)',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '📲 \u064A\u0631\u062C\u0649 \u062A\u062D\u0648\u064A\u0644 \u0627\u0644\u0645\u0628\u0644\u063A \u0639\u0628\u0631 \u062A\u0637\u0628\u064A\u0642 D17 \u062B\u0645 \u0625\u062F\u062E\u0627\u0644 \u0631\u0642\u0645 \u0627\u0644\u0645\u0631\u062C\u0639 \u0644\u062A\u0623\u0643\u064A\u062F \u0627\u0644\u0625\u064A\u062F\u0627\u0639 \u0641\u064A \u0627\u0644\u062D\u064A\u0646.',
                style: TextStyle(fontSize: 11, color: Colors.blue),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: voucherController,
              maxLength: 14,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '\u0623\u062F\u062E\u0644 \u0631\u0645\u0632 \u0643\u0627\u0631\u062A \u0627\u0644\u0634\u062D\u0646 (12 \u0623\u0648 14 \u0631\u0642\u0645)',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '🎟️ \u0627\u062F\u0639\u0645 \u0643\u0631\u0648\u062A \u0634\u062D\u0646 \u0627\u062A\u0635\u0627\u0644\u0627\u062A \u062A\u0648\u0646\u0633\u060C \u0623\u0648\u0631\u064A\u062F\u0648\u060C \u0648\u0623\u0648\u0631\u0646\u062C. \u064A\u062A\u0645 \u062A\u0641\u0639\u064A\u0644 \u0627\u0644\u0631\u0635\u064A\u062F \u062A\u0644\u0642\u0627\u0626\u064A\u0627\u064B.',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF6200EE), size: 28),
                  const SizedBox(height: 6),
                  const Text(
                    '\u0627\u0644\u062F\u0641\u0639 \u0627\u0644\u0641\u0648\u0631\u064A \u0639\u0628\u0631 \u0634\u0628\u0627\u0628\u064A\u0643 RunPay',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u0633\u064A\u062A\u0645 \u062A\u0648\u0644\u064A\u062F \u0631\u0645\u0632 \u0643\u0648\u062F \u062F\u0641\u0639 \u0644\u0645\u0628\u0644\u063A ${selectedAmount.toStringAsFixed(2)} \u062F.\u062A',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6200EE)),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildValueProposition() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6200EE).withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFF6200EE), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '💡 \u0643\u0644 10 \u062F.\u062A \u062A\u0645\u0646\u062D\u0643 \u0625\u0645\u0643\u0627\u0646\u064A\u0629 \u0627\u0644\u062A\u0648\u0627\u0635\u0644 \u0627\u0644\u0645\u0628\u0627\u0634\u0631 \u0645\u0639 \u0645\u0644\u0627\u0643 \u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0648\u0627\u0644\u0648\u0635\u0648\u0644 \u0644\u0623\u0631\u0642\u0627\u0645\u0647\u0645 \u0639\u0644\u0649 \u0627\u0644\u0648\u0627\u062A\u0633\u0627\u0628 \u0648\u0627\u0644\u0647\u0627\u062A\u0641.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF4A35A6),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('\u0625\u0644\u063A\u0627\u0621'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: isLoading
                ? null
                : () {
                    switch (selectedTabIndex) {
                      case 0:
                        if (d17Controller.text.isEmpty || referenceController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('\u064A\u0631\u062C\u0649 \u0645\u0644\u0621 \u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062A\u0641 \u0648\u0631\u0642\u0645 \u0627\u0644\u0645\u0631\u062C\u0639')),
                          );
                          return;
                        }
                        _processRecharge(PaymentMethod.d17, referenceController.text);
                        break;
                      case 1:
                        if (voucherController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0631\u0645\u0632 \u0643\u0627\u0631\u062A \u0627\u0644\u0634\u062D\u0646')),
                          );
                          return;
                        }
                        _processRecharge(PaymentMethod.voucherRecharge, voucherController.text);
                        break;
                      case 2:
                        _processRecharge(
                          PaymentMethod.runpay,
                          'runpay-${DateTime.now().millisecondsSinceEpoch}',
                        );
                        break;
                    }
                  },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: const Color(0xFF6200EE),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('\u062A\u0623\u0643\u064A\u062F \u0634\u062D\u0646 ${selectedAmount.toStringAsFixed(0)} \u062F.\u062A'),
          ),
        ),
      ],
    );
  }
}
