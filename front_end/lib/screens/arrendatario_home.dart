import 'package:flutter/material.dart';
import '../models/usuario.dart';

class ArrendatarioHomeScreen extends StatelessWidget {
  final Usuario usuario;

  const ArrendatarioHomeScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Arrendatario'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bienvenida
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido, ${usuario.nombre}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rol: ${usuario.rol}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Email: ${usuario.email}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Acciones del arrendatario
            const Text(
              '¿Qué quieres hacer?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    icon: Icons.search,
                    title: 'Buscar Habitaciones',
                    color: Colors.blue,
                    onTap: () {
                      // Navegar a búsqueda
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.favorite,
                    title: 'Favoritos',
                    color: Colors.red,
                    onTap: () {
                      // Navegar a favoritos
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.history,
                    title: 'Mis Solicitudes',
                    color: Colors.orange,
                    onTap: () {
                      // Navegar a historial
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.person,
                    title: 'Mi Perfil',
                    color: Colors.purple,
                    onTap: () {
                      // Navegar a perfil
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}