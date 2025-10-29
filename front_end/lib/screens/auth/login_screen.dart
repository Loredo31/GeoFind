import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/usuario.dart';
import 'register_screen.dart';
import '../arrendador/arrendador_home.dart';
import '../arrendatario/arrendatario_home.dart';
import '../../widget/auth/authCard.dart';

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
  bool _obscurePassword = true;

  void _navigateToRoleScreen(Usuario usuario) {
    if (usuario.rol == 'arrendador') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ArrendadorHome(usuario: usuario),
        ),
      );
    } else if (usuario.rol == 'arrendatario') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ArrendatarioHome(usuario: usuario),
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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
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
                    const SizedBox(height: 20),
                    Icon(
                      Icons.account_circle,
                      size: 80,
                      color: Colors.green[700],
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
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Gmail',
                        labelStyle: TextStyle(color: Colors.green[800]),
                        prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green[500]!,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.green[50],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu gmail';
                        }
                        if (!value.contains('@')) {
                          return 'Ingresa un gmail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: Colors.green[800]),
                        prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.green[700],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.green[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.green[500]!,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.green[50],
                      ),
                      obscureText: _obscurePassword,
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

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        '¿No tienes cuenta? Regístrate aquí',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 16,
                        ),
                      ),
                    ),
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
