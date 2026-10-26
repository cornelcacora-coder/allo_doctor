import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AvatarImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const AvatarImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rawUrl = imageUrl?.trim() ?? '';
    if (rawUrl.isEmpty) {
      return placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: Icon(
              Icons.person,
              size: (width != null ? width! * 0.5 : 24.0),
              color: Colors.white,
            ),
          );
    }

    // Support for Base64 Data URI or raw Base64 string
    final isBase64 = rawUrl.startsWith('data:image') ||
        (!rawUrl.startsWith('http://') &&
            !rawUrl.startsWith('https://') &&
            rawUrl.length > 100);

    if (isBase64) {
      try {
        final cleanBase64 =
            rawUrl.contains(',') ? rawUrl.split(',').last : rawUrl;
        final Uint8List bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) =>
              placeholder ??
              Icon(
                Icons.person,
                size: (width != null ? width! * 0.5 : 24.0),
              ),
        );
      } catch (_) {
        // Fallback if base64 decode fails
      }
    }

    // Standard HTTP / HTTPS network image
    return CachedNetworkImage(
      imageUrl: rawUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      errorWidget: (_, __, ___) =>
          placeholder ??
          Icon(
            Icons.person,
            size: (width != null ? width! * 0.5 : 24.0),
          ),
      placeholder: (_, __) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
          ),
    );
  }
}
