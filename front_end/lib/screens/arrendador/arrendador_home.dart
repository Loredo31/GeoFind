// import 'package:flutter/material.dart';
// import '../../models/usuario.dart';

// class ArrendadorHomeScreen extends StatelessWidget {
//   final Usuario usuario;

//   const ArrendadorHomeScreen({Key? key, required this.usuario}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Panel Arrendador'),
//         backgroundColor: Colors.blue[700],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Bienvenida
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '¡Hola, ${usuario.nombre}!',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Rol: ${usuario.rol}',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     Text(
//                       'Email: ${usuario.email}',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Acciones del arrendador
//             const Text(
//               'Acciones Disponibles:',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),

//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: [
//                   _buildActionCard(
//                     icon: Icons.add_home,
//                     title: 'Agregar Propiedad',
//                     color: Colors.green,
//                     onTap: () {
//                       // Navegar a agregar propiedad
//                     },
//                   ),
//                   _buildActionCard(
//                     icon: Icons.list,
//                     title: 'Mis Propiedades',
//                     color: Colors.blue,
//                     onTap: () {
//                       // Navegar a listar propiedades
//                     },
//                   ),
//                   _buildActionCard(
//                     icon: Icons.request_quote,
//                     title: 'Solicitudes',
//                     color: Colors.orange,
//                     onTap: () {
//                       // Navegar a solicitudes
//                     },
//                   ),
//                   _buildActionCard(
//                     icon: Icons.analytics,
//                     title: 'Estadísticas',
//                     color: Colors.purple,
//                     onTap: () {
//                       // Navegar a estadísticas
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCard({
//     required IconData icon,
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 4,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: color),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/informacion_service.dart';
import '../../widget/arrendatario/welcome_card.dart';
import '../../widget/arrendatario/habitacion_card.dart';
import '../auth/login_screen.dart';
import 'registrar_cuarto.dart';

class ArrendadorHome extends StatefulWidget {
  final Usuario usuario;

  const ArrendadorHome({Key? key, required this.usuario}) : super(key: key);

  @override
  _ArrendadorHomeState createState() => _ArrendadorHomeState();
}

class _ArrendadorHomeState extends State<ArrendadorHome> {
  List<dynamic> _misHabitaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMisHabitaciones();
  }

  Future<void> _cargarMisHabitaciones() async {
    try {
      final response = await InformacionService.obtenerInformacionArrendador(
        widget.usuario.id!,
      );
      if (response['success'] == true) {
        setState(() {
          _misHabitaciones = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception(
          response['message'] ?? 'Error al cargar tus propiedades',
        );
      }
    } catch (error) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar tus propiedades: ${error.toString()}');
    }
  }

  void _mostrarDetallesHabitacion(Map<String, dynamic> habitacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Habitación en ${habitacion['zona'] ?? 'Sin ubicación'}',
          style: TextStyle(color: Colors.green[800]),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen de la habitación
              if (habitacion['foto'] != null &&
                  habitacion['foto'].toString().isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(habitacion['foto']),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.home_work,
                    size: 60,
                    color: Colors.green[300],
                  ),
                ),

              const SizedBox(height: 16),

              // Precio
              Text(
                '\$${habitacion['costo'] ?? '0'} / mes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 12),

              // Información básica
              _buildInfoItem('Zona', habitacion['zona'] ?? 'No especificada'),
              _buildInfoItem(
                'Tipo',
                habitacion['tipoCuarto'] ?? 'No especificado',
              ),

              if (habitacion['capacidad'] != null)
                _buildInfoItem(
                  'Capacidad',
                  '${habitacion['capacidad']} personas',
                ),

              // Servicios
              if (habitacion['servicios'] != null &&
                  (habitacion['servicios'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Servicios incluidos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (habitacion['servicios'] as List).map((
                        servicio,
                      ) {
                        return Chip(
                          label: Text(servicio.toString()),
                          backgroundColor: Colors.green[100],
                          labelStyle: TextStyle(color: Colors.green[800]),
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Estado
              _buildEstadoHabitacion(habitacion),
            ],
          ),
        ),
        actions: [
          // Botón eliminar
          TextButton(
            onPressed: () {
              _eliminarHabitacion(habitacion['_id']);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),

          // Botón editar
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editarHabitacion(habitacion);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.green[800])),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoHabitacion(Map<String, dynamic> habitacion) {
    final bool estaDisponible = habitacion['disponible'] ?? true;
    final int solicitudes = habitacion['solicitudes']?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                estaDisponible ? 'Disponible' : 'En revisión',
                style: TextStyle(
                  color: estaDisponible
                      ? Colors.green[700]
                      : Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        if (solicitudes > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.request_quote, color: Colors.blue[700], size: 16),
                const SizedBox(width: 4),
                Text(
                  '$solicitudes solicitud(es)',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _eliminarHabitacion(String? habitacionId) async {
    if (habitacionId == null) return;

    bool confirmar =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar esta propiedad?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmar) {
      try {
        final response = await InformacionService.eliminarInformacion(
          habitacionId,
        );
        if (response['success'] == true) {
          _mostrarMensaje('Propiedad eliminada correctamente');
          _cargarMisHabitaciones(); // Recargar la lista
        } else {
          _mostrarError(
            response['message'] ?? 'Error al eliminar la propiedad',
          );
        }
      } catch (error) {
        _mostrarError('Error al eliminar la propiedad: ${error.toString()}');
      }
    }
  }

  void _editarHabitacion(Map<String, dynamic> habitacion) {
    // Aquí iría la navegación a la pantalla de edición
    _mostrarMensaje('Funcionalidad de edición en desarrollo');
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    bool confirmar =
        await showDialog(
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
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmar) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // void _navegarAAgregarPropiedad() {
  //   // Aquí iría la navegación a la pantalla de agregar propiedad
  //   _mostrarMensaje('Funcionalidad de agregar propiedad en desarrollo');
  // }

void _navegarAAgregarPropiedad() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RegistrarCuarto(usuario: widget.usuario),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Panel Arrendador'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navegarAAgregarPropiedad,
            tooltip: 'Agregar Propiedad',
          ),
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
            // Tarjeta de bienvenida
            WelcomeCard(usuario: widget.usuario),
            const SizedBox(height: 16),

            // Título de propiedades
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mis Propiedades (${_misHabitaciones.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Row(
                  children: [
                    if (_misHabitaciones.isNotEmpty)
                      Text(
                        'Total: \$${_calcularTotalIngresos()}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.green[700]),
                      onPressed: _cargarMisHabitaciones,
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Grid de habitaciones
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green[700]!,
                        ),
                      ),
                    )
                  : _misHabitaciones.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_work,
                            size: 64,
                            color: Colors.green[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes propiedades registradas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _navegarAAgregarPropiedad,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Agregar Primera Propiedad'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _misHabitaciones.length,
                      itemBuilder: (context, index) {
                        final habitacion = _misHabitaciones[index];
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

  String _calcularTotalIngresos() {
    double total = 0;
    for (var habitacion in _misHabitaciones) {
      final costo =
          double.tryParse(habitacion['costo']?.toString() ?? '0') ?? 0;
      total += costo;
    }
    return total.toStringAsFixed(0);
  }
}
