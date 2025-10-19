const mongoose = require("mongoose");

const informacionSchema = new mongoose.Schema(
  {
    nombre: {
      type: String,
      required: [true, "El nombre de la propiedad es requerido"],
      trim: true,
    },
    descripcion: {
      type: String,
      required: [true, "La descripción es requerida"],
      trim: true,
    },
    costo: {
      type: Number,
      required: [true, "El costo es requerido"],
      min: [0, "El costo no puede ser negativo"],
    },
    moneda: {
      type: String,
      default: "MXN",
      enum: ["MXN", "USD"],
    },
    // Array de servicios
    servicios: [
      {
        type: String,
        trim: true,
      },
    ],
    // Array de políticas
    politicas: [
      {
        tipo: {
          type: String,
          required: true,
          enum: ["normas", "cancelacion", "checkin", "checkout", "general"],
        },
        descripcion: {
          type: String,
          required: true,
        },
      },
    ],
    // Array de requisitos
    requisitos: [
      {
        tipo: {
          type: String,
          required: true,
          enum: ["documento", "edad", "ocupacion", "referencia", "otros"],
        },
        descripcion: {
          type: String,
          required: true,
        },
        obligatorio: {
          type: Boolean,
          default: true,
        },
      },
    ],
    // Fotos - guardaremos las URLs o paths
    fotos: [
      {
        url: {
          type: String,
          required: true,
        },
        descripcion: {
          type: String,
          trim: true,
        },
        esPrincipal: {
          type: Boolean,
          default: false,
        },
        orden: {
          type: Number,
          default: 0,
        },
      },
    ],
    // Información de ubicación
    direccion: {
      calle: {
        type: String,
        required: true,
        trim: true,
      },
      numeroExterior: {
        type: String,
        required: true,
        trim: true,
      },
      numeroInterior: {
        type: String,
        trim: true,
      },
      colonia: {
        type: String,
        required: true,
        trim: true,
      },
      ciudad: {
        type: String,
        required: true,
        trim: true,
      },
      estado: {
        type: String,
        required: true,
        trim: true,
      },
      codigoPostal: {
        type: String,
        required: true,
        trim: true,
      },
      pais: {
        type: String,
        default: "México",
        trim: true,
      },
    },
    // Enlace de Google Maps
    googleMaps: {
      url: {
        type: String,
        trim: true,
      },
      embedCode: {
        type: String,
        trim: true,
      },
      coordenadas: {
        lat: {
          type: Number,
        },
        lng: {
          type: Number,
        },
      },
    },
    // Información adicional
    capacidad: {
      type: Number,
      required: true,
      min: 1,
    },
    habitaciones: {
      type: Number,
      required: true,
      min: 1,
    },
    banos: {
      type: Number,
      required: true,
      min: 1,
    },
    metrosCuadrados: {
      type: Number,
      min: 0,
    },
    // Estado de la propiedad
    estaActiva: {
      type: Boolean,
      default: true,
    },
    estaDisponible: {
      type: Boolean,
      default: true,
    },
    // Fechas importantes
    fechaCreacion: {
      type: Date,
      default: Date.now,
    },
    fechaActualizacion: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Middleware para actualizar fechaActualizacion
informacionSchema.pre("save", function (next) {
  this.fechaActualizacion = Date.now();

  // Asegurar que solo una foto sea principal
  if (this.fotos && this.fotos.length > 0) {
    const fotosPrincipales = this.fotos.filter((foto) => foto.esPrincipal);
    if (fotosPrincipales.length > 1) {
      // Si hay más de una foto principal, dejar solo la primera como principal
      this.fotos.forEach((foto, index) => {
        foto.esPrincipal = index === 0;
      });
    }
  }

  next();
});

// Método para obtener la dirección completa
informacionSchema.methods.obtenerDireccionCompleta = function () {
  const dir = this.direccion;
  return `${dir.calle} ${dir.numeroExterior}${
    dir.numeroInterior ? " Int. " + dir.numeroInterior : ""
  }, ${dir.colonia}, ${dir.ciudad}, ${dir.estado}, ${dir.codigoPostal}, ${
    dir.pais
  }`;
};

// Método para obtener foto principal
informacionSchema.methods.obtenerFotoPrincipal = function () {
  const fotoPrincipal = this.fotos.find((foto) => foto.esPrincipal);
  return fotoPrincipal || (this.fotos.length > 0 ? this.fotos[0] : null);
};

// Índices para búsquedas eficientes
informacionSchema.index({ "direccion.ciudad": 1 });
informacionSchema.index({ costo: 1 });
informacionSchema.index({ estaActiva: 1, estaDisponible: 1 });

module.exports = mongoose.model("informacion", informacionSchema);
