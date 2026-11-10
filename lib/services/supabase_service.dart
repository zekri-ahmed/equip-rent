import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/equipment.dart';
import '../models/rental.dart';
import '../models/user_profile.dart';
import '../models/lead_unlock.dart';
import '../models/wallet_transaction.dart';

class SupabaseService {
  SupabaseService._();
  static final instance = SupabaseService._();
  SupabaseClient? get client => Supabase.instance.client;

  bool get ready {
    try {
      return Supabase.instance.client.auth.currentSession != null ||
          Supabase.instance.client.rest.url.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String? get currentUserId => client?.auth.currentUser?.id;
  String? get currentUserEmail => client?.auth.currentUser?.email;

  // ==================== AUTH & USER PROFILE (SELF-HEALING) ====================
  Future<UserProfile?> ensureCurrentUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (!ready || client?.auth.currentUser == null) return null;

    final authUser = client!.auth.currentUser!;
    try {
      final existing = await client!
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (existing == null) {
        final metadata = authUser.userMetadata ?? <String, dynamic>{};
        final userEmail = (authUser.email ?? '').trim().toLowerCase();
        final insertData = {
          'id': authUser.id,
          'email': authUser.email ?? '',
          'full_name':
              fullName ?? metadata['full_name'] ?? metadata['name'] ?? '',
          'phone': phone ?? metadata['phone'] ?? '',
          'avatar_url': avatarUrl ?? metadata['avatar_url'] ?? '',
          'role': userEmail == 'ahmedzekri20666202@gmail.com'
              ? 'admin'
              : 'renter',
          'wallet_balance': 10.0,
        };

        await client!.from('users').insert(insertData);
        final created = await client!
            .from('users')
            .select()
            .eq('id', authUser.id)
            .maybeSingle();
        if (created != null) return UserProfile.fromJson(created);
      } else {
        return UserProfile.fromJson(existing);
      }
    } catch (e) {
      debugPrint('Self-healing profile check exception: $e');
    }

    return getCurrentUser();
  }

  Future<UserProfile?> getCurrentUser() async {
    if (!ready || currentUserId == null) return null;
    try {
      final user = await client!
          .from('users')
          .select()
          .eq('id', currentUserId!)
          .maybeSingle();
      if (user != null) return UserProfile.fromJson(user);
      return await ensureCurrentUserProfile();
    } catch (_) {
      return null;
    }
  }

  Future<UserProfile?> fetchUserById(String userId) async {
    if (!ready) return null;
    try {
      final user = await client!
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      return UserProfile.fromJson(user);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUserProfile({
    required String fullName,
    required String phone,
    String? city,
    String? avatarUrl,
  }) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');

    // Ensure profile row exists first
    await ensureCurrentUserProfile();

    final updateData = <String, dynamic>{'full_name': fullName, 'phone': phone};
    if (city != null) updateData['city'] = city;
    if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

    await client!.from('users').update(updateData).eq('id', currentUserId!);
  }

  // ==================== ITEMS / EQUIPMENT ====================
  Future<List<EquipmentItem>> fetchItems({bool availableOnly = false}) async {
    if (!ready) return const [];
    try {
      var query = client!.from('items').select();
      if (availableOnly) query = query.eq('is_available', true);
      final rows = await query.order('created_at', ascending: false);
      return (rows as List).map((row) => EquipmentItem.fromJson(row)).toList();
    } catch (e) {
      debugPrint('Error fetching items from Supabase: $e');
      return const [];
    }
  }

  Future<List<EquipmentItem>> fetchMyItems() async {
    if (!ready || currentUserId == null) return const [];
    try {
      final rows = await client!
          .from('items')
          .select()
          .eq('owner_id', currentUserId!)
          .order('created_at', ascending: false);
      return rows.map((row) => EquipmentItem.fromJson(row)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<EquipmentItem?> fetchItemById(String itemId) async {
    if (!ready) return null;
    try {
      final row = await client!
          .from('items')
          .select()
          .eq('id', itemId)
          .single();
      return EquipmentItem.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  Future<EquipmentItem> createItem({
    required String title,
    required String category,
    required String location,
    required double pricePerDay,
    required String description,
    String? imageUrl,
    List<String>? imageUrls,
  }) async {
    if (!ready || currentUserId == null) {
      throw Exception('Authentication required to add a listing');
    }

    // Validate FK constraint: ensure public.users row exists before insertion
    final profile = await ensureCurrentUserProfile();
    if (profile == null) {
      throw Exception('Could not prepare your user profile');
    }

    final urls = _consolidateImageUrls(imageUrls, imageUrl);
    final encodedImages = urls.isNotEmpty ? jsonEncode(urls) : null;

    final itemData = <String, dynamic>{
      'owner_id': currentUserId!,
      'title': title,
      'category': category,
      'location': location,
      'description': description,
      'image_url': encodedImages,
    };

    final row = await client!
        .from('items')
        .insert({
          ...itemData,
          'price_per_day': pricePerDay,
          'is_available': true,
        })
        .select()
        .single();
    return EquipmentItem.fromJson(row);
  }

  List<String> _consolidateImageUrls(
    List<String>? imageUrls,
    String? imageUrl,
  ) {
    final images = <String>[];

    void addImage(String? value) {
      final image = value?.trim();
      if (image != null && image.isNotEmpty && !images.contains(image)) {
        images.add(image);
      }
    }

    for (final image in imageUrls ?? const <String>[]) {
      addImage(image);
    }
    addImage(imageUrl);
    return images;
  }

  Future<void> updateItem({
    required String itemId,
    required String title,
    required String category,
    required String location,
    required double pricePerDay,
    required String description,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');

    final itemData = <String, dynamic>{
      'title': title,
      'category': category,
      'location': location,
      'description': description,
    };

    if (imageUrl != null) {
      itemData['image_url'] = jsonEncode(_consolidateImageUrls(null, imageUrl));
    }

    await client!
        .from('items')
        .update({
          ...itemData,
          'price_per_day': pricePerDay,
          'is_available': ?isAvailable,
        })
        .eq('id', itemId);
  }

  Future<void> deleteItem(String itemId) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');
    await client!.from('items').delete().eq('id', itemId);
  }

  Future<void> toggleItemAvailability(String itemId, bool available) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');
    await client!
        .from('items')
        .update({'is_available': available})
        .eq('id', itemId);
  }

  // ==================== RENTALS / BOOKINGS ====================
  Future<void> createRental({
    required EquipmentItem item,
    required DateTime start,
    required DateTime end,
    required double total,
  }) async {
    if (!ready || currentUserId == null) {
      throw Exception('Authentication required to submit a rental request');
    }

    await ensureCurrentUserProfile();

    // Deduct total booking price from renter's wallet balance
    await deductFromWallet(
      total,
      WalletTransactionType.unlock,
      itemId: item.id,
    );

    final insertData = <String, dynamic>{
      'item_id': item.id,
      'renter_id': currentUserId!,
      'owner_id': item.ownerId,
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
      'total_price': total,
      'total': total,
      'status': 'pending',
    };

    try {
      await client!.from('rentals').insert(insertData);
    } catch (e) {
      debugPrint(
        'Warning inserting rental into public.rentals: $e. Retrying fallback columns.',
      );
      try {
        final fallback = <String, dynamic>{
          'item_id': item.id,
          'renter_id': currentUserId!,
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
          'total_price': total,
          'status': 'pending',
        };
        await client!.from('rentals').insert(fallback);
      } catch (e2) {
        debugPrint('Rental database table fallback handled gracefully: $e2');
      }
    }
  }

  Future<List<Rental>> fetchMyRentals() async {
    if (!ready || currentUserId == null) return const [];
    try {
      final rows = await client!
          .from('rentals')
          .select('*, items(title)')
          .eq('renter_id', currentUserId!)
          .order('created_at', ascending: false);
      return rows
          .map(
            (row) =>
                Rental.fromJson({...row, 'item_title': row['items']?['title']}),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<Rental>> fetchIncomingRentals() async {
    if (!ready || currentUserId == null) return const [];
    try {
      final rows = await client!
          .from('rentals')
          .select(
            '*, items!inner(title, owner_id), users!renter_id(full_name, phone)',
          )
          .eq('items.owner_id', currentUserId!)
          .order('created_at', ascending: false);
      return rows
          .map(
            (row) => Rental.fromJson({
              ...row,
              'item_title': row['items']?['title'],
              'renter_name': row['users']?['full_name'],
              'renter_phone': row['users']?['phone'],
            }),
          )
          .toList();
    } catch (e) {
      // Fallback query if relation syntax varies
      try {
        final rows = await client!
            .from('rentals')
            .select()
            .order('created_at', ascending: false);
        return rows.map((r) => Rental.fromJson(r)).toList();
      } catch (_) {
        return const [];
      }
    }
  }

  Future<void> updateRentalStatus(String rentalId, String newStatus) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');
    await client!
        .from('rentals')
        .update({'status': newStatus})
        .eq('id', rentalId);
  }

  // ==================== LEAD UNLOCKS & WALLET ====================
  Future<bool> isLeadUnlocked(String itemId) async {
    if (!ready || currentUserId == null) return false;
    try {
      final result = await client!
          .from('lead_unlocks')
          .select()
          .eq('renter_id', currentUserId!)
          .eq('item_id', itemId)
          .maybeSingle();
      return result != null;
    } catch (_) {
      return false;
    }
  }

  Future<LeadUnlock?> unlockLead(String itemId) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');

    // Check wallet balance
    final userProfile = await getCurrentUser();
    if (userProfile == null || userProfile.walletBalance < 5.0) {
      throw Exception('Insufficient balance. Please add credit');
    }

    try {
      // Create lead unlock
      final result = await client!
          .from('lead_unlocks')
          .insert({
            'renter_id': currentUserId!,
            'item_id': itemId,
            'unlocked_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Deduct 5.00 TND from wallet
      await deductFromWallet(5.0, WalletTransactionType.unlock, itemId: itemId);

      return LeadUnlock.fromJson(result);
    } catch (e) {
      throw Exception('Could not unlock contact: $e');
    }
  }

  // ==================== WALLET OPERATIONS ====================
  Future<double> getWalletBalance() async {
    if (!ready || currentUserId == null) return 0.0;
    try {
      final user = await getCurrentUser();
      return user?.walletBalance ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  Future<void> addToWallet({
    required double amount,
    required PaymentMethod paymentMethod,
    required String reference,
  }) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');

    try {
      // Ensure user profile exists
      await ensureCurrentUserProfile();

      // Record transaction
      await client!.from('wallet_transactions').insert({
        'user_id': currentUserId!,
        'type': WalletTransactionType.topup.name,
        'amount': amount,
        'payment_method': paymentMethod.name,
        'reference': reference,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update wallet balance preserving existing balance
      final currentBalance = await getWalletBalance();
      final newBalance = currentBalance + amount;
      await client!
          .from('users')
          .update({'wallet_balance': newBalance})
          .eq('id', currentUserId!);
    } catch (e) {
      throw Exception('Could not add wallet credit: $e');
    }
  }

  Future<void> deductFromWallet(
    double amount,
    WalletTransactionType type, {
    String? itemId,
  }) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');

    try {
      final currentBalance = await getWalletBalance();
      final newBalance = currentBalance - amount;
      if (newBalance < 0) throw Exception('Insufficient balance');

      // Record transaction
      await client!.from('wallet_transactions').insert({
        'user_id': currentUserId!,
        'type': type.name,
        'amount': amount,
        'item_id': itemId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update wallet balance
      await client!
          .from('users')
          .update({'wallet_balance': newBalance})
          .eq('id', currentUserId!);
    } catch (e) {
      throw Exception('Operation failed: $e');
    }
  }

  Future<List<WalletTransaction>> fetchWalletTransactions() async {
    if (!ready || currentUserId == null) return const [];
    try {
      final rows = await client!
          .from('wallet_transactions')
          .select()
          .eq('user_id', currentUserId!)
          .order('created_at', ascending: false)
          .limit(50);
      return rows.map((row) => WalletTransaction.fromJson(row)).toList();
    } catch (_) {
      return const [];
    }
  }

  // ==================== MESSAGES & CHAT ====================
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    if (!ready || currentUserId == null) return const [];
    try {
      final rows = await client!
          .from('messages')
          .select()
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      return const [];
    }
  }

  Future<void> sendMessage({
    required String receiverId,
    required String content,
    String? itemId,
  }) async {
    if (!ready || currentUserId == null) throw Exception('Authentication required');
    await client!.from('messages').insert({
      'sender_id': currentUserId!,
      'receiver_id': receiverId,
      'content': content,
      'item_id': itemId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ==================== SANITIZED IMAGE UPLOAD (NON-BLOCKING) ====================
  Future<String?> uploadImage(Uint8List bytes, String fileName) async {
    if (!ready) {
      debugPrint(
        'Warning: Supabase is unavailable; the image will be stored in the listing.',
      );
      return null;
    }

    // Sanitize filename completely with timestamp
    final cleanPath = '${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      final bucket = client!.storage.from('equipment-images');
      await bucket.uploadBinary(
        cleanPath,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
      );
      return bucket.getPublicUrl(cleanPath);
    } on StorageException catch (error) {
      debugPrint(
        'Warning: image upload failed (equipment-images bucket may be missing or restricted): $error',
      );
      return null;
    } catch (error) {
      debugPrint(
        'Warning: image upload failed; the image will be stored in the listing: $error',
      );
      return null;
    }
  }
}
