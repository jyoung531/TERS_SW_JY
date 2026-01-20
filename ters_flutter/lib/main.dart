import 'package:flutter/material.dart';
import 'package:ters_flutter/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TERS-SW',
      debugShowCheckedModeBanner: false, // 디버그 배너 숨기기
      theme: ThemeData(
        // 전체 테마를 어둡게 설정합니다.
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // 기본 배경색
        primaryColor: Colors.tealAccent, // 포인트 컬러 (임의 지정)

        // 텍스트 테마 설정
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        // ListTile (사이드바 메뉴) 테마
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white70,
        ),
      ),
      home: const HomeScreen(), // 앱이 시작되면 HomeScreen을 보여줍니다.
    );
  }
}

