const ReseñaService = require("../services/reseñaService");

class ReseñaController {
  async crearReseña(req, res) {
    try {
      // Obtener datos de la reseña
      const datosReseña = req.body;
      const reseña = await ReseñaService.crearReseña(datosReseña);

      res.status(201).json({
        success: true,
        message: "Reseña creada exitosamente",
        data: reseña,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // Controlador para obtener todas las reseñas de una habitación
  async obtenerReseñasHabitacion(req, res) {
    try {
      const { habitacionId } = req.params;
      const reseñas = await ReseñaService.obtenerReseñasPorHabitacion(
        habitacionId
      );

      res.json({
        success: true,
        data: reseñas,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // Controlador para obtener todas las reseñas
  async obtenerTodasLasReseñas(req, res) {
    try {
      const reseñas = await ReseñaService.obtenerTodasLasReseñas();

      res.json({
        success: true,
        data: reseñas,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // Controlador para obtener promedios de calificaciones
  async obtenerPromedioCalificaciones(req, res) {
    try {
      const { habitacionId } = req.params;
      const promedios = await ReseñaService.obtenerPromedioCalificaciones(
        habitacionId
      );

      res.json({
        success: true,
        data: promedios,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

   // Controlador para obtener evolución
  async obtenerEvolucionCalificaciones(req, res) {
    try {
      const { habitacionId } = req.params;
      const reseñas = await ReseñaService.obtenerReseñasPorHabitacion(
        habitacionId
      );

      // Ordenar por fecha 
      const evolucion = reseñas
        .sort((a, b) => new Date(a.fechaReseña) - new Date(b.fechaReseña))
        .map((reseña) => ({
          fecha: reseña.fechaReseña,
          calificacion: reseña.calificacionGeneral,
          usuario: reseña.nombre,
        }));

      res.json({
        success: true,
        data: evolucion,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // Controlador para obtener datos de gráfica de barras
  async obtenerDatosGraficaBarras(req, res) {
    try {
      const { habitacionId } = req.params;
      const datos = await ReseñaService.obtenerDatosGraficaBarras(habitacionId);

      res.json({
        success: true,
        data: datos,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // Controlador para obtener datos de gráfica de área
  async obtenerDatosGraficaArea(req, res) {
    try {
      const { habitacionId } = req.params;
      const datos = await ReseñaService.obtenerDatosGraficaArea(habitacionId);

      res.json({
        success: true,
        data: datos,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // Controlador para obtener datos de gráfica radar
  async obtenerDatosGraficaRadar(req, res) {
    try {
      const { habitacionId } = req.params;
      const datos = await ReseñaService.obtenerDatosGraficaRadar(habitacionId);

      res.json({
        success: true,
        data: datos,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // Controlador para obtener datos de gráfica de barras dobles
  async obtenerDatosGraficaBarrasDobles(req, res) {
    try {
      console.log('Solicitando datos para gráfica de barras dobles, habitacionId:', req.params.habitacionId);
      
      const { habitacionId } = req.params;
      const datos = await ReseñaService.obtenerDatosGraficaBarrasDobles(habitacionId);

      console.log('Datos obtenidos para barras dobles:', datos);
      
      res.json({
        success: true,
        data: datos,
      });
    } catch (error) {
      console.error('Error en obtenerDatosGraficaBarrasDobles:', error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }
}

module.exports = new ReseñaController();