import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:front_end/models/usuario.dart';
import 'package:front_end/widget/arrendatario/modal_reserva.dart';
import 'package:front_end/widget/arrendatario/modal_cita.dart';
import 'package:front_end/widget/arrendatario/reseña_modal.dart';

class DetalleHabitacionScreen extends StatefulWidget {
  final Map<String, dynamic> habitacion;
  final Usuario usuario;

  const DetalleHabitacionScreen({
    Key? key,
    required this.habitacion,
    required this.usuario,
  }) : super(key: key);

  @override
  State<DetalleHabitacionScreen> createState() =>
      _DetalleHabitacionScreenState();
}

class _DetalleHabitacionScreenState extends State<DetalleHabitacionScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchGoogleMaps(String url) async {
    try {
      if (url.isEmpty) {
        _mostrarError('URL de Google Maps no disponible');
        return;
      }

      String mapsUrl = url.trim();

      if (mapsUrl.startsWith('https://maps.app.goo.gl/') ||
          mapsUrl.startsWith('https://goo.gl/maps/')) {
        html.window.open(mapsUrl, '_blank');
        return;
      }

      final String encodedAddress = Uri.encodeComponent(mapsUrl);
      final String googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

      html.window.open(googleMapsUrl, '_blank');
    } catch (e) {
      _mostrarError('No se pudo abrir Google Maps: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarModalAgendarCita() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModalCita(
          habitacion: widget.habitacion,
          usuario: widget.usuario,
        ),
      ),
    );
  }

  void _mostrarModalApartar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ModalReserva(
          habitacion: widget.habitacion,
          usuario: widget.usuario,
          onAgendarCita: _mostrarModalAgendarCita,
        ),
      ),
    );
  }

  void _mostrarModalResenas() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ResenaModal(
          habitacionId: widget.habitacion['_id'] ?? '',
          usuarioId: widget.usuario.id ?? '',
          nombreUsuario: widget.usuario.nombre ?? 'Usuario',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Icon(Icons.home_work, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles de la Habitación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Información completa',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoBasica(),
                              const SizedBox(height: 16),
                              _buildDetallesCompletos(),
                              const SizedBox(height: 16),
                              _buildServicios(),
                              const SizedBox(height: 16),
                              _buildUbicacion(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(flex: 1, child: _buildCarruselFotos()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Colors.grey),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        _buildInfoArrendador(),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ModalReserva.botonAgendarCita(
                                onPressed: _mostrarModalAgendarCita,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModalReserva.botonApartarHabitacion(
                                onPressed: _mostrarModalApartar,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _mostrarModalResenas,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.reviews, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Reseñas y Comentarios',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUbicacion() {
    final hasGoogleMaps =
        widget.habitacion['googleMaps'] != null &&
        widget.habitacion['googleMaps'].toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '📍 Ubicación',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUbicacionItem(
                '🏙️ Zona',
                widget.habitacion['zona'] ?? 'No especificada',
              ),
              const SizedBox(height: 12),
              _buildUbicacionItem(
                '🏠 Dirección',
                widget.habitacion['direccion'] ?? 'No especificada',
              ),
              const SizedBox(height: 16),
              if (hasGoogleMaps)
                Container(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _launchGoogleMaps(widget.habitacion['googleMaps']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.blue[300]!, width: 2),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 20,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ver en Google Maps',
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
    );
  }

  Widget _buildCarruselFotos() {
    final fotografias = widget.habitacion['fotografias'] ?? [];

    return Column(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: fotografias.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No hay imágenes',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: fotografias.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image(
                            image: _getImageProvider(fotografias[index]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (fotografias.length > 1 && _currentImageIndex > 0)
                      Positioned(
                        left: 8,
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
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                                size: 24,
                              ),
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
                    if (fotografias.length > 1 &&
                        _currentImageIndex < fotografias.length - 1)
                      Positioned(
                        right: 8,
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
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 24,
                              ),
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
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_currentImageIndex + 1}/${fotografias.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        if (fotografias.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(fotografias.length, (index) {
              return Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Colors.green
                      : Colors.green.withOpacity(0.3),
                ),
              );
            }),
          ),
      ],
    );
  }

  ImageProvider _getImageProvider(String imageData) {
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
      return const AssetImage('assets/placeholder.png');
    }
  }

  Widget _buildInfoBasica() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Precio mensual',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${widget.habitacion['costo'] ?? '0'}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getTipoText(widget.habitacion),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesCompletos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 Detalles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildDetalleItem(
                '👥 Capacidad',
                '${widget.habitacion['capacidad']} personas',
              ),
              const SizedBox(height: 12),
              _buildDetalleItem(
                '📅 Duración',
                '${widget.habitacion['duracionRutas']} meses',
              ),
              const SizedBox(height: 12),
              _buildDetalleItem('🏠 Tipo', _getTipoCompleto(widget.habitacion)),
              const SizedBox(height: 12),
              _buildDetalleItem(
                '📍 Dirección',
                widget.habitacion['direccion'] ?? 'No especificada',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📝 Cláusulas:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.habitacion['clausulas'] ?? 'No hay cláusulas especiales',
                style: const TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetalleItem(String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicios() {
    final servicios = widget.habitacion['servicios'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚡ Servicios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        servicios.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Center(
                  child: Text(
                    'No hay servicios',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: servicios.map<Widget>((servicio) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green[100]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          servicio.toString(),
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildUbicacionItem(String icono, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icono, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoArrendador() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👤 Arrendador',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[100]!),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habitacion['nombreArrendador'] ??
                          'No especificado',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Arrendador verificado',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTipoText(Map<String, dynamic> habitacion) {
    final tipo = habitacion['tipo']?.toString().toLowerCase() ?? 'individual';
    final capacidad = habitacion['capacidad']?.toString() ?? '';

    if (tipo == 'individual') {
      return 'Individual';
    } else if (tipo == 'compartido' || tipo == 'compartida') {
      return capacidad.isNotEmpty ? 'Compartido ($capacidad)' : 'Compartido';
    } else {
      return tipo;
    }
  }

  String _getTipoCompleto(Map<String, dynamic> habitacion) {
    final tipo = habitacion['tipo']?.toString().toLowerCase() ?? 'individual';
    return tipo == 'individual'
        ? 'Habitación Individual'
        : 'Habitación Compartida';
  }
}
