const ReservarCuartoService = require('../services/reservarCuartoService');

class ReservarCuartoController {
  async crearReserva(req, res) {
    try {
      const datosReserva = req.body;
      const reserva = await ReservarCuartoService.crearReserva(datosReserva);
      
      res.status(201).json({
        success: true,
        message: 'Reserva creada exitosamente',
        data: reserva
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerReservasArrendador(req, res) {
    try {
      const { habitacionId } = req.params;
      const reservas = await ReservarCuartoService.obtenerReservasPorArrendador(habitacionId);
      
      res.json({
        success: true,
        data: reservas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerReservasArrendatario(req, res) {
    try {
      const { arrendatarioId } = req.params;
      const reservas = await ReservarCuartoService.obtenerReservasPorArrendatario(arrendatarioId);
      
      res.json({
        success: true,
        data: reservas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async actualizarEstadoReserva(req, res) {
    try {
      const { id } = req.params;
      const { estado } = req.body;
      const reserva = await ReservarCuartoService.actualizarEstadoReserva(id, estado);
      
      res.json({
        success: true,
        message: 'Estado de reserva actualizado',
        data: reserva
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new ReservarCuartoController();