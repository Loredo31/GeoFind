import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/informacion_service.dart';
import '../../widget/arrendatario/welcome_card.dart';
import '../../widget/arrendatario/search_filter_widget.dart';
import '../../widget/arrendatario/habitacion_card.dart';
import '../auth/login_screen.dart'; // Importar el login para la navegación

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
      // Filtro por zona
      if (filtros['zona'] != null && habitacion['zona'] != filtros['zona']) {
        return false;
      }

      // Filtro por tipo de cuarto
      if (filtros['tipoCuarto'] != null && habitacion['tipoCuarto'] != filtros['tipoCuarto']) {
        return false;
      }

      // Filtro por precio
      final precio = double.tryParse(habitacion['costo']?.toString() ?? '0') ?? 0;
      if (precio < filtros['precioMin'] || precio > filtros['precioMax']) {
        return false;
      }

      // Filtro por servicios
      if (filtros['servicios'] != null && (filtros['servicios'] as List).isNotEmpty) {
        final serviciosHabitacion = List<String>.from(habitacion['servicios'] ?? []);
        final serviciosRequeridos = List<String>.from(filtros['servicios']);
        if (!serviciosRequeridos.every((servicio) => serviciosHabitacion.contains(servicio))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _mostrarDetallesHabitacion(Map<String, dynamic> habitacion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Habitación en ${habitacion['zona']}',
          style: TextStyle(
            color: Colors.green[800],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (habitacion['foto'] != null)
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
                ),
              const SizedBox(height: 16),
              Text(
                '\$${habitacion['costo']} / mes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoItem('Zona', habitacion['zona']),
              _buildInfoItem('Tipo', habitacion['tipoCuarto']),
              if (habitacion['capacidad'] != null)
                _buildInfoItem('Capacidad', '${habitacion['capacidad']} personas'),
              if (habitacion['servicios'] != null && (habitacion['servicios'] as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Servicios:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (habitacion['servicios'] as List).map((servicio) {
                        return Chip(
                          label: Text(servicio.toString()),
                          backgroundColor: Colors.green[100],
                          labelStyle: TextStyle(color: Colors.green[800]),
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: Colors.green[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para solicitar la habitación
              Navigator.pop(context);
              _mostrarMensaje('Solicitud enviada para la habitación');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Solicitar'),
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
          Text(
            value,
            style: TextStyle(color: Colors.green[800]),
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
              // Navegar al login screen con reemplazo
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
      backgroundColor: Colors.green[50], // Fondo verde bajito
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
            // Filtros de búsqueda
            SearchFilterWidget(onFiltersChanged: _aplicarFiltros),
            const SizedBox(height: 16),

            // Tarjeta de bienvenida
            WelcomeCard(usuario: widget.usuario),
            const SizedBox(height: 16),

            // Título de habitaciones
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

            // Grid de habitaciones
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
                            crossAxisCount: 2,
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
