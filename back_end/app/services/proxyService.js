// const NodeCache = require("node-cache");
// const Reseña = require("../models/ReseñaModel");
// const sharp = require('sharp');
// const blockhash = require('blockhash-core');
// const Informacion = require('../models/InformacionModel');

// // Servicio Proxy que maneja el caché de datos para evitar consultas repetidas a la base de datos
// class ProxyService {
//   constructor() {
//     // Se inicializa el cache con TTL estándar de 5 minutos
//     this.cache = new NodeCache({
//       stdTTL: 300, // Tiempo de vida por defecto (5 minutos)
//       checkperiod: 60, // Intervalo para limpiar datos expirados
//     });
//   }

//   // Método genérico para obtener datos desde cache o desde una función que consulta la BD
//   async obtenerConCache(clave, funcionObtener, ttl = 300) {
//     let datos = this.cache.get(clave);

//     // Si no existen datos en el cache, se ejecuta la función para obtenerlos
//     if (datos == undefined) {
//       datos = await funcionObtener();
//       this.cache.set(clave, datos, ttl); // Se guarda en el cache
//     }

//     return datos;
//   }

//   // Obtiene las reseñas de una habitación utilizando cache
//   async obtenerReseñasHabitacion(habitacionId) {
//     const clave = `reseñas_${habitacionId}`;
//     return this.obtenerConCache(clave, async () => {
//       // Consulta a la base de datos y ordena por fecha descendente
//       return await Reseña.find({ habitacionId }).sort({ fechaReseña: -1 });
//     });
//   }

//   // Calcula y retorna los promedios de las calificaciones de una habitación
//   async obtenerPromediosHabitacion(habitacionId) {
//     const clave = `promedios_${habitacionId}`;
//     return this.obtenerConCache(clave, async () => {
//       const reseñas = await Reseña.find({ habitacionId });

//       if (reseñas.length === 0) {
//         return null; // Si no hay reseñas, no hay promedios
//       }

//       // Inicialización de acumuladores
//       const promedios = {
//         general: 0,
//         limpieza: 0,
//         ubicacion: 0,
//         comodidad: 0,
//         precio: 0,
//         atencion: 0,
//         arrendatario: 0,
//         totalResenas: reseñas.length,
//       };

//       // Acumular valores
//       reseñas.forEach((reseña) => {
//         promedios.general += reseña.calificacionGeneral;
//         promedios.limpieza += reseña.calificacionesDetalladas.limpieza;
//         promedios.ubicacion += reseña.calificacionesDetalladas.ubicacion;
//         promedios.comodidad += reseña.calificacionesDetalladas.comodidad;
//         promedios.precio += reseña.calificacionesDetalladas.precio;
//         promedios.atencion += reseña.calificacionesDetalladas.atencion;
//         promedios.arrendatario += reseña.calificacionArrendatario;
//       });

//       // Calcular promedios finales
//       const total = reseñas.length;
//       Object.keys(promedios).forEach((key) => {
//         if (key !== "totalResenas") {
//           promedios[key] = Number((promedios[key] / total).toFixed(1));
//         }
//       });

//       return promedios;
//     });
//   }

// // Datos para gráfica de barras dobles (arrendador vs cuarto) 
// async obtenerDatosGraficaBarrasDobles(habitacionId) {
//   const clave = `barrasDobles_${habitacionId}`;
//   return this.obtenerConCache(clave, async () => {
//     const reseñas = await Reseña.find({ habitacionId })
//       .sort({ fechaReseña: -1 }) 
//       .limit(7); // Solo últimas 7

//     if (reseñas.length === 0) return [];

//     // Invertir para mostrar en orden cronológico (más antigua a más reciente)
//     const reseñasOrdenadas = reseñas.reverse();

//     return reseñasOrdenadas.map((reseña, index) => ({
//       califArrendador: reseña.calificacionArrendatario,  // Calificación arrendador
//       califCuarto: reseña.calificacionGeneral,  // Calificación cuarto/general
//       nombre: reseña.nombre,
//       fecha: reseña.fechaReseña,
//       indice: index + 1, 
//     }));
//   });
// }

