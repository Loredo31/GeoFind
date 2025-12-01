// const Reseña = require("../models/ReseñaModel");
// const ProxyService = require("./proxyService");

// class ReseñaService {
//   async crearReseña(datosReseña) {
//     try {
//       // Procesar análisis de sentimiento
//       const analisis = await this.analizarSentimiento(datosReseña.comentario);
//       datosReseña.analisisSentimiento = analisis;

//       const reseña = new Reseña(datosReseña);
//       const resultado = await reseña.save();

//       // Limpiar cache después de crear nueva reseña
//       ProxyService.limpiarCacheHabitacion(datosReseña.habitacionId);

//       return resultado;
//     } catch (error) {
//       throw new Error(`Error al crear reseña: ${error.message}`);
//     }
//   }

//   // Método para obtener todas las reseñas de una habitación
//   async obtenerReseñasPorHabitacion(habitacionId) {
//     try {
//       return await ProxyService.obtenerReseñasHabitacion(habitacionId);
//     } catch (error) {
//       throw new Error(`Error al obtener reseñas: ${error.message}`);
//     }
//   }

//   // Método para obtener todas las reseñas
//   async obtenerTodasLasReseñas() {
//     try {
//       return await Reseña.find();
//     } catch (error) {
//       throw new Error(`Error al obtener reseñas: ${error.message}`);
//     }
//   }

// async analizarSentimiento(comentario) {
//     // Lista de palabras consideradas positivas
//     const palabrasPositivas = [
//       "excelente",
//       "bueno",
//       "genial",
//       "recomiendo",
//       "perfecto",
//       "maravilloso",
//     ];
//     // Lista de palabras consideradas negativas
//     const palabrasNegativas = [
//       "malo",
//       "terrible",
//       "horrible",
//       "pésimo",
//       "decepcionante",
//       "ruido",
//       "sucio",
//     ];

//     // Convertir comentario a minúsculas y dividir en palabras individuales
//     const palabras = comentario.toLowerCase().split(" ");
//     let puntuacion = 0;
//     let intensidad = 0;
//     const tópicos = [];

//     // Análisis simple de palabras clave
//     palabras.forEach((palabra) => {
//       // Incrementar puntuación e intensidad si encuentra palabras positivas
//       if (palabrasPositivas.includes(palabra)) {
//         puntuacion += 0.2;
//         intensidad += 0.1;
//       }
//       // Decrementar puntuación e incrementar intensidad si encuentra palabras negativas
//       if (palabrasNegativas.includes(palabra)) {
//         puntuacion -= 0.3;
//         intensidad += 0.2;

//         // Identificar tópicos específicos basados en palabras clave
//         if (["ruido", "sucio", "limpio", "limpieza"].includes(palabra)) {
//           tópicos.push({
//             nombre: "limpieza",
//             sentimiento: -0.5,
//             intensidad: 0.7,
//           });
//         }
//       }
//     });

//     // Normalizar valores para mantenerlos dentro de rangos esperados
//     puntuacion = Math.max(-1, Math.min(1, puntuacion));
//     intensidad = Math.max(0, Math.min(1, intensidad));

//     // Retornar objeto con los resultados del análisis de sentimiento
//     return {
//       puntuacion,
//       intensidad,
//       tópicos: tópicos.length > 0 ? tópicos : [],
//     };
//   }


//   // Método para obtener datos de gráfica de barras dobles
//   async obtenerDatosGraficaBarrasDobles(habitacionId) {
//     try {
//       return await ProxyService.obtenerDatosGraficaBarrasDobles(habitacionId);
//     } catch (error) {
//       throw new Error(
//         `Error al obtener datos de barras dobles: ${error.message}`
//       );
//     }
//   }

//   // Método para obtener promedios de calificaciones de una habitación
//   async obtenerPromedioCalificaciones(habitacionId) {
//     try {
//       return await ProxyService.obtenerPromediosHabitacion(habitacionId);
//     } catch (error) {
//       throw new Error(`Error al obtener promedios: ${error.message}`);
//     }
//   }

