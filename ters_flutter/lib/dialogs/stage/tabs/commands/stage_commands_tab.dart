import 'package:flutter/material.dart';
import 'manual_move_tab.dart'; 

class StageCommandsTab extends StatelessWidget {
  // 🌟 상위에서 컨트롤러 받기
  final TextEditingController xCtrl;
  final TextEditingController yCtrl;
  final TextEditingController zCtrl;

  const StageCommandsTab({
    super.key,
    required this.xCtrl,
    required this.yCtrl,
    required this.zCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.grey,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            labelPadding: EdgeInsets.symmetric(horizontal: 56.0),
            tabs: [
              Tab(text: "Manual Move"),
              Tab(text: "Command Terminal"),
              Tab(text: "Meander"),
              Tab(text: "Position List"),
              Tab(text: "I/O"),
            ],
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 🌟 컨트롤러 전달
                ManualMoveTab(
                  xCtrl: xCtrl,
                  yCtrl: yCtrl,
                  zCtrl: zCtrl,
                ), 
                const Center(child: Text("Command Terminal View")),
                const Center(child: Text("Meander View")),
                const Center(child: Text("Position List View")),
                const Center(child: Text("I/O View")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}