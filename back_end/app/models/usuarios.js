const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: [true, 'El nombre es requerido'],
    trim: true
  },
  email: {
    type: String,
    required: [true, 'El email es requerido'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Por favor ingresa un email válido']
  },
  password: {
    type: String,
    required: [true, 'La contraseña es requerida'],
    minlength: [6, 'La contraseña debe tener al menos 6 caracteres']
  },
  telefono: {
    type: String,
    required: [true, 'El teléfono es requerido'],
    trim: true
  },
  direccion: {
    type: String,
    required: [true, 'La dirección es requerida'],
    trim: true
  },
  edad: {
    type: Number,
    required: [true, 'La edad es requerida'],
    min: [18, 'Debes ser mayor de 18 años']
  },
  ocupacion: {
    type: String,
    required: [true, 'La ocupación es requerida'],
    trim: true
  },
  // SOLO UN ROL - usuario
  role: {
    type: String,
    default: 'usuario'
  },
  estaActivo: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Hash password antes de guardar
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Comparar password
userSchema.methods.compararPassword = async function(password) {
  return await bcrypt.compare(password, this.password);
};

module.exports = mongoose.model('Usuario', userSchema);