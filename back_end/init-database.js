const { MongoClient } = require('mongodb');

const url = 'mongodb://localhost:27017';
const dbName = 'renta_habitaciones';

async function initDatabase() {
  const client = new MongoClient(url);
  
  try {
    await client.connect();
    console.log('Conectado a MongoDB');
    
    const db = client.db(dbName);
    
    // Crear las colecciones
    await db.createCollection('usuarios');
    await db.createCollection('citas');
    await db.createCollection('informacion');
    await db.createCollection('reservas');
    await db.createCollection('reseñas');
    await db.createCollection('contratos');
    
    console.log('✅ Base de datos creada exitosamente');
    console.log('📊 Tablas creadas:');
    console.log('   - usuarios');
    console.log('   - citas');
    console.log('   - informacion');
    console.log('   - reservas');
    console.log('   - reseñas');
    console.log('   - contratos');
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await client.close();
  }
}

initDatabase();





// para recrear la base de datos se ejecuta esta
// node init-database.js 
// este se ejecuta dentro del proyecto dentro de back_end