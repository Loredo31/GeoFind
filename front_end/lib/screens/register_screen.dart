import 'package:flutter/material.dart';
import 'package:front_end/models/usuario.dart';
import '../services/auth_service.dart';
import 'arrendador_home.dart';
import 'arrendatario_home.dart';
import 'login_screen.dart';

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
            // Navegar directamente al home según el rol
            if (usuario.rol == 'arrendador') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ArrendadorHomeScreen(usuario: usuario),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ArrendatarioHomeScreen(usuario: usuario),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.person_add,
                  size: 60,
                  color: Colors.green[700],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Campo Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                const SizedBox(height: 16),

                // Campo Contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
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
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown Rol
                DropdownButtonFormField<String>(
                  value: _selectedRol,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Usuario',
                    prefixIcon: const Icon(Icons.people),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
                TextFormField(
                  controller: _telefonoController,
                  decoration: InputDecoration(
                    labelText: 'Teléfono (Opcional)',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Campo Dirección
                TextFormField(
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección (Opcional)',
                    prefixIcon: const Icon(Icons.home),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 30),

                // Botón de Registro
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            'Registrarse',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
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
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión aquí',
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
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }
}