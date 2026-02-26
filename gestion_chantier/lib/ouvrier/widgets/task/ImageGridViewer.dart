import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../bet/utils/constant.dart';


class ImageGridViewer extends StatelessWidget {
  final List<String> imageUrls;

  const ImageGridViewer({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final int displayCount = imageUrls.length > 4 ? 4 : imageUrls.length;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final imageUrl = APIConstants.API_BASE_URL_IMG+  imageUrls[index];

        // Si c'est le 4ème élément et qu'il y a plus de 4 images
        if (index == 3 && imageUrls.length > 4) {
          return GestureDetector(
            onTap: () => _openImageSlider(context, 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.center,
                  child: Text(
                    '+${imageUrls.length - 3}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }

        // Image normale
        return GestureDetector(
          onTap: () => _openImageSlider(context, index),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Container(color: Colors.grey.shade200),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      },
    );
  }

  void _openImageSlider(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: _ImageSlider(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ImageSlider({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl:  APIConstants.API_BASE_URL_IMG+ widget.imageUrls[index],
                fit: BoxFit.contain,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            );
          },
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '${currentIndex + 1} / ${widget.imageUrls.length}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
