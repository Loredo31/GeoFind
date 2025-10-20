import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';
import 'register_screen.dart';
import 'arrendador_home.dart';
import 'arrendatario_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _navigateToRoleScreen(Usuario usuario) {
    // Navegar según el rol
    if (usuario.rol == 'arrendador') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ArrendadorHomeScreen(usuario: usuario),
        ),
      );
    } else if (usuario.rol == 'arrendatario') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ArrendatarioHomeScreen(usuario: usuario),
        ),
      );
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (response['success'] == true) {
        // Convertir respuesta a objeto Usuario
        final usuario = Usuario.fromJson(response['usuario']);
        _navigateToRoleScreen(usuario);
      } else {
        _showErrorDialog(response['message']);
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    } finally {
      setState(() => _isLoading = false);
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.blue[700],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Inicia sesión en tu cuenta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
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
                const SizedBox(height: 20),

                // Campo Contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botón de Login
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Enlace a Registro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}