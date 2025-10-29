const Usuario = require('../models/UsuarioModel');
const DatosClienteService = require('../services/datosClienteService');

class AuthController {
  async register(req, res) {
    try {
      const { nombre, email, password, rol, telefono, direccion } = req.body;

      // valida rol
      if (!['arrendador', 'arrendatario'].includes(rol)) {
        return res.status(400).json({
          success: false,
          message: 'Rol inválido. Debe ser "arrendador" o "arrendatario"'
        });
      }

      const usuario = await DatosClienteService.registrarUsuario({
        nombre,
        email,
        password, 
        rol,
      });

      // Devolver usuario 
      const usuarioSinPassword = {
        _id: usuario._id,
        nombre: usuario.nombre,
        email: usuario.email,
        rol: usuario.rol,
       // telefono: usuario.telefono,
        //direccion: usuario.direccion
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

  async login(req, res) {
  try {
    const { email, password } = req.body;

    // valida campos
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email y password son requeridos'
      });
    }

    // llama al servicio
    const usuario = await DatosClienteService.loginUsuario({
      email,
      password
    });

    res.json({
      success: true,
      message: 'Login exitoso',
      usuario: usuario
    });

  } catch (error) {
    res.status(400).json({
      success: false,
      message: error.message
    });
  }
}
}

module.exports = new AuthController();