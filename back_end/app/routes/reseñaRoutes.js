// const express = require('express');
// const router = express.Router();
// const ReseñaController = require('../controllers/reseñaController');

// // crear
// router.post('/', ReseñaController.crearReseña);
// // obtener por habitacion
// router.get('/habitacion/:habitacionId', ReseñaController.obtenerReseñasHabitacion);
// // obtener todas 
// router.get('/', ReseñaController.obtenerTodasLasReseñas);

// module.exports = router;



const express = require('express');
const router = express.Router();
const ReseñaController = require('../controllers/reseñaController');

// crear
router.post('/', ReseñaController.crearReseña);
// obtener por habitacion
router.get('/habitacion/:habitacionId', ReseñaController.obtenerReseñasHabitacion);
// obtener todas 
router.get('/', ReseñaController.obtenerTodasLasReseñas);
// nuevos endpoints para gráficas
router.get('/grafica-dispersion/:habitacionId', ReseñaController.obtenerDatosGraficaDispersion);
router.get('/promedios/:habitacionId', ReseñaController.obtenerPromedioCalificaciones);
router.get('/evolucion/:habitacionId', ReseñaController.obtenerEvolucionCalificaciones);

module.exports = router;