
import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const RadioLlacctanyApp());
}

class RadioLlacctanyApp extends StatelessWidget {
  const RadioLlacctanyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Radio TV Estación Llacctany',

      theme: AppTheme.darkTheme,

      home: const MainNavigation(),
    );
  }
}