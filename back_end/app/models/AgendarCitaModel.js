const mongoose = require('mongoose');

const agendarCitaSchema = new mongoose.Schema({
  fecha: {
    type: Date,
    required: true
  },
  hora: {
    type: String,
    required: true
  },
  nombreSolicitante: {
    type: String,
    required: true
  },
  estado: {
    type: Boolean,
    default: null
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
  },
  direccionHabitacion: String,
});

module.exports = mongoose.model('AgendarCita', agendarCitaSchema);