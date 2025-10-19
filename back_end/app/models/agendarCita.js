const mongoose = require('mongoose');

const citaSchema = new mongoose.Schema({
  usuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El usuario es requerido']
  },
  propiedad: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Property',
    required: [true, 'La propiedad es requerida']
  },
  fechaCita: {
    type: Date,
    required: [true, 'La fecha de la cita es requerida'],
    validate: {
      validator: function(fecha) {
        return fecha > new Date();
      },
      message: 'La fecha de la cita debe ser futura'
    }
  },
  estado: {
    type: String,
    enum: ['pendiente', 'aceptada', 'rechazada', 'cancelada'],
    default: 'pendiente'
  },
  disponible: {
    type: Boolean,
    default: true
  },
  fechaCreacion: {
    type: Date,
    default: Date.now
  },
  motivoRechazo: {
    type: String,
    trim: true
  }
}, {
  timestamps: true
});

// Índice para evitar citas duplicadas en la misma fecha y propiedad
citaSchema.index({ propiedad: 1, fechaCita: 1 }, { unique: true });

// Método para verificar disponibilidad
citaSchema.statics.verificarDisponibilidad = async function(propiedadId, fechaCita) {
  const citaExistente = await this.findOne({
    propiedad: propiedadId,
    fechaCita: fechaCita,
    disponible: false,
    estado: { $in: ['pendiente', 'aceptada'] }
  });
  return !citaExistente;
};

// Método para cambiar estado y disponibilidad
citaSchema.methods.cambiarEstado = function(nuevoEstado, motivo = '') {
  this.estado = nuevoEstado;
  this.motivoRechazo = motivo;
  
  // Actualizar disponibilidad según el estado
  if (nuevoEstado === 'aceptada') {
    this.disponible = false;
  } else if (nuevoEstado === 'rechazada' || nuevoEstado === 'cancelada') {
    this.disponible = true;
  }
  
  return this.save();
};

module.exports = mongoose.model('agendarCita', citaSchema);