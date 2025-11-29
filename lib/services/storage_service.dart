import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<File?> tomarFoto() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (imagen != null) {
        return File(imagen.path);
      }
      return null;
    } catch (e) {
      print('Error al tomar foto: $e');
      return null;
    }
  }

  Future<File?> seleccionarDeGaleria() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (imagen != null) {
        return File(imagen.path);
      }
      return null;
    } catch (e) {
      print('Error al seleccionar de galería: $e');
      return null;
    }
  }

  Future<String?> subirImagen({
    required File archivo,
    required String carpeta,
    required String nombreArchivo,
  }) async {
    try {
      print('===== SUBIENDO IMAGEN =====');
      print('Carpeta: $carpeta');
      print('Nombre: $nombreArchivo');
      print('Archivo existe: ${archivo.existsSync()}');
      print('Tamaño: ${archivo.lengthSync()} bytes');

      // Crear referencia
      Reference ref = _storage.ref().child(carpeta).child(nombreArchivo);
      print('Referencia creada: ${ref.fullPath}');

      // Configurar metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      // Subir archivo
      UploadTask uploadTask = ref.putFile(archivo, metadata);

      // Monitorear progreso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progreso = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Progreso: ${progreso.toStringAsFixed(2)}%');
      });

      // Esperar a que termine
      TaskSnapshot snapshot = await uploadTask;
      print('Estado: ${snapshot.state}');

      // Obtener URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('URL obtenida: $downloadUrl');
      print('===== IMAGEN SUBIDA EXITOSAMENTE =====');

      return downloadUrl;
    } catch (e) {
      print('===== ERROR AL SUBIR IMAGEN =====');
      print('Error: $e');
      return null;
    }
  }

  Future<bool> eliminarImagen(String url) async {
    try {
      Reference ref = _storage.refFromURL(url);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }
}