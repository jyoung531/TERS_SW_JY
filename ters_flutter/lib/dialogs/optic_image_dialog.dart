// lib/dialogs/optic_image_dialog.dart

import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class OpticImageDialog extends StatefulWidget {
  final List<Map<String, dynamic>> gallery;
  final Function(Uint8List, String) onCapture;
  final Function(List<int>) onDelete;

  const OpticImageDialog({
    super.key,
    required this.gallery,
    required this.onCapture,
    required this.onDelete,
  });

  @override
  State<OpticImageDialog> createState() => _OpticImageDialogState();
}

class _OpticImageDialogState extends State<OpticImageDialog> {
  // --- 상태 변수들 (화면 제어) ---
  bool _autoFocus = false;
  bool _multiFocus = false;
  bool _liveView = true;
  bool _showSettings = false; 

  // --- 상태 변수들 (카메라 설정 데이터) ---
  String _resLive = "1920 x 1080"; // 실시간 해상도 (헤더에 표시됨)
  String _resCapture = "2840 x 2160";
  bool _isColorMode = true;
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  double _frameRate = 0.5;
  bool _autoExposure = true;
  
  double _wbR = 0.5;
  double _wbG = 0.5;
  double _wbB = 0.5;
  
  double _bbR = 0.5;
  double _bbG = 0.5;
  double _bbB = 0.5;
  
  double _hue = 0.5;
  double _saturation = 0.5;
  double _brightness = 0.5;
  double _contrast = 0.5;
  double _gamma = 0.5;

