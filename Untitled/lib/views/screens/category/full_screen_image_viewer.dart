// import 'package:flutter/material.dart';
import 'package:ecommerce_app/app_colors.dart';
import 'package:flutter/material.dart';

/// Full-screen, pinch-to-zoom image viewer — opened by tapping the
/// main product image on ProductDetailScreen. Swipeable when the
/// product has multiple photos, starting on whichever one was tapped.
class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _controller;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final url = widget.images[index];
                final bool isNetwork = url.startsWith('http://') || url.startsWith('https://');
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  clipBehavior: Clip.none,
                  child: SizedBox.expand(
                    child: isNetwork
                        ? Image.network(
                            url,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(child: CircularProgressIndicator(color: Colors.white));
                            },
                            errorBuilder: (context, error, stack) =>
                                const Center(child: Icon(Icons.image_outlined, size: 80, color: Colors.white38)),
                          )
                        : Image.asset(
                            url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) =>
                                const Center(child: Icon(Icons.image_outlined, size: 80, color: Colors.white38)),
                          ),
                  ),
                );
              },
            ),
            Positioned(
              top: 8,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
            if (widget.images.length > 1) ...[
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '${_currentPage + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    final bool active = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primaryBlue : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ] else
              // Single-image products still get a discoverable zoom
              // hint at the bottom, since there's no page-dot row to
              // imply "there's more to this view".
              const Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Pinch to zoom',
                    style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}