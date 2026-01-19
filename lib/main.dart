import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const JrnlApp());
}

class JrnlApp extends StatelessWidget {
  const JrnlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JournalProvider(),
      child: MaterialApp(
        title: 'jrnl droid',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system, // Respect system setting
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.blueGrey,
          fontFamily: 'Roboto', // Default, but good for clean typography
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blueGrey,
          // Ensure dark background is truly dark for "late-night journaling"
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}