const Usuario = require('../models/UsuarioModel');
const DatosClienteService = require('../services/datosClienteService');

class AuthController {
  async login(req, res) {
    try {
      const { email, password } = req.body;

      // Buscar usuario por email
      const usuario = await Usuario.findOne({ email });
      
      if (!usuario) {
        return res.status(400).json({
          success: false,
          message: 'Usuario no encontrado'
        });
      }

      // Verificar contraseña (sin encriptación por ahora)
      if (usuario.password !== password) {
        return res.status(400).json({
          success: false,
          message: 'Contraseña incorrecta'
        });
      }

      // Devolver datos del usuario (sin password)
      const usuarioSinPassword = {
        _id: usuario._id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol,
        telefono: usuario.telefono,
        direccion: usuario.direccion
      };

      res.json({
        success: true,
        message: 'Login exitoso',
        usuario: usuarioSinPassword
      });

    } catch (error) {
      res.status(500).json({
        success: false,
        message: `Error en el login: ${error.message}`
      });
    }
  }

  async register(req, res) {
    try {
      const { nombre, email, password, rol, telefono, direccion } = req.body;

      // Validar que el rol sea válido
      if (!['arrendador', 'arrendatario'].includes(rol)) {
        return res.status(400).json({
          success: false,
          message: 'Rol inválido. Debe ser "arrendador" o "arrendatario"'
        });
      }

      const usuario = await DatosClienteService.registrarUsuario({
        nombre,
        email,
        password, // Sin encriptar por ahora
        rol,
        telefono,
        direccion
      });

      // Devolver usuario sin password
      const usuarioSinPassword = {
        _id: usuario._id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol,
        telefono: usuario.telefono,
        direccion: usuario.direccion
      };

      res.status(201).json({
        success: true,
        message: 'Usuario registrado exitosamente',
        usuario: usuarioSinPassword
      });

    } catch (error) {
      res.status(500).json({
        success: false,
        message: `Error en el registro: ${error.message}`
      });
    }
  }
}

module.exports = new AuthController();