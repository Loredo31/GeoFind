const ReservarCuartoService = require('../services/reservarCuartoService');
const ReservarCuarto = require('../models/ReservarCuartoModel');
const InformacionModel = require('../models/InformacionModel');

// carga la librería de correos y contratos
let EmailSender, ContractGenerator;
let libreriaCargada = false;

try {
  EmailSender = require('geofind-contract-generator/src/emailSender');
  ContractGenerator = require('geofind-contract-generator/src/contractGenerator');
  console.log('Librerías de correo y contratos cargadas correctamente');
  libreriaCargada = true;
} catch (error) {
  console.warn('No se pudieron cargar las librerías de correo/contratos:', error.message);
  libreriaCargada = false;
}

// manda correo aceptacion y contrato
async function enviarCorreoAprobacionConContrato(reservaId) {
  console.log(`Iniciando envío de correo de APROBACIÓN para reserva: ${reservaId}`);
  
  if (!libreriaCargada) {
    console.log('Librerías de correo no disponibles');
    return;
  }

  try {
    const emailSender = new EmailSender();
    const contractGenerator = new ContractGenerator();

    // obtener datos reserva
    const reserva = await ReservarCuarto.findById(reservaId);
    if (!reserva) {
      console.log('Reserva no encontrada');
      return;
    }

    // obtener datos habitacion
    const habitacion = await InformacionModel.findById(reserva.habitacionId);
    if (!habitacion) {
      console.log('Habitación no encontrada');
      return;
    }

    console.log('✅ Datos encontrados:', {
      cliente: reserva.nombre,
      email: reserva.email,
      propiedad: habitacion.direccion
    });

    // prepara datos
    const clientData = {
      nombre: reserva.nombre,
      edad: reserva.edad.toString(),
      gmail: reserva.email,
      numero_telefonico: reserva.telefono,
      direccion: reserva.direccionVivienda,
      curp: reserva.curp
    };

    const propertyData = {
      property_address: reserva.direccionHabitacion || habitacion.direccion,
      property_type: reserva.tipoHabitacion || habitacion.tipo,
      rental_period: `${reserva.duracion || habitacion.duracionRutas} meses`,
      monthly_rent: reserva.costo?.toString() || habitacion.costo?.toString(),
      deposit_amount: reserva.costo?.toString() || habitacion.costo?.toString(),
      arrendador_nombre: reserva.nombreArrendador || habitacion.nombreArrendador,
      bankDetails: reserva.datosBancarios || habitacion.datosBancarios || null,
      clausulas: habitacion.clausulas ? 
        (Array.isArray(habitacion.clausulas) ? habitacion.clausulas : [habitacion.clausulas]) 
        : []
    };

    console.log('Generando contrato...');
    const contractPath = await contractGenerator.generateRentalContract(clientData, propertyData);
    console.log(`Contrato generado: ${contractPath}`);

    // manda detalles de correo
    const contractDetails = {
      property_name: `${propertyData.property_type} - ${propertyData.property_address}`,
      property_address: propertyData.property_address,
      map_property: habitacion.googleMaps || '',
      period: propertyData.rental_period,
      price: propertyData.monthly_rent,
      contract_number: reserva.numeroContrato
    };

    const bankDetails = propertyData.bankDetails;

    console.log('Enviando correo de APROBACIÓN con contrato...');
    const [success, info] = await emailSender.sendAcceptanceEmail(
      reserva.email,
      reserva.nombre,
      contractDetails,
      bankDetails,
      contractPath
    );

    if (success) {
      console.log('Correo de APROBACIÓN enviado exitosamente');
    } else {
      console.log('Error al enviar correo de aprobación:', info);
    }

  } catch (error) {
    console.error('ERROR en enviarCorreoAprobacionConContrato:', error.message);
  }
}

// enviar correo rechazo
async function enviarCorreoRechazo(reservaId, motivoRechazo = '') {
  console.log(`Iniciando envío de correo de RECHAZO para reserva: ${reservaId}`);
  
  if (!libreriaCargada) {
    console.log('Librerías de correo no disponibles');
    return;
  }

  try {
    const emailSender = new EmailSender();

    // obtener datos de reserva
    const reserva = await ReservarCuarto.findById(reservaId);
    if (!reserva) {
      console.log('Reserva no encontrada');
      return;
    }

    console.log('Datos para rechazo:', {
      cliente: reserva.nombre,
      email: reserva.email
    });

    // motivo del rechazo
    const motivo = motivoRechazo || 'No se pudo procesar su solicitud en este momento';

    console.log('Enviando correo de RECHAZO...');
    const [success, info] = await emailSender.sendRejectionEmail(
      reserva.email,
      reserva.nombre,
      motivo
    );

    if (success) {
      console.log('Correo de RECHAZO enviado exitosamente');
    } else {
      console.log('Error al enviar correo de rechazo:', info);
    }

  } catch (error) {
    console.error('ERROR en enviarCorreoRechazo:', error.message);
  }
}

class ReservarCuartoController {
  async crearReserva(req, res) {
    try {
      console.log('Creando nueva reserva...');
      const datosReserva = req.body;
      const reserva = await ReservarCuartoService.crearReserva(datosReserva);
      
      return res.status(201).json({
        success: true,
        message: 'Reserva creada exitosamente',
        data: reserva
      });
    } catch (error) {
      console.error('Error al crear reserva:', error);
      return res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerReservasArrendador(req, res) {
    try {
      const { habitacionId } = req.params;
      const reservas = await ReservarCuartoService.obtenerReservasPorArrendador(habitacionId);
      
      return res.json({
        success: true,
        data: reservas
      });
    } catch (error) {
      console.error('Error al obtener reservas del arrendador:', error);
      return res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerReservasArrendatario(req, res) {
    try {
      const { arrendatarioId } = req.params;
      const reservas = await ReservarCuartoService.obtenerReservasPorArrendatario(arrendatarioId);
      
      return res.json({
        success: true,
        data: reservas
      });
    } catch (error) {
      console.error('Error al obtener reservas del arrendatario:', error);
      return res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async actualizarEstadoReserva(req, res) {
    try {
      const { id } = req.params;
      const { estado, motivoRechazo } = req.body;
      
      console.log(`Actualizando estado de reserva ${id} a:`, estado);
      
      // actualizar estado de reserva
      const reservaActualizada = await ReservarCuartoService.actualizarEstadoReserva(id, estado);
      
      // enviar correo segun el false y true
      if (estado === true) {
        // aprobado
        try {
          console.log('Enviando correo de APROBACIÓN con contrato...');
          await enviarCorreoAprobacionConContrato(id);
          console.log('Proceso de aprobación completado');
        } catch (emailError) {
          console.warn('No se pudo enviar correo de aprobación:', emailError.message);
        }
      } else if (estado === false) {
        // rechazado
        try {
          console.log('Enviando correo de RECHAZO...');
          await enviarCorreoRechazo(id, motivoRechazo);
          console.log('Proceso de rechazo completado');
        } catch (emailError) {
          console.warn('No se pudo enviar correo de rechazo:', emailError.message);
        }
      }
      
      return res.json({
        success: true,
        message: 'Estado de reserva actualizado',
        data: reservaActualizada
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new ReservarCuartoController();