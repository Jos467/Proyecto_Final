import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarEstadoInicial();
  }

  Future<void> _verificarEstadoInicial() async {
    // Esperar un momento para mostrar el splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Verificar si ya aceptó la política de privacidad
    final prefs = await SharedPreferences.getInstance();
    final politicaAceptada = prefs.getBool('politica_aceptada') ?? false;

    if (!politicaAceptada) {
      // Primera vez: mostrar política de privacidad
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/politica-inicial');
      }
      return;
    }

    // Esperar a que Firebase Auth restaure el estado de sesión
    // Esto es CLAVE para mantener la sesión
    User? usuario = await _esperarUsuario();

    if (!mounted) return;

    if (usuario != null) {
      // Hay sesión activa: ir directo al home
      print('✅ Usuario encontrado: ${usuario.email}');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // No hay sesión: ir al login
      print('❌ No hay sesión activa');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Esperar a que Firebase restaure el usuario
  Future<User?> _esperarUsuario() async {
    // Método 1: Esperar el primer evento de authStateChanges
    try {
      // Esperar máximo 3 segundos para que Firebase restaure la sesión
      User? usuario = await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
      return usuario;
    } catch (e) {
      print('Error esperando usuario: $e');
      // Si hay error, verificar directamente
      return FirebaseAuth.instance.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 45, 29),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono de la app
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Gestión de',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            const Text(
              'Emergencias',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 48),

            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),

            const SizedBox(height: 16),

            Text(
              'Verificando sesión...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}