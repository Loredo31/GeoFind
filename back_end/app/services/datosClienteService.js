const Usuario = require('../models/UsuarioModel');

class DatosClienteService {
  async registrarUsuario(datosUsuario) {
    try {
      // verificar si el gmail ya existe
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


 async loginUsuario(credenciales) {
  try {
    const { email, password } = credenciales;

    // buscar por gmail
    const usuario = await Usuario.findOne({ email });
    
    if (!usuario) {
      throw new Error('Usuario no encontrado');
    }

    // verifica contraseña
    if (usuario.password !== password) {
      throw new Error('Contraseña incorrecta');
    }

    // devuelve usuario sin contraseña
    const { password: _, ...usuarioSinPassword } = usuario.toObject();
    return usuarioSinPassword;

  } catch (error) {
    throw new Error(`Error ${error.message}`);
  }
}
}

module.exports = new DatosClienteService();