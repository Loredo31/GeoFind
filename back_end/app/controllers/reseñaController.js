// const ReseñaService = require('../services/reseñaService');

// class ReseñaController {
//   async crearReseña(req, res) {
//     try {
//       const datosReseña = req.body;
//       const reseña = await ReseñaService.crearReseña(datosReseña);
      
//       res.status(201).json({
//         success: true,
//         message: 'Reseña creada exitosamente',
//         data: reseña
//       });
//     } catch (error) {
//       res.status(500).json({
//         success: false,
//         message: error.message
//       });
//     }
//   }

//   async obtenerReseñasHabitacion(req, res) {
//     try {
//       const { habitacionId } = req.params;
//       const reseñas = await ReseñaService.obtenerReseñasPorHabitacion(habitacionId);
      
//       res.json({
//         success: true,
//         data: reseñas
//       });
//     } catch (error) {
//       res.status(500).json({
//         success: false,
//         message: error.message
//       });
//     }
//   }

//   async obtenerTodasLasReseñas(req, res) {
//     try {
//       const reseñas = await ReseñaService.obtenerTodasLasReseñas();
      
//       res.json({
//         success: true,
//         data: reseñas
//       });
//     } catch (error) {
//       res.status(500).json({
//         success: false,
//         message: error.message
//       });
//     }
//   }
// }

// module.exports = new ReseñaController();





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

  // NUEVOS ENDPOINTS PARA GRÁFICAS
  async obtenerDatosGraficaDispersion(req, res) {
    try {
      const { habitacionId } = req.params;
      const datos = await ReseñaService.obtenerDatosGraficaDispersion(habitacionId);
      
      res.json({
        success: true,
        data: datos
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerPromedioCalificaciones(req, res) {
    try {
      const { habitacionId } = req.params;
      const promedios = await ReseñaService.obtenerPromedioCalificaciones(habitacionId);
      
      res.json({
        success: true,
        data: promedios
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerEvolucionCalificaciones(req, res) {
    try {
      const { habitacionId } = req.params;
      const reseñas = await ReseñaService.obtenerReseñasPorHabitacion(habitacionId);
      
      // Ordenar por fecha y extraer evolución
      const evolucion = reseñas
        .sort((a, b) => new Date(a.fechaReseña) - new Date(b.fechaReseña))
        .map(reseña => ({
          fecha: reseña.fechaReseña,
          calificacion: reseña.calificacionGeneral,
          usuario: reseña.nombre
        }));
      
      res.json({
        success: true,
        data: evolucion
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