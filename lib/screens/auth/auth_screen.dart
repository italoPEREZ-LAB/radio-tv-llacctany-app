
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _esRegistro = false;
  bool _cargando = false;
  bool _mostrarPassword = false;

  final _supabase = Supabase.instance.client;
Future<void> _recuperarPassword() async {
  final correoController = TextEditingController(
    text: _correoController.text.trim(),
  );

  try {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool enviando = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Recuperar contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresa tu correo electrónico para recibir '
                    'un enlace de recuperación.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: enviando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: enviando
                      ? null
                      : () async {
                          final correo =
                              correoController.text.trim();

                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(correo)) {
                            ScaffoldMessenger.of(this.context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ingresa un correo válido',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => enviando = true);

                          try {
                            await _supabase.auth
                                .resetPasswordForEmail(
                              correo,
                              redirectTo:
                                  'radiollacctany://reset-password',
                            );

                            if (!mounted) return;

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            ScaffoldMessenger.of(this.context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Solicitud enviada. Revisa tu '
                                  'correo y la carpeta de spam.',
                                ),
                              ),
                            );
                          } on AuthException catch (error) {
                            if (!mounted ||
                                !dialogContext.mounted) {
                              return;
                            }

                            setDialogState(
                              () => enviando = false,
                            );

                            ScaffoldMessenger.of(this.context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(error.message),
                              ),
                            );
                          } catch (_) {
                            if (!mounted ||
                                !dialogContext.mounted) {
                              return;
                            }

                            setDialogState(
                              () => enviando = false,
                            );

                            ScaffoldMessenger.of(this.context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo solicitar la '
                                  'recuperación.',
                                ),
                              ),
                            );
                          }
                        },
                  child: enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Enviar enlace'),
                ),
              ],
            );
          },
        );
      },
    );
  } finally {
    correoController.dispose();
  }
}
  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _autenticar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final correo = _correoController.text.trim();
      final password = _passwordController.text;

      if (_esRegistro) {
        final respuesta = await _supabase.auth.signUp(
          email: correo,
          password: password,
          data: {
            'nombre': _nombreController.text.trim(),
          },
        );

        if (!mounted) return;

        if (respuesta.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registro recibido. Revisa tu correo '
                'para confirmar tu cuenta.',
              ),
            ),
          );

          setState(() => _esRegistro = false);
          return;
        }
      } else {
        await _supabase.auth.signInWithPassword(
          email: correo,
          password: password,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on AuthException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo completar la operación. '
            'Inténtalo nuevamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esRegistro ? 'Crear cuenta' : 'Iniciar sesión',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      AssetImage('assets/images/logo_radio.jpg'),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Radio TV Estación Llacctany',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                if (_esRegistro) ...[
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final correo = valor?.trim() ?? '';
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(correo)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_mostrarPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _mostrarPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _mostrarPassword = !_mostrarPassword;
                        });
                      },
                    ),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                if (!_esRegistro)
  Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: _cargando ? null : _recuperarPassword,
      child: const Text('¿Olvidaste tu contraseña?'),
    ),
  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _autenticar,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: _cargando
                          ? const CircularProgressIndicator()
                          : Text(
                              _esRegistro
                                  ? 'Registrarme'
                                  : 'Iniciar sesión',
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _cargando
                      ? null
                      : () {
                          setState(() {
                            _esRegistro = !_esRegistro;
                          });
                        },
                  child: Text(
                    _esRegistro
                        ? '¿Ya tienes cuenta? Inicia sesión'
                        : '¿No tienes cuenta? Regístrate',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
