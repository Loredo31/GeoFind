const mongoose = require('mongoose');

const reseñaSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true
  },
  duracionRenta: {
    type: Number,
    required: true
  },
  comentario: {
    type: String,
    required: true
  },
  habitacionId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Informacion',
    required: true
  },
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true
  },
  fechaReseña: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Reseña', reseñaSchema);