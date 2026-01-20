import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// 위젯 import
import 'package:ters_flutter/widgets/status_bar.dart';
import 'package:ters_flutter/widgets/triggers/database_view_trigger.dart';
import 'package:ters_flutter/widgets/triggers/settings_panel_trigger.dart';
import 'package:ters_flutter/widgets/triggers/spectrum_measurement_trigger.dart';
import 'package:ters_flutter/widgets/triggers/optic_image_trigger.dart';
import 'package:ters_flutter/widgets/triggers/stage_controller_trigger.dart';
import 'package:ters_flutter/widgets/triggers/spectrum_view_trigger.dart';
import 'package:ters_flutter/widgets/triggers/image_capture_trigger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 📸 데이터 관리
  final GlobalKey _captureKey = GlobalKey();
  final List<Map<String, dynamic>> _gallery = [];

  // ⚙️ [기존] Spectrum 설정값
  Map<String, dynamic> _spectrumSettings = {
    'lines': '', 'blaze': '', 'density': '', 'model': '',
    'measureMode': 'Raman', 'laserWavelength': '', 'offset': '',
    'acquisitionMode': 'Accumulate', 'accumulateCount': '10', 'exposureTime': '100',
  };

  // 🕹️ [추가됨] Stage Controller 설정값 저장소
  Map<String, dynamic> _stageSettings = {
    'x': '0',
    'y': '0',
    'z': '0',
  };

  void _updateSpectrumSettings(Map<String, dynamic> newSettings) {
    setState(() => _spectrumSettings = newSettings);
  }

  // 🕹️ [추가됨] Stage 설정값 업데이트 함수
  void _updateStageSettings(Map<String, dynamic> newSettings) {
    setState(() {
      _stageSettings = newSettings;
    });
    // 저장 확인 메시지 (선택사항)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("스테이지 위치가 저장되었습니다."), duration: Duration(milliseconds: 1000)),
    );
  }

  // ... (기존 이미지 관련 함수들: _addImageFromDialog, _deleteImages, _captureImage 동일)
  void _addImageFromDialog(Uint8List data, String time) {
    setState(() {
      _gallery.insert(0, {'data': data, 'time': time});
    });
  }

  void _deleteImages(List<int> indicesToRemove) {
    setState(() {
      indicesToRemove.sort((a, b) => b.compareTo(a)); 
      for (int index in indicesToRemove) {
        if (index < _gallery.length) {
          _gallery.removeAt(index);
        }
      }
    });
  }

  Future<void> _captureImage() async {
    try {
      RenderRepaintBoundary? boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        String timeStamp = DateFormat('HH:mm:ss').format(DateTime.now());
        _addImageFromDialog(pngBytes, timeStamp);
      }
    } catch (e) {
      print("캡처 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const StatusBar(),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // ⬅️ [Left Sidebar]
                Container(
                  width: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161618),
                    border: Border(right: BorderSide(color: Colors.grey[800]!)),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Expanded(flex: 1, child: DatabaseViewTrigger()),
                      const SizedBox(height: 12),
                      const SizedBox(height: 80, child: SettingsPanelTrigger()), 
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120, 
                        child: SpectrumMeasurementTrigger(
                          settings: _spectrumSettings,
                          onSettingsChanged: _updateSpectrumSettings,
                        ),
                      ),
                    ],
                  ),
                ),

                // ⏺️ [Center Area]
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: RepaintBoundary(
                      key: _captureKey, 
                      child: OpticImageTrigger(
                        gallery: _gallery,
                        onAddImage: _addImageFromDialog,
                        onDelete: _deleteImages,
                      ),
                    ),
                  ),
                ),

                // ➡️ [Right Sidebar]
                Container(
                  width: 170,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161618),
                    border: Border(left: BorderSide(color: Colors.grey[800]!)),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ImageCaptureTrigger(
                          gallery: _gallery,
                          onCapture: _captureImage,
                          onDelete: _deleteImages,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // 🌟 [수정됨] StageControllerTrigger에 설정값 전달
                      Expanded(
                        flex: 1, 
                        child: StageControllerTrigger(
                          settings: _stageSettings,
                          onSettingsChanged: _updateStageSettings,
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ⬇️ [Bottom Area]
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161618),
              border: Border(top: BorderSide(color: Colors.grey[800]!)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: const SpectrumViewTrigger(),
          ),
        ],
      ),
    );
  }
}