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
  
  // 🌟 Dropdown 대신 직접 입력을 받기 위한 변수 (기본값 없음)
  String _researcherName = ""; 

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 기존 DB에 있는 연구원 이름들만 중복 없이 가져오기 (자동완성 추천용)
    final existingResearchers = context.read<DatabaseProvider>()
        .experiments
        .map((e) => e['researcher'].toString())
        .toSet()
        .toList();

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
            
            // 🌟 2. 연구원 입력 (자동완성 기능 포함)
            // 기존 DropdownButtonFormField -> Autocomplete로 변경
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return existingResearchers.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _researcherName = selection;
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onChanged: (val) => _researcherName = val, // 타이핑한 내용 저장
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Researcher Name", // 직접 입력 가능
                    hintText: "Type name (e.g. Dr. Strange)",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.grey[850],
                    elevation: 4.0,
                    child: SizedBox(
                      width: 300,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(option, style: const TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
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
            _saveData();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  void _saveData() {
    final spectrumProvider = context.read<SpectrographProvider>();
    if (!spectrumProvider.hasData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to save!")));
      return;
    }
    
    // 🌟 입력값 검증: 연구원 이름이 비어있으면 안됨
    if (_researcherName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a researcher name.")));
      return;
    }

    final newExperiment = {
      "title": _titleController.text.isEmpty ? "Untitled_Experiment" : _titleController.text,
      "researcher": _researcherName, // 입력받은 이름 저장
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "tags": _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "spectrum": List<double>.from(spectrumProvider.spectrumData),
    };

    context.read<DatabaseProvider>().addExperiment(newExperiment);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Saved to Database!")));
  }
}