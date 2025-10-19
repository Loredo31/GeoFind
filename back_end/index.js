require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connection = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const houseRoutes = require('./routes/houseRoutes');
const appointmentRoutes = require('./routes/appointmentRoutes');
const reservationRoutes = require('./routes/reservationRoutes');
const reviewRoutes = require('./routes/reviewRoutes');

const app = express();
connection();

app.use(cors());
app.use(express.json({ limit: '50mb' }));

app.use('/api', authRoutes);
app.use('/api', houseRoutes);
app.use('/api', appointmentRoutes);
app.use('/api', reservationRoutes);
app.use('/api', reviewRoutes);

const PORT = process.env.PORT || 3006;
app.listen(PORT, () => console.log(`Servidor corriendo en puerto ${PORT}`));
