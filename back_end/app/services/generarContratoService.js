class GenerarContratoService {
  generarNumeroContrato() {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);
    return `CONTRATO-${timestamp}-${random}`;
  }

  generarContratoCompleto(datosReserva) {
    return {
      numeroContrato: this.generarNumeroContrato(),
      fechaGeneracion: new Date(),
      datos: datosReserva
    };
  }
}

module.exports = new GenerarContratoService();