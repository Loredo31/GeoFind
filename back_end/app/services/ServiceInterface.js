class ServiceInterface {
  // Declaración abstracta (no implementada)
  async obtenerReseñasPorHabitacion(habitacionId) {
    throw new Error("Método no implementado");
  }

  async obtenerPromedioCalificaciones(habitacionId) {
    throw new Error("Método no implementado");
  }

  async obtenerDatosGraficaBarras(habitacionId) {
    throw new Error("Método no implementado");
  }

  async obtenerDatosGraficaBarrasDobles(habitacionId) {
    throw new Error("Método no implementado");
  }

  async obtenerEvolucionCalificaciones(habitacionId) {
    throw new Error("Método no implementado");
  }

  async obtenerDatosGraficaArea(habitacionId) {
    throw new Error("Método no implementado");
  }

  async obtenerDatosGraficaRadar(habitacionId) {
    throw new Error("Método no implementado");
  }
}

module.exports = ServiceInterface;
