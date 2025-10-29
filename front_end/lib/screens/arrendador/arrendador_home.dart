import 'package:flutter/material.dart';
import '../../models/usuario.dart';
import '../../services/informacion_service.dart';
import '../../widget/arrendador/welcome_card_arre.dart';
import '../../widget/arrendatario/habitacion_card.dart';
import '../auth/login_screen.dart';
import 'registrar_cuarto.dart';
import 'dart:convert';
import '../../widget/arrendador/notifications_widget.dart';

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

  Widget _buildImagenHabitacion(dynamic fotografias) {
    String? imageData;

    if (fotografias is List && fotografias.isNotEmpty) {
      imageData = fotografias.first.toString();
    } else if (fotografias is String) {
      imageData = fotografias;
    }

    if (imageData == null || imageData.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.home_work, size: 60, color: Colors.green[300]),
      );
    }

    try {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: _getImage(imageData),
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      print('Error cargando imagen: $e');
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text('Error cargando imagen', style: TextStyle(color: Colors.red)),
          ],
        ),
      );
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
          final bool tieneImagenes =
              fotografias is List && fotografias.isNotEmpty;

          return Dialog(
            backgroundColor: Colors.green[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
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

                              if (fotografias.length > 1 &&
                                  _currentImageIndex > 0)
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
                                        icon: Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _pageController.previousPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              if (fotografias.length > 1 &&
                                  _currentImageIndex < fotografias.length - 1)
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
                                        icon: Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _pageController.nextPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
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
                            children: List.generate(fotografias.length, (
                              index,
                            ) {
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
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
                                    children: (habitacion['servicios'] as List)
                                        .map((servicio) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.green[100]!,
                                              ),
                                            ),
                                            child: Text(
                                              servicio.toString(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _eliminarHabitacion(habitacion['_id']);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _editarHabitacion(habitacion);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Editar'),
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
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.green[800],
              ),
            ),
          ],
        ),
      ],
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
          _cargarMisHabitaciones();
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
                  foregroundColor: Colors.white,
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

  void _navegarAAgregarPropiedad() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrarCuarto(usuario: widget.usuario),
      ),
    );

    if (result == true) {
      _cargarMisHabitaciones();
    }
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
              child: Icon(Icons.business_center, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Arrendador',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Mis Propiedades',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
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
          NotificationsWidget(usuario: widget.usuario),
          const SizedBox(width: 4),
          Container(
            margin: const EdgeInsets.only(right: 4),
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
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 2),
                  Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              onPressed: _navegarAAgregarPropiedad,
              tooltip: 'Agregar Propiedad',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
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
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: 2),
                  Text(
                    'Salir',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeCardArre(usuario: widget.usuario),
              const SizedBox(height: 16),
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

              _isLoading
                  ? Container(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green[700]!,
                          ),
                        ),
                      ),
                    )
                  : _misHabitaciones.isEmpty
                  ? Container(
                      height: 300,
                      child: Center(
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
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.7,
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
            ],
          ),
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
