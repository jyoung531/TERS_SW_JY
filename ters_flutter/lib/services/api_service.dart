import 'dart:convert'; // JSON 변환용 (텍스트 <-> 객체)
import 'package:http/http.dart' as http; // HTTP 통신 패키지

class ApiService {
  // ------------------------------------------------------------------------
  // [1] 서버 주소 설정
   // 실제 사용시 변경 필요!!! 
  // ------------------------------------------------------------------------
  static const String baseUrl = 'http://10.0.2.2:8000'; 

  // ------------------------------------------------------------------------
  // [2] 공통 요청 함수 (GET)
  // 데이터를 가져올 때 사용 (예: 현재 카메라 설정값 조회)
  // ------------------------------------------------------------------------
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 성공하면 JSON을 풀어서(Decode) 돌려줍니다.
        return jsonDecode(response.body);
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('GET 요청 실패: $e');
      return null; // 실패 시 null 반환
    }
  }

  // ------------------------------------------------------------------------
  // [3] 공통 요청 함수 (POST)
  // 명령을 보낼 때 사용 (예: 촬영해라, 이동해라)
  // ------------------------------------------------------------------------
  Future<bool> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      
      // 데이터를 JSON 문자열로 변환하여 전송
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('명령 전송 성공: $endpoint');
        return true;
      } else {
        print('명령 전송 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('POST 요청 에러: $e');
      return false;
    }
  }

  // ------------------------------------------------------------------------
  // [4] TERS 프로젝트 전용 함수들 (예시)
  // 나중에 Provider에서 이 함수들을 호출하게 됩니다.
  // ------------------------------------------------------------------------

  // 예: 카메라 촬영 명령
  Future<bool> sendCaptureCommand() async {
    // Python 서버의 라우터 주소에 맞게 수정 필요 (예: /camera/capture)
    return await post('/camera/capture', {}); 
  }

  // 예: 스테이지 이동 명령
  Future<bool> moveStage(double x, double y) async {
    return await post('/stage/move', {
      'x': x,
      'y': y,
    });
  }
}