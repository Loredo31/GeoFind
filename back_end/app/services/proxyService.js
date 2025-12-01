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
    console.log("\n🔍 BUSCANDO CLAVE EN CACHE:", clave);

    const datosCache = this.cache.get(clave);

    if (datosCache !== undefined) {
      console.log("📦 CACHE HIT →", clave);
      return datosCache;
    }

    console.log("🐢 CACHE MISS → Petición REAL para:", clave);

    const datos = await obtenerDatosCallback();

    this.cache.set(clave, datos, ttl);
    console.log("💾 GUARDADO EN CACHE →", clave);

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

    claves.forEach(clave => {
      this.cache.del(clave);
      console.log("🧹 CACHE LIMPIADO →", clave);
    });
  }

    /**
   * PROXY VERIFICADOR DE IMÁGENES
   */
   async verificarImagenDuplicada(imageBase64) {
  //   // Validación superficial antes de llamar al servicio real
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
