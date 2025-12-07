import 'package:flutter/material.dart';

class ZungosDataScreen extends StatefulWidget {
  const ZungosDataScreen({super.key});

  @override
  State<ZungosDataScreen> createState() => _ZungosDataScreenState();
}

class _ZungosDataScreenState extends State<ZungosDataScreen> {
  final PageController _pageController = PageController();
  int _paginaActual = 0;

  // Lista de imágenes del equipo
  final List<Map<String, String>> _equipo = const [
    {
      'imagen': 'assets/team/foto1.jpg',
      'nombre': '',
    },
    {
      'imagen': 'assets/team/foto2.jpg',
      'nombre': 'Integrante 2',
    },
    {
      'imagen': 'assets/team/foto3.jpg',
      'nombre': 'Integrante 3',
    },
    {
      'imagen': 'assets/team/foto4.jpg',
      'nombre': 'Integrante 4',
    },
  ];

  void _irAnterior() {
    if (_paginaActual > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _irSiguiente() {
    if (_paginaActual < _equipo.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Conócenos'),
        backgroundColor: const Color.fromARGB(255, 25, 45, 29),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.code,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'El Equipo Zungos',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los cerebros detrás de esta app',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección de galería
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      
                      SizedBox(width: 8),
                      Text(
                        'Nuestro Equipo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ========================================
                  // CARRUSEL DE IMÁGENES
                  // ========================================
                  Container(
                    height: 420,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Imagen principal
                        Expanded(
                          child: Stack(
                            children: [
                              // PageView de imágenes
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _paginaActual = index;
                                    });
                                  },
                                  itemCount: _equipo.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => _mostrarFotoCompleta(context, _equipo[index]),
                                      child: Image.asset(
                                        _equipo[index]['imagen']!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  size: 80,
                                                  color: Colors.grey.shade400,
                                                ),
                                                const SizedBox(height: 12),
                                               
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Botón izquierda
                              Positioned(
                                left: 10,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: _irAnterior,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _paginaActual > 0
                                            ? Colors.black.withOpacity(0.5)
                                            : Colors.black.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: _paginaActual > 0
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Botón derecha
                              Positioned(
                                right: 10,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: GestureDetector(
                                    onTap: _irSiguiente,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: _paginaActual < _equipo.length - 1
                                            ? Colors.black.withOpacity(0.5)
                                            : Colors.black.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: _paginaActual < _equipo.length - 1
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Contador de fotos
                              
                            ],
                          ),
                        ),

                        // Nombre del integrante
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Frase especial
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade50,
                    Colors.pink.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple.shade100,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.pink.shade300,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"Hicimos esta app con amor… y con la esperanza de que nunca encuentres nuestros commits del viernes por la noche."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '— El Equipo Zungos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Datos adicionales
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDatoItem(
                    icon: Icons.calendar_today,
                    titulo: 'Año de creación',
                    valor: '2025',
                  ),
                  const Divider(),
                  _buildDatoItem(
                    icon: Icons.school,
                    titulo: 'Universidad',
                    valor: 'Universidad Católica de Honduras',
                  ),
                  const Divider(),
                  _buildDatoItem(
                    icon: Icons.code,
                    titulo: 'Proyecto',
                    valor: 'Programación Móvil II',
                  ),
                  const Divider(),
                  _buildDatoItem(
                    icon: Icons.person,
                    titulo: 'Catedrático',
                    valor: 'Ing. Ludwin Navarro',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer - Copyright
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copyright,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Copyright 2025 Zungos.inc',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _mostrarFotoCompleta(BuildContext context, Map<String, String> miembro) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón cerrar
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                miembro['imagen']!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Nombre
            
          ],
        ),
      ),
    );
  }

  Widget _buildDatoItem({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 25, 45, 29).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 25, 45, 29),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}