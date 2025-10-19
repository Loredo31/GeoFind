const reservaCuartoService = require('../services/reservaCuartoService');

const reservaCuartoController = {
  // Crear nueva reserva
  crearReserva: async (req, res) => {
    try {
      const datosReserva = {
        ...req.body,
        usuarioId: req.usuario.id
      };
      const reserva = await reservaCuartoService.crearReserva(datosReserva);
      res.status(201).json({
        success: true,
        message: 'Solicitud de reserva creada exitosamente',
        data: reserva
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener reservas del usuario
  obtenerMisReservas: async (req, res) => {
    try {
      const reservas = await reservaCuartoService.obtenerReservasPorUsuario(req.usuario.id);
      res.status(200).json({
        success: true,
        data: reservas
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener reserva específica
  obtenerReserva: async (req, res) => {
    try {
      const { id } = req.params;
      const reserva = await reservaCuartoService.obtenerReservaPorId(id);
      res.status(200).json({
        success: true,
        data: reserva
      });
    } catch (error) {
      res.status(404).json({
        success: false,
        message: error.message
      });
    }
  },

  // Procesar decisión aleatoria para UNA reserva
  procesarDecisionAleatoria: async (req, res) => {
    try {
      const { reservaId } = req.params;
      const resultado = await reservaCuartoService.procesarDecisionAleatoria(reservaId);
      res.status(200).json({
        success: true,
        message: `Reserva ${resultado.decision}`,
        data: resultado
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Procesar TODAS las reservas pendientes automáticamente
  procesarTodasReservasPendientes: async (req, res) => {
    try {
      const resultados = await reservaCuartoService.procesarTodasReservasPendientes();
      res.status(200).json({
        success: true,
        message: 'Procesamiento de reservas pendientes completado',
        data: resultados
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Cancelar reserva
  cancelarReserva: async (req, res) => {
    try {
      const { reservaId } = req.params;
      const reserva = await reservaCuartoService.cancelarReserva(reservaId, req.usuario.id);
      res.status(200).json({
        success: true,
        message: 'Reserva cancelada exitosamente',
        data: reserva
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
  // NOTA: Se eliminó el método regenerarContrato completamente
};

module.exports = reservaCuartoController;