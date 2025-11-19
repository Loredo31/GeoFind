// const Reseña = require('../models/ReseñaModel');

// class ReseñaService {
//   async crearReseña(datosReseña) {
//     try {
//       const reseña = new Reseña(datosReseña);
//       return await reseña.save();
//     } catch (error) {
//       throw new Error(`Error al crear reseña: ${error.message}`);
//     }
//   }

//   async obtenerReseñasPorHabitacion(habitacionId) {
//     try {
//       return await Reseña.find({ habitacionId });
//     } catch (error) {
//       throw new Error(`Error al obtener reseñas: ${error.message}`);
//     }
//   }

//   async obtenerTodasLasReseñas() {
//     try {
//       return await Reseña.find();
//     } catch (error) {
//       throw new Error(`Error al obtener reseñas: ${error.message}`);
//     }
//   }
// }

// module.exports = new ReseñaService();





const Reseña = require('../models/ReseñaModel');

class ReseñaService {
  async crearReseña(datosReseña) {
    try {
      // Procesar análisis de sentimiento (puedes integrar un servicio externo aquí)
      const analisis = await this.analizarSentimiento(datosReseña.comentario);
      datosReseña.analisisSentimiento = analisis;
      
      const reseña = new Reseña(datosReseña);
      return await reseña.save();
    } catch (error) {
      throw new Error(`Error al crear reseña: ${error.message}`);
    }
  }

  async obtenerReseñasPorHabitacion(habitacionId) {
    try {
      return await Reseña.find({ habitacionId });
    } catch (error) {
      throw new Error(`Error al obtener reseñas: ${error.message}`);
    }
  }

  async obtenerTodasLasReseñas() {
    try {
      return await Reseña.find();
    } catch (error) {
      throw new Error(`Error al obtener reseñas: ${error.message}`);
    }
  }

  // NUEVOS MÉTODOS PARA ANÁLISIS
  async analizarSentimiento(comentario) {
    // Esto es un ejemplo básico - integra con una API de análisis de sentimiento
    const palabrasPositivas = ['excelente', 'bueno', 'genial', 'recomiendo', 'perfecto', 'maravilloso'];
    const palabrasNegativas = ['malo', 'terrible', 'horrible', 'pésimo', 'decepcionante', 'ruido', 'sucio'];
    
    const palabras = comentario.toLowerCase().split(' ');
    let puntuacion = 0;
    let intensidad = 0;
    const tópicos = [];

    // Análisis simple de palabras clave
    palabras.forEach(palabra => {
      if (palabrasPositivas.includes(palabra)) {
        puntuacion += 0.2;
        intensidad += 0.1;
      }
      if (palabrasNegativas.includes(palabra)) {
        puntuacion -= 0.3;
        intensidad += 0.2;
        
        // Identificar tópicos
        if (['ruido', 'sucio', 'limpio', 'limpieza'].includes(palabra)) {
          tópicos.push({
            nombre: 'limpieza',
            sentimiento: -0.5,
            intensidad: 0.7
          });
        }
      }
    });

    // Normalizar valores
    puntuacion = Math.max(-1, Math.min(1, puntuacion));
    intensidad = Math.max(0, Math.min(1, intensidad));

    return {
      puntuacion,
      intensidad,
      tópicos: tópicos.length > 0 ? tópicos : []
    };
  }

  // Método para obtener datos para gráfica de dispersión
  async obtenerDatosGraficaDispersion(habitacionId) {
    const reseñas = await Reseña.find({ habitacionId });
    
    // Agrupar tópicos y calcular frecuencia e intensidad
    const tópicosMap = new Map();
    
    reseñas.forEach(reseña => {
      reseña.analisisSentimiento.tópicos.forEach(tópico => {
        if (!tópicosMap.has(tópico.nombre)) {
          tópicosMap.set(tópico.nombre, {
            frecuencia: 0,
            intensidadAcumulada: 0,
            menciones: 0
          });
        }
        
        const datos = tópicosMap.get(tópico.nombre);
        datos.frecuencia += 1;
        datos.intensidadAcumulada += Math.abs(tópico.intensidad * tópico.sentimiento);
        datos.menciones += 1;
      });
    });

    // Convertir a formato para gráfica
    const datosGrafica = Array.from(tópicosMap.entries()).map(([nombre, datos]) => ({
      tópico: nombre,
      frecuencia: datos.frecuencia,
      intensidadPromedio: datos.menciones > 0 ? datos.intensidadAcumulada / datos.menciones : 0
    }));

    return datosGrafica;
  }

  // Método para calcular promedio de calificaciones
  async obtenerPromedioCalificaciones(habitacionId) {
    const reseñas = await Reseña.find({ habitacionId });
    
    if (reseñas.length === 0) {
      return null;
    }

    const promedios = {
      general: 0,
      limpieza: 0,
      ubicacion: 0,
      comodidad: 0,
      precio: 0,
      atencion: 0,
      arrendatario: 0
    };

    reseñas.forEach(reseña => {
      promedios.general += reseña.calificacionGeneral;
      promedios.limpieza += reseña.calificacionesDetalladas.limpieza;
      promedios.ubicacion += reseña.calificacionesDetalladas.ubicacion;
      promedios.comodidad += reseña.calificacionesDetalladas.comodidad;
      promedios.precio += reseña.calificacionesDetalladas.precio;
      promedios.atencion += reseña.calificacionesDetalladas.atencion;
      promedios.arrendatario += reseña.calificacionArrendatario;
    });

    const total = reseñas.length;
    Object.keys(promedios).forEach(key => {
      promedios[key] = promedios[key] / total;
    });

    return promedios;
  }
}

module.exports = new ReseñaService();