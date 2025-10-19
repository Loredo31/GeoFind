const ReservarCuarto = require('../models/ReservarCuartoModel');
const GenerarContratoService = require('./generarContratoService');

class ReservarCuartoService {
  async crearReserva(datosReserva) {
    try {
      // Generar número de contrato único
      datosReserva.numeroContrato = GenerarContratoService.generarNumeroContrato();
      
      const reserva = new ReservarCuarto(datosReserva);
      return await reserva.save();
    } catch (error) {
      throw new Error(`Error al crear reserva: ${error.message}`);
    }
  }

  async obtenerReservasPorArrendador(habitacionId) {
    try {
      return await ReservarCuarto.find({ habitacionId });
    } catch (error) {
      throw new Error(`Error al obtener reservas: ${error.message}`);
    }
  }

  async obtenerReservasPorArrendatario(arrendatarioId) {
    try {
      return await ReservarCuarto.find({ arrendatarioId }).populate('habitacionId');
    } catch (error) {
      throw new Error(`Error al obtener reservas: ${error.message}`);
    }
  }

  async actualizarEstadoReserva(id, estado) {
    try {
      return await ReservarCuarto.findByIdAndUpdate(
        id, 
        { estado }, 
        { new: true }
      );
    } catch (error) {
      throw new Error(`Error al actualizar reserva: ${error.message}`);
    }
  }
}

module.exports = new ReservarCuartoService();