import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_movil_2/models/alerta_model.dart';
import 'package:proyecto_movil_2/services/alerta_service.dart';
import 'package:proyecto_movil_2/services/auth_service.dart';

class DetalleAlertaScreen extends StatelessWidget {
  DetalleAlertaScreen({super.key});

  final AlertaService _alertaService = AlertaService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final Alerta alerta = ModalRoute.of(context)!.settings.arguments as Alerta;
    String fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(alerta.fechaCreacion);
    Color tipoColor = _getColorTipo(alerta.tipo);
    IconData tipoIcono = _getIconoTipo(alerta.tipo);
    
    // Verificar si es el dueño de la alerta
    final bool esPropia = _authService.usuarioActual?.uid == alerta.usuarioId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Alerta'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          // Solo mostrar botón eliminar si es su propia alerta
          if (esPropia)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmarEliminar(context, alerta),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            if (alerta.fotoUrl != null && alerta.fotoUrl!.isNotEmpty)
              Image.network(
                alerta.fotoUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 250,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  );
                },
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                color: tipoColor.withOpacity(0.1),
                child: Icon(tipoIcono, size: 80, color: tipoColor),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador si es propia o ajena
                  if (!esPropia)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Alerta de otro usuario',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Tipo de emergencia
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: tipoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tipoIcono, color: tipoColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          alerta.tipo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: tipoColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información
                  _buildInfoItem(
                    icon: Icons.person,
                    titulo: 'Reportado por',
                    valor: alerta.usuarioEmail,
                  ),

                  _buildInfoItem(
                    icon: Icons.access_time,
                    titulo: 'Fecha y hora',
                    valor: fechaFormateada,
                  ),

                  _buildInfoItem(
                    icon: Icons.location_on,
                    titulo: 'Ubicación',
                    valor: alerta.direccion,
                  ),

                  _buildInfoItem(
                    icon: Icons.gps_fixed,
                    titulo: 'Coordenadas',
                    valor: '${alerta.latitud.toStringAsFixed(6)}, ${alerta.longitud.toStringAsFixed(6)}',
                  ),

                  _buildInfoItem(
                    icon: Icons.info,
                    titulo: 'Estado',
                    valor: alerta.estado.toUpperCase(),
                  ),

                  const SizedBox(height: 24),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      alerta.descripcion,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, Alerta alerta) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Alerta'),
        content: const Text('¿Estás seguro de eliminar esta alerta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _alertaService.eliminarAlerta(alerta.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Color _getColorTipo(String tipo) {
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

  IconData _getIconoTipo(String tipo) {
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
}