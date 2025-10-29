const AgendarCitaService = require('../services/agendarCitaService');
const AgendarCita = require('../models/AgendarCitaModel');
const UsuarioModel = require('../models/UsuarioModel');
const InformacionModel = require('../models/InformacionModel');

console.log('Buscando librería de correos...');

let MessageTemplates;
let libreriaCargada = false;

try {
  MessageTemplates = require('geofind-contract-generator/src/messageTemplates');
  console.log('Librería cargada desde: geofind-contract-generator/src/messageTemplates');
  libreriaCargada = true;
} catch (error1) {
  console.log('Intento 1 fallo:', error1.message);
  
  try {
    MessageTemplates = require('./node_modules/geofind-contract-generator/src/messageTemplates');
    console.log('Librería cargada desde ruta relativa');
    libreriaCargada = true;
  } catch (error2) {
    console.log('Intento 2 falló:', error2.message);
    
    try {
      MessageTemplates = require('geofind-contract-generator');
      console.log('Librería cargada desde raíz del paquete');
      libreriaCargada = true;
    } catch (error3) {
      console.log('Intento 3 falló:', error3.message);
      console.log('La librería no está disponible en ninguna ruta probada');
    }
  }
}

if (libreriaCargada && MessageTemplates) {
  console.log('Verificando métodos de la librería...');
  try {
    const tempInstance = new MessageTemplates();
    console.log('Instancia creada correctamente');
    
    if (typeof tempInstance.sendAppointmentConfirmation === 'function') {
      console.log('Método sendAppointmentConfirmation disponible');
    } else {
      console.log('Método sendAppointmentConfirmation NO disponible');
    }
    
    if (typeof tempInstance.sendAppointmentRejection === 'function') {
      console.log('Método sendAppointmentRejection disponible');
    } else {
      console.log('Método sendAppointmentRejection NO disponible');
    }
  } catch (error) {
    console.log('Error al verificar métodos:', error.message);
  }
} else {
  console.log('No se pudo cargar la librería de correos');
}

