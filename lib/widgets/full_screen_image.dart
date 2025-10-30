import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// method that will open image in FullScreenView
openFullScreenImage(String imageUrl, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) {
        return FullScreenImage(
          imageUrl: imageUrl,
          tag: imageUrl,
        );
      },
    ),
  );
}

class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  final String tag;

  const FullScreenImage({super.key, required this.imageUrl, required this.tag});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Center(
        child: Hero(
          tag: widget.tag,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: PhotoView(
              backgroundDecoration:
                  const BoxDecoration(color: Colors.transparent),
              minScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(
                widget.imageUrl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
