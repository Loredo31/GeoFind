const { proxyImageSearch } = require("../services/proxyImageService");

const proxyImageController = async (req, res) => {
  try {
    const { imageBase64 } = req.body;
    
    if (!imageBase64) {
      return res.status(400).json({ 
        ok: false, 
        message: 'La imagen es requerida' 
      });
    }
    
    console.log('📨 Solicitud recibida para verificar imagen');
    
    const resultado = await proxyImageSearch(imageBase64);
    
    return res.status(200).json({ 
      ok: true, 
      result: resultado
    });
    
  } catch (error) {
    console.error(`❌ Error en controlador: ${error.message}`);
    return res.status(500).json({ 
      ok: false, 
      message: error.message 
    });
  }
};

module.exports = { proxyImageController };