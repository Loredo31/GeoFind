const ProxyService = require('../services/proxyService');

class InformacionController {
  async crearInformacion(req, res) {
    try {
      const datos = req.body;
      const informacion = await InformacionService.crearInformacion(datos);
      
      res.status(201).json({
        success: true,
        message: 'Información creada exitosamente',
        data: informacion
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerInformacionArrendador(req, res) {
    try {
      const { arrendadorId } = req.params;
      const informacion = await InformacionService.obtenerInformacionPorArrendador(arrendadorId);
      
      res.json({
        success: true,
        data: informacion
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerTodasLasHabitaciones(req, res) {
    try {
      const habitaciones = await InformacionService.obtenerTodasLasHabitaciones();
      
      res.json({
        success: true,
        data: habitaciones
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async actualizarInformacion(req, res) {
    try {
      const { id } = req.params;
      const datos = req.body;
      const informacion = await InformacionService.actualizarInformacion(id, datos);
      
      res.json({
        success: true,
        message: 'Información actualizada exitosamente',
        data: informacion
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async eliminarInformacion(req, res) {
    try {
      const { id } = req.params;
      await InformacionService.eliminarInformacion(id);
      
      res.json({
        success: true,
        message: 'Información eliminada exitosamente'
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  // ==========   MÉTODO DE PROCESAMIENTO DE IMÁGENES   ==========

  async verificarImagenDuplicada(req, res) {
    try {
      const { imageBase64 } = req.body;
      
      // Validar que se reciba la imagen
      if (!imageBase64) {
        return res.status(400).json({ 
          success: false,
          message: 'La imagen es requerida' 
        });
      }
            
      // Usar proxy como intermediario
      const resultado = await ProxyService.verificarImagenDuplicada(imageBase64);
      
      return res.status(200).json({ 
        success: true,
        data: resultado
      });
      
    } catch (error) {
      console.error(`Error en controlador: ${error.message}`);
      return res.status(500).json({ 
        success: false,
        message: error.message 
      });
    }
  }
}

module.exports = new InformacionController();