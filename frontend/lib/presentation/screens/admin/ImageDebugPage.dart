import 'package:flutter/material.dart';

class ImageDebugPage extends StatelessWidget {
  const ImageDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    const url = 'https://res.cloudinary.com/doanvrjez/image/upload/v1771166116/lokyatra/sites/MyImage-1770877894-04_ejzzwj.jpg';
    return Scaffold(
      appBar: AppBar(title: const Text('Image Debug')),
      body: Center(
        child: Image.network(
          url,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return const CircularProgressIndicator();
          },
          errorBuilder: (ctx, err, stack) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image, size: 48),
                Text('Error: $err'),
              ],
            );
          },
        ),
      ),
    );
  }
}