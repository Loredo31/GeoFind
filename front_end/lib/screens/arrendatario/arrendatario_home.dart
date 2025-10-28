// import 'package:flutter/material.dart';
// import '../../models/usuario.dart';
// import '../../services/informacion_service.dart';
// import '../../services/reserva_cuarto.dart';
// import '../../widget/arrendatario/welcome_card.dart';
// import '../../widget/arrendatario/search_filter_widget.dart';
// import '../../widget/arrendatario/habitacion_card.dart';
// import '../auth/login_screen.dart';
// import 'dart:convert';
// // Importa la pantalla de detalles que creamos
// import '../arrendatario/arrendatario_habitacion.dart'; // Asegúrate de que esta ruta sea correcta

// class ArrendatarioHome extends StatefulWidget {
//   final Usuario usuario;

//   const ArrendatarioHome({Key? key, required this.usuario}) : super(key: key);

//   @override
//   _ArrendatarioHomeState createState() => _ArrendatarioHomeState();
// }

// class _ArrendatarioHomeState extends State<ArrendatarioHome> {
//   List<dynamic> _habitaciones = [];
//   List<dynamic> _habitacionesFiltradas = [];
//   bool _isLoading = true;
//   Map<String, dynamic> _filtrosActuales = {};

//   @override
//   void initState() {
//     super.initState();
//     _cargarHabitaciones();
//   }

//   Future<void> _cargarHabitaciones() async {
//     try {
//       final response = await InformacionService.obtenerTodasLasHabitaciones();
//       if (response['success'] == true) {
//         setState(() {
//           _habitaciones = response['data'] ?? [];
//           _habitacionesFiltradas = _habitaciones;
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('Error al cargar habitaciones');
//       }
//     } catch (error) {
//       setState(() => _isLoading = false);
//       _mostrarError('Error al cargar las habitaciones: $error');
//     }
//   }

//   void _aplicarFiltros(Map<String, dynamic> filtros) {
//     setState(() {
//       _filtrosActuales = filtros;
//       _habitacionesFiltradas = _filtrarHabitaciones(_habitaciones, filtros);
//     });
//   }

//   List<dynamic> _filtrarHabitaciones(List<dynamic> habitaciones, Map<String, dynamic> filtros) {
//     return habitaciones.where((habitacion) {
//       // Filtro por zona - CORREGIDO
//       if (filtros['zona'] != null && 
//           filtros['zona'].isNotEmpty && 
//           habitacion['zona'] != null) {
//         final zonaHabitacion = habitacion['zona'].toString().toLowerCase();
//         final zonaFiltro = filtros['zona'].toString().toLowerCase();
//         if (!zonaHabitacion.contains(zonaFiltro)) {
//           return false;
//         }
//       }

//       if (filtros['tipoCuarto'] != null && 
//           filtros['tipoCuarto'].isNotEmpty && 
//           habitacion['tipoCuarto'] != null) {
//         final tipoHabitacion = habitacion['tipoCuarto'].toString().toLowerCase();
//         final tipoFiltro = filtros['tipoCuarto'].toString().toLowerCase();
//         if (tipoHabitacion != tipoFiltro) {
//           return false;
//         }
//       }

//       final precio = double.tryParse(habitacion['costo']?.toString() ?? '0') ?? 0;
//       final precioMin = (filtros['precioMin'] as num?)?.toDouble() ?? 0;
//       final precioMax = (filtros['precioMax'] as num?)?.toDouble() ?? double.maxFinite;
      
//       if (precio < precioMin || precio > precioMax) {
//         return false;
//       }

//       if (filtros['servicios'] != null && 
//           (filtros['servicios'] as List).isNotEmpty) {
//         final serviciosHabitacion = List<String>.from(habitacion['servicios'] ?? []);
//         final serviciosRequeridos = List<String>.from(filtros['servicios']);
        
//         if (!serviciosRequeridos.every((servicio) => 
//             serviciosHabitacion.any((s) => s.toString().toLowerCase() == servicio.toString().toLowerCase()))) {
//           return false;
//         }
//       }

//       return true;
//     }).toList();
//   }

//   // CAMBIO PRINCIPAL: Navegar a la pantalla de detalles en lugar de mostrar modal
//   void _mostrarDetallesHabitacion(Map<String, dynamic> habitacion) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DetalleHabitacionScreen(
//           habitacion: habitacion,
//           usuario: widget.usuario,
//         ),
//       ),
//     );
//   }

//   Future<void> _reservarHabitacion(Map<String, dynamic> habitacion) async {
//     await _mostrarFormularioReserva(habitacion);
//   }

