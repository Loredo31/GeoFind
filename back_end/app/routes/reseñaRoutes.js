const express = require('express');
const router = express.Router();
const ReseñaController = require('../controllers/reseñaController');

router.post('/', ReseñaController.crearReseña);
router.get('/habitacion/:habitacionId', ReseñaController.obtenerReseñasHabitacion);
router.get('/', ReseñaController.obtenerTodasLasReseñas);
router.get('/promedios/:habitacionId', ReseñaController.obtenerPromedioCalificaciones);
router.get('/evolucion/:habitacionId', ReseñaController.obtenerEvolucionCalificaciones);

router.get('/grafica-barras/:habitacionId', ReseñaController.obtenerDatosGraficaBarras);
router.get('/grafica-area/:habitacionId', ReseñaController.obtenerDatosGraficaArea);
router.get('/grafica-radar/:habitacionId', ReseñaController.obtenerDatosGraficaRadar);
router.get('/grafica-barras-doble/:habitacionId', ReseñaController.obtenerDatosGraficaBarrasDobles);


module.exports = router;