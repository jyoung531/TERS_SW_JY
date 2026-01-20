import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ters_flutter/dialogs/optic_image_dialog.dart';

class OpticImageTrigger extends StatelessWidget {
  // 1️⃣ 부모(HomeScreen)에서 받아올 데이터와 함수들
  final List<Map<String, dynamic>> gallery;
  final Function(Uint8List, String) onAddImage;
  final Function(List<int>) onDelete; // 🗑️ [추가됨] 삭제 함수

  const OpticImageTrigger({
    super.key,
    required this.gallery,
    required this.onAddImage,
    required this.onDelete, // 🗑️ 필수 인자로 추가
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 2️⃣ 팝업창을 열 때 삭제 함수도 같이 넘겨줍니다.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return OpticImageDialog(
              gallery: gallery,
              onCapture: onAddImage,
              onDelete: onDelete, // 🗑️ 전달
            );
          },
        );
      },
      // 3️⃣ 겉모습 UI (기존과 동일)
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            // 상단 바
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[950],
                border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.camera, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text('Camera Status', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, color: Colors.grey[500], size: 12),
                      const SizedBox(width: 4),
                      Text('Loading...', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // 중앙 뷰
            Expanded(
              child: Container(
                color: Colors.grey[950],
                alignment: Alignment.center,
                child: const Text(
                  'Optic Image View (Click to open dialog)',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}