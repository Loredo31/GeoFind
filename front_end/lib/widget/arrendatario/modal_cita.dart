import 'package:flutter/material.dart';
import 'package:front_end/models/usuario.dart';
import 'package:front_end/services/cita_service.dart';

class ModalCita extends StatefulWidget {
  final Map<String, dynamic> habitacion;
  final Usuario usuario;

  const ModalCita({
    Key? key,
    required this.habitacion,
    required this.usuario,
  }) : super(key: key);

  @override
  State<ModalCita> createState() => _ModalCitaState();
}

class _ModalCitaState extends State<ModalCita> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final List<String> _horasDisponibles = [
    '08:00', '09:00', '10:00', '11:00', '12:00', 
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
  ];
  
  String? _horaSeleccionada;
  DateTime? _fechaSeleccionada;
  bool _isLoading = false;

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
                    const Icon(Icons.calendar_today, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Agendar Cita',
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
                  'Programa una visita para conocer la habitación',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
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
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.usuario.nombre,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.usuario.email,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        'Fecha de la cita',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _seleccionarFecha,
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _fechaController,
                            decoration: InputDecoration(
                              hintText: 'Selecciona una fecha',
                              prefixIcon: const Icon(Icons.calendar_today, color: Colors.orange),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.orange),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecciona una fecha';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Hora de la cita (24H)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _horaSeleccionada,
                            hint: const Text('Selecciona una hora'),
                            isExpanded: true,
                            icon: const Icon(Icons.access_time, color: Colors.orange),
                            items: _horasDisponibles.map((String hora) {
                              return DropdownMenuItem<String>(
                                value: hora,
                                child: Text(
                                  hora,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _horaSeleccionada = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      if (_horaSeleccionada == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Selecciona una hora',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      const Text(
                        'Nota: La cita deberá ser confirmada por el arrendador.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _procesarCita,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'AGENDAR CITA',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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

  Future<void> _seleccionarFecha() async {
    DateTime initialDate = DateTime.now();
    while (initialDate.weekday == DateTime.saturday || initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      selectableDayPredicate: (DateTime day) {
        return day.weekday != DateTime.saturday && day.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _fechaSeleccionada = picked;
        _fechaController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _procesarCita() async {
    if (_horaSeleccionada == null) {
      _mostrarError('Por favor selecciona una hora');
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_fechaSeleccionada == null) {
        _mostrarError('Por favor selecciona una fecha');
        return;
      }

      setState(() => _isLoading = true);

      try {
        final citaData = {
          'nombreSolicitante': widget.usuario.nombre,
          'email': widget.usuario.email,
          'fecha': _fechaSeleccionada!.toIso8601String(),
          'hora': _horaSeleccionada,
          'habitacionId': widget.habitacion['_id'],
          'arrendatarioId': widget.usuario.id,
          'direccionHabitacion': widget.habitacion['direccion'],
          'estado': null, 
        };

        final response = await CitaService.crearCita(citaData);

        setState(() => _isLoading = false);

        if (response['success'] == true) {
          _mostrarExito();
        } else {
          _mostrarError('Error al agendar cita: ${response['message']}');
        }

      } catch (error) {
        setState(() => _isLoading = false);
        _mostrarError('Error de conexión: $error');
      }
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Cita Agendada!', style: TextStyle(color: Colors.orange)),
        content: const Text('Tu cita ha sido agendada correctamente. El arrendador la revisará y te confirmará pronto.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); 
            },
            child: const Text('Aceptar', style: TextStyle(color: Colors.orange)),
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
    _fechaController.dispose();
    super.dispose();
  }
}