//   // Obtiene la evolución en el tiempo de las calificaciones
//   async obtenerEvolucionCalificaciones(habitacionId) {
//     const clave = `evolucion_${habitacionId}`;
//     return this.obtenerConCache(clave, async () => {
//       const reseñas = await Reseña.find({ habitacionId }).sort({
//         fechaReseña: 1, // Orden ascendente por fecha
//       });

//       // Se estructura por índice y detalle
//       return reseñas.map((reseña, index) => ({
//         fecha: reseña.fechaReseña,
//         calificacion: reseña.calificacionGeneral,
//         usuario: reseña.nombre,
//         indice: index + 1,
//         detalles: {
//           limpieza: reseña.calificacionesDetalladas.limpieza,
//           ubicacion: reseña.calificacionesDetalladas.ubicacion,
//           comodidad: reseña.calificacionesDetalladas.comodidad,
//           precio: reseña.calificacionesDetalladas.precio,
//           atencion: reseña.calificacionesDetalladas.atencion,
//         },
//       }));
//     });
//   }

//   // Construye datos para la gráfica de barras 
//   async obtenerDatosGraficaBarras(habitacionId) {
//     const clave = `barras_${habitacionId}`;
//     return this.obtenerConCache(clave, async () => {
//       const promedios = await this.obtenerPromediosHabitacion(habitacionId);

//       if (!promedios) return null;

//       return [
//         { categoria: "General", valor: promedios.general },
//         { categoria: "Limpieza", valor: promedios.limpieza },
//         { categoria: "Ubicación", valor: promedios.ubicacion },
//         { categoria: "Comodidad", valor: promedios.comodidad },
//         { categoria: "Precio", valor: promedios.precio },
//         { categoria: "Atención", valor: promedios.atencion },
//         { categoria: "Arrendatario", valor: promedios.arrendatario },
//       ];
//     });
//   }

//   // Datos para una gráfica de área 
//   async obtenerDatosGraficaArea(habitacionId) {
//     const clave = `area_${habitacionId}`;
//     return this.obtenerConCache(clave, async () => {
//       const reseñas = await Reseña.find({ habitacionId }).sort({
//         fechaReseña: 1,
//       });

//       if (reseñas.length === 0) return null;

//       let sumaAcumulada = 0;
//       return reseñas.map((reseña, index) => {
//         sumaAcumulada += reseña.calificacionGeneral;
//         const promedioAcumulado = sumaAcumulada / (index + 1);

//         return {
//           fecha: reseña.fechaReseña,
//           calificacionActual: reseña.calificacionGeneral,
//           promedioAcumulado: Number(promedioAcumulado.toFixed(2)),
//           indice: index + 1,
//         };
//       });
//     });
//   }

//   // Elimina del cache todos los datos relacionados 
//   limpiarCacheHabitacion(habitacionId) {
//     const patrones = [
//       `reseñas_${habitacionId}`,
//       `promedios_${habitacionId}`,
//       `barrasDobles_${habitacionId}`,
//       `evolucion_${habitacionId}`,
//       `barras_${habitacionId}`,
//       `area_${habitacionId}`,
//     ];

//     // Se eliminan todas las claves del cache
//     patrones.forEach((patron) => {
//       this.cache.del(patron);
//     });
//   }

//   // Datos para una gráfica de radar
//   async obtenerDatosGraficaRadar(habitacionId) {
//     const clave = `radar_${habitacionId}`;
//     return this.obtenerConCache(clave, async () => {
//       const promedios = await this.obtenerPromediosHabitacion(habitacionId);

//       if (!promedios) return null;

//       return [
//         {
//           categoria: "Limpieza",
//           valor: promedios.limpieza,
//           maxValor: 5.0,
//         },
//         {
//           categoria: "Ubicación",
//           valor: promedios.ubicacion,
//           maxValor: 5.0,
//         },
//         {
//           categoria: "Comodidad",
//           valor: promedios.comodidad,
//           maxValor: 5.0,
//         },
//         {
//           categoria: "Precio",
//           valor: promedios.precio,
//           maxValor: 5.0,
//         },
//         {
//           categoria: "Atención",
//           valor: promedios.atencion,
//           maxValor: 5.0,
//         },
//         {
//           categoria: "Arrendatario",
//           valor: promedios.arrendatario,
//           maxValor: 5.0,
//         },
//       ];
//     });
//   }

