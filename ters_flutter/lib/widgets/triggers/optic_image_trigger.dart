import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart'; // [필수] Provider 추가

import 'package:ters_flutter/dialogs/optic_image_dialog.dart';
import 'package:ters_flutter/providers/camera_provider.dart'; // [필수] Provider 파일 import

class OpticImageTrigger extends StatefulWidget {
  final List<Map<String, dynamic>> gallery;
  final Function(Uint8List, String) onAddImage;
  final Function(List<int>) onDelete;

  const OpticImageTrigger({
    super.key,
    required this.gallery,
    required this.onAddImage,
    required this.onDelete,
  });

  @override
  State<OpticImageTrigger> createState() => _OpticImageTriggerState();
}

class _OpticImageTriggerState extends State<OpticImageTrigger> {
  
  // 앱이 켜지고 이 위젯이 보이면 바로 카메라 연결 시도!
  @override
  void initState() {
    super.initState();
    // 화면이 그려진 직후에 연결을 시도합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 이미 연결되어 있으면 Provider 내부에서 알아서 무시하므로 호출해도 안전합니다.
      context.read<CameraProvider>().connectToCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return OpticImageDialog(
              gallery: widget.gallery,
              onCapture: widget.onAddImage,
              onDelete: widget.onDelete,
            );
          },
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
                  // [수정] Provider의 상태를 보고 연결 여부 표시
                  Consumer<CameraProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          Icon(
                            LucideIcons.circle, // 점 아이콘
                            color: provider.isConnected ? Colors.green : Colors.red, 
                            size: 10
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.isConnected ? 'Live' : 'Disconnected', 
                            style: TextStyle(
                              color: provider.isConnected ? Colors.green : Colors.grey[500], 
                              fontSize: 12
                            )
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
            // 중앙 뷰 (여기가 핵심!)
            Expanded(
              child: Container(
                color: Colors.black, // 배경을 완전 검정으로
                alignment: Alignment.center,
                // [핵심] Consumer로 감싸서 영상 데이터가 바뀌면 화면을 갱신
                child: Consumer<CameraProvider>(
                  builder: (context, provider, child) {
                    if (provider.currentImage != null) {
                      // 1. 영상 데이터가 있으면 이미지 보여주기
                      return Image.memory(
                        provider.currentImage!,
                        fit: BoxFit.cover, // 꽉 차게 보이기
                        gaplessPlayback: true, // 깜빡임 방지
                        width: double.infinity,
                        height: double.infinity,
                      );
                    } else {
                      // 2. 영상 데이터가 없으면 로딩 텍스트
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Connecting to Camera...',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}