const usuarioService = require('../services/usuarioService');

const usuarioController = {
  // Registrar nuevo usuario
  registrar: async (req, res) => {
    try {
      const resultado = await usuarioService.registrarUsuario(req.body);
      res.status(201).json({
        success: true,
        message: 'Usuario registrado exitosamente',
        data: resultado
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Iniciar sesión
  login: async (req, res) => {
    try {
      const { email, password } = req.body;
      const resultado = await usuarioService.iniciarSesion(email, password);
      res.status(200).json({
        success: true,
        message: 'Inicio de sesión exitoso',
        data: resultado
      });
    } catch (error) {
      res.status(401).json({
        success: false,
        message: error.message
      });
    }
  },

  // Obtener perfil
  obtenerPerfil: async (req, res) => {
    try {
      const usuario = await usuarioService.obtenerPerfil(req.usuario.id);
      res.status(200).json({
        success: true,
        data: usuario
      });
    } catch (error) {
      res.status(404).json({
        success: false,
        message: error.message
      });
    }
  },

  // Actualizar perfil
  actualizarPerfil: async (req, res) => {
    try {
      const usuario = await usuarioService.actualizarPerfil(req.usuario.id, req.body);
      res.status(200).json({
        success: true,
        message: 'Perfil actualizado exitosamente',
        data: usuario
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  },

  // Cambiar password
  cambiarPassword: async (req, res) => {
    try {
      const { passwordActual, nuevoPassword } = req.body;
      const resultado = await usuarioService.cambiarPassword(
        req.usuario.id, 
        passwordActual, 
        nuevoPassword
      );
      res.status(200).json({
        success: true,
        message: resultado.mensaje
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        message: error.message
      });
    }
  }
};

module.exports = usuarioController;