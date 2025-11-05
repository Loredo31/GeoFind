const Informacion = require('../models/InformacionModel');

class InformacionService {
  async crearInformacion(datos) {
    try {
      // ✅ EXTRAER PRIMERA FOTO para fotoPortada
      if (datos.fotografias && datos.fotografias.length > 0) {
        datos.fotoPortada = datos.fotografias[0];
      }
      
      const informacion = new Informacion(datos);
      return await informacion.save();
    } catch (error) {
      throw new Error(`Error al crear información: ${error.message}`);
    }
  }

  // ✅ LOS DEMÁS MÉTODOS SE MANTIENEN IGUAL
  async obtenerInformacionPorArrendador(arrendadorId) {
    try {
      return await Informacion.find({ arrendadorId });
    } catch (error) {
      throw new Error(`Error al obtener información: ${error.message}`);
    }
  }

  async obtenerTodasLasHabitaciones() {
    try {
      return await Informacion.find();
    } catch (error) {
      throw new Error(`Error al obtener habitaciones: ${error.message}`);
    }
  }

  async actualizarInformacion(id, datos) {
    try {
      // ✅ ACTUALIZAR fotoPortada si hay nuevas fotografías
      if (datos.fotografias && datos.fotografias.length > 0) {
        datos.fotoPortada = datos.fotografias[0];
      }
      
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