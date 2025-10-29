const express = require('express');
const router = express.Router();
const ReservarCuartoController = require('../controllers/reservarCuartoController');

// crear 
router.post('/', ReservarCuartoController.crearReserva);
// obtener reservas  arrendador
router.get('/arrendador/:habitacionId', ReservarCuartoController.obtenerReservasArrendador);
// obtener reservas arrendatario
router.get('/arrendatario/:arrendatarioId', ReservarCuartoController.obtenerReservasArrendatario);
//actualizae
router.put('/:id/estado', ReservarCuartoController.actualizarEstadoReserva);

module.exports = router;