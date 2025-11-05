const express = require('express');
const router = express.Router();
const proxyController = require('../controllers/proxyController');

router.get('/foto-portada/:habitacionId', proxyController.getFotoPortada);

module.exports = router;