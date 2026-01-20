import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
// 1. 다이얼로그 import (경로 확인해주세요)
import 'package:ters_flutter/dialogs/spectrum_settings_dialog.dart'; 

class SpectrumMeasurementTrigger extends StatelessWidget {
  // 🌟 [추가됨] 부모로부터 받을 데이터
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const SpectrumMeasurementTrigger({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container( // 전체 InkWell 제거 -> 개별 버튼에 InkWell 적용
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          // 1. 헤더 (Header)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.grey[950],
              border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.activity, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text('Spectrum', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          
          // 2. 바디 (Body) - 버튼 2개를 세로로 배치
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
                children: [
                  
                  // ▶️ 첫 번째 버튼: Start Measure
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: InkWell( // 2. 개별 버튼 클릭 이벤트 추가
                      onTap: () {
                        // 측정 시작 로직 (나중에 구현)
                        print("Measure Start Clicked");
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.play, size: 14, color: Colors.green),
                            SizedBox(width: 5),
                            Text("Measure", style: TextStyle(color: Colors.green, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8), // 버튼 사이 간격

                  // ⚙️ 두 번째 버튼: Measurement Settings
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: InkWell( // 3. Settings 버튼 클릭 이벤트
                      onTap: () {
                        // 4. 다이얼로그 띄우기 (데이터 전달)
                        showDialog(
                          context: context,
                          builder: (context) => SpectrumSettingsDialog(
                            settings: settings,
                            onSettingsChanged: onSettingsChanged,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[800], // 배경색을 다르게 해서 구분
                          border: Border.all(color: Colors.grey[600]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 설정 아이콘
                            Icon(LucideIcons.settings2, size: 14, color: Colors.white70), 
                            SizedBox(width: 5),
                            Text("settings", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}