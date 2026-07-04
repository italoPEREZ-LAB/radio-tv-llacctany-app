
import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/home/home_radio_live_screen.dart';

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

      home: const HomeRadioLiveScreen(),
    );
  }
}