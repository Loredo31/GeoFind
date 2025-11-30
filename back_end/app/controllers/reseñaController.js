const ProxyService = require("../services/proxyService"); 
// ProxyService YA es una instancia → úsalo así
const proxy = ProxyService;

class ReseñaController {
  async crearReseña(req, res) {
    try {
      const datosReseña = req.body;
      const reseña = await proxy.crearReseña(datosReseña);

      // Cuando se crea una reseña, limpiar cache de esa habitación
      proxy.limpiarCacheHabitacion(datosReseña.habitacionId);

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

  async obtenerReseñasHabitacion(req, res) {
    try {
      const { habitacionId } = req.params;
      const data = await proxy.obtenerReseñasPorHabitacion(habitacionId);

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async obtenerTodasLasReseñas(req, res) {
    try {
      const data = await proxy.obtenerReseñasPorHabitacion(null); // si tienes un método para todas ajusta aquí

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async obtenerPromedioCalificaciones(req, res) {
    try {
      const { habitacionId } = req.params;
      const data = await proxy.obtenerPromedioCalificaciones(habitacionId);

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async obtenerEvolucionCalificaciones(req, res) {
    try {
      const { habitacionId } = req.params;
      const data = await proxy.obtenerEvolucionCalificaciones(habitacionId);

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async obtenerDatosGraficaBarras(req, res) {
    try {
      const { habitacionId } = req.params;
      const data = await proxy.obtenerDatosGraficaBarras(habitacionId);

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async obtenerDatosGraficaArea(req, res) {
    try {
      const { habitacionId } = req.params;
      const data = await proxy.obtenerDatosGraficaArea(habitacionId);

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async obtenerDatosGraficaRadar(req, res) {
    try {
      const { habitacionId } = req.params;
      const data = await proxy.obtenerDatosGraficaRadar(habitacionId);

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  async obtenerDatosGraficaBarrasDobles(req, res) {
    try {
      console.log("📊 Solicitando barras dobles:", req.params.habitacionId);

      const { habitacionId } = req.params;
      const data = await proxy.obtenerDatosGraficaBarrasDobles(habitacionId);

      console.log("📈 Datos barras dobles:", data);

      res.json({
        success: true,
        data,
      });
    } catch (error) {
      console.error("❌ Error barras dobles:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }
}

module.exports = new ReseñaController();
