const validarRegistro = (req, res, next) => {
  const { nombre, email, password, telefono, direccion, edad, ocupacion } = req.body;

  if (!nombre || !email || !password || !telefono || !direccion || !edad || !ocupacion) {
    return res.status(400).json({
      success: false,
      message: 'Todos los campos son requeridos'
    });
  }

  if (password.length < 6) {
    return res.status(400).json({
      success: false,
      message: 'La contraseña debe tener al menos 6 caracteres'
    });
  }

  if (edad < 18) {
    return res.status(400).json({
      success: false,
      message: 'Debes ser mayor de 18 años'
    });
  }

  next();
};

const validarLogin = (req, res, next) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Email y contraseña son requeridos'
    });
  }

  next();
};

const validarActualizacion = (req, res, next) => {
  const { email, password } = req.body;

  if (email || password) {
    return res.status(400).json({
      success: false,
      message: 'No se puede actualizar email o contraseña desde esta ruta'
    });
  }

  next();
};

module.exports = {
  validarRegistro,
  validarLogin,
  validarActualizacion
};