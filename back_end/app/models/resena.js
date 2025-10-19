const mongoose = require('mongoose');

const resenaSchema = new mongoose.Schema({
  usuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El usuario es requerido']
  },
  propiedad: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Informacion',
    required: [true, 'La propiedad es requerida']
  },
  // Datos básicos de la reseña
  nombre: {
    type: String,
    required: [true, 'El nombre es requerido'],
    trim: true
  },
  comentario: {
    type: String,
    required: [true, 'El comentario es requerido'],
    trim: true,
    maxlength: [1000, 'El comentario no puede exceder 1000 caracteres']
  },
  tiempoEstancia: {
    type: String,
    required: [true, 'El tiempo de estancia es requerido'],
    trim: true
  },
  calificacion: {
    type: Number,
    required: [true, 'La calificación es requerida'],
    min: [0, 'La calificación mínima es 0'],
    max: [5, 'La calificación máxima es 5']
  },
  // Fechas de la estancia
  fechaInicio: {
    type: Date,
    required: [true, 'La fecha de inicio es requerida']
  },
  fechaFin: {
    type: Date,
    required: [true, 'La fecha de fin es requerida']
  },
  // Estado de la reseña
  estaActiva: {
    type: Boolean,
    default: true
  },
  fechaCreacion: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Índice para evitar reseñas duplicadas
resenaSchema.index({ usuario: 1, propiedad: 1 }, { unique: true });

// Método para calcular estrellas (para mostrar en frontend)
resenaSchema.methods.obtenerEstrellas = function() {
  return '★'.repeat(this.calificacion) + '☆'.repeat(5 - this.calificacion);
};

// Calcular promedio de calificaciones para una propiedad
resenaSchema.statics.obtenerPromedioCalificacion = async function(propiedadId) {
  const resultado = await this.aggregate([
    {
      $match: {
        propiedad: mongoose.Types.ObjectId(propiedadId),
        estaActiva: true
      }
    },
    {
      $group: {
        _id: '$propiedad',
        promedioCalificacion: { $avg: '$calificacion' },
        totalResenas: { $sum: 1 }
      }
    }
  ]);

  return resultado.length > 0 ? resultado[0] : { promedioCalificacion: 0, totalResenas: 0 };
};

module.exports = mongoose.model('Resena', resenaSchema);