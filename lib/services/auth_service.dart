import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_movil_2/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? get usuarioActual => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============================================
  // REGISTRO CON CORREO Y CONTRASEÑA
  // ============================================
  Future<Map<String, dynamic>> registrarConCorreo({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential resultado = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar nombre en Auth
      await resultado.user?.updateDisplayName(nombre);

      // Guardar datos adicionales en Firestore
      if (resultado.user != null) {
        await _firestoreService.guardarUsuario(
          uid: resultado.user!.uid,
          nombre: nombre,
          email: email,
        );
      }

      return {
        'success': true,
        'user': resultado.user,
        'message': 'Usuario registrado exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      String mensaje = _obtenerMensajeError(e.code);
      return {
        'success': false,
        'user': null,
        'message': mensaje,
      };
    } catch (e) {
      return {
        'success': false,
        'user': null,
        'message': 'Error: $e',
      };
    }
  }

  // ============================================
  // INICIAR SESIÓN CON CORREO Y CONTRASEÑA
  // ============================================
  Future<Map<String, dynamic>> iniciarSesionConCorreo({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential resultado = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {
        'success': true,
        'user': resultado.user,
        'message': 'Inicio de sesión exitoso',
      };
    } on FirebaseAuthException catch (e) {
      String mensaje = _obtenerMensajeError(e.code);
      return {
        'success': false,
        'user': null,
        'message': mensaje,
      };
    } catch (e) {
      return {
        'success': false,
        'user': null,
        'message': 'Error: $e',
      };
    }
  }

  // ============================================
  // CERRAR SESIÓN
  // ============================================
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // ============================================
  // RESTABLECER CONTRASEÑA
  // ============================================
  Future<Map<String, dynamic>> restablecerPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Correo de recuperación enviado',
      };
    } on FirebaseAuthException catch (e) {
      String mensaje = _obtenerMensajeError(e.code);
      return {
        'success': false,
        'message': mensaje,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // ============================================
  // MENSAJES DE ERROR EN ESPAÑOL
  // ============================================
  String _obtenerMensajeError(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: $codigo';
    }
  }
}