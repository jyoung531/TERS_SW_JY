import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ters_flutter/dialogs/image_capture_dialog.dart'; 

class ImageCaptureTrigger extends StatelessWidget {
  final List<Map<String, dynamic>> gallery;
  final VoidCallback onCapture;
  final Function(List<int>) onDelete; // 🗑️

  const ImageCaptureTrigger({
    super.key,
    required this.gallery,
    required this.onCapture,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final recentImage = gallery.isNotEmpty ? gallery.first : null;

    return InkWell(
      onTap: () {
        // 팝업 열기 (데이터, 캡처함수, 삭제함수 모두 전달)
        showDialog(
          context: context,
          builder: (context) => ImageCaptureDialog(
            gallery: gallery,
            onCapture: onCapture,
            onDelete: onDelete,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[950],
                border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.image, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Image Capture', 
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),

            // 바디 (최근 이미지 미리보기)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                child: recentImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.memory(
                              recentImage['data'] as Uint8List,
                              fit: BoxFit.cover,
                              color: Colors.black.withOpacity(0.3),
                              colorBlendMode: BlendMode.darken,
                            ),
                          ),
                          const Center(
                             child: Icon(LucideIcons.layoutGrid, color: Colors.white70, size: 24),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(LucideIcons.camera, color: Colors.grey, size: 24),
                          SizedBox(height: 8),
                          Text("Click to Open", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
              ),
            ),

            // 캡처 버튼 (팝업 안 열고 바로 촬영)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: InkWell(
                onTap: onCapture,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.aperture, color: Colors.blueAccent, size: 18),
                      SizedBox(width: 8),
                      Text("Capture", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}