const AgendarCita = require('../models/AgendarCitaModel');

class AgendarCitaService {
  async crearCita(datosCita) {
    try {
      const cita = new AgendarCita(datosCita);
      return await cita.save();
    } catch (error) {
      throw new Error(`Error al crear cita: ${error.message}`);
    }
  }

  async obtenerCitasPorArrendador(habitacionId) {
    try {
      return await AgendarCita.find({ habitacionId }).populate('arrendatarioId', 'nombre email');
    } catch (error) {
      throw new Error(`Error al obtener citas: ${error.message}`);
    }
  }

  async obtenerCitasPorArrendatario(arrendatarioId) {
    try {
      return await AgendarCita.find({ arrendatarioId }).populate('habitacionId');
    } catch (error) {
      throw new Error(`Error al obtener citas: ${error.message}`);
    }
  }

  async actualizarEstadoCita(id, estado) {
    try {
      return await AgendarCita.findByIdAndUpdate(
        id, 
        { estado }, 
        { new: true }
      );
    } catch (error) {
      throw new Error(`Error al actualizar cita: ${error.message}`);
    }
  }
}

module.exports = new AgendarCitaService();