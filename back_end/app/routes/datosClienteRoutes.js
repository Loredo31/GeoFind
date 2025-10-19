const express = require('express');
const router = express.Router();
const DatosClienteController = require('../controllers/datosClienteController');

// Obtener usuario por ID
router.get('/:id', DatosClienteController.obtenerUsuario);

// Actualizar usuario
router.put('/:id', DatosClienteController.actualizarUsuario);

// Obtener usuarios por rol
router.get('/rol/:rol', DatosClienteController.obtenerUsuariosPorRol);

module.exports = router;