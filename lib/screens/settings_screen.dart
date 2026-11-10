import 'package:flutter/material.dart';

import '../models/equipment.dart';
import '../models/user_profile.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/language_controller.dart';
import '../services/supabase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? user;
  List<EquipmentItem> myItems = [];
  bool isLoading = true;
  bool isLoadingItems = false;
  bool isSaving = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfile();
    _loadMyItems();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _syncFormFromUser() {
    final currentUser = user ?? UserProfile(
      id: SupabaseService.instance.currentUserId ?? 'user',
      email: SupabaseService.instance.currentUserEmail ?? 'user@rento.tn',
      fullName: '\u0645\u0633\u062A\u062E\u062F\u0645 Rento',
      phone: '+216 00 000 000',
      city: '\u062A\u0648\u0646\u0633',
      walletBalance: 0,
    );

    _fullNameController.text = currentUser.fullName;
    _phoneController.text = currentUser.phone;
    _cityController.text = currentUser.city;
    _emailController.text = currentUser.email;
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    try {
      final loaded = await SupabaseService.instance
          .getCurrentUser()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (mounted) {
        setState(() {
          user = loaded ?? UserProfile(
            id: SupabaseService.instance.currentUserId ?? 'user',
            email: SupabaseService.instance.currentUserEmail ?? 'user@rento.tn',
            fullName: '\u0645\u0633\u062A\u062E\u062F\u0645 Rento',
            phone: '+216 00 000 000',
            city: '\u062A\u0648\u0646\u0633',
            walletBalance: 0,
          );
          isLoading = false;
        });
        _syncFormFromUser();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      if (mounted) {
        setState(() {
          user = UserProfile(
            id: SupabaseService.instance.currentUserId ?? 'user',
            email: SupabaseService.instance.currentUserEmail ?? 'user@rento.tn',
            fullName: '\u0645\u0633\u062A\u062E\u062F\u0645 Rento',
            phone: '+216 00 000 000',
            city: '\u062A\u0648\u0646\u0633',
            walletBalance: 0,
          );
          isLoading = false;
        });
        _syncFormFromUser();
      }
    }
  }

  Future<void> _loadMyItems() async {
    if (!mounted) return;
    setState(() => isLoadingItems = true);
    try {
      final items = await SupabaseService.instance.fetchMyItems();
      if (mounted) {
        setState(() => myItems = items);
      }
    } catch (_) {
      if (mounted) {
        setState(() => myItems = const []);
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingItems = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final updatedUser = UserProfile(
      id: user?.id ?? SupabaseService.instance.currentUserId ?? 'user',
      email: _emailController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      role: user?.role ?? 'renter',
      walletBalance: user?.walletBalance ?? 0,
      avatarUrl: user?.avatarUrl,
    );

    try {
      if (SupabaseService.instance.ready) {
        await SupabaseService.instance.updateUserProfile(
          fullName: updatedUser.fullName,
          phone: updatedUser.phone,
          city: updatedUser.city,
        );
      }

      if (mounted) {
        setState(() => user = updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('\u062A\u0645 \u062D\u0641\u0638 \u0627\u0644\u062A\u063A\u064A\u064A\u0631\u0627\u062A \u0628\u0646\u062C\u0627\u062D')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('\u062A\u0639\u0630\u0651\u0631 \u062D\u0641\u0638 \u0627\u0644\u062A\u063A\u064A\u064A\u0631\u0627\u062A: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C'),
        content: const Text('\u0647\u0644 \u0623\u0646\u062A \u0645\u062A\u0623\u0643\u062F \u0645\u0646 \u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C \u0645\u0646 \u0627\u0644\u062A\u0637\u0628\u064A\u0642\u061F'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('\u0625\u0644\u063A\u0627\u0621')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('\u062E\u0631\u0648\u062C')),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final compact = MediaQuery.sizeOf(context).width < 600;
    final pagePadding = EdgeInsets.symmetric(
      horizontal: compact ? 16.0 : 20.0,
      vertical: 12.0,
    );

    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: pagePadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.profile,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6200EE),
                    fontSize: compact ? 24 : 30,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 16.0 : 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.personalInformation,
                            style: TextStyle(
                              fontSize: compact ? 18 : 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _fullNameController,
                            label: context.l10n.fullName,
                            icon: Icons.person_outline,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0627\u0644\u0627\u0633\u0645 \u0627\u0644\u0643\u0627\u0645\u0644'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _phoneController,
                            label: context.l10n.phoneNumber,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062A\u0641'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _cityController,
                            label: context.l10n.cityRegion,
                            icon: Icons.location_on_outlined,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0627\u0644\u0645\u062F\u064A\u0646\u0629 \u0623\u0648 \u0627\u0644\u0645\u0646\u0637\u0642\u0629'
                                    : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _emailController,
                            label: context.l10n.email,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0627\u0644\u0628\u0631\u064A\u062F \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A';
                              }
                              if (!value.contains('@')) {
                                return '\u064A\u0631\u062C\u0649 \u0625\u062F\u062E\u0627\u0644 \u0628\u0631\u064A\u062F \u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A \u0635\u0627\u0644\u062D';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: isSaving ? null : _saveProfile,
                              icon: isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(isSaving ? context.l10n.saving : context.l10n.saveChanges),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLanguageSelector(context),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: Color(0xFF6200EE)),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.myEquipment,
                      style: TextStyle(
                        fontSize: compact ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (isLoadingItems)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (myItems.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        context.l10n.noPublishedEquipment,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: myItems.map((item) {
                      return SizedBox(
                        width: compact ? double.infinity : 260,
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: item.available
                                            ? const Color(0xFFE8F5E9)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        item.available ? '\u0645\u062A\u0627\u062D\u0629' : '\u063A\u064A\u0631 \u0645\u062A\u0627\u062D\u0629',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: item.available ? Colors.green.shade800 : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${item.price.toStringAsFixed(0)} \u062F.\u062A / \u064A\u0648\u0645',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6200EE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 28),
                Card(
                  elevation: 1,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C \u0645\u0646 \u0627\u0644\u062D\u0633\u0627\u0628', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    subtitle: const Text('\u0625\u0646\u0647\u0627\u0621 \u0627\u0644\u062C\u0644\u0633\u0629 \u0627\u0644\u062D\u0627\u0644\u064A\u0629 \u0648\u0627\u0644\u0639\u0648\u062F\u0629 \u0644\u0635\u0641\u062D\u0629 \u0627\u0644\u062F\u062E\u0648\u0644'),
                    onTap: _handleLogout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final controller = LanguageController.instance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          initialValue: controller.languageCode,
          decoration: InputDecoration(
            labelText: context.l10n.language,
            prefixIcon: const Icon(Icons.language),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [
            DropdownMenuItem(value: 'ar', child: Text(context.l10n.arabic)),
            DropdownMenuItem(value: 'fr', child: Text(context.l10n.french)),
            DropdownMenuItem(value: 'en', child: Text(context.l10n.english)),
          ],
          onChanged: (value) {
            if (value != null) controller.setLanguage(value);
          },
        ),
      ),
    );
  }
}
