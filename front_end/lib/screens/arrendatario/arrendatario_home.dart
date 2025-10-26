import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/informacion_service.dart';
import '../../services/reserva_cuarto.dart';
import '../../widget/arrendatario/welcome_card.dart';
import '../../widget/arrendatario/search_filter_widget.dart';
import '../../widget/arrendatario/habitacion_card.dart';
import '../auth/login_screen.dart';
import 'dart:convert';

class ArrendatarioHome extends StatefulWidget {
  final Usuario usuario;

  const ArrendatarioHome({Key? key, required this.usuario}) : super(key: key);

  @override
  _ArrendatarioHomeState createState() => _ArrendatarioHomeState();
}

class _ArrendatarioHomeState extends State<ArrendatarioHome> {
  List<dynamic> _habitaciones = [];
  List<dynamic> _habitacionesFiltradas = [];
  bool _isLoading = true;
  Map<String, dynamic> _filtrosActuales = {};

  @override
  void initState() {
    super.initState();
    _cargarHabitaciones();
  }

  Future<void> _cargarHabitaciones() async {
    try {
      final response = await InformacionService.obtenerTodasLasHabitaciones();
      if (response['success'] == true) {
        setState(() {
          _habitaciones = response['data'] ?? [];
          _habitacionesFiltradas = _habitaciones;
          _isLoading = false;
        });
      } else {
        throw Exception('Error al cargar habitaciones');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar las habitaciones: $error');
    }
  }

  void _aplicarFiltros(Map<String, dynamic> filtros) {
  setState(() {
    _filtrosActuales = filtros;
    _habitacionesFiltradas = _filtrarHabitaciones(_habitaciones, filtros);
  });
}

List<dynamic> _filtrarHabitaciones(List<dynamic> habitaciones, Map<String, dynamic> filtros) {
  return habitaciones.where((habitacion) {
    // Filtro por zona - CORREGIDO
    if (filtros['zona'] != null && 
        filtros['zona'].isNotEmpty && 
        habitacion['zona'] != null) {
      final zonaHabitacion = habitacion['zona'].toString().toLowerCase();
      final zonaFiltro = filtros['zona'].toString().toLowerCase();
      if (!zonaHabitacion.contains(zonaFiltro)) {
        return false;
      }
    }

    if (filtros['tipoCuarto'] != null && 
        filtros['tipoCuarto'].isNotEmpty && 
        habitacion['tipoCuarto'] != null) {
      final tipoHabitacion = habitacion['tipoCuarto'].toString().toLowerCase();
      final tipoFiltro = filtros['tipoCuarto'].toString().toLowerCase();
      if (tipoHabitacion != tipoFiltro) {
        return false;
      }
    }

    final precio = double.tryParse(habitacion['costo']?.toString() ?? '0') ?? 0;
    final precioMin = (filtros['precioMin'] as num?)?.toDouble() ?? 0;
    final precioMax = (filtros['precioMax'] as num?)?.toDouble() ?? double.maxFinite;
    
    if (precio < precioMin || precio > precioMax) {
      return false;
    }

    if (filtros['servicios'] != null && 
        (filtros['servicios'] as List).isNotEmpty) {
      final serviciosHabitacion = List<String>.from(habitacion['servicios'] ?? []);
      final serviciosRequeridos = List<String>.from(filtros['servicios']);
      
      if (!serviciosRequeridos.every((servicio) => 
          serviciosHabitacion.any((s) => s.toString().toLowerCase() == servicio.toString().toLowerCase()))) {
        return false;
      }
    }

    return true;
  }).toList();
}

  ImageProvider _getImage(String imageData) {
    try {
      if (imageData.startsWith('data:image')) {
        final base64String = imageData.split(',').last;
        final bytes = base64.decode(base64String);
        return MemoryImage(bytes);
      } else if (imageData.startsWith('http')) {
        return NetworkImage(imageData);
      } else {
        final bytes = base64.decode(imageData);
        return MemoryImage(bytes);
      }
    } catch (e) {
      return const AssetImage('assets/images/placeholder.png');
    }
  }

  void _mostrarDetallesHabitacion(Map<String, dynamic> habitacion) {
    final PageController _pageController = PageController();
    int _currentImageIndex = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final fotografias = habitacion['fotografias'] ?? [];
          final bool tieneImagenes = fotografias is List && fotografias.isNotEmpty;
          
          return Dialog(
            backgroundColor: Colors.green[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Habitación en ${habitacion['zona'] ?? 'Sin ubicación'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.green[700]),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),

                      
                      if (tieneImagenes) ...[
                        Container(
                          height: 220,
                          child: Stack(
                            children: [
                             
                              PageView.builder(
                                controller: _pageController,
                                itemCount: fotografias.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: _getImage(fotografias[index]),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          
                              if (fotografias.length > 1 && _currentImageIndex > 0)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.chevron_left, color: Colors.white, size: 20),
                                        onPressed: () {
                                          _pageController.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                       
                              if (fotografias.length > 1 && _currentImageIndex < fotografias.length - 1)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                        onPressed: () {
                                          _pageController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                    
                              if (fotografias.length > 1)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_currentImageIndex + 1}/${fotografias.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
             
                        if (fotografias.length > 1) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(fotografias.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index 
                                        ? Colors.green[700]!
                                        : Colors.green[300]!,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                        const SizedBox(height: 8),
                      ] else ...[
                  
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.home_work,
                            size: 50,
                            color: Colors.green[300],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                         
                            Center(
                              child: Text(
                                '\$${habitacion['costo'] ?? '0'} / mes',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                           
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _buildInfoItemCompact(
                                  Icons.location_on,
                                  'Zona',
                                  habitacion['zona'] ?? 'No especificada',
                                ),
                                _buildInfoItemCompact(
                                  Icons.category,
                                  'Tipo',
                                  habitacion['tipo'] ?? 'No especificado',
                                ),
                                if (habitacion['capacidad'] != null)
                                  _buildInfoItemCompact(
                                    Icons.people,
                                    'Capacidad',
                                    '${habitacion['capacidad']} personas',
                                  ),
                                if (habitacion['descripcion'] != null)
                                  _buildInfoItemCompact(
                                    Icons.description,
                                    'Descripción',
                                    habitacion['descripcion'],
                                  ),
                              ],
                            ),

                       
                            if (habitacion['servicios'] != null &&
                                (habitacion['servicios'] as List).isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    'Servicios:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: (habitacion['servicios'] as List).take(4).map((servicio) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.green[100]!),
                                        ),
                                        child: Text(
                                          servicio.toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green[800],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 12),

                           
                            _buildEstadoHabitacionCompact(habitacion),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                    
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _reservarHabitacion(habitacion),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Reservar Habitación'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

 
  Widget _buildInfoItemCompact(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.green[600]),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

 
  Widget _buildEstadoHabitacionCompact(Map<String, dynamic> habitacion) {
    final bool estaDisponible = habitacion['disponible'] ?? true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: estaDisponible ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estaDisponible ? Icons.check_circle : Icons.pending,
            color: estaDisponible ? Colors.green[700] : Colors.orange[700],
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            estaDisponible ? 'Disponible para reservar' : 'No disponible',
            style: TextStyle(
              color: estaDisponible ? Colors.green[700] : Colors.orange[700],
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _reservarHabitacion(Map<String, dynamic> habitacion) async {
   
    Navigator.pop(context);


    await _mostrarFormularioReserva(habitacion);
  }

  Future<void> _mostrarFormularioReserva(Map<String, dynamic> habitacion) async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: widget.usuario.nombre);
    final emailController = TextEditingController(text: widget.usuario.email);
    final telefonoController = TextEditingController();
    final edadController = TextEditingController();
    final direccionController = TextEditingController();
    final curpController = TextEditingController();
    final duracionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reservar Habitación',
          style: TextStyle(color: Colors.green[800]),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: edadController,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu edad';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor ingresa una edad válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección de vivienda actual',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu dirección';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: curpController,
                  decoration: const InputDecoration(
                    labelText: 'CURP',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu CURP';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: duracionController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (meses)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la duración';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor ingresa un número válido';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _procesarReserva(
                  habitacion,
                  nombreController.text,
                  emailController.text,
                  telefonoController.text,
                  int.parse(edadController.text),
                  direccionController.text,
                  curpController.text,
                  int.parse(duracionController.text),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Reserva'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarReserva(
    Map<String, dynamic> habitacion,
    String nombre,
    String email,
    String telefono,
    int edad,
    String direccionVivienda,
    String curp,
    int duracion,
  ) async {
    try {
      final numeroContrato = 'CTR-${DateTime.now().millisecondsSinceEpoch}';

      final datosReserva = {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'edad': edad,
        'direccionVivienda': direccionVivienda,
        'curp': curp,
        'direccionHabitacion': habitacion['zona'],
        'tipoHabitacion': habitacion['tipoCuarto'],
        'duracion': duracion,
        'costo': habitacion['costo'],
        'nombreArrendador': habitacion['nombreArrendador'] ?? 'No especificado',
        'numeroContrato': numeroContrato,
        'estado': false,
        'habitacionId': habitacion['_id'],
        'arrendatarioId': widget.usuario.id,
        'datosBancarios': {
          'metodoPago': 'Por definir',
        },
      };

      final response = await ReservarCuartoService.crearReserva(datosReserva);

      if (response['success'] == true) {
        _mostrarMensaje('¡Reserva enviada exitosamente! Número de contrato: $numeroContrato');
      } else {
        throw Exception(response['message'] ?? 'Error al crear la reserva');
      }
    } catch (error) {
      _mostrarError('Error al procesar la reserva: $error');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.green[800]),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.green[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
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
        title: const Text('Panel Arrendatario'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            SearchFilterWidget(onFiltersChanged: _aplicarFiltros),
            const SizedBox(height: 16),

            
            WelcomeCard(usuario: widget.usuario),
            const SizedBox(height: 16),

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Habitaciones Disponibles (${_habitacionesFiltradas.length})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.green[700]),
                    onPressed: _cargarHabitaciones,
                    tooltip: 'Actualizar',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                      ),
                    )
                  : _habitacionesFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.green[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron habitaciones',
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: Colors.green[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Intenta ajustar los filtros de búsqueda',
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: Colors.green[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, 
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _habitacionesFiltradas.length,
                          itemBuilder: (context, index) {
                            final habitacion = _habitacionesFiltradas[index];
                            return HabitacionCard(
                              habitacion: habitacion,
                              onTap: () => _mostrarDetallesHabitacion(habitacion),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}