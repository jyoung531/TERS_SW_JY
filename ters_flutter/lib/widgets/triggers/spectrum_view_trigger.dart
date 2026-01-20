import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SpectrumViewTrigger extends StatelessWidget {
  const SpectrumViewTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
            // 바디 (그래프 파형 흉내)
            Expanded(
              child: ClipRect(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _WaveformPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 간단한 파형 그리기 (장식용)
class _WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    // 사인파 그리기
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.8 - (size.height * 0.3) * (0.5 * (1 + 0.5 * (i / size.width)) * (amount(i / 30) * 0.5 + 0.5)),
      );
    }
    canvas.drawPath(path, paint);
  }

  double amount(double x) => (x % 2 == 0) ? 1.0 : -1.0; // 단순 진동
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}