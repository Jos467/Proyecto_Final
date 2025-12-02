import 'package:cloud_firestore/cloud_firestore.dart';

class Alerta {
  final String id;
  final String usuarioId;
  final String usuarioNombre;
  final String usuarioEmail;
  final String tipo;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String direccion;
  final String? fotoUrl;
  final DateTime fechaCreacion;
  final String estado;

  Alerta({
    required this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.usuarioEmail,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    this.fotoUrl,
    required this.fechaCreacion,
    required this.estado,
  });

  factory Alerta.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Alerta(
      id: doc.id,
      usuarioId: data['usuarioId'] ?? '',
      usuarioNombre: data['usuarioNombre'] ?? '',
      usuarioEmail: data['usuarioEmail'] ?? '',
      tipo: data['tipo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      latitud: (data['latitud'] ?? 0).toDouble(),
      longitud: (data['longitud'] ?? 0).toDouble(),
      direccion: data['direccion'] ?? '',
      fotoUrl: data['fotoUrl'],
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: data['estado'] ?? 'activa',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'usuarioEmail': usuarioEmail,
      'tipo': tipo,
      'descripcion': descripcion,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'fotoUrl': fotoUrl,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'estado': estado,
    };
  }
}
