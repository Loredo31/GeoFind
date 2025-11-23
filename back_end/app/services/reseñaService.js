const Reseña = require("../models/ReseñaModel");
const ProxyService = require("./proxyService");

class ReseñaService {
  async crearReseña(datosReseña) {
    try {
      // Procesar análisis de sentimiento
      const analisis = await this.analizarSentimiento(datosReseña.comentario);
      datosReseña.analisisSentimiento = analisis;

      const reseña = new Reseña(datosReseña);
      const resultado = await reseña.save();

      // Limpiar cache después de crear nueva reseña
      ProxyService.limpiarCacheHabitacion(datosReseña.habitacionId);

      return resultado;
    } catch (error) {
      throw new Error(`Error al crear reseña: ${error.message}`);
    }
  }

  // Método para obtener todas las reseñas de una habitación
  async obtenerReseñasPorHabitacion(habitacionId) {
    try {
      return await ProxyService.obtenerReseñasHabitacion(habitacionId);
    } catch (error) {
      throw new Error(`Error al obtener reseñas: ${error.message}`);
    }
  }

  // Método para obtener todas las reseñas
  async obtenerTodasLasReseñas() {
    try {
      return await Reseña.find();
    } catch (error) {
      throw new Error(`Error al obtener reseñas: ${error.message}`);
    }
  }

  // Método para obtener datos de gráfica de barras dobles
  async obtenerDatosGraficaBarrasDobles(habitacionId) {
    try {
      return await ProxyService.obtenerDatosGraficaBarrasDobles(habitacionId);
    } catch (error) {
      throw new Error(
        `Error al obtener datos de barras dobles: ${error.message}`
      );
    }
  }

  // Método para obtener promedios de calificaciones de una habitación
  async obtenerPromedioCalificaciones(habitacionId) {
    try {
      return await ProxyService.obtenerPromediosHabitacion(habitacionId);
    } catch (error) {
      throw new Error(`Error al obtener promedios: ${error.message}`);
    }
  }

  // Método para obtener la evolución (Gráfica de líneas)
  async obtenerEvolucionCalificaciones(habitacionId) {
    try {
      return await ProxyService.obtenerEvolucionCalificaciones(habitacionId);
    } catch (error) {
      throw new Error(`Error al obtener evolución: ${error.message}`);
    }
  }

  // Método para obtener datos de gráfica de barras
  async obtenerDatosGraficaBarras(habitacionId) {
    try {
      return await ProxyService.obtenerDatosGraficaBarras(habitacionId);
    } catch (error) {
      throw new Error(`Error al obtener datos de barras: ${error.message}`);
    }
  }

  // Método para obtener datos de gráfica de área
  async obtenerDatosGraficaArea(habitacionId) {
    try {
      return await ProxyService.obtenerDatosGraficaArea(habitacionId);
    } catch (error) {
      throw new Error(`Error al obtener datos de área: ${error.message}`);
    }
  }

  // Método para obtener datos de gráfica radar
  async obtenerDatosGraficaRadar(habitacionId) {
    try {
      return await ProxyService.obtenerDatosGraficaRadar(habitacionId);
    } catch (error) {
      throw new Error(`Error al obtener datos de radar: ${error.message}`);
    }
  }
}

module.exports = new ReseñaService();
