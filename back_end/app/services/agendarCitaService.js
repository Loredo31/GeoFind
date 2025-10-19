const AgendarCita = require('../models/agendarCita');

class AgendarCitaService {
  // Verificar disponibilidad de fecha
  async verificarDisponibilidad(propiedadId, fechaCita) {
    try {
      const estaDisponible = await AgendarCita.verificarDisponibilidad(propiedadId, fechaCita);
      return { disponible: estaDisponible };
    } catch (error) {
      throw new Error(`Error al verificar disponibilidad: ${error.message}`);
    }
  }

  // Agendar nueva cita
  async agendarCita(datosCita) {
    try {
      const { propiedadId, fechaCita, usuarioId } = datosCita;

      // Verificar disponibilidad
      const estaDisponible = await AgendarCita.verificarDisponibilidad(propiedadId, fechaCita);
      if (!estaDisponible) {
        throw new Error('La fecha seleccionada no está disponible. Por favor elige otra fecha.');
      }

      // Crear nueva cita
      const nuevaCita = new AgendarCita({
        usuario: usuarioId,
        propiedad: propiedadId,
        fechaCita: fechaCita,
        estado: 'pendiente',
        disponible: false // Se marca como no disponible al agendar
      });

      await nuevaCita.save();
      await nuevaCita.populate('usuario', 'nombre email telefono');
      await nuevaCita.populate('propiedad', 'nombre direccion');

      return nuevaCita;
    } catch (error) {
      if (error.code === 11000) {
        throw new Error('Ya existe una cita para esta propiedad en la fecha seleccionada');
      }
      throw new Error(`Error al agendar cita: ${error.message}`);
    }
  }

  // Obtener citas por usuario
  async obtenerCitasPorUsuario(usuarioId) {
    try {
      const citas = await AgendarCita.find({ usuario: usuarioId })
        .populate('usuario', 'nombre email telefono')
        .populate('propiedad', 'nombre direccion precio')
        .sort({ fechaCita: 1 });

      return citas;
    } catch (error) {
      throw new Error(`Error al obtener citas: ${error.message}`);
    }
  }

  // Obtener todas las citas pendientes para el componente aleatorio
  async obtenerCitasPendientes() {
    try {
      const citas = await AgendarCita.find({ estado: 'pendiente' })
        .populate('usuario', 'nombre email telefono')
        .populate('propiedad', 'nombre direccion')
        .sort({ fechaCreacion: 1 });

      return citas;
    } catch (error) {
      throw new Error(`Error al obtener citas pendientes: ${error.message}`);
    }
  }

  // Componente aleatorio para aceptar/rechazar citas (automático)
  async procesarDecisionAleatoria(citaId) {
    try {
      const cita = await AgendarCita.findById(citaId);
      if (!cita) {
        throw new Error('Cita no encontrada');
      }

      if (cita.estado !== 'pendiente') {
        throw new Error('La cita ya ha sido procesada');
      }

      // Decision aleatoria 50/50
      const decision = Math.random() > 0.5 ? 'aceptada' : 'rechazada';
      const motivo = decision === 'rechazada' ? 'Decisión automática del sistema' : '';

      await cita.cambiarEstado(decision, motivo);

      return {
        cita: await cita.populate('usuario', 'nombre email'),
        decision,
        motivo
      };
    } catch (error) {
      throw new Error(`Error al procesar decisión: ${error.message}`);
    }
  }

  // Procesar TODAS las citas pendientes automáticamente
  async procesarTodasCitasPendientes() {
    try {
      const citasPendientes = await this.obtenerCitasPendientes();
      const resultados = [];

      for (const cita of citasPendientes) {
        try {
          const resultado = await this.procesarDecisionAleatoria(cita._id);
          resultados.push(resultado);
        } catch (error) {
          resultados.push({
            citaId: cita._id,
            error: error.message
          });
        }
      }

      return resultados;
    } catch (error) {
      throw new Error(`Error al procesar citas pendientes: ${error.message}`);
    }
  }

  // Cancelar cita (solo usuario que la creó)
  async cancelarCita(citaId, usuarioId) {
    try {
      const cita = await AgendarCita.findOne({ _id: citaId, usuario: usuarioId });
      if (!cita) {
        throw new Error('Cita no encontrada o no autorizada');
      }

      if (cita.estado === 'aceptada') {
        throw new Error('No se puede cancelar una cita ya aceptada');
      }

      await cita.cambiarEstado('cancelada', 'Cancelada por el usuario');
      return cita;
    } catch (error) {
      throw new Error(`Error al cancelar cita: ${error.message}`);
    }
  }

  // Obtener fechas disponibles de una propiedad
  async obtenerFechasDisponibles(propiedadId, fechaInicio, fechaFin) {
    try {
      const citasOcupadas = await AgendarCita.find({
        propiedad: propiedadId,
        fechaCita: {
          $gte: new Date(fechaInicio),
          $lte: new Date(fechaFin)
        },
        disponible: false,
        estado: { $in: ['pendiente', 'aceptada'] }
      }).select('fechaCita');

      const fechasOcupadas = citasOcupadas.map(cita => cita.fechaCita.toISOString().split('T')[0]);
      
      return { fechasOcupadas };
    } catch (error) {
      throw new Error(`Error al obtener fechas disponibles: ${error.message}`);
    }
  }
}

module.exports = new AgendarCitaService();