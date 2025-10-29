import 'package:flutter/material.dart';
import 'package:front_end/services/informacion_service.dart';
import '../../models/usuario.dart';
import '../../services/cita_service.dart';
import '../../services/reserva_cuarto.dart';

class NotificationsWidget extends StatefulWidget {
  final Usuario usuario;

  const NotificationsWidget({Key? key, required this.usuario}) : super(key: key);

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  List<dynamic> _solicitudesCitas = [];
  List<dynamic> _solicitudesReservas = [];
  bool _isLoading = true;
  int _notificacionesPendientes = 0;

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    try {
      
      final habitacionesResponse = await InformacionService.obtenerInformacionArrendador(widget.usuario.id!);
      
      if (habitacionesResponse['success'] == true) {
        final List<dynamic> habitaciones = habitacionesResponse['data'] ?? [];
        List<dynamic> todasCitas = [];
        List<dynamic> todasReservas = [];

       
        for (var habitacion in habitaciones) {
          final String habitacionId = habitacion['_id'];
          
         
          final citasResponse = await CitaService.obtenerCitasArrendador(habitacionId);
          if (citasResponse['success'] == true) {
            todasCitas.addAll(citasResponse['data'] ?? []);
          }

         
          final reservasResponse = await ReservarCuartoService.obtenerReservasArrendador(habitacionId);
          if (reservasResponse['success'] == true) {
            todasReservas.addAll(reservasResponse['data'] ?? []);
          }
        }

        setState(() {
          
          _solicitudesCitas = todasCitas.where((cita) => cita['estado'] == null).toList();
          _solicitudesReservas = todasReservas.where((reserva) => reserva['estado'] == null).toList();
          _notificacionesPendientes = _solicitudesCitas.length + _solicitudesReservas.length;
          _isLoading = false;
        });

        print('✅ Notificaciones cargadas: ${_solicitudesCitas.length} citas, ${_solicitudesReservas.length} reservas');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      print('Error cargando notificaciones: $error');
    }
  }

  void _mostrarModalNotificaciones() {
    showDialog(
      context: context,
      builder: (context) => _buildNotificacionesModal(),
    );
  }

  Widget _buildNotificacionesModal() {
    return Dialog(
      backgroundColor: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[700],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Notificaciones',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.green[700]))
                  : _buildListaNotificaciones(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaNotificaciones() {
    final todasSolicitudes = [
      ..._solicitudesCitas.map((cita) => {'tipo': 'cita', 'data': cita}),
      ..._solicitudesReservas.map((reserva) => {'tipo': 'reserva', 'data': reserva}),
    ];

    if (todasSolicitudes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.green[300]),
            SizedBox(height: 16),
            Text(
              'No hay notificaciones pendientes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: todasSolicitudes.length,
      itemBuilder: (context, index) {
        final solicitud = todasSolicitudes[index];
        return _buildTarjetaSolicitud(solicitud);
      },
    );
  }

  Widget _buildTarjetaSolicitud(Map<String, dynamic> solicitud) {
    final bool esCita = solicitud['tipo'] == 'cita';
    final dynamic datos = solicitud['data'];

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Row(
              children: [
                Icon(
                  esCita ? Icons.calendar_today : Icons.home_work,
                  color: Colors.green[700],
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  esCita ? 'Solicitud de Cita' : 'Solicitud de Reserva',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pendiente',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

           
            Text(
              'Solicitante: ${datos['nombreSolicitante'] ?? datos['nombre']}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),

            if (esCita) ...[
              Text('Fecha: ${_formatearFecha(datos['fecha'])}'),
              SizedBox(height: 4),
              Text('Hora: ${datos['hora']}'),
            ] else ...[
              Text('Propiedad: ${datos['direccionHabitacion']}'),
              SizedBox(height: 4),
              Text('Duración: ${datos['duracion']} meses'),
            ],

            SizedBox(height: 16),

      
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _mostrarInfoSolicitud(solicitud),
                    icon: Icon(Icons.info, size: 16),
                    label: Text('Info'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      side: BorderSide(color: Colors.blue[700]!),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rechazarSolicitud(solicitud),
                    icon: Icon(Icons.close, size: 16),
                    label: Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[700]!),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _aceptarSolicitud(solicitud),
                    icon: Icon(Icons.check, size: 16),
                    label: Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarInfoSolicitud(Map<String, dynamic> solicitud) {
    final bool esCita = solicitud['tipo'] == 'cita';
    final dynamic datos = solicitud['data'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          esCita ? 'Información de Cita' : 'Información de Reserva',
          style: TextStyle(color: Colors.green[800]),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem('Solicitante', datos['nombreSolicitante'] ?? datos['nombre']),
              
              if (esCita) ...[
                _buildInfoItem('Fecha', _formatearFecha(datos['fecha'])),
                _buildInfoItem('Hora', datos['hora']),
                _buildInfoItem('Dirección', datos['direccionHabitacion'] ?? 'No especificada'),
              ] else ...[
                _buildInfoItem('Email', datos['email']),
                _buildInfoItem('Teléfono', datos['telefono']),
                _buildInfoItem('Edad', datos['edad'].toString()),
                _buildInfoItem('Dirección Actual', datos['direccionVivienda']),
                _buildInfoItem('CURP', datos['curp']),
                _buildInfoItem('Duración', '${datos['duracion']} meses'),
                _buildInfoItem('Costo Mensual', '\$${datos['costo']}'),
                _buildInfoItem('Dirección Propiedad', datos['direccionHabitacion']),
                _buildInfoItem('Tipo', datos['tipoHabitacion']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar', style: TextStyle(color: Colors.green[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'No especificado' : value),
          ),
        ],
      ),
    );
  }

  Future<void> _aceptarSolicitud(Map<String, dynamic> solicitud) async {
    final bool esCita = solicitud['tipo'] == 'cita';
    final String id = solicitud['data']['_id'];

    try {
      if (esCita) {
        await CitaService.actualizarEstadoCita(id, true);
      } else {
        await ReservarCuartoService.actualizarEstadoReserva(id, true);
      }

      _mostrarMensaje('Solicitud aceptada exitosamente');
      _cargarNotificaciones();
      Navigator.pop(context); 
    } catch (error) {
      _mostrarError('Error al aceptar la solicitud: $error');
    }
  }

  Future<void> _rechazarSolicitud(Map<String, dynamic> solicitud) async {
    final bool esCita = solicitud['tipo'] == 'cita';
    final String id = solicitud['data']['_id'];

   
    final motivoController = TextEditingController();

    bool confirmado = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rechazar Solicitud', style: TextStyle(color: Colors.green[800])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Estás seguro de que quieres rechazar esta solicitud?'),
            SizedBox(height: 12),
            TextField(
              controller: motivoController,
              decoration: InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.green[700])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Rechazar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirmado) {
      try {
        if (esCita) {
          await CitaService.actualizarEstadoCita(id, false);
        } else {
          await ReservarCuartoService.actualizarEstadoReserva(id, false);
        }

        _mostrarMensaje('Solicitud rechazada');
        _cargarNotificaciones();
        Navigator.pop(context); 
      } catch (error) {
        _mostrarError('Error al rechazar la solicitud: $error');
      }
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return fecha;
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green[700],
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

  @override
  Widget build(BuildContext context) {
    return Container(
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
        icon: Stack(
          children: [
            Icon(Icons.notifications, color: Colors.white, size: 20),
            if (_notificacionesPendientes > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    _notificacionesPendientes > 9 ? '9+' : _notificacionesPendientes.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        onPressed: _mostrarModalNotificaciones,
        tooltip: 'Notificaciones',
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}