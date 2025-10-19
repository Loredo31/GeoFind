const express = require('express');
const router = express.Router();
const informacionController = require('../controllers/informacionController');
const { authMiddleware } = require('../middleware/authMiddleware');

// Rutas públicas
router.get('/', informacionController.obtenerPropiedades);
router.get('/buscar', informacionController.buscarPorUbicacion);
router.get('/:id', informacionController.obtenerPropiedad);

// Rutas protegidas
router.post('/', authMiddleware, informacionController.crearPropiedad);
router.put('/:id', authMiddleware, informacionController.actualizarPropiedad);
router.delete('/:id', authMiddleware, informacionController.eliminarPropiedad);
router.put('/:id/disponibilidad', authMiddleware, informacionController.actualizarDisponibilidad);

// Rutas para fotos
router.post('/:id/fotos', authMiddleware, informacionController.agregarFoto);
router.delete('/:id/fotos/:fotoId', authMiddleware, informacionController.eliminarFoto);
router.put('/:id/fotos/:fotoId/principal', authMiddleware, informacionController.marcarFotoPrincipal);

module.exports = router;