const express = require('express');
const router = express.Router();
const AgendarCitaController = require('../controllers/agendarCitaController');

// Agendar cita
router.post('/', AgendarCitaController.crearCita);

// Obtener citas por arrendador (por habitación)
router.get('/arrendador/:habitacionId', AgendarCitaController.obtenerCitasArrendador);

// Obtener citas por arrendatario
router.get('/arrendatario/:arrendatarioId', AgendarCitaController.obtenerCitasArrendatario);

// Actualizar estado de cita
router.put('/:id/estado', AgendarCitaController.actualizarEstadoCita);

module.exports = router;