//   Future<void> _mostrarFormularioReserva(Map<String, dynamic> habitacion) async {
//     final formKey = GlobalKey<FormState>();
//     final nombreController = TextEditingController(text: widget.usuario.nombre);
//     final emailController = TextEditingController(text: widget.usuario.email);
//     final telefonoController = TextEditingController();
//     final edadController = TextEditingController();
//     final direccionController = TextEditingController();
//     final curpController = TextEditingController();
//     final duracionController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.green[50],
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Reservar Habitación',
//           style: TextStyle(color: Colors.green[800]),
//         ),
//         content: SingleChildScrollView(
//           child: Form(
//             key: formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: nombreController,
//                   decoration: const InputDecoration(
//                     labelText: 'Nombre completo',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor ingresa tu nombre';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor ingresa tu email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: telefonoController,
//                   decoration: const InputDecoration(
//                     labelText: 'Teléfono',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor ingresa tu teléfono';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: edadController,
//                   decoration: const InputDecoration(
//                     labelText: 'Edad',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor ingresa tu edad';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Por favor ingresa una edad válida';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: direccionController,
//                   decoration: const InputDecoration(
//                     labelText: 'Dirección de vivienda actual',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 2,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor ingresa tu dirección';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: curpController,
//                   decoration: const InputDecoration(
//                     labelText: 'CURP',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor ingresa tu CURP';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: duracionController,
//                   decoration: const InputDecoration(
//                     labelText: 'Duración (meses)',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Por favor ingresa la duración';
//                     }
//                     if (int.tryParse(value) == null) {
//                       return 'Por favor ingresa un número válido';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancelar',
//               style: TextStyle(color: Colors.green[700]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (formKey.currentState!.validate()) {
//                 await _procesarReserva(
//                   habitacion,
//                   nombreController.text,
//                   emailController.text,
//                   telefonoController.text,
//                   int.parse(edadController.text),
//                   direccionController.text,
//                   curpController.text,
//                   int.parse(duracionController.text),
//                 );
//                 Navigator.pop(context);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green[700],
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Confirmar Reserva'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _procesarReserva(
//     Map<String, dynamic> habitacion,
//     String nombre,
//     String email,
//     String telefono,
//     int edad,
//     String direccionVivienda,
//     String curp,
//     int duracion,
//   ) async {
//     try {
//       final numeroContrato = 'CTR-${DateTime.now().millisecondsSinceEpoch}';

//       final datosReserva = {
//         'nombre': nombre,
//         'email': email,
//         'telefono': telefono,
//         'edad': edad,
//         'direccionVivienda': direccionVivienda,
//         'curp': curp,
//         'direccionHabitacion': habitacion['zona'],
//         'tipoHabitacion': habitacion['tipoCuarto'],
//         'duracion': duracion,
//         'costo': habitacion['costo'],
//         'nombreArrendador': habitacion['nombreArrendador'] ?? 'No especificado',
//         'numeroContrato': numeroContrato,
//         'estado': false,
//         'habitacionId': habitacion['_id'],
//         'arrendatarioId': widget.usuario.id,
//         'datosBancarios': {
//           'metodoPago': 'Por definir',
//         },
//       };

//       final response = await ReservarCuartoService.crearReserva(datosReserva);

//       if (response['success'] == true) {
//         _mostrarMensaje('¡Reserva enviada exitosamente! Número de contrato: $numeroContrato');
//       } else {
//         throw Exception(response['message'] ?? 'Error al crear la reserva');
//       }
//     } catch (error) {
//       _mostrarError('Error al procesar la reserva: $error');
//     }
//   }

//   void _mostrarError(String mensaje) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(mensaje),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _mostrarMensaje(String mensaje) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(mensaje),
//         backgroundColor: Colors.green[700],
//       ),
//     );
//   }

