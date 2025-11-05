const mongoose = require('mongoose');

const informacionSchema = new mongoose.Schema({
  nombreArrendador: {
    type: String,
    required: true
  },
  tipo: {
    type: String,
    enum: ['individual', 'compartido'],
    required: true
  },
  capacidad: {
    type: Number,
    required: function() {
      return this.tipo === 'compartido';
    }
  },
  zona: {
    type: String,
    enum: ['centro', 'sur', 'norte'],
    required: true
  },
  clausulas: {
    type: String,
    default: null
  },
  duracionRutas: {
    type: Number,
    min: 6,
    max: 12,
    required: true
  },
  direccion: {
    type: String,
    required: true
  },
  googleMaps: String,
  fotografias: [String],
  fotoPortada: String,
  costo: {
    type: Number,
    required: true
  },
  servicios: [String],
  datosBancarios: {
    bank_name: String,
    account_number: String,
    account_holder: String,
    clabe: String
  },
  arrendadorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true
  }
});

module.exports = mongoose.model('Informacion', informacionSchema);