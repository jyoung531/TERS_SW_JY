// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 필수
import 'package:intl/date_symbol_data_local.dart';

// [필수] 우리가 만든 Provider들 import
import 'package:ters_flutter/providers/camera_provider.dart';
import 'package:ters_flutter/providers/device_status_provider.dart'; // 👈 [추가된 부분]
import 'package:ters_flutter/screens/home_screen.dart';
import 'package:ters_flutter/providers/spectrograph_provider.dart';
import 'package:ters_flutter/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  runApp(
    MultiProvider(
      providers: [
        // 1. 카메라 관리자
        ChangeNotifierProvider(create: (_) => CameraProvider()),

        // 2. 장비 상태 관리자
        // create 뒤에 ..initialize()를 붙이면 앱 켜지자마자 연결을 시도
        ChangeNotifierProvider(create: (_) => DeviceStatusProvider()..initialize()),

        ChangeNotifierProvider(create: (_) => SpectrographProvider()),

        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TERS-SW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.tealAccent,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white70,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}