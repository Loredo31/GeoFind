import 'package:flutter/material.dart';
import 'package:front_end/models/usuario.dart';
import '../../services/auth_service.dart';
import '../arrendador/arrendador_home.dart';
import '../arrendatario/arrendatario_home.dart';
import 'login_screen.dart';
import '../../widget/auth/authCard.dart';
import '../../widget/auth/custom_text_field.dart';
import '../../widget/auth/custom_elevated_button.dart';
import '../../widget/auth/auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  String _selectedRol = 'arrendatario';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Las contraseñas no coinciden');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.register(
        _nombreController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRol,
        _telefonoController.text.trim(),
        _direccionController.text.trim(),
      );

      if (response['success'] == true) {
        final usuario = Usuario.fromJson(response['usuario']);
        _showSuccessDialog(usuario);
      } else {
        _showErrorDialog(response['message']);
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registro Exitoso'),
        content: const Text('Tu cuenta ha sido creada correctamente.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (usuario.rol == 'arrendador') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArrendadorHome(usuario: usuario),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArrendatarioHome(usuario: usuario),
                  ),
                );
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AuthCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AuthHeader(
                      icon: Icons.person_add,
                      title: 'Crear Cuenta',
                      subtitle: 'Completa tus datos para registrarte',
                    ),

                    // Campo Nombre
                    CustomTextField(
                      controller: _nombreController,
                      labelText: 'Nombre Completo',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Email
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu email';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Contraseña
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      prefixIcon: Icons.lock,
                      suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      onSuffixPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Confirmar Contraseña
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirmar Contraseña',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      onSuffixPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor confirma tu contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Rol (mantenemos el original sin widget personalizado)
                    DropdownButtonFormField<String>(
                      value: _selectedRol,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Usuario',
                        labelStyle: TextStyle(color: Colors.green[800]),
                        prefixIcon: Icon(Icons.people, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green[500]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.green[50],
                      ),
                      dropdownColor: Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: 'arrendatario',
                          child: Text('Arrendatario'),
                        ),
                        DropdownMenuItem(
                          value: 'arrendador',
                          child: Text('Arrendador'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRol = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Teléfono
                    CustomTextField(
                      controller: _telefonoController,
                      labelText: 'Teléfono (Opcional)',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Campo Dirección
                    CustomTextField(
                      controller: _direccionController,
                      labelText: 'Dirección (Opcional)',
                      prefixIcon: Icons.home,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 30),

                    // Botón de Registro
                    CustomElevatedButton(
                      text: 'Registrarse',
                      onPressed: _register,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),

                    // Enlace a Login
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        '¿Ya tienes cuenta? Inicia sesión aquí',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}