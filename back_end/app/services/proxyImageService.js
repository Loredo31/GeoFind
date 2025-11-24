const sharp = require('sharp');
const blockhash = require('blockhash-core');
const Informacion = require('../models/InformacionModel');

/**
 * Genera hash perceptual de una imagen
 */
const generateHash = async (imageBuffer) => {
  try {
    // Procesar imagen con sharp
    const { data, info } = await sharp(imageBuffer)
      .resize(256, 256, { fit: 'fill' })
      .raw()
      .toBuffer({ resolveWithObject: true });

    // Generar hash usando blockhash
    const hash = blockhash.bmvbhash({
      data: data,
      width: info.width,
      height: info.height
    }, 16);

    return hash;
  } catch (error) {
    console.error(`❌ Error generando hash: ${error.message}`);
    throw error;
  }
};

/**
 * Calcula la distancia de Hamming entre dos hashes
 */
function hammingDistance(hash1, hash2) {
  if (!hash1 || !hash2 || hash1.length !== hash2.length) {
    return 100; // Máxima diferencia
  }

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
function calculateSimilarity(hash1, hash2) {
  const distance = hammingDistance(hash1, hash2);
  const maxDistance = hash1.length;
  const similarity = ((maxDistance - distance) / maxDistance) * 100;
  return similarity;
}

/**
 * Verifica si una imagen ya existe en la base de datos
 */
const proxyImageSearch = async (imageBase64) => {
  try {
    console.log('📸 Iniciando verificación de imagen...');
    
    // Convertir base64 a buffer
    const imageBuffer = Buffer.from(imageBase64, 'base64');
    console.log(`📦 Buffer creado: ${imageBuffer.length} bytes`);
    
    // Generar hash de la nueva imagen
    const newImageHash = await generateHash(imageBuffer);
    console.log(`🔑 Hash generado: ${newImageHash}`);
    
    // Buscar habitaciones con fotografías
    const habitaciones = await Informacion.find({}, 'fotografias');
    console.log(`🏠 Habitaciones encontradas: ${habitaciones.length}`);
    
    let imagenDuplicada = false;
    let mejorCoincidencia = null;
    let similitudMaxima = 0;
    let imagenesComparadas = 0;
    
    // Si no hay habitaciones, la imagen es original
    if (habitaciones.length === 0) {
      console.log('✅ Primera imagen - no hay comparaciones');
      return {
        found: false,
        similarity: 0,
        message: 'Primera imagen registrada',
        hash: newImageHash
      };
    }
    
    // Comparar con cada imagen existente
    for (const habitacion of habitaciones) {
      if (!habitacion.fotografias || habitacion.fotografias.length === 0) continue;
      
      for (const fotoBase64 of habitacion.fotografias) {
        try {
          const fotoBuffer = Buffer.from(fotoBase64, 'base64');
          const fotoHash = await generateHash(fotoBuffer);
          
          const similitud = calculateSimilarity(newImageHash, fotoHash);
          imagenesComparadas++;
          
          console.log(`🔍 Similitud encontrada: ${similitud.toFixed(2)}%`);
          
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
          console.warn(`⚠️ Error al procesar imagen de BD: ${err.message}`);
        }
      }
    }
    
    console.log(`🔍 Imágenes comparadas: ${imagenesComparadas}`);
    
    // Preparar respuesta
    if (imagenDuplicada) {
      console.log(`❌ Imagen duplicada (${similitudMaxima.toFixed(2)}% similar)`);
      return {
        found: true,
        similarity: similitudMaxima.toFixed(2),
        message: `Imagen duplicada con ${similitudMaxima.toFixed(2)}% de similitud`,
        match: mejorCoincidencia
      };
    }
    
    console.log('✅ Imagen original verificada');
    return {
      found: false,
      similarity: imagenesComparadas > 0 ? similitudMaxima.toFixed(2) : 0,
      message: 'Imagen original - no hay duplicados',
      hash: newImageHash
    };
    
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    console.error(error.stack);
    throw new Error(`Error al procesar imagen: ${error.message}`);
  }
};

module.exports = { proxyImageSearch };