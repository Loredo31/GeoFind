const Informacion = require('../models/InformacionModel');

class InformacionService {
  async crearInformacion(datos) {
    try {
      const informacion = new Informacion(datos);
      return await informacion.save();
    } catch (error) {
      throw new Error(`Error al crear información: ${error.message}`);
    }
  }

  async obtenerInformacionPorArrendador(arrendadorId) {
    try {
      return await Informacion.find({ arrendadorId });
    } catch (error) {
      throw new Error(`Error al obtener información: ${error.message}`);
    }
  }

  async obtenerTodasLasHabitaciones() {
    try {
      return await Informacion.find().populate('arrendadorId', 'nombre email');
    } catch (error) {
      throw new Error(`Error al obtener habitaciones: ${error.message}`);
    }
  }

  async actualizarInformacion(id, datos) {
    try {
      return await Informacion.findByIdAndUpdate(id, datos, { new: true });
    } catch (error) {
      throw new Error(`Error al actualizar información: ${error.message}`);
    }
  }

  async eliminarInformacion(id) {
    try {
      return await Informacion.findByIdAndDelete(id);
    } catch (error) {
      throw new Error(`Error al eliminar información: ${error.message}`);
    }
  }
}

module.exports = new InformacionService();