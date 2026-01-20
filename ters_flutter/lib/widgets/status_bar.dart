import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart'; // 루시드 아이콘 사용

class StatusBar extends StatefulWidget implements PreferredSizeWidget {
  const StatusBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50); // 높이 50으로 고정

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late String _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    
    // 1초마다 시간 갱신
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) { // 위젯이 화면에 있을 때만 실행
        setState(() {
          _currentTime = _formatDateTime(DateTime.now());
        });
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  void dispose() {
    _timer.cancel(); // 타이머 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AppBar 대신 Container로 커스텀 디자인 적용
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161618), // 배경색 (다른 패널 배경과 통일)
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!), // 하단 경계선 추가
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ==============================
          // 🟢 좌측: 시스템 상태 표시
          // ==============================
          Row(
            children: [
              // 상태 표시 LED (초록색 원 + 그림자)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.greenAccent, blurRadius: 4, spreadRadius: 1)
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '시스템 작동 중',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              
              const SizedBox(width: 24), // 간격
              
              // 연결됨 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.circleCheck, color: Colors.grey, size: 14),
                    SizedBox(width: 6),
                    Text('연결됨', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),

          // ==============================
          // 🕒 우측: 설정 버튼 + 상태 배지 + 시간
          // ==============================
          Row(
            children: [
              // ⚙️ [New] 설정 버튼 추가
               IconButton(
                onPressed: () {
                  print("Refresh Button Clicked");
                  // 여기에 설정 팝업 로직 추가 가능
                },
                icon: const Icon(LucideIcons.refreshCw, color: Colors.grey, size: 20),
                tooltip: '새로고침',
                splashRadius: 20, // 클릭 효과 크기 줄임
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // 여백 최소화
              ),
              const SizedBox(width: 16),

              IconButton(
                onPressed: () {
                  print("Settings Button Clicked");
                  // 여기에 설정 팝업 로직 추가 가능
                },
                icon: const Icon(LucideIcons.settings, color: Colors.grey, size: 20),
                tooltip: '환경 설정',
                splashRadius: 20, // 클릭 효과 크기 줄임
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // 여백 최소화
              ),
              
              const SizedBox(width: 16),

              IconButton(
                onPressed: () {
                  print("Save Button Clicked");
                  // 여기에 설정 팝업 로직 추가 가능
                },
                icon: const Icon(LucideIcons.save, color: Colors.grey, size: 20),
                tooltip: '저장',
                splashRadius: 20, // 클릭 효과 크기 줄임
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // 여백 최소화
              ),
              
              const SizedBox(width: 16),
              
              // 완료 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2), // 연한 초록 배경
                  border: Border.all(color: Colors.green.withOpacity(0.5)), // 초록 테두리
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '완료',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(width: 16),
              
              // ⏰ 현재 시간
              Row(
                children: [
                  const Icon(LucideIcons.clock, color: Colors.grey, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    _currentTime,
                    // monospace 폰트를 써야 숫자가 바뀔 때 글자가 흔들리지 않음
                    style: TextStyle(color: Colors.grey[400], fontFamily: 'monospace', fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}