const express = require('express');
const router = express.Router();
const InformacionController = require('../controllers/informacionController');

// crear habitación
router.post('/', InformacionController.crearInformacion);
// obtener información arrendador
router.get('/arrendador/:arrendadorId', InformacionController.obtenerInformacionArrendador);
// obtener habitaciones
router.get('/', InformacionController.obtenerTodasLasHabitaciones);
// actualizar 
router.put('/:id', InformacionController.actualizarInformacion);
// eliminar
router.delete('/:id', InformacionController.eliminarInformacion);
// verificar si existe imagen similar
router.post('/proxy-image', InformacionController.verificarImagenDuplicada);

module.exports = router;