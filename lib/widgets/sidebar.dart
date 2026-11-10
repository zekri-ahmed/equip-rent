import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onAdd,
    required this.currentMode,
    required this.onModeChanged,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final String currentMode; // 'renter' or 'owner'
  final ValueChanged<String> onModeChanged;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  UserProfile? currentUser;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await SupabaseService.instance.getCurrentUser();
      if (mounted) {
        setState(() {
          currentUser = user;
          isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingUser = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Container(
        width: 260,
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Switcher
            _buildModeSwitcher(),
            const SizedBox(height: 20),

            // User Info Card
            if (!isLoadingUser && currentUser != null) _buildUserInfo(),
            const SizedBox(height: 16),

            // Navigation list
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (widget.currentMode == 'renter') ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        '\u0627\u0644\u0627\u0633\u062A\u0643\u0634\u0627\u0641',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildNavItem(
                      index: 0,
                      icon: Icons.explore,
                      label: '\u0627\u0633\u062A\u0643\u0634\u0641 \u0627\u0644\u0645\u0639\u062F\u0627\u062A',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.bookmark_outline,
                      label: context.l10n.favorites,
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.chat_bubble_outline,
                      label: context.l10n.messages,
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        '\u0625\u062F\u0627\u0631\u0629 \u0627\u0644\u0645\u0639\u062F\u0627\u062A',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildNavItem(
                      index: 0,
                      icon: Icons.inventory_2_outlined,
                      label: context.l10n.myEquipment,
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.trending_up,
                      label: context.l10n.analytics,
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Icons.chat_bubble_outline,
                      label: context.l10n.messages,
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      '\u0627\u0644\u062D\u0633\u0627\u0628',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    index: 4,
                    icon: Icons.settings_outlined,
                    label: context.l10n.settings,
                  ),
                ],
              ),
            ),

            // Add button (for owner mode)
            if (widget.currentMode == 'owner')
              FilledButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addEquipment),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onModeChanged('renter'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: widget.currentMode == 'renter'
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.explore,
                      size: 18,
                      color: Color(0xFF6200EE),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.explore,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: widget.currentMode == 'renter'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: widget.currentMode == 'renter'
                            ? const Color(0xFF6200EE)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onModeChanged('owner'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: widget.currentMode == 'owner'
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.manage_accounts,
                      size: 18,
                      color: Color(0xFF6200EE),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.owner,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: widget.currentMode == 'owner'
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: widget.currentMode == 'owner'
                            ? const Color(0xFF6200EE)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6200EE).withValues(alpha: 0.2)),

      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF6200EE),
            child: Text(
              (currentUser?.fullName.isNotEmpty == true
                      ? currentUser!.fullName[0]
                      : '\u0645')
                  .toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser?.fullName.isNotEmpty == true
                      ? currentUser!.fullName
                      : '\u0645\u0633\u062A\u062E\u062F\u0645 Rento',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = widget.selected == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSelected ? const Color(0xFFF0EDFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? const Color(0xFF6200EE) : Colors.grey.shade600,
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF6200EE) : Colors.black87,
              fontSize: 13,
            ),
          ),
          selected: isSelected,
          selectedTileColor: const Color(0xFFF0EDFF),
          onTap: () => widget.onSelect(index),
        ),
      ),
    );
  }
}


