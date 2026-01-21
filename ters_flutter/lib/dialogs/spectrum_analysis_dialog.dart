import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ters_flutter/providers/spectrograph_provider.dart';
import 'package:ters_flutter/widgets/triggers/spectrum_view_trigger.dart'; // Painter 재사용

class SpectrumAnalysisDialog extends StatelessWidget {
  const SpectrumAnalysisDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // 📡 데이터 가져오기
    final provider = context.watch<SpectrographProvider>();
    final data = provider.spectrumData;

    // 간단한 통계 계산 (데이터가 있을 때만)
    double maxIntensity = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 0.0;
    int dataCount = data.length;

    return Dialog(
      backgroundColor: const Color(0xFF1E1E20), // 다이얼로그 배경색
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 800, // 너비 (태블릿/PC 고려해서 넓게)
        height: 600, // 높이
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 (제목 + 닫기 버튼)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.activity, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Text(
                      "Detailed Spectrum Analysis",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, color: Colors.grey),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 30),

            // 2. 메인 그래프 영역 (확대된 뷰)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  border: Border.all(color: Colors.grey[800]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  size: Size.infinite,
                  // 아까 만든 Painter 재사용 (코드 중복 방지!)
                  painter: SpectrumDataPainter(data: data),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // 3. 하단 정보 패널 (통계 수치)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem("Max Intensity", "${maxIntensity.toStringAsFixed(1)} a.u.", Colors.redAccent),
                  _buildInfoItem("Data Points", "$dataCount", Colors.white),
                  _buildInfoItem("Range", "400 - 900 nm", Colors.blueAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 아이템 위젯
  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}