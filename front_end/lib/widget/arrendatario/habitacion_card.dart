import 'package:flutter/material.dart';
import 'dart:convert';

class HabitacionCard extends StatelessWidget {
  final Map<String, dynamic> habitacion;
  final VoidCallback onTap;

  const HabitacionCard({
    Key? key,
    required this.habitacion,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          
          height: 220,
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
                        Icon(Icons.people, size: 12, color: Colors.grey[600]),
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
                                border: Border.all(color: Colors.green[100]!),
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
    );
  }


  Widget _buildImagenHabitacion() {
    final fotografias = habitacion['fotografias'];
    String? imageData;


    if (fotografias is List && fotografias.isNotEmpty) {
      imageData = fotografias.first.toString();
    } else if (fotografias is String) {
      imageData = fotografias;
    }

    ImageProvider imageProvider;

    if (imageData == null || imageData.isEmpty) {
    
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

    try {
      
      if (imageData.startsWith('data:image')) {
        final base64String = imageData.split(',').last;
        final bytes = base64.decode(base64String);
        imageProvider = MemoryImage(bytes);
      } else if (imageData.startsWith('http')) {
        imageProvider = NetworkImage(imageData);
      } else {
        final bytes = base64.decode(imageData);
        imageProvider = MemoryImage(bytes);
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          image: DecorationImage(
            image: imageProvider,
            fit:
                BoxFit.cover, 
          ),
        ),
        child: Stack(
          children: [
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
    } catch (e) {
      print('Error cargando imagen en HabitacionCard: $e');
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          color: Colors.red[100],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.red, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'Error imagen',
                    style: TextStyle(color: Colors.red, fontSize: 9),
                  ),
                ],
              ),
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
