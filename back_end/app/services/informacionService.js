const Informacion = require('../models/InformacionModel');
const sharp = require('sharp');
const blockhash = require('blockhash-core');
const ImageKit = require('imagekit');

class InformacionService {

  // Contructor con el API de ImageKit
  constructor() {
    this.THRESHOLD = 95;
    this.SIMILARITY_THRESHOLD = 95;

    this.imagekit = new ImageKit({
      publicKey: process.env.IMAGEKIT_PUBLIC_KEY,
      privateKey: process.env.IMAGEKIT_PRIVATE_KEY,
      urlEndpoint: process.env.IMAGEKIT_URL_ENDPOINT
    });
  }

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
   * Valida si un buffer contiene una imagen válida
   */
  async validarImagenBuffer(buffer) {
    try {
      if (!buffer || buffer.length === 0) {
        return false;
      }

      // Verificar que el buffer tenga un tamaño mínimo razonable
      if (buffer.length < 100) {
        return false;
      }

      // Intentar obtener metadata sin procesar la imagen
      const metadata = await sharp(buffer).metadata();
      
      // Verificar que tenga formato válido y dimensiones
      return !!(metadata.format && metadata.width && metadata.height);
    } catch {
      return false;
    }
  }

  /**
   * Limpia y valida el string base64
   */
  limpiarBase64(base64String) {
    if (!base64String || typeof base64String !== 'string') {
      throw new Error('Base64 string inválido');
    }

    // Remover el prefijo data URL si existe
    let cleanBase64 = base64String;
    if (base64String.includes(',')) {
      cleanBase64 = base64String.split(',')[1];
    }

    // Validar longitud mínima
    if (cleanBase64.length < 100) {
      throw new Error('Base64 demasiado corto');
    }

    // Validar que sea base64 válido
    if (!/^[A-Za-z0-9+/]*={0,2}$/.test(cleanBase64)) {
      throw new Error('Formato base64 inválido');
    }

    return cleanBase64;
  }

  /**
   * Genera un hash perceptual de una imagen usando blockhash
   */
  async generarHash(imageBuffer) {
    try {
      // Validar buffer primero
      const esValido = await this.validarImagenBuffer(imageBuffer);
      if (!esValido) {
        throw new Error('Imagen no válida o corrupta');
      }

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
      // NO mostrar errores de imágenes corruptas en la terminal
      // Solo re-lanzar el error sin logging
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

  async compararImagenContraLista(newHash, lista, obtenerBufferCallback) {
    let mejorCoincidencia = null;
    let similitudMaxima = 0;
    let imagenesComparadas = 0;

    for (const item of lista) {
      try {
        const buffer = await obtenerBufferCallback(item);
        
        // Validar buffer antes de generar hash
        const esValido = await this.validarImagenBuffer(buffer);
        if (!esValido) {
          continue; // Saltar imagen inválida silenciosamente
        }

        const hash = await this.generarHash(buffer);
        const similitud = await this.calcularSimilitud(newHash, hash);
        imagenesComparadas++;

        if (similitud >= this.SIMILARITY_THRESHOLD && similitud > similitudMaxima) {
          similitudMaxima = similitud;
          mejorCoincidencia = { item, hash, similitud };
        }
      } catch {
        // Silenciosamente ignorar imágenes corruptas
        continue;
      }
    }

    return {
      found: !!mejorCoincidencia,
      match: mejorCoincidencia,
      similarity: similitudMaxima.toFixed(2),
      compared: imagenesComparadas
    };
  }

  async verificarImagenEnBaseDatos(imageBase64) {
    try {
      const cleanBase64 = this.limpiarBase64(imageBase64);
      const newBuffer = Buffer.from(cleanBase64, 'base64');
      
      // Validar la imagen principal antes de continuar
      const esValido = await this.validarImagenBuffer(newBuffer);
      if (!esValido) {
        return {
          found: false,
          similarity: 0,
          message: 'Imagen principal no válida',
          source: 'database'
        };
      }

      const newHash = await this.generarHash(newBuffer);
      const habitaciones = await Informacion.find({}, 'fotografias');
      const fotosBD = habitaciones.flatMap(h => h.fotografias || []);

      const resultado = await this.compararImagenContraLista(
        newHash,
        fotosBD,
        async (fotoBase64) => {
          const cleanFoto = this.limpiarBase64(fotoBase64);
          return Buffer.from(cleanFoto, 'base64');
        }
      );

      return {
        ...resultado,
        source: 'database',
        hash: newHash
      };
    } catch (error) {
      return {
        found: false,
        similarity: 0,
        message: 'Error en validación',
        source: 'database'
      };
    }
  }

  async verificarImagenEnImageKit(imageBase64) {
    try {
      const cleanBase64 = this.limpiarBase64(imageBase64);
      const buffer = Buffer.from(cleanBase64, 'base64');
      
      // Validar imagen antes de continuar
      const esValido = await this.validarImagenBuffer(buffer);
      if (!esValido) {
        return {
          found: false,
          similarity: 0,
          message: 'Imagen no válida',
          source: 'imagekit'
        };
      }

      const newHash = await this.generarHash(buffer);
      const imagenes = await this.imagekit.listFiles({ limit: 1000 });

      const resultado = await this.compararImagenContraLista(
        newHash,
        imagenes,
        async (img) => {
          const response = await fetch(img.url);
          return Buffer.from(await response.arrayBuffer());
        }
      );

      return {
        ...resultado,
        source: 'imagekit'
      };

    } catch (error) {
      return {
        found: false,
        similarity: 0,
        message: 'Error verificando en ImageKit',
        source: 'imagekit'
      };
    }
  }

  /**
   * 
   */
  async verificarImagenDuplicada(imageBase64) {
    const db = await this.verificarImagenEnBaseDatos(imageBase64);
    const kit = await this.verificarImagenEnImageKit(imageBase64);

    if (db.found) {
      return {
        found: true,
        similarity: db.similarity,
        message: `PLAGIO DETECTADO: ${db.similarity}%`,
        source: 'database',
        match: db.match,
        imagekit_result: kit
      };
    }

    if (kit.found) {
      return {
        found: true,
        similarity: kit.similarity,
        message: `Imagen encontrada en internet (${kit.similarity}%)`,
        source: 'internet',
        match: kit.match,
        database_result: db
      };
    }

    return {
      found: false,
      similarity: Math.max(db.similarity, kit.similarity),
      message: "Imagen original",
      source: "original",
      database_result: db,
      imagekit_result: kit
    };
  }
}

module.exports = new InformacionService();