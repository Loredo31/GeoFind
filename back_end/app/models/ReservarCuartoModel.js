const mongoose = require('mongoose');

const reservarCuartoSchema = new mongoose.Schema({
  // Datos del solicitante
  nombre: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true
  },
  telefono: {
    type: String,
    required: true
  },
  edad: {
    type: Number,
    required: true
  },
  direccionVivienda: {
    type: String,
    required: true
  },
  curp: {
    type: String,
    required: true
  },
  
  // Datos de la habitación
  direccionHabitacion: String,
  tipoHabitacion: String,
  duracion: Number,
  costo: Number,
  nombreArrendador: String,
  datosBancarios: Object,
  
  // Información de la reserva
  numeroContrato: {
    type: String,
    unique: true,
    required: true
  },
  estado: {
    type: Boolean,
    default: false // false = rechazado, true = aceptado
  },
  habitacionId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Informacion',
    required: true
  },
  arrendatarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true
  },
  fechaSolicitud: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('ReservarCuarto', reservarCuartoSchema);