const Usuario = require('../models/User');
const { generarToken } = require('../utils/jwt');

class UsuarioService {
  // Registrar nuevo usuario
  async registrarUsuario(datosUsuario) {
    try {
      // Verificar si el usuario ya existe
      const usuarioExistente = await Usuario.findOne({ email: datosUsuario.email });
      if (usuarioExistente) {
        throw new Error('El usuario ya está registrado');
      }

      // Crear nuevo usuario
      const usuario = new Usuario(datosUsuario);
      await usuario.save();

      // Generar token
      const token = generarToken(usuario._id);

      return {
        usuario: {
          id: usuario._id,
          nombre: usuario.nombre,
          email: usuario.email,
          telefono: usuario.telefono,
          direccion: usuario.direccion,
          edad: usuario.edad,
          ocupacion: usuario.ocupacion,
          role: usuario.role
        },
        token
      };
    } catch (error) {
      throw new Error(`Error al registrar usuario: ${error.message}`);
    }
  }

  // Iniciar sesión
  async iniciarSesion(email, password) {
    try {
      // Buscar usuario por email
      const usuario = await Usuario.findOne({ email, estaActivo: true });
      if (!usuario) {
        throw new Error('Credenciales inválidas');
      }

      // Verificar password
      const esPasswordValido = await usuario.compararPassword(password);
      if (!esPasswordValido) {
        throw new Error('Credenciales inválidas');
      }

      // Generar token
      const token = generarToken(usuario._id);

      return {
        usuario: {
          id: usuario._id,
          nombre: usuario.nombre,
          email: usuario.email,
          telefono: usuario.telefono,
          direccion: usuario.direccion,
          edad: usuario.edad,
          ocupacion: usuario.ocupacion,
          role: usuario.role
        },
        token
      };
    } catch (error) {
      throw new Error(`Error al iniciar sesión: ${error.message}`);
    }
  }

  // Obtener perfil de usuario
  async obtenerPerfil(usuarioId) {
    try {
      const usuario = await Usuario.findById(usuarioId).select('-password');
      if (!usuario) {
        throw new Error('Usuario no encontrado');
      }
      return usuario;
    } catch (error) {
      throw new Error(`Error al obtener perfil: ${error.message}`);
    }
  }

  // Actualizar perfil de usuario
  async actualizarPerfil(usuarioId, datosActualizados) {
    try {
      // No permitir actualizar email o password directamente
      const { email, password, ...datosPermitidos } = datosActualizados;

      const usuario = await Usuario.findByIdAndUpdate(
        usuarioId,
        datosPermitidos,
        { new: true, runValidators: true }
      ).select('-password');

      if (!usuario) {
        throw new Error('Usuario no encontrado');
      }

      return usuario;
    } catch (error) {
      throw new Error(`Error al actualizar perfil: ${error.message}`);
    }
  }

  // Cambiar password
  async cambiarPassword(usuarioId, passwordActual, nuevoPassword) {
    try {
      const usuario = await Usuario.findById(usuarioId);
      if (!usuario) {
        throw new Error('Usuario no encontrado');
      }

      // Verificar password actual
      const esPasswordValido = await usuario.compararPassword(passwordActual);
      if (!esPasswordValido) {
        throw new Error('La contraseña actual es incorrecta');
      }

      // Actualizar password
      usuario.password = nuevoPassword;
      await usuario.save();

      return { mensaje: 'Contraseña actualizada correctamente' };
    } catch (error) {
      throw new Error(`Error al cambiar contraseña: ${error.message}`);
    }
  }
}

module.exports = new UsuarioService();