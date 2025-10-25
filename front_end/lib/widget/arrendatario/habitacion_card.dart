import 'package:flutter/material.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la habitación
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: habitacion['foto'] != null 
                      ? NetworkImage(habitacion['foto'] as String)
                      : const AssetImage('assets/default_room.jpg') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Badge de tipo de cuarto
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        habitacion['tipoCuarto'] ?? 'Individual',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Información de la habitación
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio
                  Text(
                    '\$${habitacion['costo'] ?? '0'} / mes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Zona
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        habitacion['zona'] ?? 'Sin zona',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Tipo y capacidad
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _getTipoText(habitacion),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Servicios (si existen)
                  if (habitacion['servicios'] != null && (habitacion['servicios'] as List).isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: (habitacion['servicios'] as List).take(2).map((servicio) {
                        return Chip(
                          label: Text(
                            servicio.toString(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          backgroundColor: Colors.green[50],
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTipoText(Map<String, dynamic> habitacion) {
    final tipo = habitacion['tipoCuarto'] ?? 'Individual';
    if (tipo == 'Compartido' && habitacion['capacidad'] != null) {
      return 'Compartido (${habitacion['capacidad']} personas)';
    }
    return tipo;
  }
}