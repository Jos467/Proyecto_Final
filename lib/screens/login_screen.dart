import 'package:flutter/material.dart';
import 'package:proyecto_movil_2/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoadingGoogle = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _esEmailValido(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _iniciarSesion() async {
    setState(() {
      _errorMessage = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu correo electrónico';
      });
      return;
    }

    if (!_esEmailValido(email)) {
      setState(() {
        _errorMessage = 'Por favor ingresa un correo electrónico válido';
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu contraseña';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> resultado = await _authService.iniciarSesionConCorreo(
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (resultado['success']) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() {
        _errorMessage = resultado['message'];
      });
    }
  }

  Future<void> _iniciarSesionConGoogle() async {
    setState(() {
      _errorMessage = null;
      _isLoadingGoogle = true;
    });

    Map<String, dynamic> resultado = await _authService.iniciarSesionConGoogle();

    setState(() {
      _isLoadingGoogle = false;
    });

    if (resultado['success']) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() {
        _errorMessage = resultado['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener dimensiones de pantalla
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    
    // Calcular valores responsivos
    final bool isSmallScreen = screenHeight < 600;
    final bool isLargeScreen = screenWidth > 600;
    final double horizontalPadding = isLargeScreen ? screenWidth * 0.15 : 24.0;
    final double maxCardWidth = isLargeScreen ? 500.0 : double.infinity;
    
    // Tamaños de fuente responsivos
    final double titleSize = isSmallScreen ? 24 : (isLargeScreen ? 36 : 32);
    final double subtitleSize = isSmallScreen ? 16 : (isLargeScreen ? 22 : 20);
    final double cardTitleSize = isSmallScreen ? 18 : 22;
    final double buttonTextSize = isSmallScreen ? 16 : 18;
    
    // Espaciados responsivos
    final double verticalSpacing = isSmallScreen ? 12 : 24;
    final double cardPadding = isSmallScreen ? 16 : 24;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isSmallScreen ? 8 : 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxCardWidth,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    "Gestión de Emergencias",
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),
                  Text(
                    "Con Localización",
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),
                  
                  // Card del formulario
                  Container(
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: cardTitleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Mensaje de error
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, 
                                  color: Colors.red.shade700,
                                  size: isSmallScreen ? 20 : 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isSmallScreen ? 13 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Campo Email
                        _buildTextField(
                          controller: _emailController,
                          hint: "Correo electrónico",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isSmallScreen: isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),

                        // Campo Contraseña
                        _buildTextField(
                          controller: _passwordController,
                          hint: "Contraseña",
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          isSmallScreen: isSmallScreen,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        SizedBox(height: verticalSpacing),

                        // Botón Ingresar
                        SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 45 : 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 45, 80, 50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _isLoading ? null : _iniciarSesion,
                            child: _isLoading
                                ? SizedBox(
                                    height: isSmallScreen ? 18 : 20,
                                    width: isSmallScreen ? 18 : 20,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Ingresar",
                                    style: TextStyle(fontSize: buttonTextSize),
                                  ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Divisor
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 12 : 16,
                              ),
                              child: Text(
                                "o continúa con",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Botón Google
                        SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 45 : 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onPressed: _isLoadingGoogle ? null : _iniciarSesionConGoogle,
                            icon: _isLoadingGoogle
                                ? SizedBox(
                                    height: isSmallScreen ? 18 : 20,
                                    width: isSmallScreen ? 18 : 20,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Image.network(
                                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                    height: isSmallScreen ? 20 : 24,
                                    width: isSmallScreen ? 20 : 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.g_mobiledata, 
                                        size: isSmallScreen ? 20 : 24,
                                      );
                                    },
                                  ),
                            label: Flexible(
                              child: Text(
                                _isLoadingGoogle ? "Conectando..." : "Continuar con Google",
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 20),

                        // Link Registrarse
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "¿No tienes cuenta?",
                              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                "Regístrate",
                                style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    required bool isSmallScreen,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
        prefixIcon: Icon(icon, size: isSmallScreen ? 20 : 24),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isSmallScreen ? 12 : 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}