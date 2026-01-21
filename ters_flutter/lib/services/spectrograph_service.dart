// lib/services/spectrograph_service.dart
import 'dart:async';
import 'dart:math';

class SpectrographService {
  // 실제 서버가 없으므로 가짜 데이터를 만들어주는 함수
  Future<Map<String, dynamic>> measureSpectrum() async {
    // 1. 서버 통신하는 척 1초 딜레이
    await Future.delayed(const Duration(seconds: 1));

    // 2. 가짜 스펙트럼 데이터 생성 (사인파 + 노이즈)
    final Random random = Random();
    List<double> fakeSpectrum = List.generate(100, (index) {
      double x = index * 0.1;
      return 500 + (200 * sin(x)) + (random.nextDouble() * 50); 
    });

    // 3. 결과 리턴 (Base64 이미지는 생략하고 데이터만으로 그래프 그리는 걸 추천)
    return {
      "status": "success",
      "spectrum": fakeSpectrum,
    };
  }
}