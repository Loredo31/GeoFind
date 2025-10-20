const express = require('express');
const cors = require('cors');
const conectarDB = require('./db.conexion');
require('dotenv').config();

const app = express();

// Conectar a la base de datos
conectarDB();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas TEMPORALES - sin controladores completos aún
app.use('/api/auth', require('./app/routes/authRoutes'));
app.use('/api/informacion', require('./app/routes/informacionRoutes'));
app.use('/api/reservar-cuarto', require('./app/routes/reservarCuartoRoutes'));
app.use('/api/agendar-cita', require('./app/routes/agendarCitaRoutes'));
app.use('/api/resena', require('./app/routes/reseñaRoutes'));
app.use('/api/datos-cliente', require('./app/routes/datosClienteRoutes'));

// Ruta de prueba para verificar conexión
app.get('/api/test-db', async (req, res) => {
  try {
    const mongoose = require('mongoose');
    const estado = mongoose.connection.readyState;
    
    const estados = {
      0: 'Desconectado',
      1: 'Conectado',
      2: 'Conectando',
      3: 'Desconectando'
    };
    
    res.json({
      success: true,
      message: '✅ API funcionando correctamente',
      database: {
        nombre: mongoose.connection.name,
        host: mongoose.connection.host,
        estado: estados[estado]
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Ruta principal
app.get('/', (req, res) => {
  res.json({
    message: '🚀 API de Renta de Habitaciones funcionando',
    version: '1.0.0',
    endpoints: [
      '/api/auth/login',
      '/api/auth/register',
      '/api/informacion',
      '/api/reservar-cuarto',
      '/api/agendar-cita',
      '/api/resena',
      '/api/datos-cliente',
      '/api/test-db'
    ]
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`📊 Conectado a la base de datos: renta_habitaciones`);
});