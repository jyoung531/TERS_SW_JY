// lib/providers/spectrograph_provider.dart
import 'package:flutter/material.dart';
import '../services/spectrograph_service.dart';

class SpectrographProvider with ChangeNotifier {
  final SpectrographService _service = SpectrographService();

  // --- 상태 변수 ---
  List<double> _spectrumData = []; // 그래프 데이터
  bool _isMeasuring = false;       // 측정 중인가?

  // --- Getter ---
  List<double> get spectrumData => _spectrumData;
  bool get isMeasuring => _isMeasuring;
  
  // 데이터가 비어있지 않으면 유효한 데이터가 있는 것
  bool get hasData => _spectrumData.isNotEmpty;

  // --- 기능: 측정 시작 ---
  Future<void> measure() async {
    if (_isMeasuring) return; // 이미 측정 중이면 무시

    _isMeasuring = true;
    notifyListeners(); // "로딩 시작해!"

    try {
      final result = await _service.measureSpectrum();
      
      if (result['status'] == 'success') {
        _spectrumData = result['spectrum'];
      }
    } catch (e) {
      print("측정 실패: $e");
    } finally {
      _isMeasuring = false;
      notifyListeners(); // "로딩 끝! 그래프 그려!"
    }
  }
  
  // 데이터 초기화 (필요시)
  void clearData() {
    _spectrumData = [];
    notifyListeners();
  }
}