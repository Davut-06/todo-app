import 'package:flutter/material.dart';
import 'package:app_todo/screens/home.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  //This widget is the root of my application
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return MaterialApp(
      // === НАСТРОЙКИ ЛОКАЛИЗАЦИИ ===

      // 1. Делегаты: Указываем Flutter, как загружать локализованные строки.
      localizationsDelegates: const [
        // Делегат, сгенерированный Flutter (наши строки)
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 2. Поддерживаемые локали: Список языков, которые поддерживает приложение.
      supportedLocales: const [
        Locale('en', ''), // Английский
        Locale('ru', ''), // Русский
        Locale('tk', ''), // Туркменский (как мы обсуждали)
      ],

      // === ОСТАЛЬНЫЕ НАСТРОЙКИ ===
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: 'ToDo App',
      home: const Home(),
    );
  }
}
