const express = require('express');
const router = express.Router();
const agendarCitaController = require('../controllers/agendarCitaController');
const { authMiddleware } = require('../middleware/authMiddleware');

// Rutas públicas para verificar disponibilidad
router.post('/disponibilidad', agendarCitaController.verificarDisponibilidad);
router.get('/propiedad/:propiedadId/fechas-disponibles', agendarCitaController.obtenerFechasDisponibles);

// Rutas protegidas para usuarios
router.post('/agendar', authMiddleware, agendarCitaController.agendarCita);
router.get('/mis-citas', authMiddleware, agendarCitaController.obtenerMisCitas);
router.put('/cancelar/:citaId', authMiddleware, agendarCitaController.cancelarCita);

// Rutas para el componente aleatorio (accesibles sin admin)
router.put('/procesar-aleatorio/:citaId', agendarCitaController.procesarDecisionAleatoria);
router.put('/procesar-todas', agendarCitaController.procesarTodasCitasPendientes);

module.exports = router;