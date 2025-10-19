const express = require('express');
const router = express.Router();
const ReservarCuartoController = require('../controllers/reservarCuartoController');

// Crear reserva
router.post('/', ReservarCuartoController.crearReserva);

// Obtener reservas por arrendador (por habitación)
router.get('/arrendador/:habitacionId', ReservarCuartoController.obtenerReservasArrendador);

// Obtener reservas por arrendatario
router.get('/arrendatario/:arrendatarioId', ReservarCuartoController.obtenerReservasArrendatario);

// Actualizar estado de reserva
router.put('/:id/estado', ReservarCuartoController.actualizarEstadoReserva);

module.exports = router;