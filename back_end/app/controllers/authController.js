const Usuario = require('../models/UsuarioModel');
const DatosClienteService = require('../services/datosClienteService');

class AuthController {
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
       // telefono,
       // direccion
      });

      // Devolver usuario sin password
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

    // Validar campos requeridos
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email y password son requeridos'
      });
    }

    // Llamar al servicio de login
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