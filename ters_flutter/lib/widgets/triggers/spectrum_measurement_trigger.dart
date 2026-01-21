import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart'; // [필수]
import 'package:ters_flutter/dialogs/spectrum_settings_dialog.dart';
import 'package:ters_flutter/providers/spectrograph_provider.dart'; // [필수] Provider import
import 'package:ters_flutter/dialogs/save_measurement_dialog.dart'; // [필수] 저장 팝업 import

class SpectrumMeasurementTrigger extends StatelessWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const SpectrumMeasurementTrigger({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 📡 Provider 구독 (로딩 상태 및 데이터 유무 확인용)
    final provider = context.watch<SpectrographProvider>();

    return Container(
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
                const Icon(LucideIcons.activity, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text('Spectrum', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
          
          // 2. 바디 (Body)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  // ▶️ 첫 번째 버튼: Start Measure
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: InkWell(
                      // ⚡ 로딩 중이면 클릭 방지 (null)
                      onTap: provider.isMeasuring 
                          ? null 
                          : () {
                              // 측정 시작!
                              context.read<SpectrographProvider>().measure();
                            },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          // 로딩 중이면 색상을 조금 흐리게 처리
                          color: Colors.green.withOpacity(provider.isMeasuring ? 0.05 : 0.1),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🔄 로딩 중이면 스피너, 아니면 플레이 아이콘
                            if (provider.isMeasuring)
                              const SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                              )
                            else
                              const Icon(LucideIcons.play, size: 14, color: Colors.green),
                            
                            const SizedBox(width: 5),
                            
                            // 텍스트 변경 (Measure -> Measuring...)
                            Text(
                              provider.isMeasuring ? "Measuring..." : "Measure",
                              style: const TextStyle(color: Colors.green, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 💾 [추가됨] 두 번째 버튼: Save Data
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: InkWell(
                      // 데이터가 없거나 측정 중이면 비활성화
                      onTap: (!provider.hasData || provider.isMeasuring)
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => const SaveMeasurementDialog(),
                              );
                            },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          // 활성화 여부에 따라 색상 변경 (Blue Accent)
                          color: provider.hasData ? Colors.blueAccent.withOpacity(0.1) : Colors.grey[850],
                          border: Border.all(
                            color: provider.hasData ? Colors.blueAccent.withOpacity(0.5) : Colors.grey[700]!
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.save, size: 14, 
                                 color: provider.hasData ? Colors.blueAccent : Colors.grey),
                            const SizedBox(width: 5),
                            Text("Save Data", 
                                 style: TextStyle(
                                   color: provider.hasData ? Colors.blueAccent : Colors.grey, 
                                   fontSize: 12
                                 )),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ⚙️ 세 번째 버튼: Settings
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => SpectrumSettingsDialog(
                            settings: settings,
                            onSettingsChanged: onSettingsChanged,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          border: Border.all(color: Colors.grey[600]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.settings2, size: 14, color: Colors.white70), 
                            SizedBox(width: 5),
                            Text("settings", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}