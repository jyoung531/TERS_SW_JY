import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

import 'package:ters_flutter/providers/device_status_provider.dart'; // [필수]

class StatusBar extends StatefulWidget implements PreferredSizeWidget {
  const StatusBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = _formatDateTime(DateTime.now()));
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 📡 Provider 구독
    final deviceProvider = Provider.of<DeviceStatusProvider>(context);
    final isConnected = deviceProvider.isConnected; // 연결 여부

    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ============================================
          // 🟢 좌측: 시스템 상태 + 장비 정보 (동적 변경)
          // ============================================
          Row(
            children: [
              // 1. 상태 LED
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red, // 연결 유무에 따른 색상
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isConnected ? Colors.greenAccent : Colors.redAccent, 
                      blurRadius: 4, spreadRadius: 1
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isConnected ? 'SYSTEM READY' : 'DISCONNECTED', // 텍스트 변경
                style: TextStyle(
                  color: isConnected ? Colors.white : Colors.redAccent, 
                  fontWeight: FontWeight.bold, fontSize: 13
                ),
              ),
              
              Container(height: 16, width: 1, color: Colors.grey[700], margin: const EdgeInsets.symmetric(horizontal: 24)),

              // 2. 장비 정보 (연결 안되면 흐리게 표시)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(LucideIcons.microscope, color: isConnected ? Colors.blueAccent : Colors.grey[700], size: 16),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("DEVICE", style: TextStyle(color: Colors.grey[600], fontSize: 9, fontWeight: FontWeight.bold)),
                      Text(
                        deviceProvider.deviceName, // "Unknown Device" or "ToupCam..."
                        style: TextStyle(
                          color: isConnected ? Colors.white70 : Colors.grey[600], 
                          fontSize: 12
                        )
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(width: 24),
              
              // 3. 연결 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.link, color: isConnected ? Colors.green : Colors.grey, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      isConnected ? 'Connected' : 'Offline', 
                      style: TextStyle(color: isConnected ? Colors.green : Colors.grey, fontSize: 11)
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ============================================
          // 🕒 우측: 온도 + 버튼 + 시간
          // ============================================
          Row(
            children: [
              // 4. 온도 (연결 안되면 숨기거나 비활성 표시)
              // 여기서는 연결 안되면 회색 "--.-" 로 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // 연결 여부 & 냉각 여부에 따른 배경색
                  color: !isConnected 
                      ? Colors.grey[900] 
                      : (deviceProvider.isCooling ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: !isConnected
                        ? Colors.grey[800]!
                        : (deviceProvider.isCooling ? Colors.blue.withOpacity(0.3) : Colors.red.withOpacity(0.3))
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.thermometerSnowflake, 
                      color: !isConnected ? Colors.grey[700] : (deviceProvider.isCooling ? Colors.blue[300] : Colors.red[300]), 
                      size: 14
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? '${deviceProvider.temperature.toStringAsFixed(1)}°C' : '--.-°C',
                      style: TextStyle(
                        color: !isConnected ? Colors.grey[700] : (deviceProvider.isCooling ? Colors.blue[100] : Colors.red[100]), 
                        fontFamily: 'monospace', 
                        fontWeight: FontWeight.bold, fontSize: 13
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // 5. 버튼 그룹
              _buildIconButton(LucideIcons.refreshCcw, 'Refresh', () {}),
              const SizedBox(width: 8),
              _buildIconButton(LucideIcons.settings, 'Settings', () {}),
              const SizedBox(width: 8),
              _buildIconButton(LucideIcons.save, 'Save', () {}),
              
              const SizedBox(width: 24),
              
              // 6. 시간
              Text(_currentTime, style: TextStyle(color: Colors.grey[500], fontFamily: 'monospace', fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.grey[400], size: 18),
      tooltip: tooltip,
      splashRadius: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      style: IconButton.styleFrom(hoverColor: Colors.white10),
    );
  }
}