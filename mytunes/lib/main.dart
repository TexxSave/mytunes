import 'package:flutter/material.dart';
import 'screens/library_screen.dart';

void main() {
  runApp(const MyTunesApp());
}

class MyTunesApp extends StatelessWidget {
  const MyTunesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTunes',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LibraryScreen(),
    );
  }
}
