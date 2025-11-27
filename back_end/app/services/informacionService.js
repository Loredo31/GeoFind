const Informacion = require('../models/InformacionModel');

class InformacionService {
  async crearInformacion(datos) {
    try {
      // ✅ EXTRAER PRIMERA FOTO para fotoPortada
      if (datos.fotografias && datos.fotografias.length > 0) {
        datos.fotoPortada = datos.fotografias[0];
      }
      
      const informacion = new Informacion(datos);
      return await informacion.save();
    } catch (error) {
      throw new Error(`Error al crear información: ${error.message}`);
    }
  }

  // ✅ LOS DEMÁS MÉTODOS SE MANTIENEN IGUAL
  async obtenerInformacionPorArrendador(arrendadorId) {
    try {
      return await Informacion.find({ arrendadorId });
    } catch (error) {
      throw new Error(`Error al obtener información: ${error.message}`);
    }
  }

  async obtenerTodasLasHabitaciones() {
    try {
      return await Informacion.find();
    } catch (error) {
      throw new Error(`Error al obtener habitaciones: ${error.message}`);
    }
  }

  async actualizarInformacion(id, datos) {
    try {
      // ✅ ACTUALIZAR fotoPortada si hay nuevas fotografías
      if (datos.fotografias && datos.fotografias.length > 0) {
        datos.fotoPortada = datos.fotografias[0];
      }
      
      return await Informacion.findByIdAndUpdate(id, datos, { new: true });
    } catch (error) {
      throw new Error(`Error al actualizar información: ${error.message}`);
    }
  }

  async eliminarInformacion(id) {
    try {
      return await Informacion.findByIdAndDelete(id);
    } catch (error) {
      throw new Error(`Error al eliminar información: ${error.message}`);
    }
  }

  // ==========   MÉTODOS DE PROCESAMIENTO DE IMÁGENES   ==========

  /**
   * Genera un hash perceptual de una imagen usando blockhash
   */
  async generarHash(imageBuffer) {
    try {
      // Redimensionar la imagen a 256x256 y obtener datos en bruto
      const { data, info } = await sharp(imageBuffer)
        .resize(256, 256, { fit: 'fill' })
        .raw()
        .toBuffer({ resolveWithObject: true });

        // Generar el hash usando blockhash
      const hash = blockhash.bmvbhash({
        data: data,
        width: info.width,
        height: info.height
      }, 16);

      return hash;
    } catch (error) {
      console.error(`Error generando hash: ${error.message}`);
      throw error;
    }
  }

  /**
   * Calcula la distancia Hamming entre dos hashes
   */
  async calcularDistanciaHamming(hash1, hash2) {
    // Retorna una distancia máxima si los hashes no son válidos
    if (!hash1 || !hash2 || hash1.length !== hash2.length) {
      return 100;
    }

    // Calcula la distancia Hamming
    let distance = 0;
    for (let i = 0; i < hash1.length; i++) {
      if (hash1[i] !== hash2[i]) {
        distance++;
      }
    }
    return distance;
  }

  /**
   * Calcula el porcentaje de similitud entre dos hashes
   */
  async calcularSimilitud(hash1, hash2) {
    // Calcula la distancia Hamming
    const distance = await this.calcularDistanciaHamming(hash1, hash2);
    // Convierte la distancia a porcentaje de similitud
    const maxDistance = hash1.length;
    const similarity = ((maxDistance - distance) / maxDistance) * 100;
    return similarity;
  }

  /**
   * Verifica si una imagen ya existe en la BD comparando hashes
   */
  async verificarImagenDuplicada(imageBase64) {
    try {
      console.log("Iniciando verificación de imagen...");

      // Convertir la imagen de base64 a buffer
      const imageBuffer = Buffer.from(imageBase64, 'base64');
      console.log(`Buffer creado: ${imageBuffer.length} bytes`);

      // Generar hash de la nueva imagen
      const newImageHash = await this.generarHash(imageBuffer);
      console.log(`Hash generado: ${newImageHash}`);

      // Obtener todas las habitaciones y sus fotografías
      const habitaciones = await Informacion.find({}, 'fotografias');
      console.log(`Habitaciones encontradas: ${habitaciones.length}`);

      // Inicializar variables para seguimiento
      let imagenDuplicada = false;
      let mejorCoincidencia = null;
      let similitudMaxima = 0;
      let imagenesComparadas = 0;

      // Si no hay habitaciones, es la primera imagen
      if (habitaciones.length === 0) {
        console.log('Primera imagen - no hay comparaciones');
        return {
          found: false,
          similarity: 0,
          message: "Primera imagen registrada",
          hash: newImageHash
        };
      }

      // Comparar con cada fotografía en la base de datos
      for (const habitacion of habitaciones) {
        if (!habitacion.fotografias || habitacion.fotografias.length === 0) continue;

        for (const fotoBase64 of habitacion.fotografias) {
          try {
            // Convertir la foto de base64 a buffer
            const fotoBuffer = Buffer.from(fotoBase64, 'base64');
            // Generar hash de la foto de la BD
            const fotoHash = await this.generarHash(fotoBuffer);

            // Calcular similitud
            const similitud = await this.calcularSimilitud(newImageHash, fotoHash);
            imagenesComparadas++;

            console.log(`Similitud encontrada`);

            // Umbral de similitud: 95% o más se considera duplicado
            if (similitud >= 95 && similitud > similitudMaxima) {
              imagenDuplicada = true;
              similitudMaxima = similitud;
              mejorCoincidencia = {
                hash: fotoHash,
                similitud: similitud.toFixed(2)
              };
            }
          } catch (err) {
            console.warn(`Error al procesar imagen de BD: ${err.message}`);
          }
        }
      }

      // Resultado de la verificación
      if (imagenDuplicada) {
        console.log(`Imagen duplicada (${similitudMaxima.toFixed(2)}% similar)`);
        return {
          found: true,
          similarity: similitudMaxima.toFixed(2),
          message: `Imagen duplicada con ${similitudMaxima.toFixed(2)}% de similitud`,
          match: mejorCoincidencia
        };
      }

      console.log('Imagen original verificada');
      return {
        found: false,
        similarity: imagenesComparadas > 0 ? similitudMaxima.toFixed(2) : 0,
        message: "Imagen original - no hay duplicados",
        hash: newImageHash
      };

    } catch (error) {
      console.error(`Error: ${error.message}`);
      console.error(error.stack);
      throw new Error(`Error al procesar imagen: ${error.message}`);
    }
  }
}

module.exports = new InformacionService();