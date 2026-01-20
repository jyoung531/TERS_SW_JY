import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class DatabaseViewTrigger extends StatelessWidget {
  const DatabaseViewTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("Database View Tapped");
      },
      child: Container(
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
                  const Icon(LucideIcons.database, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text('Database', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            
            // 2. 바디 (Body)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[900],
                child: Column(
                  children: [
                    _buildMockItem("Experiment_001_Test_Long_Name", "10-30"), // 긴 이름 테스트
                    _buildMockItem("Experiment_002", "10-29"),
                    _buildMockItem("Experiment_003", "10-29"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockItem(String title, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // 1. 아이콘 (고정 크기)
          const Icon(LucideIcons.fileText, size: 12, color: Colors.blueAccent),
          const SizedBox(width: 6),

          // 2. 제목 (남는 공간 모두 차지 + 말줄임표)
          // Expanded로 감싸야 남는 공간을 계산할 수 있습니다.
          Expanded( 
            child: Text(
              title, 
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              overflow: TextOverflow.ellipsis, // ❗️ 글자가 넘치면 ...으로 표시
              maxLines: 1, // ❗️ 한 줄만 표시
            ),
          ),
          
          const SizedBox(width: 8), // 제목과 날짜 사이 간격

          // 3. 날짜 (고정 크기)
          Text(
            date, 
            style: TextStyle(color: Colors.grey[500], fontSize: 10)
          ),
        ],
      ),
    );
  }
}