//   Future<void> _cerrarSesion() async {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.green[50],
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Text(
//           'Cerrar Sesión',
//           style: TextStyle(color: Colors.green[800]),
//         ),
//         content: Text(
//           '¿Estás seguro de que quieres cerrar sesión?',
//           style: TextStyle(color: Colors.green[700]),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancelar',
//               style: TextStyle(color: Colors.green[700]),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//                 (route) => false,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green[700],
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Cerrar Sesión'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.green[50],
//       appBar: AppBar(
//         title: const Text('Panel Arrendatario'),
//         backgroundColor: Colors.green[700],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _cerrarSesion,
//             tooltip: 'Cerrar Sesión',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: CustomScrollView(
//           slivers: [
//             // SliverToBoxAdapter para el filtro (se mantiene estático)
//             SliverToBoxAdapter(
//               child: SearchFilterWidget(onFiltersChanged: _aplicarFiltros),
//             ),
            
//             const SliverToBoxAdapter(
//               child: SizedBox(height: 16),
//             ),

//             // SliverToBoxAdapter para la tarjeta de bienvenida (se moverá al deslizar)
//             SliverToBoxAdapter(
//               child: WelcomeCard(usuario: widget.usuario),
//             ),
            
//             const SliverToBoxAdapter(
//               child: SizedBox(height: 16),
//             ),

//             // SliverToBoxAdapter para el título y botón de actualizar
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Habitaciones Disponibles (${_habitacionesFiltradas.length})',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green[800],
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.refresh, color: Colors.green[700]),
//                       onPressed: _cargarHabitaciones,
//                       tooltip: 'Actualizar',
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SliverToBoxAdapter(
//               child: SizedBox(height: 8),
//             ),

//             // SliverGrid para las habitaciones (se moverá al deslizar)
//             _isLoading
//                 ? SliverToBoxAdapter(
//                     child: Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(32.0),
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
//                         ),
//                       ),
//                     ),
//                   )
//                 : _habitacionesFiltradas.isEmpty
//                     ? SliverToBoxAdapter(
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(32.0),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.search_off, size: 64, color: Colors.green[300]),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   'No se encontraron habitaciones',
//                                   style: TextStyle(
//                                     fontSize: 16, 
//                                     color: Colors.green[600],
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   'Intenta ajustar los filtros de búsqueda',
//                                   style: TextStyle(
//                                     fontSize: 14, 
//                                     color: Colors.green[500],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     : SliverGrid(
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 4, 
//                           crossAxisSpacing: 12,
//                           mainAxisSpacing: 12,
//                           childAspectRatio: 0.75,
//                         ),
//                         delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                             final habitacion = _habitacionesFiltradas[index];
//                             return HabitacionCard(
//                               habitacion: habitacion,
//                               onTap: () => _mostrarDetallesHabitacion(habitacion),
//                             );
//                           },
//                           childCount: _habitacionesFiltradas.length,
//                         ),
//                       ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/informacion_service.dart';
import '../../services/reserva_cuarto.dart';
import '../../widget/arrendatario/welcome_card.dart';
import '../../widget/arrendatario/search_filter_widget.dart';
import '../../widget/arrendatario/habitacion_card.dart';
import '../auth/login_screen.dart';
import 'dart:convert';
// Importa la pantalla de detalles que creamos
import '../arrendatario/arrendatario_habitacion.dart'; // Asegúrate de que esta ruta sea correcta

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

      if (filtros['tipo'] != null && 
          filtros['tipo'].isNotEmpty && 
          habitacion['tipo'] != null) {
        final tipoHabitacion = habitacion['tipo'].toString().toLowerCase();
        final tipoFiltro = filtros['tipo'].toString().toLowerCase();
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

 
  void _mostrarDetallesHabitacion(Map<String, dynamic> habitacion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleHabitacionScreen(
          habitacion: habitacion,
          usuario: widget.usuario,
        ),
      ),
    );
  }

  Future<void> _reservarHabitacion(Map<String, dynamic> habitacion) async {
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
        'tipoHabitacion': habitacion['tipo'],
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
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Arrendatario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                // Text(
                //   'Bienvenido/a',
                //   style: TextStyle(
                //     fontSize: 12,
                //     fontWeight: FontWeight.w400,
                //     color: Colors.white.withOpacity(0.8),
                //   ),
                // ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.green[800]?.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 4),
                  Text(
                    'Salir',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onPressed: _cerrarSesion,
              tooltip: 'Cerrar Sesión',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            // SliverToBoxAdapter para el filtro (se mantiene estático)
            SliverToBoxAdapter(
              child: SearchFilterWidget(onFiltersChanged: _aplicarFiltros),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // SliverToBoxAdapter para la tarjeta de bienvenida (se moverá al deslizar)
            SliverToBoxAdapter(
              child: WelcomeCard(usuario: widget.usuario),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // SliverToBoxAdapter para el título y botón de actualizar
            SliverToBoxAdapter(
              child: Padding(
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
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

            // SliverGrid para las habitaciones (se moverá al deslizar)
            _isLoading
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                        ),
                      ),
                    ),
                  )
                : _habitacionesFiltradas.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
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
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, 
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final habitacion = _habitacionesFiltradas[index];
                            return HabitacionCard(
                              habitacion: habitacion,
                              onTap: () => _mostrarDetallesHabitacion(habitacion),
                            );
                          },
                          childCount: _habitacionesFiltradas.length,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}