const express = require('express');
const router = express.Router();
const AuthController = require('../controllers/authController');

// login
router.post('/login', AuthController.login);
// registro
router.post('/register', AuthController.register);

module.exports = router;