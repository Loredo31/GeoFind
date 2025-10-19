const Reseña = require('../models/ReseñaModel');

class ReseñaService {
  async crearReseña(datosReseña) {
    try {
      const reseña = new Reseña(datosReseña);
      return await reseña.save();
    } catch (error) {
      throw new Error(`Error al crear reseña: ${error.message}`);
    }
  }

  async obtenerReseñasPorHabitacion(habitacionId) {
    try {
      return await Reseña.find({ habitacionId }).populate('usuarioId', 'nombre');
    } catch (error) {
      throw new Error(`Error al obtener reseñas: ${error.message}`);
    }
  }

  async obtenerTodasLasReseñas() {
    try {
      return await Reseña.find().populate('usuarioId', 'nombre').populate('habitacionId');
    } catch (error) {
      throw new Error(`Error al obtener reseñas: ${error.message}`);
    }
  }
}

module.exports = new ReseñaService();