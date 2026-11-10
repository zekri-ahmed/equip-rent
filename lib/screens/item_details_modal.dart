import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/equipment.dart';
import '../services/supabase_service.dart';

class ItemDetailsModal extends StatefulWidget {
  final EquipmentItem item;
  final bool isBottomSheet;

  const ItemDetailsModal({
    super.key,
    required this.item,
    this.isBottomSheet = false,
  });

  @override
  State<ItemDetailsModal> createState() => _ItemDetailsModalState();
}

class _ItemDetailsModalState extends State<ItemDetailsModal> {
  static const _placeholderImageUrl =
      'https://placehold.co/1200x800/e5e7eb/6b7280?text=No+image';

  int currentImageIndex = 0;
  final PageController pageController = PageController();
  String _resolvedOwnerPhone = '';
  String _ownerName = '';
  bool _isResolvingOwner = false;

  @override
  void initState() {
    super.initState();
    _resolvedOwnerPhone = (widget.item.ownerPhone ?? '').trim();
    _resolveOwnerContact();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ownerName.isEmpty) {
      _ownerName = context.l10n.ownerEquipment;
    }
  }

  Future<void> _resolveOwnerContact() async {
    final itemPhone = (widget.item.ownerPhone ?? '').trim();
    if (itemPhone.isNotEmpty) {
      setState(() {
        _resolvedOwnerPhone = itemPhone;
      });
      return;
    }

    final ownerId = widget.item.ownerId;
    if (ownerId == null || ownerId.isEmpty) return;

    setState(() => _isResolvingOwner = true);
    try {
      final ownerProfile = await SupabaseService.instance.fetchUserById(ownerId);
      final phone = (ownerProfile?.phone ?? '').trim();
      if (!mounted) return;
      setState(() {
        _resolvedOwnerPhone = phone;
        _ownerName = ownerProfile?.fullName.isNotEmpty == true
            ? ownerProfile!.fullName
            : context.l10n.ownerEquipment;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resolvedOwnerPhone = '';
      });
    } finally {
      if (mounted) {
        setState(() => _isResolvingOwner = false);
      }
    }
  }

  String get _effectiveOwnerPhone => _resolvedOwnerPhone.trim();

  Future<void> _launchPhoneCall() async {
    final phone = _effectiveOwnerPhone;
    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noPhone)),
      );
      return;
    }

    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.phoneOpenFailed)),
      );
    }
  }

  Future<void> _launchWhatsApp() async {
    final phone = _effectiveOwnerPhone;
    if (phone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noWhatsapp)),
      );
      return;
    }

    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappNumber = digits.startsWith('216') ? digits : '216$digits';
    final uri = Uri.parse('https://wa.me/$whatsappNumber');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.whatsappOpenFailed)),
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // All image sources (Storage URLs and local Base64 data URLs) flow through
    // the model's consolidated list in a stable order.
    final images = _galleryImages;
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return Directionality(
        textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: _modalFrame(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: widget.isBottomSheet ? double.infinity : 780,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Carousel / Header
                _buildImageCarousel(
                  images,
                  height: isCompact ? 360 : 400,
                  showDesktopControls: !isCompact,
                ),

                // Main Details Body
                Padding(
                  padding: EdgeInsets.all(isCompact ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Rating Row
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EDFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.item.category,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6200EE),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  '4.9',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title & Price Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${widget.item.price.toStringAsFixed(0)} ${context.l10n.tr('currency')}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF6200EE),
                                ),
                              ),
                              Text(
                                context.l10n.perDay,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location Badges
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF6200EE),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.item.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.verified_user_outlined,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.verifiedOwner,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // Specifications & Description
                      Text(
                        context.l10n.detailsAndSpecifications,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item.description.isNotEmpty
                            ? widget.item.description
                            : '\u0645\u0639\u062F\u0629 \u0645\u0645\u062A\u0627\u0632\u0629 \u0648\u0645\u0635\u0627\u0646\u0629 \u0628\u0627\u0644\u0643\u0627\u0645\u0644\u060C \u062C\u0627\u0647\u0632\u0629 \u0644\u0644\u062A\u0623\u062C\u064A\u0631 \u0627\u0644\u0641\u0648\u0631\u064A \u0645\u0639 \u0625\u0645\u0643\u0627\u0646\u064A\u0629 \u0627\u0644\u062A\u0648\u0635\u064A\u0644 \u0644\u0645\u0648\u0642\u0639 \u0627\u0644\u0639\u0645\u0644 \u062D\u0633\u0628 \u0627\u0644\u0627\u062A\u0641\u0627\u0642.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Owner Contact Box
                      _buildOwnerContactCard(),
                      const SizedBox(height: 28),

                      // Direct contact actions only
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _launchPhoneCall,
                              icon: const Icon(Icons.phone, size: 18),
                              label: Text(
                                context.l10n.directCall,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFF16A34A)),
                                foregroundColor: const Color(0xFF15803D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _launchWhatsApp,
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: Text(
                                context.l10n.whatsappContact,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _modalFrame({required Widget child}) {
    if (widget.isBottomSheet) {
      return FractionallySizedBox(
        heightFactor: 0.92,
        child: Material(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: child,
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildImageCarousel(
    List<String> images, {
    required double height,
    required bool showDesktopControls,
  }) {
    final itemCount = images.isEmpty ? 1 : images.length;
    return ColoredBox(
      color: const Color(0xFF1F2937),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            child: ClipRect(
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: itemCount,
                    onPageChanged: (index) =>
                        setState(() => currentImageIndex = index),
                    itemBuilder: (context, index) {
                      final imageUrl = images.isEmpty
                          ? _placeholderImageUrl
                          : images[index];
                      return _buildImageSource(
                        imageUrl,
                        height: height,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.55),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  if (images.length > 1) ...[
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _galleryCounter(images.length),
                    ),
                    if (showDesktopControls) ...[
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _galleryArrow(
                            icon: Icons.chevron_right,
                            onTap: currentImageIndex < images.length - 1
                                ? _nextImage
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _galleryArrow(
                            icon: Icons.chevron_left,
                            onTap: currentImageIndex > 0
                                ? _previousImage
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (images.length > 1) ...[
            const SizedBox(height: 8),
            _buildDotIndicators(images.length),
            const SizedBox(height: 8),
            _buildThumbnailStrip(images),
          ],
        ],
      ),
    );
  }

  Widget _galleryArrow({
    required IconData icon,
    required VoidCallback? onTap,
  }) => Directionality(
    textDirection: TextDirection.ltr,
    child: CircleAvatar(
      backgroundColor: Colors.white.withValues(
        alpha: onTap == null ? 0.35 : 0.85,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.black87),
        tooltip: icon == Icons.chevron_right ? 'Next image' : 'Previous image',
      ),
    ),
  );

  Widget _buildDotIndicators(int count) => SizedBox(
    height: 12,
    child: _centeredHorizontalRow(
      children: List.generate(
        count,
        (index) => Semantics(
          button: true,
          label: '\u0627\u0644\u0635\u0648\u0631\u0629 ${index + 1}',
          child: InkWell(
            onTap: () => _goToImage(index),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 7,
              width: index == currentImageIndex ? 18 : 7,
              decoration: BoxDecoration(
                color: index == currentImageIndex
                    ? Colors.white
                    : Colors.white54,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildThumbnailStrip(List<String> images) => Container(
    height: 76,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    child: _centeredHorizontalRow(
      children: [
        for (var index = 0; index < images.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          InkWell(
            onTap: () => _goToImage(index),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: index == currentImageIndex
                      ? const Color(0xFFFFD300)
                      : Colors.white38,
                  width: index == currentImageIndex ? 2 : 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildImageSource(
                images[index],
                height: 58,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _centeredHorizontalRow({required List<Widget> children}) =>
      LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: children,
            ),
          ),
        ),
      );

  Widget _galleryCounter(int count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      '${currentImageIndex + 1} / $count',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  void _goToImage(int index) => pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
  );

  void _nextImage() => pageController.nextPage(
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
  );

  void _previousImage() => pageController.previousPage(
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
  );

  List<String> get _galleryImages => widget.item.allImages;

  Widget _buildImageSource(
    String source, {
    double? height,
    BoxFit fit = BoxFit.contain,
    bool isPlaceholder = false,
  }) {
    if (!source.startsWith('http')) {
      try {
        final encoded = source.contains(',') ? source.split(',').last : source;
        return Image.memory(
          base64Decode(encoded),
          width: double.infinity,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => isPlaceholder
              ? _imageErrorPlaceholder()
              : _buildImageSource(
                  _placeholderImageUrl,
                  height: height,
                  fit: fit,
                  isPlaceholder: true,
                ),
        );
      } catch (_) {
        return isPlaceholder
            ? _imageErrorPlaceholder()
            : _buildImageSource(
                _placeholderImageUrl,
                height: height,
                fit: fit,
                isPlaceholder: true,
              );
      }
    }

    return _networkImage(
      source,
      height: height,
      fit: fit,
      isPlaceholder: isPlaceholder,
    );
  }

  Widget _networkImage(
    String imageUrl, {
    double? height,
    BoxFit fit = BoxFit.contain,
    bool isPlaceholder = false,
  }) => Image.network(
    imageUrl,
    width: double.infinity,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return const ColoredBox(
        color: Color(0xFFF3F4F6),
        child: Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) => isPlaceholder
        ? _imageErrorPlaceholder()
        : _buildImageSource(
            _placeholderImageUrl,
            height: height,
            fit: fit,
            isPlaceholder: true,
          ),
  );

  Widget _imageErrorPlaceholder() => const ColoredBox(
    color: Color(0xFFE5E7EB),
    child: Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFF6B7280),
        size: 38,
      ),
    ),
  );

  Widget _buildOwnerContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF16A34A),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.ownerName,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _ownerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.directPhone,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _effectiveOwnerPhone.isEmpty
                          ? (_isResolvingOwner ? context.l10n.loadingPhone : context.l10n.unavailable)
                          : _effectiveOwnerPhone,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
