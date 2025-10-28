import 'package:flutter/material.dart';
import 'package:front_end/models/usuario.dart';
import 'package:front_end/services/reserva_cuarto.dart';

class ModalReserva extends StatefulWidget {
  final Map<String, dynamic> habitacion;
  final Usuario usuario;
  final VoidCallback? onAgendarCita;

  const ModalReserva({
    Key? key,
    required this.habitacion,
    required this.usuario,
    this.onAgendarCita,
  }) : super(key: key);

  // MÉTODO ESTÁTICO para crear el botón de Agendar Cita
  static Widget botonAgendarCita({required VoidCallback onPressed}) {
    return Container(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[50],
          foregroundColor: Colors.orange[800],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange[300]!, width: 2),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 22, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Agendar Cita',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget botonApartarHabitacion({required VoidCallback onPressed}) {
    return Container(
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[50],
          foregroundColor: Colors.green[800],
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green[300]!, width: 2),
          ),
          elevation: 2,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work, size: 22, color: Colors.green),
            SizedBox(width: 8),
            Text(
              'Apartar Habitación',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<ModalReserva> createState() => _ModalReservaState();
}

class _ModalReservaState extends State<ModalReserva> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  bool _isLoading = false;

  void _mostrarModalAgendarCita() {
    if (widget.onAgendarCita != null) {
      widget.onAgendarCita!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home_work, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Apartar Habitación',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa tus datos para reservar la habitación',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.home_work, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Habitación ${widget.habitacion['tipo'] == 'individual' ? 'Individual' : 'Compartida'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.habitacion['zona'] ?? 'Sin zona',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              '\$${widget.habitacion['costo']}/mes',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tus datos de usuario',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDatoUsuario('👤 Nombre', widget.usuario.nombre),
                      _buildDatoUsuario('📧 Email', widget.usuario.email),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información adicional requerida',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _edadController,
                        label: 'Edad *',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu edad';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Ingresa una edad válida';
                          }
                          if (int.parse(value) < 18) {
                            return 'Debes ser mayor de 18 años';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _telefonoController,
                        label: 'Teléfono *',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu teléfono';
                          }
                          if (value.length < 10) {
                            return 'El teléfono debe tener 10 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _direccionController,
                        label: 'Dirección de vivienda actual *',
                        icon: Icons.location_on,
                        maxLines: 1,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu dirección';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _curpController,
                        label: 'CURP *',
                        icon: Icons.badge,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu CURP';
                          }
                          if (value.length != 18) {
                            return 'La CURP debe tener 18 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.green))
                          : Container(
                              height: 60,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _procesarReserva,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.home_work, size: 22, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'CONFIRMAR RESERVA',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatoUsuario(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  void _procesarReserva() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final reservaData = {
          'nombre': widget.usuario.nombre,
          'email': widget.usuario.email,
          'telefono': _telefonoController.text,
          'edad': int.parse(_edadController.text),
          'direccionVivienda': _direccionController.text,
          'curp': _curpController.text,
          'direccionHabitacion': widget.habitacion['direccion'],
          'tipoHabitacion': widget.habitacion['tipo'],
          'duracion': widget.habitacion['duracionRutas'] ?? 12,
          'costo': widget.habitacion['costo'],
          'nombreArrendador': widget.habitacion['nombreArrendador'],
          'numeroContrato': 'CTR-${DateTime.now().millisecondsSinceEpoch}',
          'estado': null, // IMPORTANTE: empieza como null
          'habitacionId': widget.habitacion['_id'],
          'arrendatarioId': widget.usuario.id,
          'datosBancarios': {
            'metodoPago': 'Por definir',
          },
        };

        // ENVIAR AL BACKEND
        final response = await ReservarCuartoService.crearReserva(reservaData);

        setState(() {
          _isLoading = false;
        });

        if (response['success'] == true) {
          _mostrarExito();
        } else {
          _mostrarError('Error al crear reserva: ${response['message']}');
        }

      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        _mostrarError('Error de conexión: $error');
      }
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Reserva Exitosa!', style: TextStyle(color: Colors.green)),
        content: const Text('Tu reserva ha sido enviada correctamente. El arrendador la revisará y te confirmará pronto.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Cerrar modal
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _edadController.dispose();
    _direccionController.dispose();
    _curpController.dispose();
    super.dispose();
  }
}