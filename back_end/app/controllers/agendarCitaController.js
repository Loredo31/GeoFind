const agendarCitaService = require('../services/agendarCitaService');

const agendarCitaController = {
  // Verificar disponibilidad
  verificarDisponibilidad: async (req, res) => {
    try {
      const { propiedadId, fechaCita } = req.body;
      const resultado = await agendarCitaService.verificarDisponibilidad(propiedadId, fechaCita);
      res.status(200).json({
        success: true,
        data: resultado
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Agendar nueva cita
  agendarCita: async (req, res) => {
    try {
      const datosCita = {
        ...req.body,
        usuarioId: req.usuario.id
      };
      const cita = await agendarCitaService.agendarCita(datosCita);
      res.status(201).json({
        success: true,
        message: 'Cita agendada exitosamente',
        data: cita
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener citas del usuario
  obtenerMisCitas: async (req, res) => {
    try {
      const citas = await agendarCitaService.obtenerCitasPorUsuario(req.usuario.id);
      res.status(200).json({
        success: true,
        data: citas
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Procesar decisión aleatoria para UNA cita
  procesarDecisionAleatoria: async (req, res) => {
    try {
      const { citaId } = req.params;
      const resultado = await agendarCitaService.procesarDecisionAleatoria(citaId);
      res.status(200).json({
        success: true,
        message: `Cita ${resultado.decision}`,
        data: resultado
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Procesar TODAS las citas pendientes automáticamente
  procesarTodasCitasPendientes: async (req, res) => {
    try {
      const resultados = await agendarCitaService.procesarTodasCitasPendientes();
      res.status(200).json({
        success: true,
        message: 'Procesamiento de citas pendientes completado',
        data: resultados
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Cancelar cita
  cancelarCita: async (req, res) => {
    try {
      const { citaId } = req.params;
      const cita = await agendarCitaService.cancelarCita(citaId, req.usuario.id);
      res.status(200).json({
        success: true,
        message: 'Cita cancelada exitosamente',
        data: cita
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener fechas disponibles
  obtenerFechasDisponibles: async (req, res) => {
    try {
      const { propiedadId } = req.params;
      const { fechaInicio, fechaFin } = req.query;
      const resultado = await agendarCitaService.obtenerFechasDisponibles(propiedadId, fechaInicio, fechaFin);
      res.status(200).json({
        success: true,
        data: resultado
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
};

module.exports = agendarCitaController;