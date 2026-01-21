import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// 연결 상태를 명확하게 관리하기 위한 Enum
enum DeviceConnectionState {
  disconnected, // 연결 끊김 (기본)
  connecting,   // 연결 시도 중
  connected,    // 연결 성공
  error         // 에러 발생
}

class DeviceStatusProvider with ChangeNotifier {
  // --- 1. 상태 변수들 ---
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;
  String _deviceName = "Unknown Device";
  double _temperature = 0.0;
  bool _isCooling = false;

  // --- 2. 외부에서 읽을 때 쓰는 Getter ---
  DeviceConnectionState get connectionState => _connectionState;
  String get deviceName => _deviceName;
  double get temperature => _temperature;
  bool get isCooling => _isCooling;
  
  // 연결되었는지 확인하는 간단한 Getter
  bool get isConnected => _connectionState == DeviceConnectionState.connected;

  // --- 3. 통신 관련 변수 ---
  WebSocketChannel? _channel;
  // 에뮬레이터면 10.0.2.2, 실제 기기면 PC IP 사용
  final String _wsUrl = 'ws://10.0.2.2:8000/ws/temperature'; 

  // ==========================================================
  // [기능 1] 초기화 (연결 시작)
  // ==========================================================
  void initialize() {
    _connect();
  }

  // ==========================================================
  // [기능 2] 서버 연결 및 데이터 수신
  // ==========================================================
  void _connect() {
    // 1. 상태를 '연결 중'으로 변경
    _connectionState = DeviceConnectionState.connecting;
    notifyListeners();

    try {
      print("🔌 [Device] 온도 소켓 연결 시도: $_wsUrl");
      _channel = IOWebSocketChannel.connect(Uri.parse(_wsUrl));

      _channel!.stream.listen(
        (message) {
          // 2. 데이터가 들어오기 시작하면 '연결됨'으로 변경 (최초 1회)
          if (_connectionState != DeviceConnectionState.connected) {
            _connectionState = DeviceConnectionState.connected;
            // 연결 성공 시, 장비 이름도 설정 (원래는 API로 가져오지만 여기선 시뮬레이션)
            _deviceName = "ToupCam Hyper-S"; 
            print("✅ [Device] 연결 성공!");
          }

          // 3. 실시간 온도 데이터 파싱
          try {
            final data = jsonDecode(message);
            // 서버 키값에 따라 수정 필요 (예: 'temp' or 'temperature')
            _temperature = data['temp'] ?? _temperature;
            _isCooling = data['cooling'] ?? _isCooling;
            
            notifyListeners(); // 화면 갱신
          } catch (e) {
            print("⚠️ 데이터 파싱 오류: $e");
          }
        },
        onError: (error) {
          print("❌ [Device] 소켓 에러: $error");
          _setDisconnected();
        },
        onDone: () {
          print("zzz [Device] 소켓 연결 종료");
          _setDisconnected();
        },
      );
    } catch (e) {
      print("❌ [Device] 연결 실패: $e");
      _setDisconnected();
    }
  }

  // 연결 끊김 처리 함수
  void _setDisconnected() {
    _connectionState = DeviceConnectionState.disconnected;
    _deviceName = "No Device";
    _temperature = 0.0;
    notifyListeners();
    
    // (선택사항) 3초 뒤 재연결 시도?
    // Timer(const Duration(seconds: 3), _connect);
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}