import 'package:flutter/material.dart';
import 'package:front_end/services/portada_service.dart';
import 'dart:convert';
import 'package:front_end/widget/arrendatario/ver_resenas.dart';

class HabitacionCard extends StatelessWidget {
  final Map<String, dynamic> habitacion;
  final VoidCallback onTap;

  const HabitacionCard({
    Key? key,
    required this.habitacion,
    required this.onTap,
  }) : super(key: key);

  void _mostrarResenas(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ResenasModal(habitacionId: habitacion['_id'] ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildImagenHabitacion()),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${habitacion['costo'] ?? '0'}/mes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  habitacion['zona'] ?? 'Sin zona',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  _getTipoText(habitacion),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (habitacion['servicios'] != null &&
                              (habitacion['servicios'] as List).isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 20,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (habitacion['servicios'] as List)
                                    .take(1)
                                    .length,
                                itemBuilder: (context, index) {
                                  final servicio =
                                      (habitacion['servicios'] as List)[index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green[100]!,
                                      ),
                                    ),
                                    child: Text(
                                      servicio.toString(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 30, 
                height: 30,
                child: Material(
                  color: Colors.white,
                  shape: CircleBorder(),
                  child: InkWell(
                    onTap: () => _mostrarResenas(context),
                    borderRadius: BorderRadius.circular(
                      15,
                    ), 
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_border,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenHabitacion() {
    final String habitacionId = habitacion['_id'] ?? '';

    if (habitacionId.isEmpty) {
      return _buildPlaceholderImage();
    }

    return FutureBuilder<String>(
      future: ProxyService.getFotoPortada(habitacionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingImage();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          print('Error cargando imagen del proxy: ${snapshot.error}');
          return _buildPlaceholderImage();
        }

        final imageData = snapshot.data!;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            image: DecorationImage(
              image: MemoryImage(base64.decode(imageData.split(',').last)),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getTipoAbreviado(habitacion['tipo'] ?? 'Ind'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.grey[200],
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.green[100],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.home_work, size: 40, color: Colors.green[300]),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getTipoAbreviado(habitacion['tipo'] ?? 'Ind'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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

  String _getTipoAbreviado(String? tipo) {
    if (tipo == null) return 'Ind';

    final tipoLower = tipo.toLowerCase();
    if (tipoLower == 'individual') {
      return 'Ind';
    } else if (tipoLower == 'compartido' || tipoLower == 'compartida') {
      return 'Cmp';
    } else {
      return 'Ind';
    }
  }
}


