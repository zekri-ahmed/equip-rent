import 'package:flutter/material.dart';
import '../models/equipment.dart';
import '../models/rental.dart';
import '../services/supabase_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool isLoading = true;
  List<EquipmentItem> myItems = [];
  List<Rental> incomingRentals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final items = await SupabaseService.instance.fetchMyItems();
      final rentals = await SupabaseService.instance.fetchIncomingRentals();
      if (mounted) {
        setState(() {
          myItems = items;
          incomingRentals = rentals;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  double get totalEarnings {
    double total = 0.0;
    for (final r in incomingRentals) {
      if (r.status == 'accepted' || r.status == 'completed') {
        total += r.total;
      }
    }
    return total;
  }

  int get acceptedCount => incomingRentals.where((r) => r.status == 'accepted' || r.status == 'completed').length;
  int get pendingCount => incomingRentals.where((r) => r.status == 'pending').length;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 850;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              '\u0627\u0644\u0625\u062D\u0635\u0627\u0626\u064A\u0627\u062A \u0648\u0627\u0644\u0623\u062F\u0627\u0621',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6200EE),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '\u0645\u0644\u062E\u0635 \u0627\u0644\u0623\u0631\u0628\u0627\u062D \u0648\u0627\u0644\u062D\u062C\u0648\u0632\u0627\u062A \u0644\u0645\u0639\u062F\u0627\u062A\u0643 \u0627\u0644\u0643\u0631\u0627\u0626\u064A\u0629',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 28),

            // Top Stat Cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  title: '\u0625\u062C\u0645\u0627\u0644\u064A \u0627\u0644\u0623\u0631\u0628\u0627\u062D',
                  value: '${totalEarnings.toStringAsFixed(2)} \u062F.\u062A',
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.green.shade700,
                  bgColor: Colors.green.shade50,
                  width: isMobile ? double.infinity : 260,
                ),
                _buildStatCard(
                  title: '\u0627\u0644\u062D\u062C\u0648\u0632\u0627\u062A \u0627\u0644\u0645\u0624\u0643\u062F\u0629',
                  value: '$acceptedCount',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF6200EE),
                  bgColor: const Color(0xFFF0EDFF),
                  width: isMobile ? double.infinity : 260,
                ),
                _buildStatCard(
                  title: '\u0637\u0644\u0628\u0627\u062A \u0642\u064A\u062F \u0627\u0644\u0627\u0646\u062A\u0638\u0627\u0631',
                  value: '$pendingCount',
                  icon: Icons.hourglass_top,
                  color: Colors.orange.shade800,
                  bgColor: Colors.orange.shade50,
                  width: isMobile ? double.infinity : 260,
                ),
                _buildStatCard(
                  title: '\u0639\u062F\u062F \u0627\u0644\u0645\u0639\u062F\u0627\u062A',
                  value: '${myItems.length}',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue.shade700,
                  bgColor: Colors.blue.shade50,
                  width: isMobile ? double.infinity : 260,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Distribution Card & Equipment Performance
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '\u0623\u0641\u0636\u0644 \u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0637\u0644\u0628\u0627\u064B',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (myItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('\u0644\u0627 \u062A\u0648\u062C\u062F \u0628\u064A\u0627\u0646\u0627\u062A \u0645\u062A\u0627\u062D\u0629 \u062D\u0627\u0644\u064A\u0627\u064B')),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: myItems.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {

                          final item = myItems[index];
                          final itemRentals = incomingRentals.where((r) => r.itemId == item.id).length;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF0EDFF),
                              child: Icon(item.icon, color: const Color(0xFF6200EE)),
                            ),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${item.price.toStringAsFixed(0)} \u062F.\u062A / \u064A\u0648\u0645 • ${item.location}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$itemRentals \u062D\u062C\u0632', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6200EE))),
                                Text(item.available ? '\u0645\u062A\u0627\u062D\u0629' : '\u0645\u0639\u0637\u0644\u0629', style: TextStyle(fontSize: 11, color: item.available ? Colors.green : Colors.red)),
                              ],
                            ),
                          );
                        },
                      ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
