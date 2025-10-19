const express = require('express');
const router = express.Router();
const InformacionController = require('../controllers/informacionController');

// Crear información de habitación
router.post('/', InformacionController.crearInformacion);

// Obtener información por arrendador
router.get('/arrendador/:arrendadorId', InformacionController.obtenerInformacionArrendador);

// Obtener todas las habitaciones
router.get('/', InformacionController.obtenerTodasLasHabitaciones);

// Actualizar información
router.put('/:id', InformacionController.actualizarInformacion);

// Eliminar información
router.delete('/:id', InformacionController.eliminarInformacion);

module.exports = router;