import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ManualMoveTab extends StatefulWidget {
  // 🌟 컨트롤러 받기
  final TextEditingController xCtrl;
  final TextEditingController yCtrl;
  final TextEditingController zCtrl;

  const ManualMoveTab({
    super.key,
    required this.xCtrl,
    required this.yCtrl,
    required this.zCtrl,
  });

  @override
  State<ManualMoveTab> createState() => _ManualMoveTabState();
}

class _ManualMoveTabState extends State<ManualMoveTab> {
  bool _toggleX = true;
  bool _toggleY = true;
  bool _toggleZ = true;
  
  // ❗️ 여기서 컨트롤러를 새로 생성하지 않고, widget.xCtrl 등을 사용합니다.

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [왼쪽 영역]
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Positioning"),
                // 🌟 받은 컨트롤러(widget.xCtrl) 사용
                _buildPositionInput("X", _toggleX, (v) => setState(() => _toggleX = v), widget.xCtrl),
                const SizedBox(height: 12),
                _buildPositionInput("Y", _toggleY, (v) => setState(() => _toggleY = v), widget.yCtrl),
                const SizedBox(height: 12),
                _buildPositionInput("Z", _toggleZ, (v) => setState(() => _toggleZ = v), widget.zCtrl),
                
                const SizedBox(height: 24),
                _buildSectionTitle("Move"),
                _buildButtonGrid(["Absolute", "Relative", "Center", "Home"]),

                const SizedBox(height: 24),
                _buildSectionTitle("Set/Get"),
                _buildButtonGrid(["Set Pos", "Set Zero", "Edit Home", "Pos → Home"]),
              ],
            ),
          ),
        ),

        const SizedBox(width: 24),

        // [오른쪽 영역]
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Cursor-Joystick Function"),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Text("X/Y Axis", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildJoystickPad(),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      const Text("Z Axis", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildZAxisControl(),
                    ],
                  ),
                ],
              ),
              
              const Spacer(),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current Position", style: TextStyle(color: Colors.white, fontSize: 14)),
                    SizedBox(height: 12),
                    _PositionDisplayRow(label: "X:", value: "0.000 mm"),
                    SizedBox(height: 8),
                    _PositionDisplayRow(label: "Y:", value: "0.000 mm"),
                    SizedBox(height: 8),
                    _PositionDisplayRow(label: "Z:", value: "0.000 mm"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 헬퍼 위젯들 ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPositionInput(String axis, bool value, ValueChanged<bool> onChanged, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value, 
              onChanged: onChanged, 
              activeColor: Colors.white, 
              activeTrackColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 8),
          Text(axis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200], 
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text("mm", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildButtonGrid(List<String> labels) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 3.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: labels.map((label) => OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      )).toList(),
    );
  }

  Widget _buildJoystickPad() {
    return Column(
      children: [
        Row(children: [_joyBtn(LucideIcons.cornerUpLeft), const SizedBox(width: 8), _joyBtn(LucideIcons.chevronUp), const SizedBox(width: 8), _joyBtn(LucideIcons.cornerUpRight)]),
        const SizedBox(height: 8),
        Row(children: [_joyBtn(LucideIcons.chevronLeft), const SizedBox(width: 8), _joyCenterBtn(), const SizedBox(width: 8), _joyBtn(LucideIcons.chevronRight)]),
        const SizedBox(height: 8),
        Row(children: [_joyBtn(LucideIcons.cornerDownLeft), const SizedBox(width: 8), _joyBtn(LucideIcons.chevronDown), const SizedBox(width: 8), _joyBtn(LucideIcons.cornerDownRight)]),
      ],
    );
  }

  Widget _buildZAxisControl() {
    return Column(
      children: [
        _joyBtn(LucideIcons.chevronUp),
        const SizedBox(height: 8),
        _joyBtn(LucideIcons.chevronDown),
      ],
    );
  }

  Widget _joyBtn(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }

  Widget _joyCenterBtn() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[900], 
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(LucideIcons.circle, size: 10, color: Colors.grey),
    );
  }
}

class _PositionDisplayRow extends StatelessWidget {
  final String label;
  final String value;
  const _PositionDisplayRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'monospace')),
      ],
    );
  }
}