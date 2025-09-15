import 'package:flutter/material.dart';

class PhotoCapturePage extends StatelessWidget {
  const PhotoCapturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 촬영'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 120, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              '사진 촬영 기능',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('카메라 기능이 구현될 예정입니다.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
