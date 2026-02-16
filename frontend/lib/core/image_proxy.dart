import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/constants.dart';

/// Converts a Cloudinary URL to go through our backend proxy.
/// The emulator can't reach Cloudinary directly, but it can reach our backend.
/// Our backend fetches the image from Cloudinary and sends it to the app.
String getProxyImageUrl(String originalUrl) {
  return '${apiBaseUrl}api/Sites/proxy-image?url=${Uri.encodeComponent(originalUrl)}';
}

/// Gets the first image URL from imageUrls list returned by the API.
/// Returns null if there are no images.
String? getFirstImageUrl(dynamic imageUrls) {
  if (imageUrls == null) return null;

  if (imageUrls is List && imageUrls.isNotEmpty) {
    String? first = imageUrls.first?.toString();
    if (first != null && first.isNotEmpty) return first;
  }

  return null;
}

/// A simple image widget that loads images through our backend proxy.
/// Shows a grey box while loading, and a broken icon if it fails.
class ProxyImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadiusValue;

  const ProxyImage({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.borderRadiusValue = 8,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL, show placeholder icon
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    // Load image through backend proxy
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      child: Image.network(
        getProxyImageUrl(imageUrl!),
        width: width,
        height: height,
        fit: BoxFit.cover,

        // While image is downloading, show grey box with spinner
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child; // done loading
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },

        // If image fails to load, show broken icon
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      ),
    );
  }
}