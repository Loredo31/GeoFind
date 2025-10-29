import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  
  bool _isLoading = false;
  bool _verResenas = false;
  List<dynamic> _resenas = [];

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.nombreUsuario;
  }

  Future<void> _crearResena() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> datosResena = {
        'nombre': _nombreController.text.trim(),
        'duracionRenta': int.parse(_duracionController.text.trim()),
        'comentario': _comentarioController.text.trim(),
        'habitacionId': widget.habitacionId,
        'usuarioId': widget.usuarioId,
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/resena'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datosResena),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reseña creada exitosamente'),
            backgroundColor: Colors.purple, 
          ),
        );
        _limpiarFormulario();
        _cargarResenas();
      } else {
        throw Exception(data['message'] ?? 'Error al crear reseña');
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

  Future<void> _cargarResenas() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/resena/habitacion/${widget.habitacionId}'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        setState(() {
          _resenas = data['data'] ?? [];
        });
      } else {
        throw Exception(data['message'] ?? 'Error al cargar reseñas');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar reseñas: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _limpiarFormulario() {
    _duracionController.clear();
    _comentarioController.clear();
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.purple[50], 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _verResenas ? 'Reseñas de la Habitación' : 'Agregar Reseña',
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
              
              const SizedBox(height: 16),
              
             
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verResenas ? () => setState(() => _verResenas = false) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verResenas ? Colors.purple[100] : Colors.purple[700], 
                        foregroundColor: _verResenas ? Colors.purple[700] : Colors.white, 
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Agregar Reseña'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _verResenas ? null : () {
                        setState(() => _verResenas = true);
                        _cargarResenas();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verResenas ? Colors.purple[700] : Colors.purple[100],
                        foregroundColor: _verResenas ? Colors.white : Colors.purple[700], 
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Ver Reseñas'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              if (!_verResenas) _buildFormularioResena(),
              if (_verResenas) _buildListaResenas(),
            ],
          ),
        ),
      ),
    );
  }

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
              
              TextFormField(
                controller: _comentarioController,
                decoration: InputDecoration(
                  labelText: 'Comentario',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Comparte tu experiencia...',
                  labelStyle: TextStyle(color: Colors.purple[700]), 
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple[700]!), 
                  ),
                ),
                maxLines: 4,
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
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildListaResenas() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reseñas (${_resenas.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700], 
            ),
          ),
          
          const SizedBox(height: 12),
          
          if (_resenas.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.reviews, size: 64, color: Colors.purple[300]), 
                    const SizedBox(height: 16),
                    Text(
                      'No hay reseñas aún',
                      style: TextStyle(
                        color: Colors.purple[600], 
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sé el primero en compartir tu experiencia',
                      style: TextStyle(
                        color: Colors.purple[500], 
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _resenas.length,
                itemBuilder: (context, index) {
                  final resena = _resenas[index];
                  final fecha = DateTime.parse(resena['fechaReseña']).toLocal();
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.purple[50], 
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                resena['nombre'] ?? 'Anónimo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.purple[800], 
                                ),
                              ),
                              Text(
                                _formatearFecha(fecha),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.purple[600]), 
                              const SizedBox(width: 4),
                              Text(
                                '${resena['duracionRenta']} meses',
                                style: TextStyle(
                                  color: Colors.purple[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          Text(
                            resena['comentario'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _duracionController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }
}