//  // Inicia sección de verificación de imágenes duplicadas

//   /**
//    * Genera hash perceptual de una imagen
//    */
//   async generarHash(imageBuffer) {
//     try {
//       // Procesar imagen con sharp
//       const { data, info } = await sharp(imageBuffer)
//         .resize(256, 256, { fit: 'fill' })
//         .raw()
//         .toBuffer({ resolveWithObject: true });

//       // Generar hash usando blockhash
//       const hash = blockhash.bmvbhash({
//         data: data,
//         width: info.width,
//         height: info.height
//       }, 16);

//       return hash;
//     } catch (error) {
//       console.error(`❌ Error generando hash: ${error.message}`);
//       throw error;
//     }
//   }

//   /**
//    * Calcula la distancia de Hamming entre dos hashes
//    */
//   async calcularDistanciaHamming(hash1, hash2) {
//     if (!hash1 || !hash2 || hash1.length !== hash2.length) {
//       return 100; // Máxima diferencia
//     }

//     let distance = 0;
//     for (let i = 0; i < hash1.length; i++) {
//       if (hash1[i] !== hash2[i]) {
//         distance++;
//       }
//     }
//     return distance;
//   }

//   /**
//    * Calcula el porcentaje de similitud entre dos hashes
//    */
//   async calcularSimilitud(hash1, hash2) {
//     const distance = await this.calcularDistanciaHamming(hash1, hash2);
//     const maxDistance = hash1.length;
//     const similarity = ((maxDistance - distance) / maxDistance) * 100;
//     return similarity;
//   }

//   /**
//    * Verifica si una imagen ya existe en la base de datos
//    */
//   async verificarImagenDuplicada(imageBase64) {
//     try {
//       console.log('📸 Iniciando verificación de imagen...');
      
//       // Convertir base64 a buffer
//       const imageBuffer = Buffer.from(imageBase64, 'base64');
//       console.log(`📦 Buffer creado: ${imageBuffer.length} bytes`);
      
//       // Generar hash de la nueva imagen
//       const newImageHash = await this.generarHash(imageBuffer);
//       console.log(`🔑 Hash generado: ${newImageHash}`);
      
//       // Buscar habitaciones con fotografías
//       const habitaciones = await Informacion.find({}, 'fotografias');
//       console.log(`🏠 Habitaciones encontradas: ${habitaciones.length}`);
      
//       let imagenDuplicada = false;
//       let mejorCoincidencia = null;
//       let similitudMaxima = 0;
//       let imagenesComparadas = 0;
      
//       // Si no hay habitaciones, la imagen es original
//       if (habitaciones.length === 0) {
//         console.log('✅ Primera imagen - no hay comparaciones');
//         return {
//           found: false,
//           similarity: 0,
//           message: 'Primera imagen registrada',
//           hash: newImageHash
//         };
//       }
      
//       // Comparar con cada imagen existente
//       for (const habitacion of habitaciones) {
//         if (!habitacion.fotografias || habitacion.fotografias.length === 0) continue;
        
//         for (const fotoBase64 of habitacion.fotografias) {
//           try {
//             const fotoBuffer = Buffer.from(fotoBase64, 'base64');
//             const fotoHash = await this.generarHash(fotoBuffer);
            
//             const similitud = await this.calcularSimilitud(newImageHash, fotoHash);
//             imagenesComparadas++;
            
//             console.log(`🔍 Similitud encontrada: ${similitud.toFixed(2)}%`);
            
//             // Umbral de similitud: 95% o más se considera duplicado
//             if (similitud >= 95 && similitud > similitudMaxima) {
//               imagenDuplicada = true;
//               similitudMaxima = similitud;
//               mejorCoincidencia = {
//                 hash: fotoHash,
//                 similitud: similitud.toFixed(2)
//               };
//             }
//           } catch (err) {
//             console.warn(`⚠️ Error al procesar imagen de BD: ${err.message}`);
//           }
//         }
//       }
      
//       console.log(`🔍 Imágenes comparadas: ${imagenesComparadas}`);
      
