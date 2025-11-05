const proxyService = require('../services/proxyService');

const proxyController = {

  getFotoPortada: async (req, res) => {
    try {
      const { habitacionId } = req.params;
      //trae la ID de la habitación para la URL
      const imageBuffer = await proxyService.getFotoPortada(habitacionId);
      //llama al servicio para obtener la imagen optimizada
      
      res.set('Content-Type', 'image/jpeg');
      res.set('Cache-Control', 'public, max-age=3600');
      //hace que la imagen cache solo dure 1 hora
      res.send(imageBuffer);
      //envia la imagem como respuesta
    } catch (error) {
      res.status(404).json({
        success: false,
        message: error.message
      });
    }
  }
};

module.exports = proxyController;
