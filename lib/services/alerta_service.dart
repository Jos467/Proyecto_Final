import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_movil_2/models/alerta_model.dart';

class AlertaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coleccion = 'alertas';

  Future<Map<String, dynamic>> crearAlerta({
    required String usuarioId,
    required String usuarioNombre,
    required String usuarioEmail,
    required String tipo,
    required String descripcion,
    required double latitud,
    required double longitud,
    required String direccion,
    String? fotoUrl,
  }) async {
    try {
      print('===== CREANDO ALERTA =====');
      print('Usuario ID: $usuarioId');
      print('Usuario Nombre: $usuarioNombre');
      print('Usuario Email: $usuarioEmail');
      print('Tipo: $tipo');
      print('Ubicación: $latitud, $longitud');
      print('Foto URL: $fotoUrl');

      DocumentReference docRef = await _db.collection(_coleccion).add({
        'usuarioId': usuarioId,
        'usuarioNombre': usuarioNombre,
        'usuarioEmail': usuarioEmail,
        'tipo': tipo,
        'descripcion': descripcion,
        'latitud': latitud,
        'longitud': longitud,
        'direccion': direccion,
        'fotoUrl': fotoUrl ?? '',
        'fechaCreacion': FieldValue.serverTimestamp(),
        'estado': 'activa',
      });

      print('Alerta creada con ID: ${docRef.id}');
      print('===== ALERTA CREADA EXITOSAMENTE =====');

      return {
        'success': true,
        'message': 'Alerta creada exitosamente',
        'alertaId': docRef.id,
      };
    } catch (e) {
      print('===== ERROR AL CREAR ALERTA =====');
      print('Error: $e');
      return {
        'success': false,
        'message': 'Error al crear alerta: $e',
      };
    }
  }

  Stream<List<Alerta>> obtenerAlertasStream() {
    return _db
        .collection(_coleccion)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Alerta.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Alerta>> obtenerAlertasUsuarioStream(String usuarioId) {
    return _db
        .collection(_coleccion)
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fechaCreacion', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Alerta.fromFirestore(doc)).toList();
    });
  }

  Future<Alerta?> obtenerAlerta(String alertaId) async {
    try {
      DocumentSnapshot doc = await _db.collection(_coleccion).doc(alertaId).get();
      if (doc.exists) {
        return Alerta.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> eliminarAlerta(String alertaId) async {
    try {
      await _db.collection(_coleccion).doc(alertaId).delete();
      return {
        'success': true,
        'message': 'Alerta eliminada',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al eliminar: $e',
      };
    }
  }
}