import 'package:flutter/material.dart';
import 'package:front_end/services/reseña_service.dart';

class ResenaModal extends StatefulWidget {
  final String habitacionId;
  final String usuarioId;
  final String nombreUsuario;

  const ResenaModal({
    Key? key,
    required this.habitacionId,
    required this.usuarioId,
    required this.nombreUsuario,
  }) : super(key: key);

  @override
  _ResenaModalState createState() => _ResenaModalState();
}

class _ResenaModalState extends State<ResenaModal> {
  final _formKey =
      GlobalKey<FormState>(); // Clave global para validar el formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _comentarioArrendatarioController =
      TextEditingController();

  bool _isLoading = false;

  double _calificacionGeneral = 1.0;
  double _calificacionArrendatario = 1.0;
  Map<String, double> _calificacionesDetalladas = {
    'limpieza': 1.0,
    'ubicacion': 1.0,
    'comodidad': 1.0,
    'precio': 1.0,
    'atencion': 1.0,
  };

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombreUsuario; //Autorrellenar el nombre
  }

  // Función para crear y enviar la reseña
  Future<void> _crearResena() async {
    if (!_formKey.currentState!.validate()) return; // Validación

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> datosResena = {
        'nombre': _nombreController.text.trim(),
        'duracionRenta': int.parse(_duracionController.text.trim()),
        'comentario': _comentarioController.text.trim(),
        'habitacionId': widget.habitacionId,
        'usuarioId': widget.usuarioId,
        'calificacionGeneral': _calificacionGeneral,
        'calificacionesDetalladas': _calificacionesDetalladas,
        'calificacionArrendatario': _calificacionArrendatario,
        'comentarioArrendatario': _comentarioArrendatarioController.text.trim(),
      };

      final response = await ResenaService.crearResena(
        datosResena,
      ); // Crea reseña

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reseña creada exitosamente'),
            backgroundColor: Colors.purple,
          ),
        );
        _limpiarFormulario();
        Navigator.pop(context);
      } else {
        throw Exception(response['message'] ?? 'Error al crear reseña');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario() {
    _duracionController.clear();
    _comentarioController.clear();
    _comentarioArrendatarioController.clear();
    setState(() {
      _calificacionGeneral = 1.0;
      _calificacionArrendatario = 1.0;
      _calificacionesDetalladas = {
        'limpieza': 1.0,
        'ubicacion': 1.0,
        'comodidad': 1.0,
        'precio': 1.0,
        'atencion': 1.0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.purple[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Agregar Reseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.purple[700]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Formulario
              _buildFormularioResena(),
            ],
          ),
        ),
      ),
    );
  }

  // Construye el formulario
  Widget _buildFormularioResena() {
    return Expanded(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.purple[700]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!),
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

              TextFormField(
                controller: _duracionController,
                decoration: InputDecoration(
                  labelText: 'Duración de renta (meses)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ej: 6',
                  labelStyle: TextStyle(color: Colors.purple[700]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la duración';
                  }
                  final meses = int.tryParse(value);
                  if (meses == null || meses <= 0) {
                    return 'Ingresa un número válido de meses';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildCampoCalificacion(
                titulo: '⭐ Calificación General',
                valor: _calificacionGeneral,
                onChanged: (valor) {
                  setState(() {
                    _calificacionGeneral = valor;
                  });
                },
              ),

              const SizedBox(height: 16),

              _buildCalificacionesDetalladas(),

              const SizedBox(height: 16),

              TextFormField(
                controller: _comentarioController,
                decoration: InputDecoration(
                  labelText: 'Comentario sobre la habitación',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Comparte tu experiencia con la habitación...',
                  labelStyle: TextStyle(color: Colors.purple[700]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un comentario';
                  }
                  if (value.length < 10) {
                    return 'El comentario debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _buildCampoCalificacion(
                titulo: '👤 Calificación del Arrendatario',
                valor: _calificacionArrendatario,
                onChanged: (valor) {
                  setState(() {
                    _calificacionArrendatario = valor;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _comentarioArrendatarioController,
                decoration: InputDecoration(
                  labelText: 'Comentario sobre el arrendatario',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Comparte tu experiencia con el arrendatario...',
                  labelStyle: TextStyle(color: Colors.purple[700]),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!),
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _crearResena,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Enviar Reseña',
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
      ),
    );
  }

  // Widget reusable para campos de calificación
  Widget _buildCampoCalificacion({
    required String titulo,
    required double valor,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 12),

          // Slider para seleccionar calificación
          Slider(
            value: valor,
            min: 1.0,
            max: 5.0,
            divisions: 50,
            label: valor.toStringAsFixed(1),
            onChanged: onChanged,
            activeColor: Colors.purple[700],
            inactiveColor: Colors.purple[200],
          ),

          const SizedBox(height: 8),

          // Texto de calificacion
          Row(
            children: [
              Expanded(
                child: Text(
                  'Calificación: ${valor.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Escala de referencia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1.0',
                style: TextStyle(color: Colors.purple[600], fontSize: 12),
              ),
              Text(
                '3.0',
                style: TextStyle(color: Colors.purple[600], fontSize: 12),
              ),
              Text(
                '5.0',
                style: TextStyle(color: Colors.purple[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Construye la sección de calificaciones detalladas
  Widget _buildCalificacionesDetalladas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 Calificaciones Detalladas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Desliza para calificar cada categoría:',
            style: TextStyle(color: Colors.purple[600], fontSize: 12),
          ),
          const SizedBox(height: 16),

          _buildCampoCalificacionDetallada(
            icono: '🧹',
            titulo: 'Limpieza',
            valor: _calificacionesDetalladas['limpieza'] ?? 1.0,
            onChanged: (valor) {
              setState(() {
                _calificacionesDetalladas['limpieza'] = valor;
              });
            },
          ),

          const SizedBox(height: 16),

          _buildCampoCalificacionDetallada(
            icono: '📍',
            titulo: 'Ubicación',
            valor: _calificacionesDetalladas['ubicacion'] ?? 1.0,
            onChanged: (valor) {
              setState(() {
                _calificacionesDetalladas['ubicacion'] = valor;
              });
            },
          ),

          const SizedBox(height: 16),

          _buildCampoCalificacionDetallada(
            icono: '🛋️',
            titulo: 'Comodidad',
            valor: _calificacionesDetalladas['comodidad'] ?? 1.0,
            onChanged: (valor) {
              setState(() {
                _calificacionesDetalladas['comodidad'] = valor;
              });
            },
          ),

          const SizedBox(height: 16),

          _buildCampoCalificacionDetallada(
            icono: '💰',
            titulo: 'Precio',
            valor: _calificacionesDetalladas['precio'] ?? 1.0,
            onChanged: (valor) {
              setState(() {
                _calificacionesDetalladas['precio'] = valor;
              });
            },
          ),

          const SizedBox(height: 16),

          _buildCampoCalificacionDetallada(
            icono: '💬',
            titulo: 'Atención',
            valor: _calificacionesDetalladas['atencion'] ?? 1.0,
            onChanged: (valor) {
              setState(() {
                _calificacionesDetalladas['atencion'] = valor;
              });
            },
          ),
        ],
      ),
    );
  }

  // Widgets de calificaciones detalladas
  Widget _buildCampoCalificacionDetallada({
    required String icono,
    required String titulo,
    required double valor,
    required Function(double) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icono, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
              const Spacer(),
              // Indicador visual de la calificación con color
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getColorPorCalificacion(valor),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: valor == 1.0
                        ? Colors.grey[300]!
                        : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slider para seleccionar calificación
          Slider(
            value: valor,
            min: 1.0,
            max: 5.0,
            divisions: 50,
            label: valor.toStringAsFixed(1),
            onChanged: onChanged,
            activeColor: Colors.purple[700],
            inactiveColor: Colors.purple[200],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Calificación: ${valor.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1.0',
                style: TextStyle(color: Colors.purple[600], fontSize: 12),
              ),
              Text(
                '3.0',
                style: TextStyle(color: Colors.purple[600], fontSize: 12),
              ),
              Text(
                '5.0',
                style: TextStyle(color: Colors.purple[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorPorCalificacion(double calificacion) {
    if (calificacion == 1.0) return Colors.transparent;
    if (calificacion >= 4.0) return Colors.green;
    if (calificacion >= 3.0) return Colors.orange;
    if (calificacion >= 2.0) return Colors.yellow[700]!;
    return Colors.red;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _duracionController.dispose();
    _comentarioController.dispose();
    _comentarioArrendatarioController.dispose();
    super.dispose();
  }
}
