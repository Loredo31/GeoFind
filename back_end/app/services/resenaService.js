const Resena = require('../models/resena');

class ResenaService {
  // Crear nueva reseña
  async crearResena(datosResena) {
    try {
      const { usuarioId, propiedadId, nombre, comentario, tiempoEstancia, calificacion, fechaInicio, fechaFin } = datosResena;

      // Verificar si el usuario ya hizo reseña para esta propiedad
      const resenaExistente = await Resena.findOne({
        usuario: usuarioId,
        propiedad: propiedadId
      });

      if (resenaExistente) {
        throw new Error('Ya has realizado una reseña para esta propiedad');
      }

      // Crear nueva reseña
      const nuevaResena = new Resena({
        usuario: usuarioId,
        propiedad: propiedadId,
        nombre,
        comentario,
        tiempoEstancia,
        calificacion,
        fechaInicio,
        fechaFin
      });

      await nuevaResena.save();
      await nuevaResena.populate('usuario', 'nombre email');
      await nuevaResena.populate('propiedad', 'nombre direccion');

      // Actualizar el promedio de calificaciones de la propiedad
      await this.actualizarPromedioCalificacion(propiedadId);

      return nuevaResena;
    } catch (error) {
      if (error.code === 11000) {
        throw new Error('Ya has realizado una reseña para esta propiedad');
      }
      throw new Error(`Error al crear reseña: ${error.message}`);
    }
  }

  // Obtener reseñas por propiedad
  async obtenerResenasPorPropiedad(propiedadId) {
    try {
      const resenas = await Resena.find({
        propiedad: propiedadId,
        estaActiva: true
      })
        .populate('usuario', 'nombre email')
        .sort({ fechaCreacion: -1 });

      return resenas;
    } catch (error) {
      throw new Error(`Error al obtener reseñas: ${error.message}`);
    }
  }

  // Obtener reseñas por usuario
  async obtenerResenasPorUsuario(usuarioId) {
    try {
      const resenas = await Resena.find({ usuario: usuarioId })
        .populate('propiedad', 'nombre direccion')
        .sort({ fechaCreacion: -1 });

      return resenas;
    } catch (error) {
      throw new Error(`Error al obtener reseñas del usuario: ${error.message}`);
    }
  }

  // Obtener todas las reseñas (con filtros)
  async obtenerTodasResenas(filtros = {}) {
    try {
      const { propiedadId, usuarioId, calificacionMin } = filtros;
      let query = { estaActiva: true };

      if (propiedadId) query.propiedad = propiedadId;
      if (usuarioId) query.usuario = usuarioId;
      if (calificacionMin) query.calificacion = { $gte: parseInt(calificacionMin) };

      const resenas = await Resena.find(query)
        .populate('usuario', 'nombre email')
        .populate('propiedad', 'nombre direccion')
        .sort({ fechaCreacion: -1 });

      return resenas;
    } catch (error) {
      throw new Error(`Error al obtener todas las reseñas: ${error.message}`);
    }
  }

  // Obtener promedio de calificaciones de una propiedad
  async obtenerPromedioPropiedad(propiedadId) {
    try {
      const promedio = await Resena.obtenerPromedioCalificacion(propiedadId);
      return promedio;
    } catch (error) {
      throw new Error(`Error al obtener promedio: ${error.message}`);
    }
  }

  // Actualizar reseña
  async actualizarResena(resenaId, usuarioId, datosActualizados) {
    try {
      const resena = await Resena.findOne({
        _id: resenaId,
        usuario: usuarioId
      });

      if (!resena) {
        throw new Error('Reseña no encontrada o no autorizada');
      }

      // Actualizar campos permitidos
      const camposPermitidos = ['comentario', 'calificacion', 'tiempoEstancia'];
      camposPermitidos.forEach(campo => {
        if (datosActualizados[campo] !== undefined) {
          resena[campo] = datosActualizados[campo];
        }
      });

      await resena.save();
      
      // Actualizar promedio de calificaciones
      await this.actualizarPromedioCalificacion(resena.propiedad);

      return resena;
    } catch (error) {
      throw new Error(`Error al actualizar reseña: ${error.message}`);
    }
  }

  // Eliminar reseña (soft delete)
  async eliminarResena(resenaId, usuarioId) {
    try {
      const resena = await Resena.findOne({
        _id: resenaId,
        usuario: usuarioId
      });

      if (!resena) {
        throw new Error('Reseña no encontrada o no autorizada');
      }

      resena.estaActiva = false;
      await resena.save();

      // Actualizar promedio de calificaciones
      await this.actualizarPromedioCalificacion(resena.propiedad);

      return resena;
    } catch (error) {
      throw new Error(`Error al eliminar reseña: ${error.message}`);
    }
  }

  // Actualizar promedio de calificaciones (método interno)
  async actualizarPromedioCalificacion(propiedadId) {
    try {
      // Este método se llama automáticamente cuando se crea/actualiza/elimina una reseña
      // Podrías guardar el promedio en el modelo de propiedad si lo necesitas
      const promedio = await this.obtenerPromedioPropiedad(propiedadId);
      
      // Aquí podrías actualizar el promedio en el modelo Informacion si lo deseas
      // await Informacion.findByIdAndUpdate(propiedadId, {
      //   promedioCalificacion: promedio.promedioCalificacion,
      //   totalResenas: promedio.totalResenas
      // });

      return promedio;
    } catch (error) {
      console.error('Error al actualizar promedio:', error);
    }
  }

  // Obtener reseñas recientes
  async obtenerResenasRecientes(limite = 10) {
    try {
      const resenas = await Resena.find({ estaActiva: true })
        .populate('usuario', 'nombre')
        .populate('propiedad', 'nombre direccion')
        .sort({ fechaCreacion: -1 })
        .limit(parseInt(limite));

      return resenas;
    } catch (error) {
      throw new Error(`Error al obtener reseñas recientes: ${error.message}`);
    }
  }
}

module.exports = new ResenaService();