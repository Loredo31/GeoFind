const ReseñaService = require('../services/reseñaService');

class ReseñaController {
  async crearReseña(req, res) {
    try {
      const datosReseña = req.body;
      const reseña = await ReseñaService.crearReseña(datosReseña);
      
      res.status(201).json({
        success: true,
        message: 'Reseña creada exitosamente',
        data: reseña
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerReseñasHabitacion(req, res) {
    try {
      const { habitacionId } = req.params;
      const reseñas = await ReseñaService.obtenerReseñasPorHabitacion(habitacionId);
      
      res.json({
        success: true,
        data: reseñas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerTodasLasReseñas(req, res) {
    try {
      const reseñas = await ReseñaService.obtenerTodasLasReseñas();
      
      res.json({
        success: true,
        data: reseñas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new ReseñaController();