import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart'; // [필수] Provider 패키지
import 'package:ters_flutter/dialogs/spectrum_analysis_dialog.dart';
import 'package:ters_flutter/providers/database_provider.dart'; // [필수] DatabaseProvider

class DatabaseViewDialog extends StatefulWidget {
  const DatabaseViewDialog({super.key});

  @override
  State<DatabaseViewDialog> createState() => _DatabaseViewDialogState();
}

class _DatabaseViewDialogState extends State<DatabaseViewDialog> {
  // --- 상태 변수 ---
  String _searchQuery = "";
  String _selectedResearcher = "All"; // 초기값 All
  
  // 선택된 아이템들의 ID를 저장하는 Set
  final Set<int> _selectedIds = {};

  // 🔍 필터링 로직 (Provider의 데이터를 받아서 필터링)
  List<Map<String, dynamic>> _getFilteredList(List<Map<String, dynamic>> allData) {
    return allData.where((item) {
      final titleMatch = item["title"].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      // 태그 검색 (리스트 내부 검색)
      final tagMatch = (item["tags"] as List).any((tag) => 
          tag.toString().toLowerCase().contains(_searchQuery.toLowerCase()));
          
      // All이면 통과, 아니면 이름 일치 확인
      final researcherMatch = _selectedResearcher == "All" || item["researcher"] == _selectedResearcher;

      return (titleMatch || tagMatch) && researcherMatch;
    }).toList();
  }

  // 🗑️ 삭제 기능 (Provider 호출)
  void _deleteSelectedItems() {
    // Provider에게 삭제 요청
    context.read<DatabaseProvider>().deleteExperiments(_selectedIds);
    
    // 선택 목록 초기화
    setState(() {
      _selectedIds.clear();
    });
  }

