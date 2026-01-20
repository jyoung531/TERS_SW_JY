import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ImageCaptureDialog extends StatefulWidget {
  final List<Map<String, dynamic>> gallery;
  final VoidCallback onCapture;
  final Function(List<int>) onDelete; // 🗑️

  const ImageCaptureDialog({
    super.key,
    required this.gallery,
    required this.onCapture,
    required this.onDelete,
  });

  @override
  State<ImageCaptureDialog> createState() => _ImageCaptureDialogState();
}

class _ImageCaptureDialogState extends State<ImageCaptureDialog> {
  final Set<int> _selectedIndices = {};

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

  void _openImageViewer(Uint8List imageData, String timestamp) {
    showDialog(
      context: context,
      builder: (context) => ImageViewerDialog(imageData: imageData, timestamp: timestamp),
    );
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
          final String filePath = '$selectedDirectory/capture_${index + 1}_$time.png';
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

  @override
  Widget build(BuildContext context) {
    final bool isAllSelected = widget.gallery.isNotEmpty && _selectedIndices.length == widget.gallery.length;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('촬영된 이미지 (${widget.gallery.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Checkbox(value: isAllSelected, onChanged: (val) => _toggleSelectAll(val), activeColor: Colors.black87), const Text("전체 선택", style: TextStyle(color: Colors.black87))]),
                Text("${_selectedIndices.length}개 선택됨", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Divider(),
            Expanded(
              child: widget.gallery.isEmpty
                  ? const Center(child: Text("촬영된 이미지가 없습니다.", style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      itemCount: widget.gallery.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.0),
                      itemBuilder: (context, index) {
                        final item = widget.gallery[index];
                        final bool isSelected = _selectedIndices.contains(index);
                        return GestureDetector(
                          onTap: () => _toggleSelection(index),
                          onDoubleTap: () => _openImageViewer(item['data'], item['time']),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: isSelected ? Border.all(color: Colors.blueAccent, width: 3) : Border.all(color: Colors.grey[300]!)),
                                child: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.memory(item['data'] as Uint8List, fit: BoxFit.cover)),
                              ),
                              Positioned(top: 8, left: 8, child: Container(width: 24, height: 24, decoration: BoxDecoration(color: isSelected ? Colors.blueAccent : Colors.black54, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white, width: 1.5)), child: isSelected ? const Icon(LucideIcons.check, size: 16, color: Colors.white) : null)),
                              Positioned(bottom: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)), child: Text("#${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 10)))),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Column(
              children: [
                OutlinedButton.icon(onPressed: () { print("측정 개체 클릭"); }, icon: const Icon(LucideIcons.ruler, size: 18, color: Colors.black87), label: const Text("측정 개체", style: TextStyle(color: Colors.black87)), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: Colors.grey))),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: () { print("교정 관리자 클릭"); }, icon: const Icon(LucideIcons.settings2, size: 18, color: Colors.black87), label: const Text("교정 관리자", style: TextStyle(color: Colors.black87)), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), side: const BorderSide(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: ElevatedButton.icon(onPressed: () => _saveImages(saveAll: false), icon: const Icon(LucideIcons.save, size: 18), label: Text("선택 항목 저장 (${_selectedIndices.length})"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
                const SizedBox(width: 16),
                Expanded(child: OutlinedButton.icon(onPressed: _deleteSelectedImages, icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red), label: const Text("선택 삭제", style: TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🔍 이미지 확대 보기 다이얼로그 (중복 방지를 위해 여기에도 포함)
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