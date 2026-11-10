import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import 'wallet_recharge_modal.dart';


class RentalDialog extends StatefulWidget {
  const RentalDialog({super.key, required this.item});

  final EquipmentItem item;

  @override
  State<RentalDialog> createState() => _RentalDialogState();
}

class _RentalDialogState extends State<RentalDialog> {
  DateTime startDate = DateTime.now().add(const Duration(days: 1));
  DateTime endDate = DateTime.now().add(const Duration(days: 3));
  bool isSubmitting = false;
  UserProfile? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SupabaseService.instance.getCurrentUser();
    if (mounted) {
      setState(() => currentUser = user);
    }
  }

  int get rentalDays {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get totalPrice => rentalDays * widget.item.price;

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    if (picked != null && mounted) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (currentUser == null) {
      final user = await SupabaseService.instance.getCurrentUser();
      if (!mounted) return;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u064A\u0631\u062C\u0649 \u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062F\u062E\u0648\u0644 \u0644\u0637\u0644\u0628 \u0627\u0644\u0643\u0631\u0627\u0621')),
        );
        return;
      }
      currentUser = user;
    }


    if ((currentUser?.walletBalance ?? 0) < totalPrice) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => WalletRechargeModal(
            currentBalance: currentUser!.walletBalance,
            onSuccess: _loadUser,
          ),
        );
      }
      return;
    }

    setState(() => isSubmitting = true);
    try {
      await SupabaseService.instance.createRental(
        item: widget.item,
        start: startDate,
        end: endDate,
        total: totalPrice,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 \u062A\u0645 \u0625\u0631\u0633\u0627\u0644 \u0637\u0644\u0628 \u0627\u0644\u0643\u0631\u0627\u0621 \u0628\u0646\u062C\u0627\u062D \u0648\u062E\u0635\u0645 \u0627\u0644\u0645\u0628\u0644\u063A \u0645\u0646 \u0645\u062D\u0641\u0638\u062A\u0643!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('\u062E\u0637\u0623 \u0641\u064A \u062A\u0642\u062F\u064A\u0645 \u0627\u0644\u0637\u0644\u0628: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.key, color: Color(0xFF6200EE), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '\u0637\u0644\u0628 \u0643\u0631\u0627\u0621: ${widget.item.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Item info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.item.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.agriculture),
                            ),
                          ),

                        )
                      else
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EDFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.agriculture, color: Color(0xFF6200EE)),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 ${widget.item.location} • 🏷️ ${widget.item.category}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.item.price.toStringAsFixed(0)} \u062F.\u062A / \u064A\u0648\u0645',
                              style: const TextStyle(
                                color: Color(0xFF6200EE),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Date Picker trigger
                Text(
                  '\u0641\u062A\u0631\u0629 \u0627\u0644\u0643\u0631\u0627\u0621',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF6200EE)),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF0EDFF),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF6200EE)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${startDate.day}/${startDate.month}/${startDate.year}  ⬅  ${endDate.day}/${endDate.month}/${endDate.year}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '\u0645\u062F\u0629 \u0627\u0644\u0643\u0631\u0627\u0621: $rentalDays \u064A\u0648\u0645',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF6200EE)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pricing Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('\u0633\u0639\u0631 \u0627\u0644\u064A\u0648\u0645:'),
                          Text('${widget.item.price.toStringAsFixed(0)} \u062F.\u062A'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('\u0639\u062F\u062F \u0627\u0644\u0623\u064A\u0627\u0645:'),
                          Text('$rentalDays \u0623\u064A\u0627\u0645'),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('\u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A \u0627\u0644\u0643\u0644\u064A:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            '${totalPrice.toStringAsFixed(2)} \u062F.\u062A',
                            style: const TextStyle(
                              color: Color(0xFF6200EE),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : () => Navigator.pop(context, false),
                        child: const Text('\u0625\u0644\u063A\u0627\u0621'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: isSubmitting ? null : _submitBooking,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('\u062A\u0623\u0643\u064A\u062F \u0648\u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0637\u0644\u0628'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
