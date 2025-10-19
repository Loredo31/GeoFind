const Usuario = require('../models/UsuarioModel');

class DatosClienteService {
  async registrarUsuario(datosUsuario) {
    try {
      // Verificar si el email ya existe
      const usuarioExistente = await Usuario.findOne({ email: datosUsuario.email });
      if (usuarioExistente) {
        throw new Error('El email ya está registrado');
      }

      const usuario = new Usuario(datosUsuario);
      return await usuario.save();
    } catch (error) {
      throw new Error(`Error al registrar usuario: ${error.message}`);
    }
  }

  async obtenerUsuarioPorId(id) {
    try {
      return await Usuario.findById(id).select('-password');
    } catch (error) {
      throw new Error(`Error al obtener usuario: ${error.message}`);
    }
  }

  async actualizarUsuario(id, datosActualizados) {
    try {
      return await Usuario.findByIdAndUpdate(
        id, 
        datosActualizados, 
        { new: true }
      ).select('-password');
    } catch (error) {
      throw new Error(`Error al actualizar usuario: ${error.message}`);
    }
  }

  async obtenerUsuariosPorRol(rol) {
    try {
      return await Usuario.find({ rol }).select('-password');
    } catch (error) {
      throw new Error(`Error al obtener usuarios: ${error.message}`);
    }
  }
}

module.exports = new DatosClienteService();