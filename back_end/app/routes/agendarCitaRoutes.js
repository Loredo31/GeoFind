const express = require('express');
const router = express.Router();
const AgendarCitaController = require('../controllers/agendarCitaController');

//crea
router.post('/', AgendarCitaController.crearCita);
// obtener citas arrendador
router.get('/arrendador/:habitacionId', AgendarCitaController.obtenerCitasArrendador);
// obtener citas arrendatario
router.get('/arrendatario/:arrendatarioId', AgendarCitaController.obtenerCitasArrendatario);
// actualizar
router.put('/:id/estado', AgendarCitaController.actualizarEstadoCita);

module.exports = router;