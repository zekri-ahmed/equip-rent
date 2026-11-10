import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/equipment.dart';
import '../services/supabase_service.dart';
import '../screens/item_details_modal.dart';

class EquipmentCard extends StatefulWidget {
  const EquipmentCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onDelete,
    this.showDelete = true,
  });

  final EquipmentItem item;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

  @override
  State<EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<EquipmentCard> {
  static const _placeholderImageUrl =
      'https://placehold.co/1200x800/e5e7eb/6b7280?text=No+image';

  bool canDelete = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final currentUserId = SupabaseService.instance.currentUserId;
    final currentUser = await SupabaseService.instance.getCurrentUser();

    final bool isOwner =
        currentUserId != null &&
        widget.item.ownerId != null &&
        widget.item.ownerId == currentUserId;
    final bool isAdmin =
        (currentUser?.email.trim().toLowerCase() ==
            'ahmedzekri20666202@gmail.com') ||
        (currentUser?.isAdmin == true);

    if (mounted) {
      setState(() {
        canDelete = isOwner || isAdmin;
      });
    }
  }

  Future<void> _openItemDetails() async {
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    if (isCompact) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            ItemDetailsModal(item: widget.item, isBottomSheet: true),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => ItemDetailsModal(item: widget.item),
    );
  }

  Widget _buildCardImage() {
    // Prefer the first Supabase gallery image, then retain compatibility with
    // records that only have the legacy single-image field.
    final images = _itemImages;
    final primaryUrl = images.isNotEmpty ? images.first : null;

    return _buildImageSource(primaryUrl ?? _placeholderImageUrl);
  }

  List<String> _validImageUrls(Iterable<String> urls) =>
      urls.map((url) => url.trim()).where((url) => url.isNotEmpty).toList();

  List<String> get _itemImages => _validImageUrls(widget.item.allImages);

  Widget _buildImageSource(String source, {bool isPlaceholder = false}) {
    if (!source.startsWith('http')) {
      try {
        final encoded = source.contains(',') ? source.split(',').last : source;
        return Image.memory(
          base64Decode(encoded),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => isPlaceholder
              ? _imageErrorPlaceholder()
              : _buildImageSource(_placeholderImageUrl, isPlaceholder: true),
        );
      } catch (_) {
        return isPlaceholder
            ? _imageErrorPlaceholder()
            : _buildImageSource(_placeholderImageUrl, isPlaceholder: true);
      }
    }

    return _networkImage(source, isPlaceholder: isPlaceholder);
  }

  Widget _networkImage(String imageUrl, {bool isPlaceholder = false}) =>
      Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ColoredBox(
            color: Color(0xFFF3F4F6),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => isPlaceholder
            ? _imageErrorPlaceholder()
            : _buildImageSource(_placeholderImageUrl, isPlaceholder: true),
      );

  Widget _imageErrorPlaceholder() => const ColoredBox(
    color: Color(0xFFE5E7EB),
    child: Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF6B7280),
        size: 32,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final imagesCount = _itemImages.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _openItemDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic Image Container with height 180
            SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCardImage(),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '🔥 ${context.l10n.availableForRent}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (imagesCount > 0)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.ltr,
                          children: [
                            Text(
                              '$imagesCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.photo_camera_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Item Details Body
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDFF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.item.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4A35A6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(
                            ' 4.8',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.item.location,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.item.price.toStringAsFixed(0)} ${context.l10n.tr('currency')} / ${context.l10n.perDay}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6200EE),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Actions are handled through the direct-contact detail dialog only.
            if (canDelete && widget.onDelete != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton.outlined(
                    onPressed: widget.onDelete,
                    tooltip: context.l10n.delete,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
