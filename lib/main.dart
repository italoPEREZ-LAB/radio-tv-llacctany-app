
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'screens/main_navigation.dart';
import 'screens/auth/restablecer_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('PASO 1: Flutter inicializado');

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError('Faltan las variables de Supabase');
  }

  debugPrint('PASO 2: Configuración Supabase encontrada');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  debugPrint('PASO 3: Supabase inicializado correctamente');

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.radiollacctany.audio',
    androidNotificationChannelName: 'Radio Llacctany en vivo',
    androidNotificationOngoing: true,
  );

  debugPrint('PASO 4: Audio inicializado correctamente');

  runApp(const RadioLlacctanyApp());

  debugPrint('PASO 5: runApp ejecutado');
}

class RadioLlacctanyApp extends StatefulWidget {
  const RadioLlacctanyApp({super.key});

  @override
  State<RadioLlacctanyApp> createState() =>
      _RadioLlacctanyAppState();
}

class _RadioLlacctanyAppState extends State<RadioLlacctanyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  StreamSubscription<AuthState>? _authSubscription;

  bool _recuperacionAbierta = false;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          debugPrint('Recuperación de contraseña detectada');

          _abrirPantallaRecuperacion();
        }
      },
      onError: (Object error) {
        debugPrint('Error de autenticación: $error');
      },
    );
  }

  void _abrirPantallaRecuperacion() {
    if (_recuperacionAbierta) return;

    _recuperacionAbierta = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _recuperacionAbierta = false;
        return;
      }

      final navigator = _navigatorKey.currentState;

      if (navigator == null) {
        _recuperacionAbierta = false;
        return;
      }

      try {
        await navigator.push(
          MaterialPageRoute<bool>(
            builder: (_) =>
                const RestablecerPasswordScreen(),
          ),
        );
      } finally {
        _recuperacionAbierta = false;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Radio TV Estación Llacctany',
      theme: AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}
