// lib/widgets/triggers/save_button_trigger.dart

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SaveButtonTrigger extends StatelessWidget {
  const SaveButtonTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border.all(color: Colors.grey[700]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.save, color: Colors.white, size: 18),
            SizedBox(width: 8),
            
            // ❗️ [수정] 텍스트가 공간을 넘어가면 자동으로 줄임 (...)
            Flexible(
              child: Text(
                'Save Project',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis, // 글자 넘침 방지
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}