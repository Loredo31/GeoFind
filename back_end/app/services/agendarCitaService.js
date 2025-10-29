const AgendarCita = require('../models/AgendarCitaModel');
const UsuarioModel = require('../models/UsuarioModel');
const InformacionModel = require('../models/InformacionModel');

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
      return await AgendarCita.find({ habitacionId });
    } catch (error) {
      throw new Error(`Error al obtener citas: ${error.message}`);
    }
  }

  async obtenerCitasPorArrendatario(arrendatarioId) {
    try {
      return await AgendarCita.find({ arrendatarioId });
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

  // obtiene citas
  async obtenerCitaCompletaPorId(id) {
    try {
      const cita = await AgendarCita.findById(id)
        .populate({
          path: 'arrendatarioId',
          model: 'UsuarioModel', 
          select: 'email nombre'
        })
        .populate({
          path: 'habitacionId',
          model: 'InformacionModel', 
          select: 'direccion zona'
        });
      
      if (!cita) {
        throw new Error('Cita no encontrada');
      }
      
      return cita;
    } catch (error) {
      throw new Error(`Error al obtener cita completa: ${error.message}`);
    }
  }

  async obtenerCitaConDatosAdicionales(id) {
    try {
      const cita = await AgendarCita.findById(id);
      
      if (!cita) {
        throw new Error('Cita no encontrada');
      }

      // obtener datos del arrendatario
      const arrendatario = await UsuarioModel.findById(cita.arrendatarioId);
      // obtener datos de la habitación
      const habitacion = await InformacionModel.findById(cita.habitacionId);

      // Combinar  datos
      return {
        ...cita.toObject(),
        arrendatarioData: arrendatario,
        habitacionData: habitacion
      };
    } catch (error) {
      throw new Error(`Error al obtener cita con datos adicionales: ${error.message}`);
    }
  }
}

module.exports = new AgendarCitaService();