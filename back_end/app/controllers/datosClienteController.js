const DatosClienteService = require('../services/datosClienteService');

class DatosClienteController {
  async obtenerUsuario(req, res) {
    try {
      const { id } = req.params;
      const usuario = await DatosClienteService.obtenerUsuarioPorId(id);
      
      res.json({
        success: true,
        data: usuario
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async actualizarUsuario(req, res) {
    try {
      const { id } = req.params;
      const datos = req.body;
      const usuario = await DatosClienteService.actualizarUsuario(id, datos);
      
      res.json({
        success: true,
        message: 'Usuario actualizado exitosamente',
        data: usuario
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerUsuariosPorRol(req, res) {
    try {
      const { rol } = req.params;
      const usuarios = await DatosClienteService.obtenerUsuariosPorRol(rol);
      
      res.json({
        success: true,
        data: usuarios
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new DatosClienteController();