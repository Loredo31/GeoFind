// const mongoose = require('mongoose');

// const reseñaSchema = new mongoose.Schema({
//   nombre: {
//     type: String,
//     required: true
//   },
//   duracionRenta: {
//     type: Number,
//     required: true
//   },
//   comentario: {
//     type: String,
//     required: true
//   },
//   habitacionId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Informacion',
//     required: true
//   },
//   usuarioId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: 'Usuario',
//     required: true
//   },
//   fechaReseña: {
//     type: Date,
//     default: Date.now
//   }
// });

// module.exports = mongoose.model('Reseña', reseñaSchema);




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
    set: v => Math.round(v * 10) / 10 // Permite un decimal
  },
  calificacionesDetalladas: {
    limpieza: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 // Permite un decimal
    },
    ubicacion: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 // Permite un decimal
    },
    comodidad: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 // Permite un decimal
    },
    precio: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 // Permite un decimal
    },
    atencion: { 
      type: Number, 
      min: 1, 
      max: 5,
      set: v => Math.round(v * 10) / 10 // Permite un decimal
    }
  },
  // Para análisis de sentimiento y tópicos
  analisisSentimiento: {
    puntuacion: { 
      type: Number, 
      default: 0,
      set: v => Math.round(v * 100) / 100 // Permite dos decimales
    },
    intensidad: { 
      type: Number, 
      default: 0,
      set: v => Math.round(v * 100) / 100 // Permite dos decimales
    },
    tópicos: [{
      nombre: String,
      sentimiento: {
        type: Number,
        set: v => Math.round(v * 100) / 100 // Permite dos decimales
      },
      intensidad: {
        type: Number,
        set: v => Math.round(v * 100) / 100 // Permite dos decimales
      }
    }]
  },
  // Para calificación del arrendatario
  calificacionArrendatario: {
    type: Number,
    min: 1,
    max: 5,
    set: v => Math.round(v * 10) / 10 // Permite un decimal
  },
  comentarioArrendatario: {
    type: String,
    default: ''
  }
});

module.exports = mongoose.model('Reseña', reseñaSchema);