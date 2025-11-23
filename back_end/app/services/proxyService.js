const NodeCache = require("node-cache");
const Reseña = require("../models/ReseñaModel");

// Servicio Proxy que maneja el caché de datos para evitar consultas repetidas a la base de datos
class ProxyService {
  constructor() {
    // Se inicializa el cache con TTL estándar de 5 minutos
    this.cache = new NodeCache({
      stdTTL: 300, // Tiempo de vida por defecto (5 minutos)
      checkperiod: 60, // Intervalo para limpiar datos expirados
    });
  }

  // Método genérico para obtener datos desde cache o desde una función que consulta la BD
  async obtenerConCache(clave, funcionObtener, ttl = 300) {
    let datos = this.cache.get(clave);

    // Si no existen datos en el cache, se ejecuta la función para obtenerlos
    if (datos == undefined) {
      datos = await funcionObtener();
      this.cache.set(clave, datos, ttl); // Se guarda en el cache
    }

    return datos;
  }

  // Obtiene las reseñas de una habitación utilizando cache
  async obtenerReseñasHabitacion(habitacionId) {
    const clave = `reseñas_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      // Consulta a la base de datos y ordena por fecha descendente
      return await Reseña.find({ habitacionId }).sort({ fechaReseña: -1 });
    });
  }

  // Calcula y retorna los promedios de las calificaciones de una habitación
  async obtenerPromediosHabitacion(habitacionId) {
    const clave = `promedios_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      const reseñas = await Reseña.find({ habitacionId });

      if (reseñas.length === 0) {
        return null; // Si no hay reseñas, no hay promedios
      }

      // Inicialización de acumuladores
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

      // Acumular valores
      reseñas.forEach((reseña) => {
        promedios.general += reseña.calificacionGeneral;
        promedios.limpieza += reseña.calificacionesDetalladas.limpieza;
        promedios.ubicacion += reseña.calificacionesDetalladas.ubicacion;
        promedios.comodidad += reseña.calificacionesDetalladas.comodidad;
        promedios.precio += reseña.calificacionesDetalladas.precio;
        promedios.atencion += reseña.calificacionesDetalladas.atencion;
        promedios.arrendatario += reseña.calificacionArrendatario;
      });

      // Calcular promedios finales
      const total = reseñas.length;
      Object.keys(promedios).forEach((key) => {
        if (key !== "totalResenas") {
          promedios[key] = Number((promedios[key] / total).toFixed(1));
        }
      });

      return promedios;
    });
  }

// Datos para gráfica de barras dobles (arrendador vs cuarto) 
async obtenerDatosGraficaBarrasDobles(habitacionId) {
  const clave = `barrasDobles_${habitacionId}`;
  return this.obtenerConCache(clave, async () => {
    const reseñas = await Reseña.find({ habitacionId })
      .sort({ fechaReseña: -1 }) 
      .limit(7); // Solo últimas 7

    if (reseñas.length === 0) return [];

    // Invertir para mostrar en orden cronológico (más antigua a más reciente)
    const reseñasOrdenadas = reseñas.reverse();

    return reseñasOrdenadas.map((reseña, index) => ({
      califArrendador: reseña.calificacionArrendatario,  // Calificación arrendador
      califCuarto: reseña.calificacionGeneral,  // Calificación cuarto/general
      nombre: reseña.nombre,
      fecha: reseña.fechaReseña,
      indice: index + 1, 
    }));
  });
}

  // Obtiene la evolución en el tiempo de las calificaciones
  async obtenerEvolucionCalificaciones(habitacionId) {
    const clave = `evolucion_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      const reseñas = await Reseña.find({ habitacionId }).sort({
        fechaReseña: 1, // Orden ascendente por fecha
      });

      // Se estructura por índice y detalle
      return reseñas.map((reseña, index) => ({
        fecha: reseña.fechaReseña,
        calificacion: reseña.calificacionGeneral,
        usuario: reseña.nombre,
        indice: index + 1,
        detalles: {
          limpieza: reseña.calificacionesDetalladas.limpieza,
          ubicacion: reseña.calificacionesDetalladas.ubicacion,
          comodidad: reseña.calificacionesDetalladas.comodidad,
          precio: reseña.calificacionesDetalladas.precio,
          atencion: reseña.calificacionesDetalladas.atencion,
        },
      }));
    });
  }

  // Construye datos para la gráfica de barras 
  async obtenerDatosGraficaBarras(habitacionId) {
    const clave = `barras_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      const promedios = await this.obtenerPromediosHabitacion(habitacionId);

      if (!promedios) return null;

      return [
        { categoria: "General", valor: promedios.general },
        { categoria: "Limpieza", valor: promedios.limpieza },
        { categoria: "Ubicación", valor: promedios.ubicacion },
        { categoria: "Comodidad", valor: promedios.comodidad },
        { categoria: "Precio", valor: promedios.precio },
        { categoria: "Atención", valor: promedios.atencion },
        { categoria: "Arrendatario", valor: promedios.arrendatario },
      ];
    });
  }

  // Datos para una gráfica de área 
  async obtenerDatosGraficaArea(habitacionId) {
    const clave = `area_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      const reseñas = await Reseña.find({ habitacionId }).sort({
        fechaReseña: 1,
      });

      if (reseñas.length === 0) return null;

      let sumaAcumulada = 0;
      return reseñas.map((reseña, index) => {
        sumaAcumulada += reseña.calificacionGeneral;
        const promedioAcumulado = sumaAcumulada / (index + 1);

        return {
          fecha: reseña.fechaReseña,
          calificacionActual: reseña.calificacionGeneral,
          promedioAcumulado: Number(promedioAcumulado.toFixed(2)),
          indice: index + 1,
        };
      });
    });
  }

  // Elimina del cache todos los datos relacionados 
  limpiarCacheHabitacion(habitacionId) {
    const patrones = [
      `reseñas_${habitacionId}`,
      `promedios_${habitacionId}`,
      `barrasDobles_${habitacionId}`,
      `evolucion_${habitacionId}`,
      `barras_${habitacionId}`,
      `area_${habitacionId}`,
    ];

    // Se eliminan todas las claves del cache
    patrones.forEach((patron) => {
      this.cache.del(patron);
    });
  }

  // Datos para una gráfica de radar
  async obtenerDatosGraficaRadar(habitacionId) {
    const clave = `radar_${habitacionId}`;
    return this.obtenerConCache(clave, async () => {
      const promedios = await this.obtenerPromediosHabitacion(habitacionId);

      if (!promedios) return null;

      return [
        {
          categoria: "Limpieza",
          valor: promedios.limpieza,
          maxValor: 5.0,
        },
        {
          categoria: "Ubicación",
          valor: promedios.ubicacion,
          maxValor: 5.0,
        },
        {
          categoria: "Comodidad",
          valor: promedios.comodidad,
          maxValor: 5.0,
        },
        {
          categoria: "Precio",
          valor: promedios.precio,
          maxValor: 5.0,
        },
        {
          categoria: "Atención",
          valor: promedios.atencion,
          maxValor: 5.0,
        },
        {
          categoria: "Arrendatario",
          valor: promedios.arrendatario,
          maxValor: 5.0,
        },
      ];
    });
  }
}

module.exports = new ProxyService();
