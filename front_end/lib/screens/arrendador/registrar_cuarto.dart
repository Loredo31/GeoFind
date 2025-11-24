import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/usuario.dart';
import '../../services/informacion_service.dart';
import '../../widget/arrendador/custom_dropdown_field.dart';
import '../../widget/arrendador/custom_form_field.dart';
import '../../widget/arrendador/form_card.dart';
import '../../widget/arrendador/services_checkbox_group.dart';

class RegistrarCuarto extends StatefulWidget {
  final Usuario usuario;

  const RegistrarCuarto({Key? key, required this.usuario}) : super(key: key);

  @override
  _RegistrarCuartoState createState() => _RegistrarCuartoState();
}

class _RegistrarCuartoState extends State<RegistrarCuarto> {
  final _formKey = GlobalKey<FormState>();
  final _costoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _clausulasController = TextEditingController();
  final _duracionRutasController = TextEditingController();
  final _googleMapsController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _clabeController = TextEditingController();
  final _capacidadController = TextEditingController();

  String? _tipoSeleccionado;
  String? _zonaSeleccionada;
  List<String> _serviciosSeleccionados = [];
  List<String> _fotografiasBase64 = [];
  bool _isLoading = false;

  final List<String> _tipos = ['individual', 'compartido'];
  final List<String> _zonas = ['centro', 'sur', 'norte'];

  @override
  void dispose() {
    _costoController.dispose();
    _direccionController.dispose();
    _clausulasController.dispose();
    _duracionRutasController.dispose();
    _googleMapsController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _clabeController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFotos() async {
    try {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..multiple = true
        ..style.display = 'none';

      final completer = Completer<void>();
      final nuevasImagenes = <String>[];

      input.onChange.listen((e) async {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          for (final file in files) {
            final reader = html.FileReader();
            final fileCompleter = Completer<void>();

            reader.onLoadEnd.listen((e) async {
              if (reader.result != null) {
                final String base64 = reader.result as String;
                final String pureBase64 = base64.split(',').last;

                // Verificar si la imagen ya existe antes de agregarla
                print('🔍 Verificando imagen: ${file.name}');
                final esDuplicada = await verificarImagen(pureBase64);

                if (esDuplicada) {
                  // Imagen duplicada - no agregar
                  print('❌ Imagen rechazada: ${file.name}');
                  _mostrarError(
                    'La imagen "${file.name}" ya existe en el sistema. Por favor usa una imagen original.'
                  );
                } else {
                  // Imagen original - agregar
                  print('✅ Imagen aceptada: ${file.name}');
                  nuevasImagenes.add(pureBase64);
                }
              }
              fileCompleter.complete();
            });

            reader.readAsDataUrl(file);
            await fileCompleter.future;
          }

          // Actualizar estado solo si hay nuevas imágenes válidas
          if (nuevasImagenes.isNotEmpty) {
            setState(() {
              _fotografiasBase64.addAll(nuevasImagenes);
            });
            _mostrarMensaje('${nuevasImagenes.length} imagen(es) agregada(s)');
          }
        }

        input.remove();
        completer.complete();
      });

      html.document.body!.append(input);
      input.click();
      await completer.future;
    } catch (error) {
      _mostrarError('Error al seleccionar imágenes: $error');
    }
  }