//       // Preparar respuesta
//       if (imagenDuplicada) {
//         console.log(`❌ Imagen duplicada (${similitudMaxima.toFixed(2)}% similar)`);
//         return {
//           found: true,
//           similarity: similitudMaxima.toFixed(2),
//           message: `Imagen duplicada con ${similitudMaxima.toFixed(2)}% de similitud`,
//           match: mejorCoincidencia
//         };
//       }
      
//       console.log('✅ Imagen original verificada');
//       return {
//         found: false,
//         similarity: imagenesComparadas > 0 ? similitudMaxima.toFixed(2) : 0,
//         message: 'Imagen original - no hay duplicados',
//         hash: newImageHash
//       };
      
//     } catch (error) {
//       console.error(`❌ Error: ${error.message}`);
//       console.error(error.stack);
//       throw new Error(`Error al procesar imagen: ${error.message}`);
//     }
//   }
// }

// module.exports = new ProxyService();





const NodeCache = require("node-cache");
const ReseñaService = require("./reseñaService");
const InformacionService = require("./informacionService");

class ProxyService {
  constructor() {
    // Configuración del sistema de caché
    this.cache = new NodeCache({
      stdTTL: 300,
      checkperiod: 60,
    });
  }

  // =====================================================
  // ===============   MÉTODOS DE CACHÉ   ================
  // =====================================================

  async obtenerConCache(clave, obtenerDatosCallback, ttl = 300) {
    const datosCache = this.cache.get(clave);

    if (datosCache !== undefined) {
      return datosCache;
    }

    const datos = await obtenerDatosCallback();
    this.cache.set(clave, datos, ttl);

    return datos;
  }

  async obtenerReseñasPorHabitacion(habitacionId) {
    const clave = `reseñas_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      return await ReseñaService.obtenerReseñasPorHabitacion(habitacionId);
    });
  }

  async obtenerPromedioCalificaciones(habitacionId) {
    const clave = `promedios_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      return await ReseñaService.obtenerPromedioCalificaciones(habitacionId);
    });
  }

  async obtenerDatosGraficaBarras(habitacionId) {
    const clave = `barras_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      return await ReseñaService.obtenerDatosGraficaBarras(habitacionId);
    });
  }

  async obtenerDatosGraficaBarrasDobles(habitacionId) {
    const clave = `barrasDobles_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      return await ReseñaService.obtenerDatosGraficaBarrasDobles(habitacionId);
    });
  }

  async obtenerEvolucionCalificaciones(habitacionId) {
    const clave = `evolucion_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      return await ReseñaService.obtenerEvolucionCalificaciones(habitacionId);
    });
  }

  async obtenerDatosGraficaArea(habitacionId) {
    const clave = `area_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      return await ReseñaService.obtenerDatosGraficaArea(habitacionId);
    });
  }

  async obtenerDatosGraficaRadar(habitacionId) {
    const clave = `radar_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      return await ReseñaService.obtenerDatosGraficaRadar(habitacionId);
    });
  }

  limpiarCacheHabitacion(habitacionId) {
    const claves = [
      `reseñas_${habitacionId}`,
      `promedios_${habitacionId}`,
      `barras_${habitacionId}`,
      `barrasDobles_${habitacionId}`,
      `evolucion_${habitacionId}`,
      `area_${habitacionId}`,
      `radar_${habitacionId}`,
    ];

    claves.forEach(clave => this.cache.del(clave));
  }

  /**
   * PROXY VERIFICADOR DE IMÁGENES
   */
  async verificarImagenDuplicada(imageBase64) {
    // Validación superficial antes de llamar al servicio real
    if (typeof imageBase64 !== "string" || imageBase64.length < 50) {
      return {
        found: false,
        similarity: 0,
        message: "Imagen demasiado pequeña o inválida",
      };
    }

    // Clave hash parcial para cachear verificaciones repetidas
    const cacheKey = `img_${imageBase64.substring(0, 60)}`;

    // CONSULTA EN CACHE (Proxy)
    const enCache = this.cache.get(cacheKey);
    if (enCache !== undefined) {
      return enCache;
    }

    // Delegación al servicio real (Proxy → Service)
    const resultado = await InformacionService.verificarImagenDuplicada(imageBase64);

    // Guardar en cache
    this.cache.set(cacheKey, resultado, 180);

    return resultado;
  }
}

module.exports = new ProxyService();
