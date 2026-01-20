import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'tabs/commands/stage_commands_tab.dart'; 

class StageControllerDialog extends StatefulWidget {
  // 🌟 설정값과 저장 콜백 받기
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSaved;

  const StageControllerDialog({
    super.key,
    required this.settings,
    required this.onSaved,
  });

  @override
  State<StageControllerDialog> createState() => _StageControllerDialogState();
}

class _StageControllerDialogState extends State<StageControllerDialog> {
  bool _isConnected = false;
  String _selectedPort = 'COM4'; 

  // 🌟 컨트롤러를 상위(여기)에서 생성하여 하위 위젯으로 내림
  late TextEditingController _xController;
  late TextEditingController _yController;
  late TextEditingController _zController;

  @override
  void initState() {
    super.initState();
    // 초기값 세팅
    _xController = TextEditingController(text: widget.settings['x']);
    _yController = TextEditingController(text: widget.settings['y']);
    _zController = TextEditingController(text: widget.settings['z']);
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _zController.dispose();
    super.dispose();
  }

  // 💾 저장 버튼 클릭 시
  void _handleSave() {
    widget.onSaved({
      'x': _xController.text,
      'y': _yController.text,
      'z': _zController.text,
    });
  }

  // 🔄 초기화 버튼 클릭 시 (원래 값으로 복구)
  void _handleReset() {
    setState(() {
      _xController.text = widget.settings['x'];
      _yController.text = widget.settings['y'];
      _zController.text = widget.settings['z'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return _buildConnectionDialog();
    } else {
      return _buildMainControllerDialog();
    }
  }

  Widget _buildConnectionDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Container(
        width: 400,
        height: 250,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('스테이지 제어 시스템', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Serial Port 선택", style: TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPort,
                  isExpanded: true,
                  style: TextStyle(color: Colors.grey[850], fontSize: 14, fontWeight: FontWeight.w500),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  icon: const Icon(LucideIcons.chevronDown, size: 16),
                  items: ['COM1', 'COM2', 'COM3', 'COM4', 'COM5']
                      .map((e) => DropdownMenuItem(value: e, child: Text("$e ${e == 'COM4' ? '(권장)' : ''}")))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPort = v!),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => setState(() => _isConnected = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("기기 연결"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainControllerDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(24.0),
        child: DefaultTabController(
          length: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (타이틀 + 아이콘 버튼들)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('스테이지 제어 시스템', style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)),
                        child: Text(_selectedPort, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      )
                    ],
                  ),
                  
                  // 🌟 [우측 상단 버튼들] 초기화 / 저장 / 닫기
                  Row(
                    children: [
                      IconButton(
                        onPressed: _handleReset,
                        icon: const Icon(LucideIcons.rotateCcw, color: Colors.grey, size: 20),
                        tooltip: "초기화",
                      ),
                      IconButton(
                        onPressed: _handleSave,
                        icon: const Icon(LucideIcons.save, color: Colors.blueAccent, size: 20),
                        tooltip: "저장",
                      ),
                      const SizedBox(width: 8), // 간격
                      Container(width: 1, height: 20, color: Colors.grey[300]), // 구분선
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.x, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 메인 탭바
              Container(
                height: 45,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25.0)),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey[600],
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: "Commands"),
                    Tab(text: "Setup"),
                    Tab(text: "Diagnosis"),
                    Tab(text: "Connect"),
                    Tab(text: "Info"),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 메인 탭 뷰
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // 🌟 컨트롤러 전달
                    StageCommandsTab(
                      xCtrl: _xController,
                      yCtrl: _yController,
                      zCtrl: _zController,
                    ),
                    const Center(child: Text("Setup View")),
                    const Center(child: Text("Diagnosis View")),
                    const Center(child: Text("Connect View")),
                    const Center(child: Text("Info View")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}