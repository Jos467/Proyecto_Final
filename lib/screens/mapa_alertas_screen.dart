import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:proyecto_movil_2/models/alerta_model.dart';
import 'package:proyecto_movil_2/services/alerta_service.dart';
import 'package:proyecto_movil_2/services/location_service.dart';

class MapaAlertasScreen extends StatefulWidget {
  const MapaAlertasScreen({super.key});

  @override
  State<MapaAlertasScreen> createState() => _MapaAlertasScreenState();
}

class _MapaAlertasScreenState extends State<MapaAlertasScreen>
    with AutomaticKeepAliveClientMixin {
  
  // Servicios
  final AlertaService _alertaService = AlertaService();
  final LocationService _locationService = LocationService();

  // Controlador del mapa
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;

  // Estado
  Set<Marker> _marcadores = {};
  List<Alerta> _alertas = [];
  bool _mapaListo = false;
  bool _cargandoUbicacion = true;
  int _cantidadAlertas = 0;

  // Ubicación
  static const LatLng _ubicacionInicial = LatLng(14.7677, -88.7797); // Santa Rosa de Copán
  LatLng? _miUbicacion;

  // Stream subscription
  StreamSubscription<List<Alerta>>? _alertasSubscription;

  @override
  bool get wantKeepAlive => true; // Mantiene el estado al cambiar de pantalla

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    await _obtenerMiUbicacion();
    _escucharAlertas();
  }

  Future<void> _obtenerMiUbicacion() async {
    try {
      Position? posicion = await _locationService.obtenerUbicacionActual();
      if (posicion != null && mounted) {
        setState(() {
          _miUbicacion = LatLng(posicion.latitude, posicion.longitude);
          _cargandoUbicacion = false;
        });
      } else {
        setState(() {
          _cargandoUbicacion = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoUbicacion = false;
        });
      }
    }
  }

  void _escucharAlertas() {
    _alertasSubscription = _alertaService.obtenerAlertasStream().listen(
      (alertas) {
        if (mounted) {
          _alertas = alertas;
          _cantidadAlertas = alertas.length;
          _construirMarcadores();
        }
      },
      onError: (error) {
        print('Error en stream de alertas: $error');
      },
    );
  }

  void _construirMarcadores() {
    final Set<Marker> nuevosMarcadores = {};

    // Marcador de mi ubicación
    if (_miUbicacion != null) {
      nuevosMarcadores.add(
        Marker(
          markerId: const MarkerId('mi_ubicacion'),
          position: _miUbicacion!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Mi ubicación',
            snippet: 'Estás aquí',
          ),
        ),
      );
    }

    // Marcadores de alertas
    for (var alerta in _alertas) {
      nuevosMarcadores.add(
        Marker(
          markerId: MarkerId(alerta.id),
          position: LatLng(alerta.latitud, alerta.longitud),
          icon: _getIconoPorTipo(alerta.tipo),
          onTap: () => _mostrarPreviewAlerta(alerta),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _marcadores = nuevosMarcadores;
      });
    }
  }

  BitmapDescriptor _getIconoPorTipo(String tipo) {
    switch (tipo) {
      case 'Accidente':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'Incendio':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'Robo':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case 'Médica':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'Desastre Natural':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }

  void _onMapaCreado(GoogleMapController controller) {
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
    _mapController = controller;
    setState(() {
      _mapaListo = true;
    });
  }

  Future<void> _centrarEnMiUbicacion() async {
    if (_miUbicacion != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_miUbicacion!, 15),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener tu ubicación'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _mostrarPreviewAlerta(Alerta alerta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetAlerta(
        alerta: alerta,
        onVerDetalles: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/detalle-alerta', arguments: alerta);
        },
      ),
    );
  }

  void _mostrarLeyenda() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _LeyendaWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Alertas'),
        backgroundColor: const Color.fromARGB(255, 25, 45, 29),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.legend_toggle),
            onPressed: _mostrarLeyenda,
            tooltip: 'Leyenda',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _miUbicacion ?? _ubicacionInicial,
              zoom: 14,
            ),
            markers: _marcadores,
            onMapCreated: _onMapaCreado,
            myLocationEnabled: false, // Desactivado para evitar conflictos
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            liteModeEnabled: false,
          ),

          // Indicador de carga inicial
          if (!_mapaListo || _cargandoUbicacion)
            Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando mapa...'),
                  ],
                ),
              ),
            ),

          // Panel superior con contador
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _PanelContador(cantidad: _cantidadAlertas),
          ),

          // Botones de control
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              children: [
                _BotonMapa(
                  icono: Icons.add,
                  onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                ),
                const SizedBox(height: 8),
                _BotonMapa(
                  icono: Icons.remove,
                  onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                ),
                const SizedBox(height: 8),
                _BotonMapa(
                  icono: Icons.my_location,
                  color: Colors.blue,
                  onTap: _centrarEnMiUbicacion,
                ),
              ],
            ),
          ),
        ],
      ),

      // Botón nueva alerta
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/home'),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text('Nueva Alerta', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _alertasSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}

