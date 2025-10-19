const mongoose = require('mongoose');

const referenciaSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: [true, 'El nombre de la referencia es requerido'],
    trim: true
  },
  telefono: {
    type: String,
    required: [true, 'El teléfono de la referencia es requerido'],
    trim: true
  },
  parentesco: {
    type: String,
    required: [true, 'El parentesco es requerido'],
    trim: true
  },
  añosConociendo: {
    type: Number,
    required: [true, 'Los años conociendo son requeridos'],
    min: 1
  }
});

const reservaSchema = new mongoose.Schema({
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
  // Datos personales del usuario
  datosPersonales: {
    nombreCompleto: {
      type: String,
      required: [true, 'El nombre completo es requerido'],
      trim: true
    },
    edad: {
      type: Number,
      required: [true, 'La edad es requerida'],
      min: [18, 'Debe ser mayor de 18 años']
    },
    telefono: {
      type: String,
      required: [true, 'El teléfono es requerido'],
      trim: true
    },
    email: {
      type: String,
      required: [true, 'El email es requerido'],
      trim: true,
      lowercase: true
    },
    direccion: {
      calle: {
        type: String,
        required: true,
        trim: true
      },
      numeroExterior: {
        type: String,
        required: true,
        trim: true
      },
      numeroInterior: {
        type: String,
        trim: true
      },
      colonia: {
        type: String,
        required: true,
        trim: true
      },
      ciudad: {
        type: String,
        required: true,
        trim: true
      },
      estado: {
        type: String,
        required: true,
        trim: true
      },
      codigoPostal: {
        type: String,
        required: true,
        trim: true
      }
    },
    curp: {
      type: String,
      required: [true, 'La CURP es requerida'],
      trim: true,
      uppercase: true,
      match: [/^[A-Z]{4}[0-9]{6}[A-Z]{6}[0-9A-Z]{2}$/, 'CURP inválida']
    },
    ocupacion: {
      type: String,
      required: [true, 'La ocupación es requerida'],
      trim: true
    },
    lugarTrabajo: {
      type: String,
      trim: true
    },
    ingresoMensual: {
      type: Number,
      min: 0
    }
  },
  // Referencias personales (múltiples)
  referencias: [referenciaSchema],
  // Estado de la reserva
  estado: {
    type: String,
    enum: ['pendiente', 'aceptada', 'rechazada', 'cancelada'],
    default: 'pendiente'
  },
  // Fechas importantes
  fechaInicioReserva: {
    type: Date,
    required: [true, 'La fecha de inicio es requerida']
  },
  fechaFinReserva: {
    type: Date,
    required: [true, 'La fecha de fin es requerida']
  },
  duracionMeses: {
    type: Number,
    min: 1
  },
  // Información de pago
  rentaMensual: {
    type: Number,
    required: true
  },
  depositoGarantia: {
    type: Number,
    required: true
  },
  // Metadata
  fechaSolicitud: {
    type: Date,
    default: Date.now
  },
  fechaDecision: {
    type: Date
  },
  motivoRechazo: {
    type: String,
    trim: true
  }
}, {
  timestamps: true
});

// Middleware para calcular duración y montos
reservaSchema.pre('save', function(next) {
  if (this.fechaInicioReserva && this.fechaFinReserva) {
    const diffTime = Math.abs(this.fechaFinReserva - this.fechaInicioReserva);
    const diffMonths = Math.ceil(diffTime / (1000 * 60 * 60 * 24 * 30));
    this.duracionMeses = diffMonths;
  }
  next();
});

// Método para cambiar estado (SIMPLIFICADO - sin contrato)
reservaSchema.methods.cambiarEstado = function(nuevoEstado, motivo = '') {
  this.estado = nuevoEstado;
  this.motivoRechazo = motivo;
  this.fechaDecision = new Date();
  
  return this.save();
};

// Método para obtener dirección completa
reservaSchema.methods.obtenerDireccionCompleta = function() {
  const dir = this.datosPersonales.direccion;
  return `${dir.calle} ${dir.numeroExterior}${dir.numeroInterior ? ' Int. ' + dir.numeroInterior : ''}, ${dir.colonia}, ${dir.ciudad}, ${dir.estado}, ${dir.codigoPostal}`;
};

module.exports = mongoose.model('ReservaCuarto', reservaSchema);