  /// Verifica si una imagen ya existe en la base de datos
  /// Retorna true si es duplicada, false si es original
  Future<bool> verificarImagen(String base64) async {
    try {
      print('🔍 Enviando imagen al servidor para verificación...');
      
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/proxy-image/proxy-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'imageBase64': base64}),
      );

      print('📡 Respuesta del servidor: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['ok'] == true) {
          final resultado = data['result'];
          final esDuplicada = resultado['found'] == true;
          
          if (esDuplicada) {
            final similitud = resultado['similarity'];
            print('❌ Duplicado detectado: $similitud% de similitud');
          } else {
            print('✅ Imagen original verificada');
          }
          
          return esDuplicada;
        }
      }

      // Si hay error en el servidor, permitir la imagen por seguridad
      print('⚠️ Error en servidor - permitiendo imagen');
      return false;
      
    } catch (error) {
      print('❌ Error al verificar: $error');
      // En caso de error, permitir la imagen
      return false;
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotografiasBase64.removeAt(index);
    });
    _mostrarMensaje('Imagen eliminada');
  }

  Future<void> _registrarCuarto() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fotografiasBase64.isEmpty) {
      _mostrarError('Por favor agrega al menos una fotografía');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final datosCuarto = {
        'nombreArrendador': widget.usuario.nombre,
        'tipo': _tipoSeleccionado,
        'capacidad': _tipoSeleccionado == 'compartido'
            ? int.parse(_capacidadController.text)
            : 1,
        'zona': _zonaSeleccionada,
        'clausulas': _clausulasController.text.isEmpty
            ? null
            : _clausulasController.text,
        'duracionRutas': int.parse(_duracionRutasController.text),
        'direccion': _direccionController.text,
        'googleMaps': _googleMapsController.text.isEmpty
            ? null
            : _googleMapsController.text,
        'fotografias': _fotografiasBase64,
        'costo': int.parse(_costoController.text),
        'servicios': _serviciosSeleccionados,
        'datosBancarios': {
          'bank_name': _bankNameController.text.isEmpty
              ? null
              : _bankNameController.text,
          'account_number': _accountNumberController.text.isEmpty
              ? null
              : _accountNumberController.text,
          'account_holder': _accountHolderController.text.isEmpty
              ? null
              : _accountHolderController.text,
          'clabe': _clabeController.text.isEmpty ? null : _clabeController.text,
        },
        'arrendadorId': widget.usuario.id,
      };

      print('Enviando datos al servidor...');
      final response = await InformacionService.crearInformacion(datosCuarto);

      if (response['success'] == true) {
        _mostrarExito('Habitación registrada exitosamente');
      } else {
        _mostrarError(
          response['message'] ?? 'Error al registrar la habitación',
        );
      }
    } catch (error) {
      _mostrarError('Error al registrar la habitación: ${error.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _costoController.clear();
    _direccionController.clear();
    _clausulasController.clear();
    _duracionRutasController.clear();
    _googleMapsController.clear();
    _bankNameController.clear();
    _accountNumberController.clear();
    _accountHolderController.clear();
    _clabeController.clear();
    _capacidadController.clear();
    _tipoSeleccionado = null;
    _zonaSeleccionada = null;
    _serviciosSeleccionados.clear();
    _fotografiasBase64.clear();
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context, true);
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String? _validarRequerido(String? value, String campo) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $campo';
    }
    return null;
  }

  String? _validarNumero(String? value, String campo, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa $campo';
    }
    final numero = int.tryParse(value);
    if (numero == null) {
      return 'Ingresa un número válido para $campo';
    }
    if (min != null && numero < min) {
      return '$campo debe ser al menos $min';
    }
    if (max != null && numero > max) {
      return '$campo no puede ser mayor a $max';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add_home_work, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registrar Habitación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Nueva propiedad',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.green[800]?.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cleaning_services, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Limpiar',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              onPressed: _limpiarFormulario,
              tooltip: 'Limpiar formulario',
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: FormCard(
              title: 'Registrar Habitación',
              subtitle: 'Completa la información de tu nueva propiedad',
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildSeccion(
                      'Información Básica',
                      Icons.info,
                      Column(
                        children: [
                          CustomDropdownField(
                            value: _tipoSeleccionado,
                            labelText: 'Tipo de habitación',
                            prefixIcon: Icons.hotel,
                            items: _tipos.map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _tipoSeleccionado = value;
                              });
                            },
                            validator: (value) => _validarRequerido(
                              value,
                              'el tipo de habitación',
                            ),
                          ),

                          if (_tipoSeleccionado == 'compartido')
                            CustomFormField(
                              controller: _capacidadController,
                              labelText: 'Capacidad (personas)',
                              prefixIcon: Icons.people,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  _validarNumero(value, 'la capacidad'),
                            ),

                          CustomDropdownField(
                            value: _zonaSeleccionada,
                            labelText: 'Zona',
                            prefixIcon: Icons.location_on,
                            items: _zonas.map((zona) {
                              return DropdownMenuItem(
                                value: zona,
                                child: Text(zona),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _zonaSeleccionada = value;
                              });
                            },
                            validator: (value) =>
                                _validarRequerido(value, 'la zona'),
                          ),

                          CustomFormField(
                            controller: _direccionController,
                            labelText: 'Dirección completa',
                            prefixIcon: Icons.home,
                            validator: (value) =>
                                _validarRequerido(value, 'la dirección'),
                          ),

                          CustomFormField(
                            controller: _duracionRutasController,
                            labelText: 'Duración del contrato (meses)',
                            prefixIcon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            validator: (value) => _validarNumero(
                              value,
                              'la duración del contrato',
                              min: 6,
                              max: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildSeccion(
                      'Fotografías',
                      Icons.photo_library,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fotografías de la habitación (mínimo 1)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.green[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Selecciona múltiples imágenes para mostrar la habitación',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _seleccionarFotos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Seleccionar Fotos'),
                          ),
                          const SizedBox(height: 12),

                          if (_fotografiasBase64.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fotos agregadas (${_fotografiasBase64.length})',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    _fotografiasBase64.length,
                                    (index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.green[300]!,
                                              ),
                                              image: DecorationImage(
                                                image: MemoryImage(
                                                  base64Decode(
                                                    _fotografiasBase64[index],
                                                  ),
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () => _eliminarFoto(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              'No hay fotografías agregadas',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildSeccion(
                      'Precio y Servicios',
                      Icons.attach_money,
                      Column(
                        children: [
                          CustomFormField(
                            controller: _costoController,
                            labelText: 'Costo mensual (\$)',
                            prefixIcon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                _validarNumero(value, 'el costo'),
                          ),

                          ServicesCheckboxGroup(
                            selectedServices: _serviciosSeleccionados,
                            onServicesChanged: (services) {
                              setState(() {
                                _serviciosSeleccionados = services;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildSeccion(
                      'Información Adicional',
                      Icons.description,
                      Column(
                        children: [
                          CustomFormField(
                            controller: _googleMapsController,
                            labelText: 'Enlace de Google Maps (opcional)',
                            prefixIcon: Icons.map,
                            keyboardType: TextInputType.url,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildSeccion(
                      'Datos Bancarios (Opcional)',
                      Icons.account_balance,
                      Column(
                        children: [
                          CustomFormField(
                            controller: _bankNameController,
                            labelText: 'Nombre del Banco',
                            prefixIcon: Icons.business,
                          ),
                          CustomFormField(
                            controller: _accountHolderController,
                            labelText: 'Titular de la cuenta',
                            prefixIcon: Icons.person,
                          ),
                          CustomFormField(
                            controller: _accountNumberController,
                            labelText: 'Número de cuenta',
                            prefixIcon: Icons.credit_card,
                            keyboardType: TextInputType.number,
                          ),
                          CustomFormField(
                            controller: _clabeController,
                            labelText: 'CLABE',
                            prefixIcon: Icons.numbers,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              side: BorderSide(color: Colors.green[700]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registrarCuarto,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Registrar Habitación'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, IconData icono, Widget contenido) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            contenido,
          ],
        ),
      ),
    );
  }
}
