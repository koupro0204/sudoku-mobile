import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sudoku_assistant/views/home_page_screen.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures plugin services are initialized
  await MobileAds.instance.initialize();
  await Firebase.initializeApp(); // Initialize Firebase
  await LocalStorageService.initialize(); // Initialize local storage service

  runApp(const SudokuAssistantApp());
}

class SudokuAssistantApp extends StatelessWidget {
  const SudokuAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''), //日本語
        Locale('en', ''), //英語
        Locale('zh', ''), //中国語
        Locale('ar', ''), //アラビア語
      ],
      title: 'Sudoku Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white.withOpacity(0.95),
      ),
      home: MyHomePage(), // The first screen displayed when the app is launched
    );
  }
}
// settingsを作成する。
// 利用規約、プライバシーポリシー
// バージョン情報、言語設定、テーマカラー設定
// アプリの評価、お問い合わせ、アプリのシェア