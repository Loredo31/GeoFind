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
  },
  // NUEVOS CAMPOS PARA LAS GRÁFICAS - CON DECIMALES
  calificacionGeneral: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
    set: v => Math.round(v * 10) / 10
  },
  calificacionesDetalladas: {
    limpieza: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10
    },
    ubicacion: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 
    },
    comodidad: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 
    },
    precio: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 
    },
    atencion: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 
    }
  },
  // Para análisis de sentimiento y tópicos
  analisisSentimiento: {
    puntuacion: { 
      type: Number, 
      default: 0,
      set: v => Math.round(v * 100) / 100 
    },
    intensidad: { 
      type: Number, 
      default: 0,
      set: v => Math.round(v * 100) / 100 
    },
    tópicos: [{
      nombre: String,
      sentimiento: {
        type: Number,
        set: v => Math.round(v * 100) / 100 
      },
      intensidad: {
        type: Number,
        set: v => Math.round(v * 100) / 100
      }
    }]
  },
  // Para calificación del arrendatario
  calificacionArrendatario: {
    type: Number,
    min: 1,
    max: 5,
    set: v => Math.round(v * 10) / 10
  },
  comentarioArrendatario: {
    type: String,
    default: ''
  }
});

module.exports = mongoose.model('Reseña', reseñaSchema);