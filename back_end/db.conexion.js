const mongoose = require('mongoose');

const conectarDB = async () => {
  try {
    const conexion = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/renta_habitaciones', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`✅ MongoDB conectado: ${conexion.connection.host}`);
    console.log(`📊 Base de datos: ${conexion.connection.name}`);
  } catch (error) {
    console.error('❌ Error conectando a MongoDB:', error);
    process.exit(1);
  }
};

module.exports = conectarDB;