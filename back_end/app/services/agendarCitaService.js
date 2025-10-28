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

  // NUEVO MÉTODO: Obtener cita completa con datos poblados (CORREGIDO)
  async obtenerCitaCompletaPorId(id) {
    try {
      const cita = await AgendarCita.findById(id)
        .populate({
          path: 'arrendatarioId',
          model: 'UsuarioModel', // Especifica el nombre del modelo exacto
          select: 'email nombre'
        })
        .populate({
          path: 'habitacionId',
          model: 'InformacionModel', // Especifica el nombre del modelo exacto
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

  // Método alternativo si el populate no funciona
  async obtenerCitaConDatosAdicionales(id) {
    try {
      const cita = await AgendarCita.findById(id);
      
      if (!cita) {
        throw new Error('Cita no encontrada');
      }

      // Obtener datos del arrendatario
      const arrendatario = await UsuarioModel.findById(cita.arrendatarioId);
      // Obtener datos de la habitación
      const habitacion = await InformacionModel.findById(cita.habitacionId);

      // Combinar los datos
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