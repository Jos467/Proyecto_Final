import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proyecto_movil_2/services/auth_service.dart';
import 'package:proyecto_movil_2/services/alerta_service.dart';
import 'package:proyecto_movil_2/services/location_service.dart';
import 'package:proyecto_movil_2/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final AlertaService _alertaService = AlertaService();
  final LocationService _locationService = LocationService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  String _loadingMessage = '';
  String? _ubicacionActual;
  Position? _posicionActual;
  File? _imagenSeleccionada;

  final List<Map<String, dynamic>> _tiposEmergencia = [
    {'tipo': 'Accidente', 'icono': Icons.car_crash, 'color': Colors.orange},
    {'tipo': 'Incendio', 'icono': Icons.local_fire_department, 'color': Colors.red},
    {'tipo': 'Robo', 'icono': Icons.warning, 'color': Colors.purple},
    {'tipo': 'Médica', 'icono': Icons.medical_services, 'color': Colors.blue},
    {'tipo': 'Desastre Natural', 'icono': Icons.flood, 'color': Colors.teal},
    {'tipo': 'Otro', 'icono': Icons.report_problem, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    setState(() {
      _ubicacionActual = 'Obteniendo ubicación...';
    });

    Position? posicion = await _locationService.obtenerUbicacionActual();

    if (posicion != null) {
      _posicionActual = posicion;
      String direccion = await _locationService.obtenerDireccion(
        posicion.latitude,
        posicion.longitude,
      );
      setState(() {
        _ubicacionActual = direccion;
      });
    } else {
      setState(() {
        _ubicacionActual = 'No se pudo obtener la ubicación. Verifica los permisos.';
      });
    }
  }

  Future<void> _mostrarOpcionesImagen() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar imagen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.blue.shade700),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la cámara del dispositivo'),
                onTap: () async {
                  Navigator.pop(context);
                  File? foto = await _storageService.tomarFoto();
                  if (foto != null) {
                    setState(() {
                      _imagenSeleccionada = foto;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.green.shade700),
                ),
                title: const Text('Galería'),
                subtitle: const Text('Seleccionar de la galería'),
                onTap: () async {
                  Navigator.pop(context);
                  File? foto = await _storageService.seleccionarDeGaleria();
                  if (foto != null) {
                    setState(() {
                      _imagenSeleccionada = foto;
                    });
                  }
                },
              ),
              if (_imagenSeleccionada != null) ...[
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: Colors.red.shade700),
                  ),
                  title: const Text('Eliminar foto'),
                  subtitle: const Text('Quitar la foto seleccionada'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imagenSeleccionada = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enviarAlerta(String tipo) async {
    if (_posicionActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esperando ubicación... Intenta de nuevo.'),
          backgroundColor: Colors.orange,
        ),
      );
      await _obtenerUbicacion();
      return;
    }

    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enviar Alerta de $tipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Confirmas enviar esta alerta de emergencia?'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _ubicacionActual ?? 'Ubicación desconocida',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            if (_imagenSeleccionada != null) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.photo, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Foto adjunta ✓',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar Alerta'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Preparando alerta...';
    });

    final user = _authService.usuarioActual;
    String? fotoUrl;

    // Subir imagen si existe
    if (_imagenSeleccionada != null) {
      setState(() {
        _loadingMessage = 'Subiendo foto...';
      });

      String nombreArchivo = '${user?.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      fotoUrl = await _storageService.subirImagen(
        archivo: _imagenSeleccionada!,
        carpeta: 'alertas',
        nombreArchivo: nombreArchivo,
      );

      if (fotoUrl == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al subir la foto. Intenta de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _loadingMessage = 'Enviando alerta...';
    });

    Map<String, dynamic> resultado = await _alertaService.crearAlerta(
      usuarioId: user?.uid ?? '',
      usuarioNombre: user?.displayName ?? 'Usuario',
      usuarioEmail: user?.email ?? '',
      tipo: tipo,
      descripcion: 'Alerta de emergencia tipo: $tipo',
      latitud: _posicionActual!.latitude,
      longitud: _posicionActual!.longitude,
      direccion: _ubicacionActual ?? '',
      fotoUrl: fotoUrl,
    );

    setState(() {
      _isLoading = false;
      _imagenSeleccionada = null;
    });

    if (resultado['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Alerta enviada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.usuarioActual;

    return Scaffold(
      appBar: AppBar(
  title: const Text('Emergencias'),
  backgroundColor: Colors.redAccent,
  foregroundColor: Colors.white,
  automaticallyImplyLeading: false,
  actions: [
    IconButton(
      icon: const Icon(Icons.list),
      onPressed: () => Navigator.pushNamed(context, '/mis-alertas'),
      tooltip: 'Mis Alertas',
    ),
    IconButton(
      icon: const Icon(Icons.person),
      onPressed: () => Navigator.pushNamed(context, '/perfil'),
      tooltip: 'Perfil',
    ),
  ],
),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_loadingMessage),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el tipo de emergencia para enviar una alerta',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Ubicación
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tu ubicación actual',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _ubicacionActual ?? 'Obteniendo...',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _obtenerUbicacion,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sección de foto
                  GestureDetector(
                    onTap: _mostrarOpcionesImagen,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _imagenSeleccionada != null
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _imagenSeleccionada != null
                              ? Colors.green.shade300
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: _imagenSeleccionada != null
                          ? Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _imagenSeleccionada!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Foto adjunta',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Toca para cambiar o eliminar',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.check_circle, color: Colors.green.shade700),
                              ],
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.add_a_photo, color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Adjuntar foto (opcional)',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Toca para tomar o seleccionar una foto',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey.shade400),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Tipo de Emergencia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Grid de emergencias
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: _tiposEmergencia.length,
                    itemBuilder: (context, index) {
                      final emergencia = _tiposEmergencia[index];
                      return InkWell(
                        onTap: () => _enviarAlerta(emergencia['tipo']),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: (emergencia['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: (emergencia['color'] as Color).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                emergencia['icono'],
                                size: 40,
                                color: emergencia['color'],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                emergencia['tipo'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: emergencia['color'],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _authService.cerrarSesion();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}