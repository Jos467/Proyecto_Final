import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_movil_2/models/alerta_model.dart';
import 'package:proyecto_movil_2/services/alerta_service.dart';
import 'package:proyecto_movil_2/services/auth_service.dart';

class ListaAlertasScreen extends StatelessWidget {
  ListaAlertasScreen({super.key});

  final AlertaService _alertaService = AlertaService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.usuarioActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Alertas'),
        backgroundColor: Color.fromARGB(255, 25, 45, 29),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Alerta>>(
        stream: _alertaService.obtenerAlertasUsuarioStream(user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          List<Alerta> alertas = snapshot.data ?? [];

          if (alertas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No has enviado alertas',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tus alertas aparecerán aquí',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alertas.length,
            itemBuilder: (context, index) {
              final alerta = alertas[index];
              return _buildAlertaCard(context, alerta);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertaCard(BuildContext context, Alerta alerta) {
    Color tipoColor = _getColorTipo(alerta.tipo);
    IconData tipoIcono = _getIconoTipo(alerta.tipo);
    String fechaFormateada = DateFormat('dd/MM/yyyy HH:mm').format(alerta.fechaCreacion);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detalle-alerta',
            arguments: alerta,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tipoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tipoIcono, color: tipoColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta.tipo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tipoColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alerta.direccion,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaFormateada,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              if (alerta.fotoUrl != null && alerta.fotoUrl!.isNotEmpty)
                const Icon(Icons.photo, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
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