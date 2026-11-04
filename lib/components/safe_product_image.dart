import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SafeProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final Widget? fallback;

  const SafeProductImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.fallback,
  }) : super(key: key);

  Widget _defaultFallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF14563C).withOpacity(0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.medication_rounded,
        size: (height != null ? (height! * 0.4).clamp(24.0, 60.0) : 36.0),
        color: const Color(0xFF14563C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final raw = imageUrl?.trim() ?? '';
    Widget imageContent;

    if (raw.isEmpty) {
      imageContent = fallback ?? _defaultFallback();
    } else if (raw.startsWith('data:image') ||
        (!raw.startsWith('http://') &&
            !raw.startsWith('https://') &&
            raw.length > 100)) {
      try {
        final cleanBase64 = raw.contains(',') ? raw.split(',').last : raw;
        final Uint8List bytes = base64Decode(cleanBase64);
        imageContent = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          errorBuilder: (_, __, ___) => fallback ?? _defaultFallback(),
        );
      } catch (_) {
        imageContent = fallback ?? _defaultFallback();
      }
    } else if (kIsWeb) {
      imageContent = Image.network(
        raw,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => fallback ?? _defaultFallback(),
        loadingBuilder: (ctx, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFE0E0E0),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
          );
        },
      );
    } else {
      imageContent = CachedNetworkImage(
        imageUrl: raw,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        errorWidget: (_, __, ___) => fallback ?? _defaultFallback(),
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: const Color(0xFFE0E0E0),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    }

    return imageContent;
  }
}
