const express = require('express');
const router = express.Router();
const DatosClienteController = require('../controllers/datosClienteController');

// obtener usuario ID
router.get('/:id', DatosClienteController.obtenerUsuario);
// actualizar
router.put('/:id', DatosClienteController.actualizarUsuario);
// Obtener rol
router.get('/rol/:rol', DatosClienteController.obtenerUsuariosPorRol);

module.exports = router;