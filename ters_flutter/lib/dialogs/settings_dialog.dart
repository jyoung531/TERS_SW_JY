import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ters_flutter/providers/database_provider.dart';
import 'package:ters_flutter/providers/spectrograph_provider.dart';

class SaveMeasurementDialog extends StatefulWidget {
  const SaveMeasurementDialog({super.key});

  @override
  State<SaveMeasurementDialog> createState() => _SaveMeasurementDialogState();
}

class _SaveMeasurementDialogState extends State<SaveMeasurementDialog> {
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  String _researcher = "Dr. Kim"; // 기본값

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E20),
      title: const Row(
        children: [
          Icon(LucideIcons.save, color: Colors.tealAccent),
          SizedBox(width: 10),
          Text("Save Measurement", style: TextStyle(color: Colors.white)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 제목 입력
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Experiment Title",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
              ),
            ),
            const SizedBox(height: 16),
            
            // 2. 연구원 선택
            DropdownButtonFormField<String>(
              value: _researcher,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Researcher",
                labelStyle: TextStyle(color: Colors.grey),
              ),
              items: ["Dr. Kim", "Researcher Lee", "Student Park"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _researcher = val!),
            ),
            const SizedBox(height: 16),

            // 3. 태그 입력
            TextField(
              controller: _tagsController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Tags (comma separated)",
                hintText: "e.g. Raman, 2D, Noise",
                hintStyle: TextStyle(color: Colors.grey),
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: () {
            // 🌟 [핵심] 실제 저장 로직
            _saveData();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  void _saveData() {
    // 1. 현재 측정된 데이터 가져오기
    final spectrumProvider = context.read<SpectrographProvider>();
    if (!spectrumProvider.hasData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to save!")));
      return;
    }

    // 2. 저장할 객체 만들기
    final newExperiment = {
      "title": _titleController.text.isEmpty ? "Untitled_Experiment" : _titleController.text,
      "researcher": _researcher,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()), // 오늘 날짜
      "tags": _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "spectrum": List<double>.from(spectrumProvider.spectrumData), // 데이터 복사
    };

    // 3. DB Provider에 추가
    context.read<DatabaseProvider>().addExperiment(newExperiment);

    // 4. 닫기 & 알림
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Saved to Database!")));
  }
}