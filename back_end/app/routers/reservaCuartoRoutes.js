const express = require('express');
const router = express.Router();
const reservaCuartoController = require('../controllers/reservaCuartoController');
const { authMiddleware } = require('../middleware/authMiddleware');

// Rutas protegidas para usuarios
router.post('/', authMiddleware, reservaCuartoController.crearReserva);
router.get('/mis-reservas', authMiddleware, reservaCuartoController.obtenerMisReservas);
router.get('/:id', authMiddleware, reservaCuartoController.obtenerReserva);
router.put('/cancelar/:reservaId', authMiddleware, reservaCuartoController.cancelarReserva);

// Rutas para el componente aleatorio
router.put('/procesar-aleatorio/:reservaId', reservaCuartoController.procesarDecisionAleatoria);
router.put('/procesar-todas', reservaCuartoController.procesarTodasReservasPendientes);

// NOTA: Se eliminó la ruta de regenerar-contrato completamente

module.exports = router;