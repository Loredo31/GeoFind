const Informacion = require('../models/InformacionModel');

const proxyService = {

  getFotoPortada: async (habitacionId) => {
    try {
      const habitacion = await Informacion.findById(habitacionId);
      //busca la habitación por ID
      
      if (!habitacion || !habitacion.fotoPortada) {
        throw new Error('No hay foto de portada para esta habitación');
        //se valida que exista la habitacion y tenga imagen
      }

      return Buffer.from(habitacion.fotoPortada, 'base64');
      //convierte el base64 almacenado en Buffer para enviar como imagen
    } catch (error) {
      throw new Error('Error al obtener foto de portada: ' + error.message);
    }
  }
};

module.exports = proxyService;