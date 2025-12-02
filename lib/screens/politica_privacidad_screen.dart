import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PoliticaPrivacidadScreen extends StatelessWidget {
  final bool esPrimeraVez;
  
  const PoliticaPrivacidadScreen({
    super.key,
    this.esPrimeraVez = false,
  });

  Future<void> _aceptarPolitica(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('politica_aceptada', true);
    
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        backgroundColor: const Color.fromARGB(255, 25, 45, 29),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: !esPrimeraVez,
      ),
      body: Column(
        children: [
          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo o ícono
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        size: 60,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Center(
                    child: Text(
                      'Gestión de Emergencias',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Center(
                    child: Text(
                      'Última actualización: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Secciones de la política
                  _buildSeccion(
                    '1. Información que Recopilamos',
                    '''
Al utilizar nuestra aplicación de Gestión de Emergencias, recopilamos la siguiente información:

• **Información de cuenta:** Nombre, correo electrónico y foto de perfil cuando te registras.

• **Datos de ubicación:** Tu ubicación GPS en tiempo real cuando envías una alerta de emergencia. Esta información es esencial para el funcionamiento de la aplicación.

• **Fotografías:** Imágenes que voluntariamente adjuntas como evidencia de una emergencia.

• **Información del dispositivo:** Datos técnicos básicos para mejorar el rendimiento de la app.
''',
                  ),
                  
                  _buildSeccion(
                    '2. Cómo Utilizamos tu Información',
                    '''
Utilizamos la información recopilada para:

• **Gestionar emergencias:** Mostrar tu ubicación y alerta a otros usuarios para facilitar la respuesta a emergencias.

• **Mejorar el servicio:** Analizar el uso de la aplicación para mejorar su funcionamiento.

• **Comunicación:** Enviarte notificaciones relacionadas con alertas de emergencia en tu área.

• **Seguridad:** Proteger a los usuarios y prevenir el uso indebido de la plataforma.
''',
                  ),
                  
                  _buildSeccion(
                    '3. Compartición de Datos',
                    '''
Tu información puede ser compartida en las siguientes circunstancias:

• **Con otros usuarios:** Las alertas de emergencia (tipo, ubicación, foto) son visibles para otros usuarios de la aplicación.

• **Servicios de terceros:** Utilizamos Firebase (Google) para almacenamiento y autenticación, y Google Maps para la visualización de mapas.

• **Requerimientos legales:** Podemos divulgar información si es requerido por ley o para proteger la seguridad pública.
''',
                  ),
                  
                  _buildSeccion(
                    '4. Almacenamiento y Seguridad',
                    '''
• Tus datos se almacenan de forma segura en servidores de Firebase (Google Cloud).

• Implementamos medidas de seguridad técnicas y organizativas para proteger tu información.

• Las contraseñas se almacenan de forma encriptada.

• El acceso a los datos está restringido mediante reglas de seguridad.
''',
                  ),
                  
                  _buildSeccion(
                    '5. Tus Derechos',
                    '''
Tienes derecho a:

• **Acceder:** Solicitar una copia de tus datos personales.

• **Rectificar:** Corregir información incorrecta desde tu perfil.

• **Eliminar:** Solicitar la eliminación de tu cuenta y datos asociados.

• **Revocar:** Retirar tu consentimiento en cualquier momento.

Para ejercer estos derechos, contáctanos a través de la aplicación.
''',
                  ),
                  
                  _buildSeccion(
                    '6. Uso de la Ubicación',
                    '''
Esta aplicación requiere acceso a tu ubicación GPS para:

• Registrar la ubicación exacta de las emergencias reportadas.

• Mostrar alertas cercanas a tu ubicación en el mapa.

• Proporcionar direcciones legibles mediante geocodificación.

**Importante:** Solo accedemos a tu ubicación cuando utilizas activamente la función de enviar alertas. No rastreamos tu ubicación en segundo plano.
''',
                  ),
                  
                  _buildSeccion(
                    '7. Menores de Edad',
                    '''
Esta aplicación no está dirigida a menores de 13 años. No recopilamos intencionalmente información de niños. Si descubrimos que hemos recopilado datos de un menor, los eliminaremos inmediatamente.
''',
                  ),
                  
                  _buildSeccion(
                    '8. Cambios en la Política',
                    '''
Podemos actualizar esta política de privacidad periódicamente. Te notificaremos sobre cambios significativos a través de la aplicación. El uso continuado de la app después de los cambios constituye tu aceptación de la política actualizada.
''',
                  ),
                  
                  _buildSeccion(
                    '9. Contacto',
                    '''
Si tienes preguntas sobre esta política de privacidad o sobre cómo manejamos tus datos, puedes contactarnos a través de:

📧 Email: soporte@emergenciasapp.com
📍 Ubicación: Santa Rosa de Copán, Honduras
''',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Nota final
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Al usar esta aplicación, aceptas esta política de privacidad y nuestros términos de servicio.',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Espacio para el botón
                ],
              ),
            ),
          ),
          
          // Botón de aceptar (solo si es primera vez)
          if (esPrimeraVez)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'He leído y acepto la política de privacidad',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _aceptarPolitica(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 25, 45, 29),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Aceptar y Continuar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSeccion(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 25, 45, 29),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            contenido.trim(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}