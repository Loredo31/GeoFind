const express = require('express');
const router = express.Router();
const usuarioController = require('../controllers/usuarioController');
const { authMiddleware } = require('../middleware/authMiddleware');
const { validarRegistro, validarLogin, validarActualizacion } = require('../middleware/validationMiddleware');

// Rutas públicas
router.post('/registro', validarRegistro, usuarioController.registrar);
router.post('/login', validarLogin, usuarioController.login);

// Rutas protegidas (requieren autenticación)
router.get('/perfil', authMiddleware, usuarioController.obtenerPerfil);
router.put('/perfil', authMiddleware, validarActualizacion, usuarioController.actualizarPerfil);
router.put('/cambiar-password', authMiddleware, usuarioController.cambiarPassword);

module.exports = router;