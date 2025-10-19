const AgendarCitaService = require('../services/agendarCitaService');

class AgendarCitaController {
  async crearCita(req, res) {
    try {
      const datosCita = req.body;
      const cita = await AgendarCitaService.crearCita(datosCita);
      
      res.status(201).json({
        success: true,
        message: 'Cita agendada exitosamente',
        data: cita
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerCitasArrendador(req, res) {
    try {
      const { habitacionId } = req.params;
      const citas = await AgendarCitaService.obtenerCitasPorArrendador(habitacionId);
      
      res.json({
        success: true,
        data: citas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerCitasArrendatario(req, res) {
    try {
      const { arrendatarioId } = req.params;
      const citas = await AgendarCitaService.obtenerCitasPorArrendatario(arrendatarioId);
      
      res.json({
        success: true,
        data: citas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async actualizarEstadoCita(req, res) {
    try {
      const { id } = req.params;
      const { estado } = req.body;
      const cita = await AgendarCitaService.actualizarEstadoCita(id, estado);
      
      res.json({
        success: true,
        message: 'Estado de cita actualizado',
        data: cita
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new AgendarCitaController();