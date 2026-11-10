import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/equipment.dart';
import '../services/supabase_service.dart';
import '../widgets/equipment_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<EquipmentItem> favoriteItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);
    try {
      final items = await SupabaseService.instance.fetchItems();
      if (mounted) {
        setState(() {
          favoriteItems = items.take(2).toList();
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
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
                Text(
                  context.l10n.favorites,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6200EE),
                        fontSize: isCompact ? 26 : null,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.savedEquipmentDescription,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (favoriteItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(Icons.bookmark_outline, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(context.l10n.noFavorites, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isMobile ? 220 : 320,
                      mainAxisExtent: isMobile ? 300 : 390,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: favoriteItems.length,
                    itemBuilder: (context, index) {
                      return EquipmentCard(
                        item: favoriteItems[index],
                        onTap: () {},
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
}

