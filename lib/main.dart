
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'core/app_theme.dart';
import 'screens/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa el servicio de reproducción en segundo plano.
  await JustAudioBackground.init(
    androidNotificationChannelId:
    'com.radiollacctany.audio',
    androidNotificationChannelName:
    'Radio Llacctany en vivo',
    androidNotificationOngoing: true,
  );

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