  // ✏️ 수정 팝업 띄우기
  void _showEditDialog() {
    // Provider에서 현재 전체 데이터 가져오기
    final allData = context.read<DatabaseProvider>().experiments;
    
    // 선택된 1개의 아이템 찾기
    final selectedId = _selectedIds.first;
    final index = allData.indexWhere((item) => item['id'] == selectedId);
    
    if (index == -1) return; // 혹시 데이터가 없으면 리턴

    final item = allData[index];
    
    // 텍스트 컨트롤러 초기화 (기존 값 채워넣기)
    final titleController = TextEditingController(text: item['title']);
    final tagsController = TextEditingController(text: (item['tags'] as List).join(", ")); 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E20),
        title: const Text("Edit Entry", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 수정
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
              ),
            ),
            const SizedBox(height: 16),
            // 태그 수정
            TextField(
              controller: tagsController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Tags (comma separated)",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.tealAccent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              // 1. 입력된 태그 문자열을 리스트로 변환
              List<String> newTags = tagsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              // 2. Provider를 통해 데이터 업데이트
              context.read<DatabaseProvider>().updateExperiment(
                selectedId, 
                titleController.text, 
                newTags
              );
              
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📡 [핵심] Provider 구독 (데이터가 변경되면 화면 자동 갱신)
    final dbProvider = context.watch<DatabaseProvider>();
    final allData = dbProvider.experiments;

    // 🌟 [핵심] DB에 있는 연구원 이름 목록을 실시간으로 추출
    // 1. 모든 데이터에서 'researcher' 값만 뽑음
    // 2. toSet()으로 중복 제거
    // 3. toList()로 리스트 변환
    final List<String> researcherList = ["All"] + 
        allData.map((e) => e['researcher'].toString()).toSet().toList();

    // 만약 현재 선택된 필터(_selectedResearcher)가 삭제되어서 목록에 없다면 'All'로 초기화
    if (!researcherList.contains(_selectedResearcher)) {
      _selectedResearcher = "All";
    }

    final filteredList = _getFilteredList(allData);

    return Dialog(
      backgroundColor: const Color(0xFF1E1E20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 900,
        height: 700,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. 헤더 (타이틀 + 액션 버튼들)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.database, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Text("Measurement Database", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                
                // 🌟 액션 버튼 그룹 (수정/삭제/닫기)
                Row(
                  children: [
                    // ✏️ 수정 버튼 (딱 1개 선택했을 때만 활성화)
                    if (_selectedIds.length == 1)
                      IconButton(
                        tooltip: "Edit",
                        onPressed: _showEditDialog,
                        icon: const Icon(LucideIcons.pencil, color: Colors.tealAccent), // 아이콘 수정됨
                      ),
                    
                    // 🗑️ 삭제 버튼 (1개 이상 선택했을 때 활성화)
                    if (_selectedIds.isNotEmpty)
                      IconButton(
                        tooltip: "Delete",
                        onPressed: _deleteSelectedItems,
                        icon: const Icon(LucideIcons.trash2, color: Colors.redAccent),
                      ),
                    
                    const SizedBox(width: 16), // 간격
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 30),

            // 2. 툴바 (검색창 + 필터)
            Row(
              children: [
                // 🔍 검색창
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                      hintText: "Search by title or tags...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 👤 연구원 필터 (동적 생성)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedResearcher,
                      dropdownColor: Colors.grey[900],
                      icon: const Icon(LucideIcons.fileX, size: 16, color: Colors.tealAccent),
                      style: const TextStyle(color: Colors.white),
                      
                      // 👇 여기가 핵심: 고정 리스트 대신 추출한 researcherList 사용
                      items: researcherList.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      
                      onChanged: (value) { if (value != null) setState(() => _selectedResearcher = value); },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. 리스트 헤더
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.grey[850],
              child: const Row(
                children: [
                  SizedBox(width: 30), // 체크박스 공간 확보
                  Expanded(flex: 1, child: Text("ID", style: TextStyle(color: Colors.grey))),
                  Expanded(flex: 4, child: Text("Title / Tags", style: TextStyle(color: Colors.grey))),
                  Expanded(flex: 2, child: Text("Researcher", style: TextStyle(color: Colors.grey))),
                  Expanded(flex: 2, child: Text("Date", style: TextStyle(color: Colors.grey))),
                ],
              ),
            ),

            // 4. 리스트 아이템 (Provider 데이터 표시)
            Expanded(
              child: filteredList.isEmpty 
                  ? const Center(child: Text("No data found.", style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final isSelected = _selectedIds.contains(item['id']);

                        return InkWell(
                          onTap: () {
                            // 클릭 시 상세 보기 (추후 ID 기반 데이터 로딩 필요)
                            showDialog(context: context, builder: (context) => const SpectrumAnalysisDialog());
                          },
                          hoverColor: Colors.white10,
                          child: Container(
                            color: isSelected ? Colors.teal.withOpacity(0.1) : null, // 선택 배경색
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                // ☑️ 체크박스
                                SizedBox(
                                  width: 30,
                                  height: 24,
                                  child: Checkbox(
                                    value: isSelected,
                                    activeColor: Colors.teal,
                                    checkColor: Colors.white,
                                    side: const BorderSide(color: Colors.grey),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedIds.add(item['id']);
                                        } else {
                                          _selectedIds.remove(item['id']);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                Expanded(flex: 1, child: Text("#${item['id']}", style: TextStyle(color: Colors.grey[400]))),
                                Expanded(
                                  flex: 4, 
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      // 태그 칩
                                      Wrap(
                                        spacing: 4,
                                        children: (item['tags'] as List).map<Widget>((tag) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                          child: Text("#$tag", style: const TextStyle(color: Colors.tealAccent, fontSize: 10)),
                                        )).toList(),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(flex: 2, child: Text(item['researcher'], style: const TextStyle(color: Colors.white70))),
                                Expanded(flex: 2, child: Text(item['date'], style: TextStyle(color: Colors.grey[500], fontSize: 12))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}