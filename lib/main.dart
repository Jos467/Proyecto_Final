import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_movil_2/screens/splash_screen.dart';
import 'package:proyecto_movil_2/screens/politica_privacidad_screen.dart';
import 'package:proyecto_movil_2/screens/login_screen.dart';
import 'package:proyecto_movil_2/screens/registro_screen.dart';
import 'package:proyecto_movil_2/screens/home_screen.dart';
import 'package:proyecto_movil_2/screens/lista_alertas_screen.dart';
import 'package:proyecto_movil_2/screens/detalle_alerta_screen.dart';
import 'package:proyecto_movil_2/screens/perfil_screen.dart';
import 'package:proyecto_movil_2/screens/mapa_alertas_screen.dart';
import 'package:proyecto_movil_2/screens/zungos_data_screen.dart'; // NUEVO

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Emergencias',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/politica-inicial': (context) => const PoliticaPrivacidadScreen(esPrimeraVez: true),
        '/politica': (context) => const PoliticaPrivacidadScreen(esPrimeraVez: false),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeScreen(),
        '/mis-alertas': (context) => ListaAlertasScreen(),
        '/detalle-alerta': (context) => DetalleAlertaScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/mapa': (context) => const MapaAlertasScreen(),
        '/conocenos': (context) => const ZungosDataScreen(), // NUEVO
      },
    );
  }
}