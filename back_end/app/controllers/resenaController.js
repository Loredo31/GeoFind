const resenaService = require('../services/resenaService');

const resenaController = {
  // Crear nueva reseña
  crearResena: async (req, res) => {
    try {
      const datosResena = {
        ...req.body,
        usuarioId: req.usuario.id
      };
      const resena = await resenaService.crearResena(datosResena);
      res.status(201).json({
        success: true,
        message: 'Reseña creada exitosamente',
        data: resena
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener reseñas por propiedad
  obtenerResenasPropiedad: async (req, res) => {
    try {
      const { propiedadId } = req.params;
      const resenas = await resenaService.obtenerResenasPorPropiedad(propiedadId);
      res.status(200).json({
        success: true,
        data: resenas
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener reseñas del usuario
  obtenerMisResenas: async (req, res) => {
    try {
      const resenas = await resenaService.obtenerResenasPorUsuario(req.usuario.id);
      res.status(200).json({
        success: true,
        data: resenas
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener todas las reseñas
  obtenerTodasResenas: async (req, res) => {
    try {
      const filtros = req.query;
      const resenas = await resenaService.obtenerTodasResenas(filtros);
      res.status(200).json({
        success: true,
        data: resenas
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener promedio de propiedad
  obtenerPromedioPropiedad: async (req, res) => {
    try {
      const { propiedadId } = req.params;
      const promedio = await resenaService.obtenerPromedioPropiedad(propiedadId);
      res.status(200).json({
        success: true,
        data: promedio
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Actualizar reseña
  actualizarResena: async (req, res) => {
    try {
      const { resenaId } = req.params;
      const resena = await resenaService.actualizarResena(resenaId, req.usuario.id, req.body);
      res.status(200).json({
        success: true,
        message: 'Reseña actualizada exitosamente',
        data: resena
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Eliminar reseña
  eliminarResena: async (req, res) => {
    try {
      const { resenaId } = req.params;
      const resena = await resenaService.eliminarResena(resenaId, req.usuario.id);
      res.status(200).json({
        success: true,
        message: 'Reseña eliminada exitosamente',
        data: resena
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener reseñas recientes
  obtenerResenasRecientes: async (req, res) => {
    try {
      const { limite } = req.query;
      const resenas = await resenaService.obtenerResenasRecientes(limite);
      res.status(200).json({
        success: true,
        data: resenas
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
};

module.exports = resenaController;