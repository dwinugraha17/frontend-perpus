import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah imageUrl adalah data URI Base64
    if (imageUrl.startsWith('data:image')) {
      try {
        final UriData? data = Uri.parse(imageUrl).data;
        if (data != null && data.mimeType.startsWith('image/')) {
          return Image.memory(
            data.contentAsBytes(),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Base64 Image Load Error: $error');
              return errorWidget ?? const Icon(Icons.error);
            },
          );
        }
      } catch (e) {
        debugPrint('Error parsing/loading Base64 URI: $e');
        return errorWidget ?? const Icon(Icons.error);
      }
    }

    // Fallback ke logika lama jika bukan data URI
    // Pada Web, CachedNetworkImage sering bermasalah dengan CORS saat Development.
    // Kita gunakan Image.network biasa untuk Web.
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image Load Error (Web): $error');
          return errorWidget ?? const Icon(Icons.error);
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
         debugPrint('Image Load Error (Mobile): $error');
         return errorWidget ?? const Icon(Icons.error);
      },
    );
  }
}
