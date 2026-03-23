import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkImageOrSvg extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;

  const NetworkImageOrSvg({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  bool get _isSvg => url.toLowerCase().contains('.svg');

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ??
        Container(
          color: Colors.grey[200],
          child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
        );

    if (_isSvg) {
      return SvgPicture.network(
        url,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => Container(color: Colors.grey[200]),
      );
    }

    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
