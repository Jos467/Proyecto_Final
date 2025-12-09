import 'package:flutter/material.dart';
import 'package:proyecto_movil_2/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isLoadingGoogle = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================
  // VALIDAR FORMATO DE EMAIL
  // ============================================
  Map<String, dynamic> _validarEmail(String email) {
    // Verificar que no esté vacío
    if (email.isEmpty) {
      return {
        'valido': false,
        'mensaje': 'Por favor ingresa tu correo electrónico',
      };
    }

    // Verificar que contenga @
    if (!email.contains('@')) {
      return {
        'valido': false,
        'mensaje': 'El correo debe contener @',
      };
    }

    // Verificar que tenga algo antes del @
    List<String> partes = email.split('@');
    if (partes[0].isEmpty) {
      return {
        'valido': false,
        'mensaje': 'Ingresa un nombre de usuario antes del @',
      };
    }

    // Verificar que tenga dominio después del @
    if (partes.length < 2 || partes[1].isEmpty) {
      return {
        'valido': false,
        'mensaje': 'Ingresa un dominio después del @',
      };
    }

    String dominio = partes[1].toLowerCase();

    // Verificar que el dominio contenga un punto
    if (!dominio.contains('.')) {
      return {
        'valido': false,
        'mensaje': 'El dominio debe contener un punto (ejemplo: .com)',
      };
    }

    // Verificar extensiones válidas comunes
    List<String> extensionesValidas = [
      '.com', '.net', '.org', '.edu', '.gov', '.io', '.co',
      '.es', '.mx', '.ar', '.cl', '.hn', '.gt', '.sv', '.ni', '.cr', '.pa',
      '.info', '.biz', '.us', '.uk', '.de', '.fr', '.it', '.br',
    ];

    bool tieneExtensionValida = extensionesValidas.any(
      (ext) => dominio.endsWith(ext)
    );

    if (!tieneExtensionValida) {
      // Verificar al menos que termine con .algo (2+ caracteres)
      RegExp extensionRegex = RegExp(r'\.[a-zA-Z]{2,}$');
      if (!extensionRegex.hasMatch(dominio)) {
        return {
          'valido': false,
          'mensaje': 'Ingresa una extensión válida (ejemplo: .com, .org, .net)',
        };
      }
    }

    // Validación con regex completa para formato correcto
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return {
        'valido': false,
        'mensaje': 'El formato del correo no es válido',
      };
    }

    return {
      'valido': true,
      'mensaje': '',
    };
  }

  // ============================================
  // REGISTRAR USUARIO
  // ============================================
  Future<void> _registrarUsuario() async {
    setState(() {
      _errorMessage = null;
    });

    String nombre = _nombreController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Validación: Nombre vacío
    if (nombre.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu nombre completo';
      });
      return;
    }

    // Validación: Nombre muy corto
    if (nombre.length < 3) {
      setState(() {
        _errorMessage = 'El nombre debe tener al menos 3 caracteres';
      });
      return;
    }

    // Validación: Email con validación detallada
    Map<String, dynamic> validacionEmail = _validarEmail(email);
    if (!validacionEmail['valido']) {
      setState(() {
        _errorMessage = validacionEmail['mensaje'];
      });
      return;
    }

    // Validación: Contraseña vacía
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa una contraseña';
      });
      return;
    }

    // Validación: Longitud mínima de contraseña
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      });
      return;
    }

    // Validación: Confirmar contraseña vacía
    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor confirma tu contraseña';
      });
      return;
    }

    // Validación: Contraseñas no coinciden
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> resultado = await _authService.registrarConCorreo(
      nombre: nombre,
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (resultado['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() {
        _errorMessage = resultado['message'];
      });
    }
  }

  // ============================================
  // INICIAR SESIÓN CON GOOGLE
  // ============================================
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
    final bool isSmallScreen = screenHeight < 700;
    final bool isVerySmallScreen = screenHeight < 600;
    final bool isLargeScreen = screenWidth > 600;
    final double horizontalPadding = isLargeScreen ? screenWidth * 0.15 : 24.0;
    final double maxCardWidth = isLargeScreen ? 500.0 : double.infinity;
    
    // Tamaños de fuente responsivos
    final double titleSize = isVerySmallScreen ? 24 : (isLargeScreen ? 36 : 32);
    final double cardTitleSize = isVerySmallScreen ? 18 : 22;
    final double buttonTextSize = isVerySmallScreen ? 16 : 18;
    
    // Espaciados responsivos
    final double verticalSpacing = isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16);
    final double cardPadding = isVerySmallScreen ? 16 : 24;
    final double fieldSpacing = isVerySmallScreen ? 10 : 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isVerySmallScreen ? 8 : 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxCardWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón volver
                  if (!isLargeScreen)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  
                  SizedBox(height: isVerySmallScreen ? 8 : 16),
                  
                  Text(
                    "Crear Cuenta",
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),
                  
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
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Registro con correo",
                          style: TextStyle(
                            fontSize: cardTitleSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Mensaje de error
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(isVerySmallScreen ? 10 : 12),
                            margin: EdgeInsets.only(bottom: fieldSpacing),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline, 
                                  color: Colors.red.shade700,
                                  size: isVerySmallScreen ? 18 : 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isVerySmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Campo Nombre
                        _buildTextField(
                          controller: _nombreController,
                          hint: "Nombre completo",
                          icon: Icons.person_outline,
                          textCapitalization: TextCapitalization.words,
                          isSmallScreen: isVerySmallScreen,
                        ),
                        SizedBox(height: fieldSpacing),

                        // Campo Email
                        _buildTextField(
                          controller: _emailController,
                          hint: "Correo electrónico",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isSmallScreen: isVerySmallScreen,
                        ),
                        
                        // Hint de formato de correo
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 4),
                          child: Text(
                            'Ejemplo: usuario@dominio.com',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 10 : 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                        SizedBox(height: fieldSpacing - 4),

                        // Campo Contraseña
                        _buildTextField(
                          controller: _passwordController,
                          hint: isVerySmallScreen ? "Contraseña (mín. 6)" : "Contraseña (mínimo 6 caracteres)",
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          isSmallScreen: isVerySmallScreen,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: isVerySmallScreen ? 20 : 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: fieldSpacing),

                        // Campo Confirmar Contraseña
                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: "Confirmar contraseña",
                          icon: Icons.lock_reset_outlined,
                          obscureText: _obscureConfirmPassword,
                          isSmallScreen: isVerySmallScreen,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              size: isVerySmallScreen ? 20 : 24,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: verticalSpacing),

                        // Botón Crear Cuenta
                        SizedBox(
                          width: double.infinity,
                          height: isVerySmallScreen ? 45 : 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 45, 80, 50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: _isLoading ? null : _registrarUsuario,
                            child: _isLoading
                                ? SizedBox(
                                    height: isVerySmallScreen ? 18 : 20,
                                    width: isVerySmallScreen ? 18 : 20,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Crear Cuenta",
                                    style: TextStyle(fontSize: buttonTextSize),
                                  ),
                          ),
                        ),

                        SizedBox(height: verticalSpacing),

                        // Divisor
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isVerySmallScreen ? 8 : 16,
                              ),
                              child: Text(
                                "o continúa con",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isVerySmallScreen ? 12 : 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),

                        SizedBox(height: verticalSpacing),

                        // Botón Google
                        SizedBox(
                          width: double.infinity,
                          height: isVerySmallScreen ? 45 : 50,
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
                                    height: isVerySmallScreen ? 18 : 20,
                                    width: isVerySmallScreen ? 18 : 20,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Image.network(
                                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                    height: isVerySmallScreen ? 20 : 24,
                                    width: isVerySmallScreen ? 20 : 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.g_mobiledata, 
                                        size: isVerySmallScreen ? 20 : 24,
                                      );
                                    },
                                  ),
                            label: Flexible(
                              child: Text(
                                _isLoadingGoogle ? "Conectando..." : "Continuar con Google",
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 14 : 16,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isVerySmallScreen ? 8 : 20),

                        // Link para ir a Login
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "¿Ya tienes una cuenta?",
                              style: TextStyle(fontSize: isVerySmallScreen ? 12 : 14),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: isVerySmallScreen ? 4 : 8,
                                ),
                              ),
                              child: Text(
                                "Inicia sesión",
                                style: TextStyle(fontSize: isVerySmallScreen ? 12 : 14),
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    required bool isSmallScreen,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: isSmallScreen ? 13 : 16),
        prefixIcon: Icon(icon, size: isSmallScreen ? 20 : 24),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isSmallScreen ? 10 : 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}