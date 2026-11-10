import 'dart:convert';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../l10n/app_localizations.dart';
import '../models/equipment.dart';
import '../services/supabase_service.dart';

class PickedImageData {
  final Uint8List bytes;
  final String name;

  PickedImageData({required this.bytes, required this.name});
}

class _EncodedImageData {
  const _EncodedImageData({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final title = TextEditingController();
  final location = TextEditingController();
  final price = TextEditingController();
  final description = TextEditingController();
  String category = '\u0623\u062F\u0648\u0627\u062A \u0648\u062A\u062C\u0647\u064A\u0632\u0627\u062A \u0639\u0627\u0645\u0629';
  List<PickedImageData> pickedImages = [];
  bool busy = false;

  @override
  void dispose() {
    title.dispose();
    location.dispose();
    price.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;

      final newPicks = <PickedImageData>[];
      for (final file in files) {
        final bytes = await file.readAsBytes();
        newPicks.add(PickedImageData(bytes: bytes, name: file.name));
      }

      if (mounted) {
        setState(() {
          pickedImages.addAll(newPicks);
        });
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  void removeImage(int index) {
    setState(() {
      pickedImages.removeAt(index);
    });
  }

  Future<void> submit() async {
    final amount = double.tryParse(price.text.replaceAll(',', '.'));
    if (title.text.trim().isEmpty ||
        location.text.trim().isEmpty ||
        amount == null ||
        amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('\u0623\u0643\u0645\u0644 \u0627\u0633\u0645 \u0627\u0644\u0645\u0639\u062F\u0629 \u0648\u0627\u0644\u0645\u0648\u0642\u0639 \u0648\u0627\u0644\u0633\u0639\u0631 \u0628\u0634\u0643\u0644 \u0635\u062D\u064A\u062D'),
        ),
      );
      return;
    }

    setState(() => busy = true);
    try {
      // Keep exactly one persisted reference for every selected file. A
      // rejected Storage upload (including RLS 403) is stored inline instead
      // of silently removing that photo from the listing.
      final allImageStrings = <String>[];
      for (final img in pickedImages) {
        allImageStrings.add(await _uploadOrEncodeImage(img));
      }

      final item = await SupabaseService.instance.createItem(
        title: title.text.trim(),
        category: category,
        location: location.text.trim(),
        pricePerDay: amount,
        description: description.text.trim(),
        imageUrl: allImageStrings.isNotEmpty ? allImageStrings.first : null,
        imageUrls: allImageStrings,
      );

      if (mounted) {
        Navigator.pop<EquipmentItem>(context, item);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('\u062A\u0639\u0630\u0631 \u0646\u0634\u0631 \u0627\u0644\u0625\u0639\u0644\u0627\u0646: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  Future<String> _asBase64DataUrl(PickedImageData image) async {
    final compressedImage = _compressForBase64(image);
    return 'data:${compressedImage.mimeType};base64,'
        '${base64Encode(compressedImage.bytes)}';
  }

  _EncodedImageData _compressForBase64(PickedImageData source) {
    final decoded = img.decodeImage(source.bytes);
    if (decoded == null) {
      // Preserve an unsupported image instead of dropping it. The common
      // JPEG/PNG/WebP cases below are resized and compressed as expected.
      return _EncodedImageData(
        bytes: source.bytes,
        mimeType: _sourceMimeType(source.name),
      );
    }

    var maxDimension = math.max(decoded.width, decoded.height);
    var resized = decoded;
    if (maxDimension > 800) {
      final scale = 800 / maxDimension;
      resized = img.copyResize(
        decoded,
        width: math.max(1, (decoded.width * scale).round()),
        height: math.max(1, (decoded.height * scale).round()),
        interpolation: img.Interpolation.average,
      );
      maxDimension = 800;
    }

    var encoded = Uint8List.fromList(img.encodeJpg(resized, quality: 70));
    // Keep Base64 payloads near 150 KB even for highly detailed photos. The
    // quality remains 70%; only the already-bounded dimensions step down.
    while (encoded.length > 110 * 1024 && maxDimension > 320) {
      maxDimension = math.max(320, (maxDimension * 0.8).round());
      final scale = maxDimension / math.max(decoded.width, decoded.height);
      resized = img.copyResize(
        decoded,
        width: math.max(1, (decoded.width * scale).round()),
        height: math.max(1, (decoded.height * scale).round()),
        interpolation: img.Interpolation.average,
      );
      encoded = Uint8List.fromList(img.encodeJpg(resized, quality: 70));
    }

    return _EncodedImageData(bytes: encoded, mimeType: 'image/jpeg');
  }

  String _sourceMimeType(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/png',
    };
  }

  Future<String> _uploadOrEncodeImage(PickedImageData image) async {
    try {
      final uploadedUrl = await SupabaseService.instance.uploadImage(
        image.bytes,
        image.name,
      );
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        return uploadedUrl;
      }
    } catch (error) {
      // `uploadImage` normally absorbs Storage errors, but this also protects
      // the selected image if a future upload implementation throws directly.
      debugPrint('Storage upload failed; using Base64 fallback: $error');
    }

    return _asBase64DataUrl(image);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: Localizations.localeOf(context).languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: AlertDialog(
        title: const Text('\u0623\u0636\u0641 \u0645\u0639\u062F\u0629 \u062C\u062F\u064A\u062F\u0629 \u0644\u0644\u062A\u0623\u062C\u064A\u0631'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: '\u0627\u0633\u0645 \u0627\u0644\u0645\u0639\u062F\u0629',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: '\u0627\u0644\u0641\u0626\u0629',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      const [
                            '\u0623\u062F\u0648\u0627\u062A \u0648\u062A\u062C\u0647\u064A\u0632\u0627\u062A \u0639\u0627\u0645\u0629',
                            '\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A\u0627\u062A \u0648\u062A\u0635\u0648\u064A\u0631',
                            '\u0625\u0636\u0627\u0621\u0629 \u0648\u0645\u0639\u062F\u0627\u062A \u0635\u0648\u062A\u064A\u0629',
                            '\u0645\u0639\u062F\u0627\u062A \u0641\u0644\u0627\u062D\u064A\u0629',
                            '\u0622\u0644\u0627\u062A \u0648\u0645\u0639\u062F\u0627\u062A \u062B\u0642\u064A\u0644\u0629',
                            '\u0648\u0633\u0627\u0626\u0644 \u0646\u0642\u0644 \u0648\u0644\u0648\u062C\u0633\u062A\u064A\u0643',
                            '\u0623\u062E\u0631\u0649',
                          ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => category = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: location,
                  decoration: const InputDecoration(
                    labelText: '\u0627\u0644\u0645\u0648\u0642\u0639 / \u0627\u0644\u0645\u062F\u064A\u0646\u0629 (\u0645\u062B\u0627\u0644: \u0628\u0646\u0632\u0631\u062A\u060C \u062A\u0648\u0646\u0633)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: '\u0627\u0644\u0633\u0639\u0631 \u0627\u0644\u064A\u0648\u0645\u064A (\u062F.\u062A)',
                    border: OutlineInputBorder(),
                    suffixText: '\u062F.\u062A / \u064A\u0648\u0645',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '\u0648\u0635\u0641 \u0627\u0644\u0645\u0639\u062F\u0629 \u0648\u0627\u0644\u0645\u0648\u0627\u0635\u0641\u0627\u062A',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Multiple Images Picker Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '\u0635\u0648\u0631 \u0627\u0644\u0645\u0639\u062F\u0629 (\u064A\u0645\u0643\u0646\u0643 \u0627\u062E\u062A\u064A\u0627\u0631 \u0639\u062F\u0629 \u0635\u0648\u0631)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : pickImages,
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text(context.l10n.addImages),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (pickedImages.isEmpty)
                  Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '\u0644\u0645 \u064A\u062A\u0645 \u0627\u062E\u062A\u064A\u0627\u0631 \u0623\u064A \u0635\u0648\u0631\u0629 \u0628\u0639\u062F',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: pickedImages.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final img = pickedImages[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                img.bytes,
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              left: 4,
                              child: InkWell(
                                onTap: () => removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: const Text('\u0625\u0644\u063A\u0627\u0621'),
          ),
          FilledButton(
            onPressed: busy ? null : submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6200EE),
            ),
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('\u0646\u0634\u0631 \u0627\u0644\u0625\u0639\u0644\u0627\u0646'),
          ),
        ],
      ),
    );
  }
}
