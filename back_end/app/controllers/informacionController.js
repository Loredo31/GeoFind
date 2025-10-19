const informacionService = require('../services/informacionService');

const informacionController = {
  // Crear nueva propiedad
  crearPropiedad: async (req, res) => {
    try {
      const propiedad = await informacionService.crearPropiedad(req.body);
      res.status(201).json({
        success: true,
        message: 'Propiedad creada exitosamente',
        data: propiedad
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener todas las propiedades
  obtenerPropiedades: async (req, res) => {
    try {
      const filtros = req.query;
      const propiedades = await informacionService.obtenerTodasPropiedades(filtros);
      res.status(200).json({
        success: true,
        data: propiedades
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener propiedad por ID
  obtenerPropiedad: async (req, res) => {
    try {
      const { id } = req.params;
      const propiedad = await informacionService.obtenerPropiedadPorId(id);
      res.status(200).json({
        success: true,
        data: propiedad
      });
    } catch (error) {
      res.status(404).json({
        success: false,
        message: error.message
      });
    }
  },

  // Actualizar propiedad
  actualizarPropiedad: async (req, res) => {
    try {
      const { id } = req.params;
      const propiedad = await informacionService.actualizarPropiedad(id, req.body);
      res.status(200).json({
        success: true,
        message: 'Propiedad actualizada exitosamente',
        data: propiedad
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Eliminar propiedad
  eliminarPropiedad: async (req, res) => {
    try {
      const { id } = req.params;
      const propiedad = await informacionService.eliminarPropiedad(id);
      res.status(200).json({
        success: true,
        message: 'Propiedad eliminada exitosamente',
        data: propiedad
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Agregar foto
  agregarFoto: async (req, res) => {
    try {
      const { id } = req.params;
      const propiedad = await informacionService.agregarFoto(id, req.body);
      res.status(200).json({
        success: true,
        message: 'Foto agregada exitosamente',
        data: propiedad
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Eliminar foto
  eliminarFoto: async (req, res) => {
    try {
      const { id, fotoId } = req.params;
      const propiedad = await informacionService.eliminarFoto(id, fotoId);
      res.status(200).json({
        success: true,
        message: 'Foto eliminada exitosamente',
        data: propiedad
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Marcar foto como principal
  marcarFotoPrincipal: async (req, res) => {
    try {
      const { id, fotoId } = req.params;
      const propiedad = await informacionService.marcarFotoPrincipal(id, fotoId);
      res.status(200).json({
        success: true,
        message: 'Foto marcada como principal',
        data: propiedad
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Buscar por ubicación
  buscarPorUbicacion: async (req, res) => {
    try {
      const { ciudad, estado } = req.query;
      const propiedades = await informacionService.buscarPorUbicacion(ciudad, estado);
      res.status(200).json({
        success: true,
        data: propiedades
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Actualizar disponibilidad
  actualizarDisponibilidad: async (req, res) => {
    try {
      const { id } = req.params;
      const { estaDisponible } = req.body;
      const propiedad = await informacionService.actualizarDisponibilidad(id, estaDisponible);
      res.status(200).json({
        success: true,
        message: `Propiedad ${estaDisponible ? 'disponible' : 'no disponible'}`,
        data: propiedad
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
};

module.exports = informacionController;