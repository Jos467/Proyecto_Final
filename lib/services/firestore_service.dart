import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================
  // GUARDAR DATOS DEL USUARIO
  // ============================================
  Future<void> guardarUsuario({
    required String uid,
    required String nombre,
    required String email,
    String? fotoUrl,
  }) async {
    await _db.collection('usuarios').doc(uid).set({
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'fotoUrl': fotoUrl ?? '',
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  // ============================================
  // OBTENER DATOS DEL USUARIO
  // ============================================
  Future<Map<String, dynamic>?> obtenerUsuario(String uid) async {
    DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // ============================================
  // ACTUALIZAR DATOS DEL USUARIO
  // ============================================
  Future<void> actualizarUsuario({
    required String uid,
    required Map<String, dynamic> datos,
  }) async {
    await _db.collection('usuarios').doc(uid).update(datos);
  }
}