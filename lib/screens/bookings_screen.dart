import 'package:flutter/material.dart';
import '../models/rental.dart';
import '../services/supabase_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key, this.isOwnerMode = false});

  final bool isOwnerMode;

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Rental> incomingBookings = [];
  List<Rental> myBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.isOwnerMode ? 0 : 1);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => isLoading = true);
    try {
      final incoming = await SupabaseService.instance.fetchIncomingRentals();
      final my = await SupabaseService.instance.fetchMyRentals();
      if (mounted) {
        setState(() {
          incomingBookings = incoming;
          myBookings = my;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateStatus(Rental booking, String status) async {
    try {
      await SupabaseService.instance.updateRentalStatus(booking.id, status);
      await _loadBookings();
      if (mounted) {
        final label = status == 'accepted' ? '\u0642\u0628\u0648\u0644' : '\u0631\u0641\u0636';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u062A\u0645 $label \u0627\u0644\u0637\u0644\u0628 \u0628\u0646\u062C\u0627\u062D'), backgroundColor: status == 'accepted' ? Colors.green : Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u062E\u0637\u0623: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 768;
    final isCompact = width < 600;

    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isCompact ? 16 : (isMobile ? 20 : 32)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u0625\u062F\u0627\u0631\u0629 \u0627\u0644\u062D\u062C\u0648\u0632\u0627\u062A',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6200EE),
                                fontSize: isCompact ? 26 : null,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\u062A\u0627\u0628\u0639 \u0637\u0644\u0628\u0627\u062A \u0627\u0644\u0643\u0631\u0627\u0621 \u0627\u0644\u0642\u0627\u062F\u0645\u0629 \u0648\u0627\u0644\u0645\u0642\u062F\u0645\u0629',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _loadBookings,
                      icon: const Icon(Icons.refresh),
                      tooltip: '\u062A\u062D\u062F\u064A\u062B \u0627\u0644\u062D\u062C\u0648\u0632\u0627\u062A',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tabs
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '\u0627\u0644\u062D\u062C\u0648\u0632\u0627\u062A \u0627\u0644\u0648\u0627\u0631\u062F\u0629 (${incomingBookings.length})'),
                    Tab(text: '\u062D\u062C\u0648\u0632\u0627\u062A\u064A (${myBookings.length})'),
                  ],
                ),
                const SizedBox(height: 20),

                // Content
                SizedBox(
                  height: 600,
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildIncomingList(),
                            _buildMyBookingsList(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingList() {
    if (incomingBookings.isEmpty) {
      return _buildEmptyState('\u0644\u0627 \u062A\u0648\u062C\u062F \u062D\u062C\u0648\u0632\u0627\u062A \u0648\u0627\u0631\u062F\u0629 \u0644\u0645\u0639\u062F\u0627\u062A\u0643 \u062D\u0627\u0644\u064A\u0627\u064B');
    }
    return ListView.builder(
      itemCount: incomingBookings.length,
      itemBuilder: (context, index) {
        final item = incomingBookings[index];
        return _buildRentalCard(item, isIncoming: true);
      },
    );
  }

  Widget _buildMyBookingsList() {
    if (myBookings.isEmpty) {
      return _buildEmptyState('\u0644\u0645 \u062A\u0642\u0645 \u0628\u0623\u064A \u0637\u0644\u0628 \u062D\u062C\u0632 \u0645\u0639\u062F\u0627\u062A \u0628\u0639\u062F');
    }
    return ListView.builder(
      itemCount: myBookings.length,
      itemBuilder: (context, index) {
        final item = myBookings[index];
        return _buildRentalCard(item, isIncoming: false);
      },
    );
  }

  Widget _buildRentalCard(Rental rental, {required bool isIncoming}) {
    Color statusColor;
    String statusText;
    switch (rental.status) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = '\u0645\u0642\u0628\u0648\u0644';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = '\u0645\u0631\u0641\u0648\u0636';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = '\u0645\u0643\u062A\u0645\u0644';
        break;
      default:
        statusColor = Colors.orange;
        statusText = '\u0642\u064A\u062F \u0627\u0644\u0627\u0646\u062A\u0638\u0627\u0631';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Color(0xFF6200EE)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    rental.itemTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📅 \u0645\u0646 ${rental.startDate.day}/${rental.startDate.month}/${rental.startDate.year} \u0625\u0644\u0649 ${rental.endDate.day}/${rental.endDate.month}/${rental.endDate.year}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    if (isIncoming && rental.renterName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '👤 \u0627\u0644\u0637\u0627\u0644\u0628: ${rental.renterName} (${rental.renterPhone.isNotEmpty ? rental.renterPhone : '\u063A\u064A\u0631 \u0645\u062A\u0648\u0641\u0631'})',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${rental.total.toStringAsFixed(2)} \u062F.\u062A',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF6200EE),
                  ),
                ),
              ],
            ),
            if (isIncoming && rental.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _updateStatus(rental, 'rejected'),
                    icon: const Icon(Icons.close, color: Colors.red, size: 18),
                    label: const Text('\u0631\u0641\u0636 \u0627\u0644\u0637\u0644\u0628', style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => _updateStatus(rental, 'accepted'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('\u0642\u0628\u0648\u0644 \u0627\u0644\u0637\u0644\u0628'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }
}
