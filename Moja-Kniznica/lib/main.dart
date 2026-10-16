import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/library_provider.dart';
import 'services/library_storage.dart';
import 'screens/library_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key, this.storage});
  final LibraryStorage? storage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryProvider(storage ?? JsonLibraryStorage())..load(),
      child: MaterialApp(
        title: 'Moja knižnica',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F5EF),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF275C4D)),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F5EF),
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        home: const LibraryScreen(),
      ),
    );
  }
}
