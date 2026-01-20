import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class SpectrumSettingsDialog extends StatefulWidget {
  // 🌟 [추가됨] 설정값과 업데이트 함수 받기
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const SpectrumSettingsDialog({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SpectrumSettingsDialog> createState() => _SpectrumSettingsDialogState();
}

class _SpectrumSettingsDialogState extends State<SpectrumSettingsDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- 상태 변수들 ---
  // 1. Grating
  late TextEditingController _linesController;
  late TextEditingController _blazeController;
  late TextEditingController _densityController;
  late TextEditingController _modelController;

  // 2. Calibrate
  late String _measureMode; // 'Raman' or 'Wavelength'
  late TextEditingController _laserWavelengthController;
  late TextEditingController _offsetController;

  // 3. Acquisition
  late String _acquisitionMode; // 'Accumulate' or 'Kinetic'
  late TextEditingController _accumulateCountController;
  late TextEditingController _exposureTimeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 🌟 [추가됨] 부모로부터 받은 설정값으로 초기화
    _linesController = TextEditingController(text: widget.settings['lines']);
    _blazeController = TextEditingController(text: widget.settings['blaze']);
    _densityController = TextEditingController(text: widget.settings['density']);
    _modelController = TextEditingController(text: widget.settings['model']);
    
    _measureMode = widget.settings['measureMode'] ?? 'Raman';
    _laserWavelengthController = TextEditingController(text: widget.settings['laserWavelength']);
    _offsetController = TextEditingController(text: widget.settings['offset']);

    _acquisitionMode = widget.settings['acquisitionMode'] ?? 'Accumulate';
    _accumulateCountController = TextEditingController(text: widget.settings['accumulateCount']);
    _exposureTimeController = TextEditingController(text: widget.settings['exposureTime']);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _linesController.dispose();
    _blazeController.dispose();
    _densityController.dispose();
    _modelController.dispose();
    _laserWavelengthController.dispose();
    _offsetController.dispose();
    _accumulateCountController.dispose();
    _exposureTimeController.dispose();
    super.dispose();
  }

  // 🌟 [추가됨] 설정값 저장 함수 (모든 탭에서 공통 사용)
  void _saveSettings() {
    final newSettings = {
      'lines': _linesController.text,
      'blaze': _blazeController.text,
      'density': _densityController.text,
      'model': _modelController.text,
      'measureMode': _measureMode,
      'laserWavelength': _laserWavelengthController.text,
      'offset': _offsetController.text,
      'acquisitionMode': _acquisitionMode,
      'accumulateCount': _accumulateCountController.text,
      'exposureTime': _exposureTimeController.text,
    };

    widget.onSettingsChanged(newSettings); // 부모 업데이트
    Navigator.pop(context); // 닫기
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Container(
        width: 500,
        height: 650, // 내용에 따라 높이 조절 가능
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 헤더 (타이틀 & 닫기 버튼)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '측정 설정',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. 탭 바 (커스텀 디자인 적용)
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent, // 탭 바 아래 기본 선 제거
                indicatorSize: TabBarIndicatorSize.tab, // 탭 전체를 채우도록
                padding: const EdgeInsets.all(4), // 인디케이터 주변 여백
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.grid3x3, size: 18), // 아이콘 변경 가능
                        SizedBox(width: 8),
                        Text("Grating"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.target, size: 18),
                        SizedBox(width: 8),
                        Text("Calibrate"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.layers, size: 18),
                        SizedBox(width: 8),
                        Text("Acquisition"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. 탭 뷰 (각 탭의 내용)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGratingTab(),
                  _buildCalibrateTab(),
                  _buildAcquisitionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 탭별 내용 위젯 ---

  // 1. Grating 탭
  Widget _buildGratingTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField("Lines/mm", "예: 1200", _linesController),
        const SizedBox(height: 16),
        _buildTextField("Blaze Wavelength (nm)", "예: 500", _blazeController),
        const SizedBox(height: 16),
        _buildTextField("Groove Density", "예: 300", _densityController),
        const SizedBox(height: 16),
        _buildTextField("Model / Serial", "예: GR-1200-500", _modelController),
        const Spacer(),
        _buildActionButton("저장", _saveSettings), // 🌟 저장 함수 연결
      ],
    );
  }

  // 2. Calibrate 탭
  Widget _buildCalibrateTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("측정 모드", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        // 커스텀 라디오 버튼 그룹
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RadioListTile<String>(
            title: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(text: "Raman ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "Raman shift 측정 모드", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            value: 'Raman',
            groupValue: _measureMode,
            onChanged: (value) => setState(() => _measureMode = value!),
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RadioListTile<String>(
            title: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 16),
                children: [
                  TextSpan(text: "Wavelength ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "파장 측정 모드", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            value: 'Wavelength',
            groupValue: _measureMode,
            onChanged: (value) => setState(() => _measureMode = value!),
            activeColor: Colors.black,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField("Laser Wavelength (nm)", "예: 532", _laserWavelengthController),
        const SizedBox(height: 16),
        _buildTextField("Offset", "예: 0", _offsetController),
        const Spacer(),
        _buildActionButton("보정 실행", _saveSettings), // 🌟 저장 함수 연결 (보정 실행도 저장으로 처리)
      ],
    );
  }

  // 3. Acquisition 탭
  // 3. Acquisition 탭
  Widget _buildAcquisitionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("수집 모드", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _acquisitionMode,
          
          // 🌟 1. [글자색 변경] 선택된 텍스트 색상 (grey[850])
          style: TextStyle(color: Colors.grey[850], fontSize: 14, fontWeight: FontWeight.w500),
          
          // 🌟 2. [드롭다운 스타일 변경] 배경색 연하게 & 모서리 둥글게
          dropdownColor: Colors.white, // 팝업 메뉴 배경색 (기존 블랙 -> 화이트)
          borderRadius: BorderRadius.circular(8), // 팝업 메뉴 모서리 (0 -> 8)
          
          // 🌟 3. [아이콘 색상] 화살표도 잘 보이게 변경
          icon: Icon(LucideIcons.chevronDown, size: 16, color: Colors.grey[600]),

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: [
            DropdownMenuItem(
              value: 'Accumulate', 
              // 🌟 4. [리스트 글자색] 메뉴 안의 글자도 잘 보이게 설정
              child: Text("Accumulate (누적 측정 모드)", style: TextStyle(color: Colors.grey[850]))
            ),
            DropdownMenuItem(
              value: 'Kinetic', 
              child: Text("Kinetic (연속 측정 모드)", style: TextStyle(color: Colors.grey[850]))
            ),
          ],
          onChanged: (value) => setState(() => _acquisitionMode = value!),
        ),
        const SizedBox(height: 16),
        _buildTextField("누적 횟수", "10", _accumulateCountController),
        const SizedBox(height: 16),
        _buildTextField("노출 시간 (ms)", "100", _exposureTimeController),
        const Spacer(),
        _buildActionButton("적용", _saveSettings), 
      ],
    );
  }
  // --- 공통 UI 컴포넌트 ---

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number, // 숫자 키패드
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F172A), // 짙은 남색 (Figma 스타일)
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: Text(text),
      ),
    );
  }
}