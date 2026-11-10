import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/equipment.dart';
import '../services/search_service.dart';
import '../services/supabase_service.dart';
import '../widgets/equipment_card.dart';
import 'add_item_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final searchController = TextEditingController();
  final heroSearchController = TextEditingController();
  List<EquipmentItem> items = [];
  List<EquipmentItem> filteredItems = [];
  String selectedRegion = '\u0643\u0644 \u0627\u0644\u0645\u0646\u0627\u0637\u0642';
  bool isLoading = true;

  static const List<String> regions = [
    '\u0643\u0644 \u0627\u0644\u0645\u0646\u0627\u0637\u0642',
    '\u062A\u0648\u0646\u0633',
    '\u0623\u0631\u064A\u0627\u0646\u0629',
    '\u0628\u0646 \u0639\u0631\u0648\u0633',
    '\u0645\u0646\u0648\u0628\u0629',
    '\u0628\u0646\u0632\u0631\u062A',
    '\u0646\u0627\u0628\u0644',
    '\u0632\u063A\u0648\u0627\u0646',
    '\u0628\u0627\u062C\u0629',
    '\u062C\u0646\u062F\u0648\u0628\u0629',
    '\u0627\u0644\u0643\u0627\u0641',
    '\u0633\u0644\u064A\u0627\u0646\u0629',
    '\u0633\u0648\u0633\u0629',
    '\u0627\u0644\u0645\u0646\u0633\u062A\u064A\u0631',
    '\u0627\u0644\u0645\u0647\u062F\u064A\u0629',
    '\u0635\u0641\u0627\u0642\u0633',
    '\u0627\u0644\u0642\u064A\u0631\u0648\u0627\u0646',
    '\u0627\u0644\u0642\u0635\u0631\u064A\u0646',
    '\u0633\u064A\u062F\u064A \u0628\u0648\u0632\u064A\u062F',
    '\u0642\u0627\u0628\u0633',
    '\u0645\u062F\u0646\u064A\u0646',
    '\u062A\u0637\u0627\u0648\u064A\u0646',
    '\u0642\u0641\u0635\u0629',
    '\u062A\u0648\u0632\u0631',
    '\u0642\u0628\u0644\u064A',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
    searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    searchController.dispose();
    heroSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final loaded = await SupabaseService.instance.fetchItems();
      if (mounted) {
        setState(() {
          items = loaded;
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('\u062E\u0637\u0623 \u0641\u064A \u062A\u062D\u0645\u064A\u0644 \u0627\u0644\u0628\u064A\u0627\u0646\u0627\u062A: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _applyFilters() {
    final query = searchController.text;
    setState(() {
      filteredItems = items.where((item) {
        final matchesSearch = SearchNormalizer.matches(query, [
          item.title,
          item.description,
          item.category,
          item.location,
        ]);

        final matchesRegion =
            selectedRegion == '\u0643\u0644 \u0627\u0644\u0645\u0646\u0627\u0637\u0642' ||
            SearchNormalizer.matches(selectedRegion, [item.location]);

        return matchesSearch && matchesRegion;
      }).toList();
    });
  }

  Future<void> _openAddItem() async {
    final result = await showDialog<EquipmentItem>(
      context: context,
      builder: (_) => AddItemScreen(),
    );
    if (result != null && mounted) {
      await _loadItems();
    }
  }

  Future<void> _deleteItem(EquipmentItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('\u062D\u0630\u0641 \u0627\u0644\u0645\u0639\u062F\u0629'),
        content: Text(
          '\u0647\u0644 \u0623\u0646\u062A \u0645\u062A\u0623\u0643\u062F \u0645\u0646 \u062D\u0630\u0641 \u0627\u0644\u0645\u0639\u062F\u0629 "${item.title}"\u061F',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('\u0625\u0644\u063A\u0627\u0621'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('\u062D\u0630\u0641'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService.instance.deleteItem(item.id);
        await _loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('\u062A\u0645 \u062D\u0630\u0641 \u0627\u0644\u0645\u0639\u062F\u0629 \u0628\u0646\u062C\u0627\u062D'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('\u062E\u0637\u0623 \u0641\u064A \u0627\u0644\u062D\u0630\u0641: $e')));
        }
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
                if (!isMobile) ...[
                  _buildDesktopHero(),
                  const SizedBox(height: 32),
                ],
                // Header Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${context.l10n.explore} ${context.l10n.availableEquipment}',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6200EE),
                                  fontSize: isCompact ? 26 : null,
                                ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _openAddItem,
                      style: FilledButton.styleFrom(
                        minimumSize: Size(isCompact ? 48 : 0, 48),
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 12 : 16,
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.addEquipment),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filters
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildFilterDropdown(context.l10n.region, selectedRegion, regions, (
                      value,
                    ) {
                      setState(() => selectedRegion = value);
                      _applyFilters();
                    }),
                    const SizedBox(width: 4),
                    FilledButton.icon(
                      onPressed: _loadItems,
                      icon: const Icon(Icons.refresh),
                      label: Text(context.l10n.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Results info
                Text(
                  '${filteredItems.length} ${context.l10n.availableEquipment}',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Loading state
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredItems.isEmpty)
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
                            context.l10n.noEquipment,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(context.l10n.addFirstEquipment),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _openAddItem,
                            icon: const Icon(Icons.add),
                            label: Text(context.l10n.addEquipment),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isCompact
                          ? 600
                          : (isMobile ? 300 : (width >= 1100 ? 260 : 280)),
                      mainAxisExtent: isCompact ? 400 : 390,
                      crossAxisSpacing: isCompact ? 12 : 16,
                      mainAxisSpacing: isCompact ? 12 : 16,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return EquipmentCard(
                        item: item,
                        showDelete: true,
                        onDelete: () => _deleteItem(item),
                        onTap: () {
                          // Interactive details
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHero() => Container(
    padding: const EdgeInsets.fromLTRB(36, 36, 36, 30),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: const LinearGradient(
        colors: [Color(0xFF6200EE), Color(0xFF8B5CF6)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeBannerTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.homeBannerSubtitle,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: heroSearchController,
                onChanged: (value) => searchController.text = value,
                onSubmitted: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText: context.l10n.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _loadItems,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD300),
                foregroundColor: Colors.black87,
                minimumSize: const Size(132, 54),
              ),
              icon: const Icon(Icons.search),
              label: Text(context.l10n.search),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildFilterDropdown(
    String label,
    String currentValue,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    );
  }
}
