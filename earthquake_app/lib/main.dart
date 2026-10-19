import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/app_data_provider.dart';

void main() => runApp(const EarthquakeApp());

class EarthquakeApp extends StatelessWidget {
  const EarthquakeApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AppDataProvider(),
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Earthquake App',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    builder: EasyLoading.init(),
    home: const HomePage(),
  );
}