//   // Método para obtener la evolución (Gráfica de líneas)
//   async obtenerEvolucionCalificaciones(habitacionId) {
//     try {
//       return await ProxyService.obtenerEvolucionCalificaciones(habitacionId);
//     } catch (error) {
//       throw new Error(`Error al obtener evolución: ${error.message}`);
//     }
//   }

//   // Método para obtener datos de gráfica de barras
//   async obtenerDatosGraficaBarras(habitacionId) {
//     try {
//       return await ProxyService.obtenerDatosGraficaBarras(habitacionId);
//     } catch (error) {
//       throw new Error(`Error al obtener datos de barras: ${error.message}`);
//     }
//   }

//   // Método para obtener datos de gráfica de área
//   async obtenerDatosGraficaArea(habitacionId) {
//     try {
//       return await ProxyService.obtenerDatosGraficaArea(habitacionId);
//     } catch (error) {
//       throw new Error(`Error al obtener datos de área: ${error.message}`);
//     }
//   }

//   // Método para obtener datos de gráfica radar
//   async obtenerDatosGraficaRadar(habitacionId) {
//     try {
//       return await ProxyService.obtenerDatosGraficaRadar(habitacionId);
//     } catch (error) {
//       throw new Error(`Error al obtener datos de radar: ${error.message}`);
//     }
//   }
// }

// module.exports = new ReseñaService();




const Reseña = require("../models/ReseñaModel");
const ProxyService = require("./proxyService");
const ServiceInterface = require("./ServiceInterface");

class ReseñaService extends ServiceInterface{

  // Crear reseña
  async crearReseña(datosReseña) {
    try {
      // Analizar sentimiento del comentario
      const analisis = await this.analizarSentimiento(datosReseña.comentario);
      datosReseña.analisisSentimiento = analisis;

      // Guardar reseña en BD
      const reseña = new Reseña(datosReseña);
      const resultado = await reseña.save();

      // Limpiar cache relacionado a la habitación
      ProxyService.limpiarCacheHabitacion(datosReseña.habitacionId);

      return resultado;
    } catch (error) {
      throw new Error(`Error al crear reseña: ${error.message}`);
    }
  }

  // Obtener reseñas sin proxy (ya no usa cache aquí)
  async obtenerReseñasPorHabitacion(habitacionId) {
    return await Reseña.find({ habitacionId }).sort({ fechaReseña: -1 });
  }

  // Obtener todas las reseñas del sistema
  async obtenerTodasLasReseñas() {
    return await Reseña.find();
  }

  // ------------------------
  // ANÁLISIS DE SENTIMIENTO
  // ------------------------
  async analizarSentimiento(comentario) {
    const palabrasPositivas = ["excelente","bueno","genial","recomiendo","perfecto","maravilloso"];
    const palabrasNegativas = ["malo","terrible","horrible","pésimo","decepcionante","ruido","sucio"];

    const palabras = comentario.toLowerCase().split(" ");
    let puntuacion = 0;
    let intensidad = 0;
    const tópicos = [];

    // Revisar palabra por palabra
    palabras.forEach((palabra) => {
      if (palabrasPositivas.includes(palabra)) {
        puntuacion += 0.2;
        intensidad += 0.1;
      }

      if (palabrasNegativas.includes(palabra)) {
        puntuacion -= 0.3;
        intensidad += 0.2;

        // Clasificar temas específicos
        if (["ruido","sucio","limpio","limpieza"].includes(palabra)) {
          tópicos.push({ nombre: "limpieza", sentimiento: -0.5, intensidad: 0.7 });
        }
      }
    });

    // Normalizar valores
    puntuacion = Math.max(-1, Math.min(1, puntuacion));
    intensidad = Math.max(0, Math.min(1, intensidad));

    return { puntuacion, intensidad, tópicos };
  }

  // ------------------------
  // LÓGICA DE GRÁFICAS
  // ------------------------

