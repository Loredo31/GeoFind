const Informacion = require('../models/informacion');

class InformacionService {
  // Crear nueva propiedad
  async crearPropiedad(datosPropiedad) {
    try {
      const propiedad = new Informacion(datosPropiedad);
      await propiedad.save();
      return propiedad;
    } catch (error) {
      throw new Error(`Error al crear propiedad: ${error.message}`);
    }
  }

  // Obtener todas las propiedades
  async obtenerTodasPropiedades(filtros = {}) {
    try {
      const { 
        ciudad, 
        costoMin, 
        costoMax, 
        habitaciones,
        estaDisponible = true 
      } = filtros;

      let query = { estaActiva: true };

      if (ciudad) query['direccion.ciudad'] = new RegExp(ciudad, 'i');
      if (costoMin || costoMax) {
        query.costo = {};
        if (costoMin) query.costo.$gte = parseInt(costoMin);
        if (costoMax) query.costo.$lte = parseInt(costoMax);
      }
      if (habitaciones) query.habitaciones = parseInt(habitaciones);
      if (estaDisponible !== undefined) query.estaDisponible = estaDisponible;

      const propiedades = await Informacion.find(query)
        .sort({ fechaCreacion: -1 });

      return propiedades;
    } catch (error) {
      throw new Error(`Error al obtener propiedades: ${error.message}`);
    }
  }

  // Obtener propiedad por ID
  async obtenerPropiedadPorId(propiedadId) {
    try {
      const propiedad = await Informacion.findById(propiedadId);
      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }
      return propiedad;
    } catch (error) {
      throw new Error(`Error al obtener propiedad: ${error.message}`);
    }
  }

  // Actualizar propiedad
  async actualizarPropiedad(propiedadId, datosActualizados) {
    try {
      const propiedad = await Informacion.findByIdAndUpdate(
        propiedadId,
        datosActualizados,
        { new: true, runValidators: true }
      );

      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }

      return propiedad;
    } catch (error) {
      throw new Error(`Error al actualizar propiedad: ${error.message}`);
    }
  }

  // Eliminar propiedad (soft delete)
  async eliminarPropiedad(propiedadId) {
    try {
      const propiedad = await Informacion.findByIdAndUpdate(
        propiedadId,
        { estaActiva: false },
        { new: true }
      );

      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }

      return propiedad;
    } catch (error) {
      throw new Error(`Error al eliminar propiedad: ${error.message}`);
    }
  }

  // Agregar foto a propiedad
  async agregarFoto(propiedadId, datosFoto) {
    try {
      const propiedad = await Informacion.findById(propiedadId);
      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }

      propiedad.fotos.push(datosFoto);
      await propiedad.save();

      return propiedad;
    } catch (error) {
      throw new Error(`Error al agregar foto: ${error.message}`);
    }
  }

  // Eliminar foto de propiedad
  async eliminarFoto(propiedadId, fotoId) {
    try {
      const propiedad = await Informacion.findById(propiedadId);
      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }

      propiedad.fotos = propiedad.fotos.filter(foto => 
        foto._id.toString() !== fotoId
      );

      await propiedad.save();
      return propiedad;
    } catch (error) {
      throw new Error(`Error al eliminar foto: ${error.message}`);
    }
  }

  // Marcar foto como principal
  async marcarFotoPrincipal(propiedadId, fotoId) {
    try {
      const propiedad = await Informacion.findById(propiedadId);
      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }

      // Quitar principal de todas las fotos
      propiedad.fotos.forEach(foto => {
        foto.esPrincipal = foto._id.toString() === fotoId;
      });

      await propiedad.save();
      return propiedad;
    } catch (error) {
      throw new Error(`Error al marcar foto como principal: ${error.message}`);
    }
  }

  // Buscar propiedades por ubicación
  async buscarPorUbicacion(ciudad, estado) {
    try {
      let query = { estaActiva: true };
      
      if (ciudad) query['direccion.ciudad'] = new RegExp(ciudad, 'i');
      if (estado) query['direccion.estado'] = new RegExp(estado, 'i');

      const propiedades = await Informacion.find(query)
        .select('nombre direccion costo fotos servicios')
        .sort({ costo: 1 });

      return propiedades;
    } catch (error) {
      throw new Error(`Error al buscar propiedades: ${error.message}`);
    }
  }

  // Obtener propiedades con servicios específicos
  async obtenerPorServicios(servicios = []) {
    try {
      const propiedades = await Informacion.find({
        estaActiva: true,
        servicios: { $in: servicios }
      });

      return propiedades;
    } catch (error) {
      throw new Error(`Error al obtener propiedades por servicios: ${error.message}`);
    }
  }

  // Actualizar disponibilidad
  async actualizarDisponibilidad(propiedadId, estaDisponible) {
    try {
      const propiedad = await Informacion.findByIdAndUpdate(
        propiedadId,
        { estaDisponible },
        { new: true }
      );

      if (!propiedad) {
        throw new Error('Propiedad no encontrada');
      }

      return propiedad;
    } catch (error) {
      throw new Error(`Error al actualizar disponibilidad: ${error.message}`);
    }
  }
}

module.exports = new InformacionService();