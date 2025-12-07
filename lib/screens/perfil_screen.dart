import 'dart:io';
import 'package:flutter/material.dart';
import 'package:proyecto_movil_2/services/auth_service.dart';
import 'package:proyecto_movil_2/services/firestore_service.dart';
import 'package:proyecto_movil_2/services/storage_service.dart';


class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _cargarFotoPerfil();
  }

  Future<void> _cargarFotoPerfil() async {
    final user = _authService.usuarioActual;
    if (user != null) {
      final datos = await _firestoreService.obtenerUsuario(user.uid);
      if (datos != null && datos['fotoUrl'] != null && datos['fotoUrl'].isNotEmpty) {
        setState(() {
          _fotoUrl = datos['fotoUrl'];
        });
      }
    }
  }

  Future<void> _cambiarFotoPerfil() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Opción: Tomar foto
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue.shade700),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la cámara del dispositivo'),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                onTap: () async {
                  Navigator.pop(context);
                  await _procesarImagen(await _storageService.tomarFoto());
                },
              ),
              
              const SizedBox(height: 8),
              
              // Opción: Galería
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.green.shade700),
                ),
                title: const Text('Elegir de galería'),
                subtitle: const Text('Seleccionar una foto existente'),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                onTap: () async {
                  Navigator.pop(context);
                  await _procesarImagen(await _storageService.seleccionarDeGaleria());
                },
              ),
              
              // Opción: Eliminar foto (solo si tiene foto)
              if (_fotoUrl != null && _fotoUrl!.isNotEmpty) ...[
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete, color: Colors.red.shade700),
                  ),
                  title: const Text('Eliminar foto'),
                  subtitle: const Text('Usar foto por defecto'),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  onTap: () async {
                    Navigator.pop(context);
                    await _eliminarFoto();
                  },
                ),
              ],
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _procesarImagen(File? imagen) async {
    if (imagen == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.usuarioActual;
      if (user == null) return;

      // Subir imagen a Storage
      String nombreArchivo = '${user.uid}_perfil_${DateTime.now().millisecondsSinceEpoch}.jpg';
      String? url = await _storageService.subirImagen(
        archivo: imagen,
        carpeta: 'usuarios/${user.uid}',
        nombreArchivo: nombreArchivo,
      );

      if (url != null) {
        // Actualizar en Firestore
        await _firestoreService.actualizarUsuario(
          uid: user.uid,
          datos: {'fotoUrl': url},
        );

        // Actualizar en Firebase Auth
        await user.updatePhotoURL(url);

        setState(() {
          _fotoUrl = url;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Foto de perfil actualizada!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _eliminarFoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.usuarioActual;
      if (user == null) return;

      // Actualizar en Firestore
      await _firestoreService.actualizarUsuario(
        uid: user.uid,
        datos: {'fotoUrl': ''},
      );

      // Actualizar en Firebase Auth
      await user.updatePhotoURL(null);

      setState(() {
        _fotoUrl = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.usuarioActual;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color.fromARGB(255, 25, 45, 29),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Actualizando foto...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header con gradiente
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 25, 45, 29),
                          Color.fromARGB(255, 45, 80, 50),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Avatar con botón de editar
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                backgroundImage: _fotoUrl != null && _fotoUrl!.isNotEmpty
                                    ? NetworkImage(_fotoUrl!)
                                    : (user?.photoURL != null
                                        ? NetworkImage(user!.photoURL!)
                                        : null),
                                child: (_fotoUrl == null || _fotoUrl!.isEmpty) && user?.photoURL == null
                                    ? Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.grey.shade400,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _cambiarFotoPerfil,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Nombre
                        Text(
                          user?.displayName ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Email
                        Text(
                          user?.email ?? 'Sin correo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // Contenido
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información de cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tarjetas de información
                        _buildInfoCard(
                          icon: Icons.email_outlined,
                          titulo: 'Correo electrónico',
                          valor: user?.email ?? 'No disponible',
                          color: Colors.blue,
                        ),

                        _buildInfoCard(
                          icon: Icons.person_outline,
                          titulo: 'Nombre',
                          valor: user?.displayName ?? 'No disponible',
                          color: Colors.green,
                        ),

                        _buildInfoCard(
                          icon: Icons.fingerprint,
                          titulo: 'ID de usuario',
                          valor: user?.uid ?? 'No disponible',
                          color: Colors.purple,
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Opciones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Botón Política de Privacidad
                        _buildOptionCard(
                          icon: Icons.privacy_tip_outlined,
                          titulo: 'Política de Privacidad',
                          subtitulo: 'Lee nuestros términos y condiciones',
                          color: Colors.blue,
                          onTap: () => Navigator.pushNamed(context, '/politica'),
                        ),

                        // Botón Conócenos
                        _buildOptionCard(
                          icon: Icons.favorite_outline,
                          titulo: 'Conócenos',
                          subtitulo: 'Conoce al equipo detrás de la app',
                          color: Colors.pink,
                          onTap: () => Navigator.pushNamed(context, '/conocenos'),
                        ),

                        const SizedBox(height: 24),

                        // Botón cerrar sesión
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => _mostrarDialogoCerrarSesion(context),
                            icon: const Icon(Icons.logout),
                            label: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  Future<void> _mostrarDialogoCerrarSesion(BuildContext context) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Text('Cerrar Sesión'),
          ],
        ),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _authService.cerrarSesion();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}