// ==================== WIDGETS SEPARADOS ====================

class _PanelContador extends StatelessWidget {
  final int cantidad;

  const _PanelContador({required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications_active, color: Colors.red.shade700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$cantidad alertas activas',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Toca un marcador para ver detalles',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonMapa extends StatelessWidget {
  final IconData icono;
  final VoidCallback onTap;
  final Color? color;

  const _BotonMapa({
    required this.icono,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icono, color: color ?? Colors.black87),
        ),
      ),
    );
  }
}

class _BottomSheetAlerta extends StatelessWidget {
  final Alerta alerta;
  final VoidCallback onVerDetalles;

  const _BottomSheetAlerta({
    required this.alerta,
    required this.onVerDetalles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorPorTipo(alerta.tipo).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconoPorTipo(alerta.tipo),
                  color: _getColorPorTipo(alerta.tipo),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta.tipo,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatearFecha(alerta.fechaCreacion),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: alerta.estado == 'activa' ? Colors.green.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  alerta.estado.toUpperCase(),
                  style: TextStyle(
                    color: alerta.estado == 'activa' ? Colors.green.shade700 : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Ubicación
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alerta.direccion.isNotEmpty ? alerta.direccion : 'Ubicación no disponible',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Usuario
          Row(
            children: [
              Icon(Icons.person, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reportado por: ${alerta.usuarioNombre}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),

          // Foto
          if (alerta.fotoUrl != null && alerta.fotoUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.photo, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Esta alerta tiene foto adjunta',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          // Botón
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onVerDetalles,
              icon: const Icon(Icons.visibility),
              label: const Text('Ver Detalles Completos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 25, 45, 29),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorPorTipo(String tipo) {
    switch (tipo) {
      case 'Accidente':
        return Colors.orange;
      case 'Incendio':
        return Colors.red;
      case 'Robo':
        return Colors.purple;
      case 'Médica':
        return Colors.blue;
      case 'Desastre Natural':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoPorTipo(String tipo) {
    switch (tipo) {
      case 'Accidente':
        return Icons.car_crash;
      case 'Incendio':
        return Icons.local_fire_department;
      case 'Robo':
        return Icons.warning;
      case 'Médica':
        return Icons.medical_services;
      case 'Desastre Natural':
        return Icons.flood;
      default:
        return Icons.report_problem;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 1) {
      return 'Hace un momento';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} horas';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}

class _LeyendaWidget extends StatelessWidget {
  const _LeyendaWidget();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    
    final bool isSmallScreen = screenHeight < 700;
    final double itemPadding = isSmallScreen ? 4.0 : 8.0;
    final double iconSize = isSmallScreen ? 18.0 : 24.0;
    final double fontSize = isSmallScreen ? 13.0 : 16.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.55,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de arrastre
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            Text(
              'Leyenda de Colores',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text(
              'Cada color representa un tipo de emergencia',
              style: TextStyle(
                color: Colors.grey,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 20),
            
            _buildItem(Colors.orange, 'Accidente', Icons.car_crash, itemPadding, iconSize, fontSize),
            _buildItem(Colors.red, 'Incendio', Icons.local_fire_department, itemPadding, iconSize, fontSize),
            _buildItem(Colors.purple, 'Robo', Icons.warning, itemPadding, iconSize, fontSize),
            _buildItem(Colors.blue, 'Emergencia Médica', Icons.medical_services, itemPadding, iconSize, fontSize),
            _buildItem(Colors.teal, 'Desastre Natural', Icons.flood, itemPadding, iconSize, fontSize),
            _buildItem(Colors.amber, 'Otro', Icons.report_problem, itemPadding, iconSize, fontSize),
            
            Divider(height: isSmallScreen ? 20 : 30),
            _buildItem(Colors.blue.shade700, 'Mi ubicación', Icons.person_pin, itemPadding, iconSize, fontSize),
            
            SizedBox(height: isSmallScreen ? 12 : 20),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Color color, String texto, IconData icono, double padding, double iconSize, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: iconSize * 0.6),
          SizedBox(width: iconSize * 0.5),
          Icon(icono, color: color, size: iconSize),
          SizedBox(width: iconSize * 0.5),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}