  // Promedios generales y detallados
  async obtenerPromedioCalificaciones(habitacionId) {
    const reseñas = await Reseña.find({ habitacionId });
    if (reseñas.length === 0) return null;

    const promedios = {
      general: 0,
      limpieza: 0,
      ubicacion: 0,
      comodidad: 0,
      precio: 0,
      atencion: 0,
      arrendatario: 0,
      totalResenas: reseñas.length,
    };

    // Sumar todas las calificaciones
    reseñas.forEach(r => {
      promedios.general += r.calificacionGeneral;
      promedios.limpieza += r.calificacionesDetalladas.limpieza;
      promedios.ubicacion += r.calificacionesDetalladas.ubicacion;
      promedios.comodidad += r.calificacionesDetalladas.comodidad;
      promedios.precio += r.calificacionesDetalladas.precio;
      promedios.atencion += r.calificacionesDetalladas.atencion;
      promedios.arrendatario += r.calificacionArrendatario;
    });

    // Calcular promedio final
    const total = reseñas.length;
    Object.keys(promedios).forEach(key => {
      if (key !== "totalResenas") {
        promedios[key] = Number((promedios[key] / total).toFixed(1));
      }
    });

    return promedios;
  }

  // Gráfica de barras dobles
  async obtenerDatosGraficaBarrasDobles(habitacionId) {
    const reseñas = await Reseña.find({ habitacionId })
      .sort({ fechaReseña: -1 })
      .limit(7); // Últimas 7 reseñas

    if (reseñas.length === 0) return [];

    const ordenadas = reseñas.reverse(); // Para mostrar cronológicamente

    return ordenadas.map((r, i) => ({
      califArrendador: r.calificacionArrendatario,
      califCuarto: r.calificacionGeneral,
      nombre: r.nombre,
      fecha: r.fechaReseña,
      indice: i + 1,
    }));
  }

  // Evolución de calificaciones
  async obtenerEvolucionCalificaciones(habitacionId) {
    const reseñas = await Reseña.find({ habitacionId }).sort({ fechaReseña: 1 });

    return reseñas.map((r, i) => ({
      fecha: r.fechaReseña,
      calificacion: r.calificacionGeneral,
      usuario: r.nombre,
      indice: i + 1,
      detalles: {
        limpieza: r.calificacionesDetalladas.limpieza,
        ubicacion: r.calificacionesDetalladas.ubicacion,
        comodidad: r.calificacionesDetalladas.comodidad,
        precio: r.calificacionesDetalladas.precio,
        atencion: r.calificacionesDetalladas.atencion,
      }
    }));
  }

  // Gráfica de barras simples
  async obtenerDatosGraficaBarras(habitacionId) {
    const p = await this.obtenerPromedioCalificaciones(habitacionId);
    if (!p) return null;

    return [
      { categoria: "General", valor: p.general },
      { categoria: "Limpieza", valor: p.limpieza },
      { categoria: "Ubicación", valor: p.ubicacion },
      { categoria: "Comodidad", valor: p.comodidad },
      { categoria: "Precio", valor: p.precio },
      { categoria: "Atención", valor: p.atencion },
      { categoria: "Arrendatario", valor: p.arrendatario },
    ];
  }

  // Gráfica de área (promedio acumulado)
  async obtenerDatosGraficaArea(habitacionId) {
    const reseñas = await Reseña.find({ habitacionId }).sort({ fechaReseña: 1 });
    if (reseñas.length === 0) return null;

    let suma = 0;

    return reseñas.map((r, i) => {
      suma += r.calificacionGeneral;
      const promedio = suma / (i + 1);

      return {
        fecha: r.fechaReseña,
        calificacionActual: r.calificacionGeneral,
        promedioAcumulado: Number(promedio.toFixed(2)),
        indice: i + 1,
      };
    });
  }

  // Gráfica tipo radar
  async obtenerDatosGraficaRadar(habitacionId) {
    const p = await this.obtenerPromedioCalificaciones(habitacionId);
    if (!p) return null;

    return [
      { categoria: "Limpieza", valor: p.limpieza, maxValor: 5 },
      { categoria: "Ubicación", valor: p.ubicacion, maxValor: 5 },
      { categoria: "Comodidad", valor: p.comodidad, maxValor: 5 },
      { categoria: "Precio", valor: p.precio, maxValor: 5 },
      { categoria: "Atención", valor: p.atencion, maxValor: 5 },
      { categoria: "Arrendatario", valor: p.arrendatario, maxValor: 5 },
    ];
  }
}

module.exports = new ReseñaService();