  late Timer _timer;
  String _currentTime = "";
  final GlobalKey _captureKey = GlobalKey();
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    if(mounted) {
      setState(() {
        // 날짜 형식 변경 (2025. 12. 17. 오후 5:25:41)
        _currentTime = DateFormat('yyyy. MM. dd. a h:mm:ss', 'ko_KR').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _openImageViewer(Uint8List imageData, String timestamp) {
    showDialog(
      context: context,
      builder: (context) => ImageViewerDialog(imageData: imageData, timestamp: timestamp),
    );
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
        widget.onCapture(pngBytes, timeStamp);
        if (mounted) {
           ScaffoldMessenger.of(context).clearSnackBars();
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📸 캡처 완료!'), duration: Duration(milliseconds: 1000)));
          setState(() {}); 
        }
      }
    } catch (e) {
      print("캡처 에러: $e");
    }
  }

  Future<void> _saveImages({bool saveAll = false}) async {
    final indicesToSave = saveAll ? List.generate(widget.gallery.length, (i) => i) : _selectedIndices.toList();
    if (indicesToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장할 이미지가 없습니다.')));
      return;
    }
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(dialogTitle: '이미지를 저장할 폴더를 선택하세요');
    if (selectedDirectory != null) {
      try {
        int savedCount = 0;
        for (int index in indicesToSave) {
          if (index >= widget.gallery.length) continue;
          final item = widget.gallery[index];
          final String time = item['time'].toString().replaceAll(':', ''); 
          final String filePath = '$selectedDirectory/optic_capture_${index + 1}_$time.png';
          final File file = File(filePath);
          await file.writeAsBytes(item['data']);
          savedCount++;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $savedCount장 저장 완료')));
          setState(() => _selectedIndices.clear());
        }
      } catch (e) {
        print("저장 오류: $e");
      }
    }
  }

  void _deleteSelectedImages() {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제할 이미지를 선택해주세요.')));
      return;
    }
    widget.onDelete(_selectedIndices.toList());
    setState(() => _selectedIndices.clear());
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedIndices.addAll(List.generate(widget.gallery.length, (i) => i));
      } else {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  // --- 메인 빌드 ---
  @override
  Widget build(BuildContext context) {
    final bool isAllSelected = widget.gallery.isNotEmpty && _selectedIndices.length == widget.gallery.length;

    return Dialog(
      backgroundColor: Colors.white, // 전체 배경 흰색 (Figma 스타일)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 최상단 타이틀 & 닫기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('광학 이미지 제어', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(LucideIcons.x, color: Colors.black54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),

            // 🌟 2. [추가됨] 검은색 Status Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 좌측: 시간 및 Live View 상태
                  Row(
                    children: [
                      const Icon(LucideIcons.clock, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(_currentTime, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _liveView ? Colors.indigoAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _liveView ? Colors.indigoAccent : Colors.redAccent),
                        ),
                        child: Text(
                          _liveView ? "Live View" : "Stopped", 
                          style: TextStyle(color: _liveView ? Colors.indigoAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                  // 우측: 해상도 및 FPS
                  Row(
                    children: [
                      Text(_resLive, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text("30 FPS", style: TextStyle(color: Colors.grey, fontSize: 14)), // FPS는 임시값
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [왼쪽] 카메라 뷰
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: RepaintBoundary(
                            key: _captureKey,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.grey[700]!), borderRadius: BorderRadius.circular(8.0)),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // 1. 카메라 화면 (배경)
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _isColorMode 
                                          ? [Colors.grey[900]!, Colors.black]
                                          : [Colors.black, Colors.grey[800]!], 
                                        begin: Alignment.center, end: Alignment.bottomCenter
                                      )
                                    ),
                                  ),
                                  
                                  // 2. 십자선 (Focus Grid)
                                  Center(child: Container(width: double.infinity, height: 1, color: Colors.redAccent.withOpacity(0.5))),
                                  Center(child: Container(width: 1, height: double.infinity, color: Colors.redAccent.withOpacity(0.5))),
                                  
                                  // 🌟 3. [추가됨] Auto Focus 표시 (좌측 상단)
                                  if (_autoFocus)
                                    Positioned(
                                      top: 16, left: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          border: Border.all(color: Colors.green),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(LucideIcons.focus, color: Colors.green, size: 14),
                                            SizedBox(width: 6),
                                            Text("Auto Focus Active", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),

                                  // 🌟 4. [추가됨] Multi Focus 표시 (우측 상단)
                                  if (_multiFocus)
                                    Positioned(
                                      top: 16, right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          border: Border.all(color: Colors.blue),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(LucideIcons.layers, color: Colors.blue, size: 14),
                                            SizedBox(width: 6),
                                            Text("Multi Focus", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBottomControls(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),

                  // [오른쪽] 갤러리 OR 설정 패널
                  Container(
                    width: 320, 
                    // 배경색을 짙은 회색으로 (설정 패널과 어울리게)
                    decoration: BoxDecoration(color: const ui.Color.fromARGB(255, 255, 255, 255), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[800]!)),
                    child: _showSettings 
                        ? _buildSettingsPanel() 
                        : _buildGalleryPanel(isAllSelected),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 위젯들 ---

  Widget _buildGalleryPanel(bool isAllSelected) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [const Icon(LucideIcons.image, color: Colors.black87, size: 16), const SizedBox(width: 8), Text('목록 (${widget.gallery.length})', style: const TextStyle(color: Colors.black87))]),
              Transform.scale(scale: 0.8, child: Checkbox(value: isAllSelected, onChanged: _toggleSelectAll, activeColor: Colors.blueAccent, side: const BorderSide(color: Colors.black87))),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        Expanded(
          child: widget.gallery.isEmpty
              ? const Center(child: Text('이미지 없음', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: widget.gallery.length,
                  itemBuilder: (context, index) {
                    final item = widget.gallery[index];
                    final bool isSelected = _selectedIndices.contains(index);
                    return GestureDetector(
                      onTap: () => _toggleSelection(index),
                      onDoubleTap: () => _openImageViewer(item['data'], item['time']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6), border: isSelected ? Border.all(color: Colors.blueAccent, width: 2) : Border.all(color: Colors.grey[700]!)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(5)), child: Image.memory(item['data'] as Uint8List, height: 100, width: double.infinity, fit: BoxFit.cover)),
                                if (isSelected) Positioned(top: 4, left: 4, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle), child: const Icon(LucideIcons.check, size: 12, color: Colors.white))),
                              ],
                            ),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text(item['time'], style: const TextStyle(color: Colors.white70, fontSize: 12))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _saveImages(saveAll: false), icon: const Icon(LucideIcons.save, size: 16, color: Colors.blueAccent), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blueAccent), padding: const EdgeInsets.symmetric(vertical: 12)), label: Text("저장(${_selectedIndices.length})", style: const TextStyle(color: Colors.blueAccent, fontSize: 12)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(onPressed: _deleteSelectedImages, icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent), padding: const EdgeInsets.symmetric(vertical: 12)), label: const Text("삭제", style: TextStyle(color: Colors.redAccent, fontSize: 12)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.settings2, color: Colors.black87, size: 16),
                  SizedBox(width: 8),
                  Text('카메라 설정', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(LucideIcons.x, color: Colors.grey, size: 16),
                onPressed: () => setState(() => _showSettings = false),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("해상도"),
                Row(
                  children: [
                    Expanded(child: _buildDropdown("실시간", ["1920 x 1080", "1280 x 720", "640 x 480"], _resLive, (v) => setState(() => _resLive = v!))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdown("캡쳐", ["2840 x 2160", "1920 x 1080"], _resCapture, (v) => setState(() => _resCapture = v!))),
                  ],
                ),
                const SizedBox(height: 20),

                _buildSectionTitle("센서 모드"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[700]!), borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_isColorMode ? "컬러" : "흑백", style: const TextStyle(color: Colors.black87)),
                      Switch(
                        value: _isColorMode, 
                        onChanged: (v) => setState(() => _isColorMode = v), 
                        activeColor: Colors.blueAccent
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle("영상 뒤집기"),
                Row(
                  children: [
                    _buildCheckbox("수평", _flipHorizontal, (v) => setState(() => _flipHorizontal = v!)),
                    const SizedBox(width: 24),
                    _buildCheckbox("수직", _flipVertical, (v) => setState(() => _flipVertical = v!)),
                  ],
                ),
                const SizedBox(height: 20),

                _buildSlider("프레임 속도", "느림", "빠름", _frameRate, (v) => setState(() => _frameRate = v)),
                const SizedBox(height: 20),

                _buildSectionTitleWithReset("노출", () => setState(() => _autoExposure = true)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[700]!), borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      Checkbox(value: _autoExposure, onChanged: (v) => setState(() => _autoExposure = v!), side: const BorderSide(color: Colors.grey), activeColor: Colors.blueAccent),
                      const Text("자동 노출", style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitleWithReset("화이트 밸런스", () => setState(() { _wbR = 0.5; _wbG = 0.5; _wbB = 0.5; })),
                _buildSlider("R (Red)", "0", "100", _wbR, (v) => setState(() => _wbR = v)),
                const SizedBox(height: 8),
                _buildSlider("G (Green)", "0", "100", _wbG, (v) => setState(() => _wbG = v)),
                const SizedBox(height: 8),
                _buildSlider("B (Blue)", "0", "100", _wbB, (v) => setState(() => _wbB = v)),

                const SizedBox(height: 20),

                _buildSectionTitleWithReset("블랙 밸런스", () => setState(() { _bbR = 0.5; _bbG = 0.5; _bbB = 0.5; })),
                _buildSlider("R (Red)", "0", "100", _bbR, (v) => setState(() => _bbR = v)),
                const SizedBox(height: 8),
                _buildSlider("G (Green)", "0", "100", _bbG, (v) => setState(() => _bbG = v)),
                const SizedBox(height: 8),
                _buildSlider("B (Blue)", "0", "100", _bbB, (v) => setState(() => _bbB = v)),

                const SizedBox(height: 20),

                _buildSectionTitleWithReset("색상", () => setState(() { _hue = 0.5; _saturation = 0.5; _brightness = 0.5; _contrast = 0.5; _gamma = 0.5; })),
                _buildSlider("색조 (Hue)", "0", "100", _hue, (v) => setState(() => _hue = v)),
                const SizedBox(height: 8),
                _buildSlider("채도 (Saturation)", "0", "100", _saturation, (v) => setState(() => _saturation = v)),
                const SizedBox(height: 8),
                _buildSlider("밝기 (Brightness)", "0", "100", _brightness, (v) => setState(() => _brightness = v)),
                const SizedBox(height: 8),
                _buildSlider("대조 (Contrast)", "0", "100", _contrast, (v) => setState(() => _contrast = v)),
                const SizedBox(height: 8),
                _buildSlider("감마 (Gamma)", "0", "100", _gamma, (v) => setState(() => _gamma = v)),
                
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showSettings = false), 
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.grey)),
                        child: const Text("취소", style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _showSettings = false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("설정이 저장되었습니다.")));
                        },
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.blueAccent)),
                        child: const Text("저장", style: TextStyle(color: Colors.blueAccent)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 헬퍼 함수들 ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Widget _buildSectionTitleWithReset(String title, VoidCallback onReset) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          InkWell(
            onTap: onReset,
            child: const Row(
              children: [
                Icon(LucideIcons.rotateCcw, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text("기본설정", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey[700]!)),
          child: DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            dropdownColor: Colors.grey[50],
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 24, height: 24,
          child: Checkbox(value: value, onChanged: onChanged, side: const BorderSide(color: Colors.grey), activeColor: Colors.blueAccent),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  Widget _buildSlider(String label, String minText, String maxText, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
            Text("${(value * 100).toInt()}%", style: const TextStyle(color: Colors.black87, fontSize: 12)),
          ],
        ),
        Row(
          children: [
            Text(minText, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(trackHeight: 1.5, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6), overlayShape: SliderComponentShape.noOverlay),
                child: Slider(
                  value: value, 
                  onChanged: onChanged, 
                  activeColor: Colors.blueAccent, inactiveColor: Colors.grey[800]
                ),
              ),
            ),
            Text(maxText, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildSwitchTile({required IconData icon, required Color iconColor, required String label, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색을 흰색으로 변경
        border: Border.all(color: Colors.grey[300]!), // 테두리 색상 변경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13), overflow: TextOverflow.ellipsis)),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blueAccent, // 활성 색상
              inactiveThumbColor: Colors.grey[400], // 비활성 색상
              inactiveTrackColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSwitchTile(icon: LucideIcons.focus, iconColor: Colors.green, label: 'Auto Focus', value: _autoFocus, onChanged: (v) => setState(() => _autoFocus = v))),
            const SizedBox(width: 8),
            Expanded(child: _buildSwitchTile(icon: LucideIcons.layers, iconColor: Colors.blue, label: 'Multi Focus', value: _multiFocus, onChanged: (v) => setState(() => _multiFocus = v))),
            const SizedBox(width: 8),
            Expanded(child: _buildSwitchTile(icon: LucideIcons.camera, iconColor: Colors.purple, label: 'Live View', value: _liveView, onChanged: (v) => setState(() => _liveView = v))),
          ],
        ),
        const SizedBox(height: 16),
        Row( 
          children: [
            Expanded(
              flex: 2, 
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(LucideIcons.camera, size: 18),
                  label: const Text('캡처'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87, // 텍스트 색상 검정
                    side: BorderSide(color: Colors.grey[600]!)
                  ),
                  onPressed: _captureImage, 
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1, 
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.settings, size: 18),
                  label: const Text('설정'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, 
                    foregroundColor: _showSettings ? Colors.blueAccent : Colors.black87,
                    side: BorderSide(
                      color: _showSettings ? Colors.blueAccent : Colors.grey[600]!,
                      width: _showSettings ? 1.5 : 1.0, 
                      ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showSettings = !_showSettings; 
                    });
                  }, 
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ImageViewerDialog extends StatelessWidget {
  final Uint8List imageData;
  final String timestamp;
  const ImageViewerDialog({super.key, required this.imageData, required this.timestamp});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.black, insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(panEnabled: true, minScale: 0.5, maxScale: 4.0, child: Image.memory(imageData, fit: BoxFit.contain, width: size.width * 0.9, height: size.height * 0.9)),
          Positioned(top: 0, left: 0, right: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: Colors.black54, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("촬영 시간: $timestamp", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(LucideIcons.x, color: Colors.white), onPressed: () => Navigator.pop(context))]))),
        ],
      ),
    );
  }
}