import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto_movil_2/screens/home_screen.dart';
import 'package:proyecto_movil_2/screens/login_screen.dart';
import 'package:proyecto_movil_2/screens/politica_privacidad_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _verificandoPolitica = true;
  bool _politicaAceptada = false;

  @override
  void initState() {
    super.initState();
    _verificarPolitica();
  }

  Future<void> _verificarPolitica() async {
    final prefs = await SharedPreferences.getInstance();
    final aceptada = prefs.getBool('politica_aceptada') ?? false;
    
    if (mounted) {
      setState(() {
        _politicaAceptada = aceptada;
        _verificandoPolitica = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras verifica la política, mostrar splash
    if (_verificandoPolitica) {
      return const _SplashWidget();
    }

    // Si no ha aceptado la política, mostrarla
    if (!_politicaAceptada) {
      return const PoliticaPrivacidadScreen(esPrimeraVez: true);
    }

    // Escuchar cambios de autenticación
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras Firebase verifica, mostrar splash
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashWidget();
        }

        // Si hay usuario, ir al Home
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ Sesión activa: ${snapshot.data!.email}');
          return const HomeScreen();
        }

        // Si no hay usuario, ir al Login
        print('❌ No hay sesión activa');
        return const LoginPage();
      },
    );
  }
}

// Widget de Splash separado
class _SplashWidget extends StatelessWidget {
  const _SplashWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 25, 45, 29),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              'Cargando...',
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