async function enviarNotificacionCorreo(citaId, estado, motivoRechazo = '') {
  console.log(`Iniciando envío de correo para cita: ${citaId}, estado: ${estado}`);
  
  if (!libreriaCargada || !MessageTemplates) {
    console.log('Librería de correos no disponible, no se enviará correo');
    
    try {
      const cita = await AgendarCita.findById(citaId);
      if (cita) {
        console.log('Datos de la cita (para verificación):', {
          nombreSolicitante: cita.nombreSolicitante,
          fecha: cita.fecha,
          hora: cita.hora,
          arrendatarioId: cita.arrendatarioId
        });
        
        const arrendatario = await UsuarioModel.findById(cita.arrendatarioId);
        if (arrendatario && arrendatario.email) {
          console.log('Email del arrendatario:', arrendatario.email);
        } else {
          console.log('No se pudo obtener email del arrendatario');
        }
      }
    } catch (error) {
      console.log('Error obteniendo datos de verificación:', error.message);
    }
    
    return;
  }

  try {
    console.log('Creando instancia de MessageTemplates...');
    const message = new MessageTemplates();
    
    console.log('Buscando cita en la base de datos...');
    const cita = await AgendarCita.findById(citaId);
    
    if (!cita) {
      console.warn('Cita no encontrada, no se enviará correo');
      return;
    }
    
    console.log('Cita encontrada:', {
      nombreSolicitante: cita.nombreSolicitante,
      fecha: cita.fecha,
      hora: cita.hora
    });

    // Formatear fecha
    const date = new Date(cita.fecha);
    const fechaFormateada = `${date.getDate().toString().padStart(2, '0')}/${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getFullYear()}`;
    console.log('Fecha formateada:', fechaFormateada);
    
    try {
      const arrendatario = await UsuarioModel.findById(cita.arrendatarioId);
      if (arrendatario && arrendatario.email) {
        emailArrendatario = arrendatario.email;
        console.log('Email del arrendatario encontrado:', emailArrendatario);
      } else {
        console.warn('No se encontró email del arrendatario, usando email de prueba:', emailArrendatario);
      }
    } catch (dbError) {
      console.error('Error obteniendo datos del arrendatario:', dbError.message);
    }

    // obtienen direccion
    let direccion = cita.direccionHabitacion || 'Dirección no especificada';
    
    try {
      const habitacion = await InformacionModel.findById(cita.habitacionId);
      if (habitacion && habitacion.direccion) {
        direccion = habitacion.direccion;
        console.log('Dirección de la habitación:', direccion);
      }
    } catch (dbError) {
      console.error('Error obteniendo datos de la habitación:', dbError.message);
    }

    // envia correo
    if (estado === true) {
      console.log('Enviando correo de CONFIRMACIÓN...');
      console.log('Datos del correo:', {
        email: emailArrendatario,
        nombre: cita.nombreSolicitante,
        fecha: fechaFormateada,
        hora: cita.hora,
        direccion: direccion
      });
      
      const [success, info] = await message.sendAppointmentConfirmation(
        emailArrendatario,
        cita.nombreSolicitante,
        fechaFormateada,
        cita.hora,
        direccion
      );
      
      console.log('Resultado del envío (confirmación):', { success, info });
      
    } else if (estado === false) {
      console.log('Enviando correo de RECHAZO...');
      console.log('Datos del correo:', {
        email: emailArrendatario,
        nombre: cita.nombreSolicitante,
        motivo: motivoRechazo || 'Motivo no especificado'
      });
      
      const [success, info] = await message.sendAppointmentRejection(
        emailArrendatario,
        cita.nombreSolicitante,
        motivoRechazo || 'Motivo no especificado'
      );
      
      console.log('Resultado del envío (rechazo):', { success, info });
    }
    
    console.log('Proceso de envío de correo completado');
    
  } catch (error) {
    console.error('ERROR al enviar correo:', error);
    console.error('Stack trace:', error.stack);
    throw error;
  }
}

class AgendarCitaController {
  async crearCita(req, res) {
    try {
      const datosCita = req.body;
      const cita = await AgendarCitaService.crearCita(datosCita);
      
      res.status(201).json({
        success: true,
        message: 'Cita agendada exitosamente',
        data: cita
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerCitasArrendador(req, res) {
    try {
      const { habitacionId } = req.params;
      const citas = await AgendarCitaService.obtenerCitasPorArrendador(habitacionId);
      
      res.json({
        success: true,
        data: citas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async obtenerCitasArrendatario(req, res) {
    try {
      const { arrendatarioId } = req.params;
      const citas = await AgendarCitaService.obtenerCitasPorArrendatario(arrendatarioId);
      
      res.json({
        success: true,
        data: citas
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }

  async actualizarEstadoCita(req, res) {
    try {
      const { id } = req.params;
      const { estado, motivoRechazo } = req.body;
      
      console.log(`Actualizando estado de cita ${id} a:`, estado);
      
      // actualizar el estado de la cita
      const citaActualizada = await AgendarCitaService.actualizarEstadoCita(id, estado);
      console.log('Cita actualizada correctamente');
      
      // envia correo
      try {
        console.log('Iniciando proceso de envío de correo...');
        await enviarNotificacionCorreo(id, estado, motivoRechazo);
        console.log('Proceso de correo completado');
      } catch (emailError) {
        console.warn('No se pudo enviar correo, pero la cita se actualizó:', emailError.message);
      }
      
      res.json({
        success: true,
        message: 'Estado de cita actualizado',
        data: citaActualizada
      });
    } catch (error) {
      console.error('Error en actualizarEstadoCita:', error);
      res.status(500).json({
        success: false,
        message: error.message
      });
    }
  }
}

module.exports = new AgendarCitaController();