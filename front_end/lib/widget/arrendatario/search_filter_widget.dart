import 'package:flutter/material.dart';

import '../arrendador/services_checkbox_group.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;

  const SearchFilterWidget({Key? key, required this.onFiltersChanged})
    : super(key: key);

  @override
  _SearchFilterWidgetState createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final List<String> _zonas = ['Todas', 'norte', 'sur', 'centro'];
  final List<String> _servicios = [
    'WiFi',
    'Agua',
    'Luz',
    'Cocina',
    'Lavandería',
    'Parqueadero',
  ];
  final List<String> _tiposCuarto = ['Todos', 'individual', 'compartido'];

  final List<int> _precios = [
    1000,
    1500,
    2000,
    2500,
    3000,
    3500,
    4000,
    4500,
    5000,
  ];

  String _zonaSeleccionada = 'Todas';
  String _tipoCuartoSeleccionado = 'Todos';
  int? _precioMinSeleccionado;
  int? _precioMaxSeleccionado;
  List<String> _serviciosSeleccionados = []; 

  void _aplicarFiltros() {
    final filtros = {
      'zona': _zonaSeleccionada == 'Todas' ? null : _zonaSeleccionada,
      'tipo': _tipoCuartoSeleccionado == 'Todos'
          ? null
          : _tipoCuartoSeleccionado,
      'precioMin': _precioMinSeleccionado,
      'precioMax': _precioMaxSeleccionado,
      'servicios': _serviciosSeleccionados,
    };
    widget.onFiltersChanged(filtros);
  }

  void _mostrarFiltrosAvanzados(BuildContext context) {
    
    String zonaTemp = _zonaSeleccionada;
    String tipoCuartoTemp = _tipoCuartoSeleccionado;
    int? precioMinTemp = _precioMinSeleccionado;
    int? precioMaxTemp = _precioMaxSeleccionado;
    List<String> serviciosTemp = List.from(_serviciosSeleccionados); 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros Avanzados',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.green[700]),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          
                          _buildFilterSection(
                            'Ubicación',
                            Icons.location_on,
                            DropdownButtonFormField<String>(
                              value: zonaTemp,
                              items: _zonas.map((zona) {
                                return DropdownMenuItem(
                                  value: zona,
                                  child: Text(zona),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  zonaTemp = value!;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.green[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.green[50],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          
                          _buildFilterSection(
                            'Tipo de Habitación',
                            Icons.hotel,
                            DropdownButtonFormField<String>(
                              value: tipoCuartoTemp,
                              items: _tiposCuarto.map((tipo) {
                                return DropdownMenuItem(
                                  value: tipo,
                                  child: Text(tipo),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  tipoCuartoTemp = value!;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.green[300]!,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.green[50],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFilterSection(
                            'Rango de Precios',
                            Icons.attach_money,
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPrecioDropdown(
                                        'Mínimo',
                                        precioMinTemp,
                                        (value) {
                                          setDialogState(() {
                                            precioMinTemp = value;
                                          });
                                        },
                                        setDialogState,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildPrecioDropdown(
                                        'Máximo',
                                        precioMaxTemp,
                                        (value) {
                                          setDialogState(() {
                                            precioMaxTemp = value;
                                          });
                                        },
                                        setDialogState,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                               
                                if (precioMinTemp != null &&
                                    precioMaxTemp != null &&
                                    precioMinTemp! >= precioMaxTemp!)
                                  Text(
                                    '⚠️ El precio mínimo debe ser menor que el máximo.',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else if (precioMinTemp != null ||
                                    precioMaxTemp != null)
                                  Text(
                                    _getRangoPrecioText(
                                      precioMinTemp,
                                      precioMaxTemp,
                                    ),
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          
                         
                          _buildFilterSection(
                            'Servicios Incluidos',
                            Icons.room_service,
                            ServicesCheckboxGroup(
                              selectedServices: serviciosTemp,
                              onServicesChanged: (List<String> updatedServices) {
                                setDialogState(() {
                                  serviciosTemp = updatedServices;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                 
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setDialogState(() {
                              zonaTemp = 'Todas';
                              tipoCuartoTemp = 'Todos';
                              precioMinTemp = null;
                              precioMaxTemp = null;
                              serviciosTemp.clear(); 
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green[700],
                            side: BorderSide(color: Colors.green[700]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Limpiar Todo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            
                            if (precioMinTemp != null &&
                                precioMaxTemp != null &&
                                precioMinTemp! >= precioMaxTemp!) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'El precio mínimo debe ser menor que el máximo.',
                                  ),
                                  backgroundColor: Colors.red[700],
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                           
                            setState(() {
                              _zonaSeleccionada = zonaTemp;
                              _tipoCuartoSeleccionado = tipoCuartoTemp;
                              _precioMinSeleccionado = precioMinTemp;
                              _precioMaxSeleccionado = precioMaxTemp;
                              _serviciosSeleccionados = serviciosTemp;
                            });
                            _aplicarFiltros();
                            Navigator.pop(context);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(String title, IconData icon, Widget child) {
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
                Icon(icon, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildPrecioDropdown(
    String label,
    int? selectedValue,
    ValueChanged<int?> onChanged,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.green[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<int?>(
          value: selectedValue,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Cualquiera', style: TextStyle(fontSize: 14)),
            ),
            ..._precios.map((precio) {
              return DropdownMenuItem(
                value: precio,
                child: Text('\$$precio', style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[500]!),
            ),
            filled: true,
            fillColor: Colors.green[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
        ),
      ],
    );
  }

  String _getRangoPrecioText(int? precioMin, int? precioMax) {
    if (precioMin != null && precioMax != null) {
      return 'Precio: \$$precioMin - \$$precioMax';
    } else if (precioMin != null) {
      return 'Precio desde: \$$precioMin';
    } else if (precioMax != null) {
      return 'Precio hasta: \$$precioMax';
    }
    return 'Cualquier precio';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.filter_alt, color: Colors.green[700], size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Filtrar habitaciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _mostrarFiltrosAvanzados(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Filtros'),
                        SizedBox(width: 4),
                        Icon(Icons.tune, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}