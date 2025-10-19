const express = require('express');
const router = express.Router();
const ReseñaController = require('../controllers/reseñaController');

// Crear reseña
router.post('/', ReseñaController.crearReseña);

// Obtener reseñas por habitación
router.get('/habitacion/:habitacionId', ReseñaController.obtenerReseñasHabitacion);

// Obtener todas las reseñas
router.get('/', ReseñaController.obtenerTodasLasReseñas);

module.exports = router;