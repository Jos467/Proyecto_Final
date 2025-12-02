import 'package:flutter/material.dart';
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
    _verificarPolitica();
  }

  Future<void> _verificarPolitica() async {
    await Future.delayed(const Duration(seconds: 2)); // Mostrar splash 2 segundos
    
    final prefs = await SharedPreferences.getInstance();
    final politicaAceptada = prefs.getBool('politica_aceptada') ?? false;
    
    if (mounted) {
      if (politicaAceptada) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/politica-inicial');
      }
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