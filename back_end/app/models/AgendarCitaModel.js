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
    default: null // null = pendiente, false = rechazado, true = aceptado
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

module.exports = mongoose.model('AgendarCita', agendarCitaSchema);