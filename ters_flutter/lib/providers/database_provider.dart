import 'package:flutter/material.dart';

class DatabaseProvider with ChangeNotifier {
  // 💾 실제 데이터가 저장되는 리스트
  final List<Map<String, dynamic>> _experiments = [
    // (초기 샘플 데이터 1개)
    {
      "id": 100,
      "title": "Initial_Sample_Data",
      "researcher": "System",
      "date": "2023-01-01",
      "tags": ["Demo"],
      "spectrum": [500.0, 510.0, 520.0, 510.0, 500.0], // 샘플 그래프 데이터
    }
  ];

  // Getter
  List<Map<String, dynamic>> get experiments => _experiments;

  // ➕ 데이터 추가 (Save)
  void addExperiment(Map<String, dynamic> newExperiment) {
    // ID 자동 생성 (가장 큰 ID + 1)
    int newId = _experiments.isNotEmpty ? _experiments.last['id'] + 1 : 101;
    newExperiment['id'] = newId;
    
    _experiments.insert(0, newExperiment); // 최신순으로 맨 앞에 추가
    notifyListeners(); // "DB 업데이트됐어!" 알림
  }

  // 🗑️ 데이터 삭제 (Delete)
  void deleteExperiments(Set<int> idsToDelete) {
    _experiments.removeWhere((item) => idsToDelete.contains(item['id']));
    notifyListeners();
  }

  // ✏️ 데이터 수정 (Edit)
  void updateExperiment(int id, String newTitle, List<String> newTags) {
    final index = _experiments.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      _experiments[index]['title'] = newTitle;
      _experiments[index]['tags'] = newTags;
      notifyListeners();
    }
  }
}