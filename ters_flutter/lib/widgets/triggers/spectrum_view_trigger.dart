import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart'; // [필수]
import 'package:ters_flutter/providers/spectrograph_provider.dart'; 
import 'package:ters_flutter/dialogs/spectrum_analysis_dialog.dart';

class SpectrumViewTrigger extends StatelessWidget {
  const SpectrumViewTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    // 📡 Provider 구독 (데이터가 바뀌면 화면 다시 그림)
    final provider = context.watch<SpectrographProvider>();

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const SpectrumAnalysisDialog(),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.activity, color: Colors.purple, size: 16),
                      const SizedBox(width: 8),
                      Text('Spectrum View', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                  Text('400-900 nm', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ),
            ),
            // 바디 (실제 데이터 그래프)
            Expanded(
              child: ClipRect(
                child: Container(
                  width: double.infinity, // 가로 꽉 채우기
                  padding: const EdgeInsets.all(8.0), // 약간의 여백
                  child: CustomPaint(
                    size: Size.infinite,
                    // 🌟 실제 데이터를 Painter에게 전달
                    painter: SpectrumDataPainter(data: provider.spectrumData),
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

// 🎨 실제 데이터를 그리는 화가
class SpectrumDataPainter extends CustomPainter {
  final List<double> data;
  SpectrumDataPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();

    // 1. 데이터가 없을 때 (초기 상태): 그냥 가운데 일직선 그리기
    if (data.isEmpty) {
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
      
      // 흐릿한 색으로 대기 상태 표현
      paint.color = Colors.white10; 
      canvas.drawPath(path, paint);
      return;
    }

    // 2. 데이터가 있을 때: 그래프 그리기
    // Y축 범위 설정 (가짜 데이터가 300~800 사이로 나옴)
    // 실제 데이터 범위에 맞춰서 자동 스케일링되면 더 좋음
    double minVal = 300.0;
    double maxVal = 800.0;
    
    // 첫 점 시작
    double firstY = _normalize(data[0], minVal, maxVal, size.height);
    path.moveTo(0, firstY);

    // 나머지 점들 연결
    for (int i = 1; i < data.length; i++) {
      double x = (i / (data.length - 1)) * size.width;
      double y = _normalize(data[i], minVal, maxVal, size.height);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  // 값을 화면 높이에 맞게 변환하는 함수
  // (값이 높으면 화면 위쪽(Y=0)으로 가야 하므로 size.height에서 뺌)
  double _normalize(double value, double min, double max, double height) {
    double normalized = (value - min) / (max - min); 
    // 범위를 벗어나지 않게 클램핑
    if (normalized < 0) normalized = 0;
    if (normalized > 1) normalized = 1;
    
    return height - (normalized * height);
  }
  
  @override
  bool shouldRepaint(covariant SpectrumDataPainter oldDelegate) {
    return oldDelegate.data != data; // 데이터가 다를 때만 다시 그림
  }
}