import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ters_flutter/dialogs/stage/stage_controller_dialog.dart';

class StageControllerTrigger extends StatelessWidget {
  // 🌟 데이터 받기
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const StageControllerTrigger({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // 🌟 다이얼로그에 데이터 전달
        showDialog(
          context: context,
          builder: (context) => StageControllerDialog(
            settings: settings,
            onSaved: onSettingsChanged,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            // 1. 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[950],
                border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.move, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Control', 
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. 바디
            Expanded(
              child: Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[600]!),
                    color: Colors.grey[850],
                  ),
                  child: Center(
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // 3. 하단 좌표 표시 (저장된 값 보여주기)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                "X: ${settings['x']}  Y: ${settings['y']}  Z: ${settings['z']}", 
                style: TextStyle(color: Colors.grey[500], fontSize: 10, fontFamily: 'monospace'),
              ),
            )
          ],
        ),
      ),
    );
  }
}