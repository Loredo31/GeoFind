const ReservaCuarto = require('../models/reservaCuarto');
const Informacion = require('../models/informacion');
const Usuario = require('../models/usuario');

class ReservaCuartoService {
  // Crear nueva reserva
  async crearReserva(datosReserva) {
    try {
      const { usuarioId, propiedadId, datosPersonales, referencias, fechaInicio, fechaFin } = datosReserva;

      // Verificar que la propiedad existe y obtener información
      const propiedad = await Informacion.findById(propiedadId);
      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }

      if (!propiedad.estaDisponible) {
        throw new Error('La propiedad no está disponible para reservar');
      }

      // Verificar que el usuario existe
      const usuario = await Usuario.findById(usuarioId);
      if (!usuario) {
        throw new Error('Usuario no encontrado');
      }

      // Crear nueva reserva
      const nuevaReserva = new ReservaCuarto({
        usuario: usuarioId,
        propiedad: propiedadId,
        datosPersonales: {
          ...datosPersonales,
          // Asegurar que el email coincida con el usuario
          email: usuario.email
        },
        referencias: referencias,
        fechaInicioReserva: fechaInicio,
        fechaFinReserva: fechaFin,
        rentaMensual: propiedad.costo,
        depositoGarantia: propiedad.costo * 2 // 2 meses de depósito
      });

      await nuevaReserva.save();
      await nuevaReserva.populate('usuario', 'nombre email telefono');
      await nuevaReserva.populate('propiedad', 'nombre direccion costo servicios');

      return nuevaReserva;
    } catch (error) {
      throw new Error(`Error al crear reserva: ${error.message}`);
    }
  }

  // Obtener reservas por usuario
  async obtenerReservasPorUsuario(usuarioId) {
    try {
      const reservas = await ReservaCuarto.find({ usuario: usuarioId })
        .populate('usuario', 'nombre email telefono')
        .populate('propiedad', 'nombre direccion costo')
        .sort({ fechaSolicitud: -1 });

      return reservas;
    } catch (error) {
      throw new Error(`Error al obtener reservas: ${error.message}`);
    }
  }

  // Obtener todas las reservas pendientes para el componente aleatorio
  async obtenerReservasPendientes() {
    try {
      const reservas = await ReservaCuarto.find({ estado: 'pendiente' })
        .populate('usuario', 'nombre email telefono')
        .populate('propiedad', 'nombre direccion costo')
        .sort({ fechaSolicitud: 1 });

      return reservas;
    } catch (error) {
      throw new Error(`Error al obtener reservas pendientes: ${error.message}`);
    }
  }

  // Componente aleatorio para aceptar/rechazar reservas
  async procesarDecisionAleatoria(reservaId) {
    try {
      const reserva = await ReservaCuarto.findById(reservaId)
        .populate('usuario')
        .populate('propiedad');

      if (!reserva) {
        throw new Error('Reserva no encontrada');
      }

      if (reserva.estado !== 'pendiente') {
        throw new Error('La reserva ya ha sido procesada');
      }

      // Decisión aleatoria 50/50
      const decision = Math.random() > 0.5 ? 'aceptada' : 'rechazada';
      const motivo = decision === 'rechazada' ? 'Decisión automática del sistema' : '';

      await reserva.cambiarEstado(decision, motivo);

      return {
        reserva,
        decision,
        motivo
      };
    } catch (error) {
      throw new Error(`Error al procesar decisión: ${error.message}`);
    }
  }

  // Procesar TODAS las reservas pendientes automáticamente
  async procesarTodasReservasPendientes() {
    try {
      const reservasPendientes = await this.obtenerReservasPendientes();
      const resultados = [];

      for (const reserva of reservasPendientes) {
        try {
          const resultado = await this.procesarDecisionAleatoria(reserva._id);
          resultados.push(resultado);
        } catch (error) {
          resultados.push({
            reservaId: reserva._id,
            error: error.message
          });
        }
      }

      return resultados;
    } catch (error) {
      throw new Error(`Error al procesar reservas pendientes: ${error.message}`);
    }
  }

  // Obtener reserva por ID
  async obtenerReservaPorId(reservaId) {
    try {
      const reserva = await ReservaCuarto.findById(reservaId)
        .populate('usuario')
        .populate('propiedad');

      if (!reserva) {
        throw new Error('Reserva no encontrada');
      }

      return reserva;
    } catch (error) {
      throw new Error(`Error al obtener reserva: ${error.message}`);
    }
  }

  // Cancelar reserva (solo usuario que la creó)
  async cancelarReserva(reservaId, usuarioId) {
    try {
      const reserva = await ReservaCuarto.findOne({ _id: reservaId, usuario: usuarioId });
      if (!reserva) {
        throw new Error('Reserva no encontrada o no autorizada');
      }

      if (reserva.estado === 'aceptada') {
        throw new Error('No se puede cancelar una reserva ya aceptada');
      }

      await reserva.cambiarEstado('cancelada', 'Cancelada por el usuario');
      return reserva;
    } catch (error) {
      throw new Error(`Error al cancelar reserva: ${error.message}`);
    }
  }
}

module.exports = new ReservaCuartoService();