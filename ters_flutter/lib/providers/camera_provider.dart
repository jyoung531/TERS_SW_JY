import 'dart:async';
import 'dart:convert'; // Base64 디코딩용
import 'dart:typed_data'; // 이미지 바이너리 데이터(Uint8List)용
import 'package:flutter/material.dart';
import '../services/socket_service.dart';

// 🌟 [추가] 카메라 상태를 정의하는 Enum (상태표)
// 문자열("IDLE") 대신 이걸 쓰면 오타 낼 걱정이 없습니다.
enum CameraStatus {
  idle,       // 대기 중 (초록)
  capturing,  // 촬영 중 (파랑)
  busy,       // 다른 작업 중 (주황)
  error       // 에러 (빨강)
}

class CameraProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
  
  Uint8List? _currentImage;
  Uint8List? get currentImage => _currentImage;
  bool get isConnected => _socketService.isConnected;

  // 🌟 [추가] 현재 카메라 상태 변수 (기본값: IDLE)
  CameraStatus _cameraStatus = CameraStatus.idle;
  
  // 외부에서 상태를 읽을 수 있게 Getter 제공
  CameraStatus get cameraStatus => _cameraStatus;

  // ------------------------------------------------------------------------
  // [기능 1] 카메라 연결 시작 (기존과 동일)
  // ------------------------------------------------------------------------
  void connectToCamera() {
    _socketService.connect();
    _socketService.stream.listen(
      (data) {
        _handleImageStream(data);
      },
      onError: (error) {
        print("영상 수신 중 에러 발생: $error");
      },
      onDone: () {
        print("영상 수신 종료");
      },
    );
  }

  void _handleImageStream(dynamic data) {
    try {
      if (data is String) {
        _currentImage = base64Decode(data);
        notifyListeners(); 
      }
    } catch (e) {
      print("이미지 변환 실패: $e");
    }
  }

  void disconnect() {
    _socketService.disconnect();
    _currentImage = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------------
  // 🌟 [추가] 촬영 시뮬레이션 함수 (UI 테스트용)
  // ------------------------------------------------------------------------
  Future<void> captureImage() async {
    // 1. 이미 다른 작업 중이면 무시 (중복 클릭 방지)
    if (_cameraStatus != CameraStatus.idle) {
      print("카메라가 바쁩니다. 촬영할 수 없습니다.");
      return;
    }

    try {
      // 2. 상태를 '촬영 중'으로 변경하고 UI 업데이트
      _cameraStatus = CameraStatus.capturing;
      notifyListeners(); // "상태 바뀌었으니 화면 다시 그려!"
      print("📸 촬영 시작 (상태: CAPTURING)");

      // 3. 실제 촬영 명령 보내기 (나중에는 여기에 ApiService 호출 코드가 들어갑니다)
      // await _apiService.sendCaptureCommand(); 
      
      // 지금은 3초 기다리는 척(Simulation) 합니다.
      await Future.delayed(const Duration(seconds: 3));

      // 4. 촬영이 끝나면 다시 '대기 중'으로 복귀
      _cameraStatus = CameraStatus.idle;
      notifyListeners();
      print("✅ 촬영 완료 (상태: IDLE)");

    } catch (e) {
      // 에러가 나면 에러 상태로 변경
      _cameraStatus = CameraStatus.error;
      notifyListeners();
      print("❌ 촬영 중 에러: $e");
      
      // 2초 뒤에 다시 IDLE로 복구시켜 줌 (센스!)
      await Future.delayed(const Duration(seconds: 2));
      _cameraStatus = CameraStatus.idle;
      notifyListeners();
    }
  }
}