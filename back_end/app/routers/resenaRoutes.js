const express = require('express');
const router = express.Router();
const resenaController = require('../controllers/resenaController');
const { authMiddleware } = require('../middleware/authMiddleware');

// Rutas públicas
router.get('/propiedad/:propiedadId', resenaController.obtenerResenasPropiedad);
router.get('/propiedad/:propiedadId/promedio', resenaController.obtenerPromedioPropiedad);
router.get('/recientes', resenaController.obtenerResenasRecientes);
router.get('/', resenaController.obtenerTodasResenas);

// Rutas protegidas para usuarios
router.post('/', authMiddleware, resenaController.crearResena);
router.get('/mis-resenas', authMiddleware, resenaController.obtenerMisResenas);
router.put('/:resenaId', authMiddleware, resenaController.actualizarResena);
router.delete('/:resenaId', authMiddleware, resenaController.eliminarResena);

module.exports = router;