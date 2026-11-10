import 'package:flutter/material.dart';

import '../models/equipment.dart';
import '../services/supabase_service.dart';
import 'add_item_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  List<EquipmentItem> myItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyItems();
  }

  Future<void> _loadMyItems() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final loaded = await SupabaseService.instance.fetchMyItems();
      if (mounted) {
        setState(() => myItems = loaded);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('\u062E\u0637\u0623 \u0641\u064A \u062A\u062D\u0645\u064A\u0644 \u0627\u0644\u0645\u0639\u062F\u0627\u062A: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _openAddItemDialog() async {
    final result = await showDialog<EquipmentItem>(
      context: context,
      builder: (_) => const AddItemScreen(),
    );
    if (result != null && mounted) {
      setState(() => myItems = [result, ...myItems]);
      await _loadMyItems();
    }
  }

  Future<void> _toggleAvailability(EquipmentItem item, bool newStatus) async {
    try {
      await SupabaseService.instance.toggleItemAvailability(item.id, newStatus);
      await _loadMyItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? '\u062A\u0645 \u062A\u0641\u0639\u064A\u0644 \u0627\u0644\u0645\u0639\u062F\u0629 \u0628\u0646\u062C\u0627\u062D' : '\u062A\u0645 \u0625\u064A\u0642\u0627\u0641 \u0627\u0644\u0645\u0639\u062F\u0629 \u0628\u0646\u062C\u0627\u062D',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      // Optimistic state fallback if Supabase table schema differs
      if (mounted) {
        setState(() {
          myItems = myItems.map((e) {
            if (e.id == item.id) {
              return EquipmentItem(
                id: e.id,
                title: e.title,
                category: e.category,
                location: e.location,
                price: e.price,
                description: e.description,
                ownerId: e.ownerId,
                imageUrl: e.imageUrl,
                imageUrls: e.imageUrls,
                available: newStatus,
                createdAt: e.createdAt,
              );
            }
            return e;
          }).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus ? '\u062A\u0645 \u062A\u0641\u0639\u064A\u0644 \u0627\u0644\u0645\u0639\u062F\u0629 \u0645\u062D\u0644\u064A\u0627\u064B' : '\u062A\u0645 \u0625\u064A\u0642\u0627\u0641 \u0627\u0644\u0645\u0639\u062F\u0629 \u0645\u062D\u0644\u064A\u0627\u064B',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(EquipmentItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('\u062D\u0630\u0641 \u0627\u0644\u0645\u0639\u062F\u0629'),
        content: const Text('\u0647\u0644 \u0623\u0646\u062A \u0645\u062A\u0623\u0643\u062F \u0645\u0646 \u062D\u0630\u0641 \u0647\u0630\u0647 \u0627\u0644\u0645\u0639\u062F\u0629\u061F'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('\u0625\u0644\u063A\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('\u062D\u0630\u0641'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService.instance.deleteItem(item.id);
        await _loadMyItems();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('\u062A\u0645 \u062D\u0630\u0641 \u0627\u0644\u0645\u0639\u062F\u0629 \u0628\u0646\u062C\u0627\u062D')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('\u062E\u0637\u0623: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 850;

    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\u0645\u0633\u0627\u062D\u0629 \u0627\u0644\u0645\u0627\u0644\u0643',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6200EE),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\u0623\u062F\u0631 \u0645\u0639\u062F\u0627\u062A\u0643 \u0648\u0627\u0628\u062F\u0623 \u0641\u064A \u0627\u0644\u0643\u0631\u0627\u0621',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _openAddItemDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('\u0623\u0636\u0641 \u0645\u0639\u062F\u0629 \u062C\u062F\u064A\u062F\u0629'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Stats
                Row(
                  children: [
                    _buildStatCard(
                      '\u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0627\u0644\u0643\u0644\u064A\u0629',
                      '${myItems.length}',
                      Icons.inventory_2_outlined,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '\u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0627\u0644\u0645\u062A\u0627\u062D\u0629',
                      '${myItems.where((e) => e.available).length}',
                      Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      '\u0627\u0644\u0645\u0639\u062F\u0627\u062A \u0627\u0644\u0645\u0639\u0637\u0644\u0629',
                      '${myItems.where((e) => !e.available).length}',
                      Icons.pause_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // My Equipment Grid
                Text(
                  '\u0645\u0639\u062F\u0627\u062A\u064A',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (myItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '\u0644\u0627 \u062A\u0648\u062C\u062F \u0645\u0639\u062F\u0627\u062A',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          const Text('\u0627\u0628\u062F\u0623 \u0628\u0625\u0636\u0627\u0641\u0629 \u0645\u0639\u062F\u0629 \u062C\u062F\u064A\u062F\u0629'),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isMobile ? 250 : 400,
                      mainAxisExtent: isMobile ? 320 : 400,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: myItems.length,
                    itemBuilder: (context, index) {
                      final item = myItems[index];
                      return _buildOwnerItemCard(item);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF6200EE)),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6200EE),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerItemCard(EquipmentItem item) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                item.imageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            )
          else
            Container(
              height: 140,
              color: Colors.grey.shade200,
              child: Icon(
                Icons.construction,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(0)} \u062F.\u062A / \u064A\u0648\u0645',
                    style: const TextStyle(
                      color: Color(0xFF6200EE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: FilterChip(
                          label: Text(
                            item.available ? '\u0645\u062A\u0627\u062D\u0629' : '\u0645\u0639\u0637\u0644\u0629',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: item.available
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          labelStyle: TextStyle(
                            color: item.available
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                          onSelected: (_) {
                            _toggleAvailability(item, !item.available);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteItem(item),
                    icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                    label: const Text(
                      '\u062D\u0630\u0641',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
