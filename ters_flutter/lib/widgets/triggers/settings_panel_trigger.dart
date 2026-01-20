import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SettingsPanelTrigger extends StatelessWidget {
  const SettingsPanelTrigger({super.key});

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
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[950],
                border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.settings, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text('Settings', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            // 바디
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                 
                    Icon(LucideIcons.settings2, color: Colors.grey[600], size: 24), 
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}