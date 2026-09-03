import 'package:flutter/material.dart';

import 'ui/home/home_screen.dart';

class ResumeGeneratorApp extends StatelessWidget {
  const ResumeGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF0000FF);
    return MaterialApp(
      title: 'Resume Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
