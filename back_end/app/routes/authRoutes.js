const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/authController');

// Ruta para login
router.post('/login', AuthController.login);

// Ruta para registro
router.post('/register', AuthController.register);

module.exports = router;