const express = require("express");

const { proxyImageController } = require("../controllers/proxyImageController");

const router = express.Router();

router.post("/proxy-image", proxyImageController);
    
module.exports = router;
