import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:front_end/services/reseña_service.dart';

class ResenasModal extends StatefulWidget {
  final String habitacionId;

  const ResenasModal({Key? key, required this.habitacionId}) : super(key: key);

  @override
  _ResenasModalState createState() => _ResenasModalState();
}

class _ResenasModalState extends State<ResenasModal> {
  List<dynamic> _resenas = [];
  bool _isLoading = true; // Estado de carga para las reseñas
  bool _mostrarGraficas =
      true; // Controla si mostrar gráficas o lista de reseñas
  String _tipoGraficaSeleccionada =
      'barras'; // Tipo de gráfica seleccionada actualmente

  // Datos para las diferentes gráficas
  Map<String, dynamic> _datosGraficas = {};
  bool _cargandoGraficas = false;

  @override
  void initState() {
    super.initState();
    if (_mostrarGraficas) {
      _cargarDatosGraficas();
    } else {
      _cargarResenas();
    }
  }

  // Carga los datos para las gráficas disponibles
  Future<void> _cargarDatosGraficas() async {
    setState(() => _cargandoGraficas = true);

    try {
      final responses = await Future.wait([
        _obtenerDatosGraficaBarras(),
        _obtenerDatosGraficaLineas(),
        _obtenerDatosGraficaArea(),
        _obtenerDatosGraficaBarrasDobles(),
        _obtenerDatosGraficaRadar(),
      ]);

      setState(() {
        // Almacenar los datos de cada gráfica
        _datosGraficas = {
          'barras': responses[0],
          'lineas': responses[1],
          'area': responses[2],
          'barrasDobles': responses[3],
          'radar': responses[4],
        };
        _cargandoGraficas = false;
      });
    } catch (error) {
      setState(() => _cargandoGraficas = false);
      _mostrarError('Error al cargar gráficas: ${error.toString()}');
    }
  }

  //Obtiene datos para graficas
  Future<dynamic> _obtenerDatosGraficaBarras() async {
    final response = await ResenaService.obtenerDatosGraficaBarras(
      widget.habitacionId,
    );
    return ResenaService.extraerDatos(response);
  }

  Future<dynamic> _obtenerDatosGraficaLineas() async {
    final response = await ResenaService.obtenerEvolucionCalificaciones(
      widget.habitacionId,
    );
    return ResenaService.extraerDatos(response);
  }

  Future<dynamic> _obtenerDatosGraficaArea() async {
    final response = await ResenaService.obtenerDatosGraficaArea(
      widget.habitacionId,
    );
    return ResenaService.extraerDatos(response);
  }

  Future<dynamic> _obtenerDatosGraficaBarrasDobles() async {
    final response = await ResenaService.obtenerDatosGraficaBarrasDobles(
      widget.habitacionId,
    );
    return ResenaService.extraerDatos(response);
  }

  Future<dynamic> _obtenerDatosGraficaRadar() async {
    final response = await ResenaService.obtenerDatosGraficaRadar(
      widget.habitacionId,
    );
    return ResenaService.extraerDatos(response);
  }

  // Carga la lista de reseñas
  Future<void> _cargarResenas() async {
    try {
      final response = await ResenaService.obtenerResenasHabitacion(
        widget.habitacionId,
      );

      if (response['success'] == true) {
        setState(() {
          _resenas = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Error al cargar reseñas');
      }
    } catch (error) {
      setState(() => _isLoading = false);
      _mostrarError('Error al cargar reseñas: ${error.toString()}');
    }
  }

  // Cambia vista
  void _cambiarVista(bool mostrarGraficas) {
    setState(() {
      _mostrarGraficas = mostrarGraficas;
    });

    // Cargar datos necesario
    if (mostrarGraficas && _datosGraficas.isEmpty) {
      _cargarDatosGraficas();
    } else if (!mostrarGraficas && _resenas.isEmpty) {
      _cargarResenas();
    }
  }

  // Mensaje error
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  // Formatea una fecha
  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.purple[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _mostrarGraficas
                        ? 'Gráficas de Reseñas'
                        : 'Reseñas de la Habitación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.purple[700]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botones para cambiar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarGraficas
                          ? null
                          : () => _cambiarVista(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mostrarGraficas
                            ? Colors.purple[700]
                            : Colors.purple[100],
                        foregroundColor: _mostrarGraficas
                            ? Colors.white
                            : Colors.purple[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Ver Gráficas'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarGraficas
                          ? () => _cambiarVista(false)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mostrarGraficas
                            ? Colors.purple[100]
                            : Colors.purple[700],
                        foregroundColor: _mostrarGraficas
                            ? Colors.purple[700]
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Ver Reseñas'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contenido principal
              if (_mostrarGraficas) _buildVistaGraficas(),
              if (!_mostrarGraficas) _buildVistaResenas(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVistaGraficas() {
    return Expanded(
      child: Column(
        children: [
          _buildSelectorGraficas(),
          SizedBox(height: 16),
          Expanded(
            child: _cargandoGraficas
                ? Center(child: CircularProgressIndicator())
                : _buildGraficaSeleccionada(),
          ),
        ],
      ),
    );
  }

  // Construye el seleccicionador de gráficas
  Widget _buildSelectorGraficas() {
    final graficas = [
      {
        'tipo': 'barras',
        'icono': Icons.bar_chart,
        'titulo': 'Barras',
        'descripcion': 'Promedio de calificaciones por categoría',
      },
      {
        'tipo': 'lineas',
        'icono': Icons.show_chart,
        'titulo': 'Líneas',
        'descripcion': 'Evolución de calificaciones en el tiempo',
      },
      {
        'tipo': 'area',
        'icono': Icons.area_chart,
        'titulo': 'Área',
        'descripcion': 'Promedio acumulado de calificaciones',
      },
      {
        'tipo': 'barrasDobles',
        'icono': Icons.bar_chart_outlined,
        'titulo': 'B. Dobles',
        'descripcion':
            'Comparación de calificaciones entre arrendador y cuarto',
      },
      {
        'tipo': 'radar',
        'icono': Icons.pentagon,
        'titulo': 'Radar',
        'descripcion': 'Perfil completo de calificaciones por categoría',
      },
    ];

    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: graficas.length,
        itemBuilder: (context, index) {
          final grafica = graficas[index];
          return _buildBotonGrafica(grafica);
        },
      ),
    );
  }

  // Construye un botón para cada grafica
  Widget _buildBotonGrafica(Map<String, dynamic> grafica) {
    final bool seleccionada = _tipoGraficaSeleccionada == grafica['tipo'];

    return Container(
      width: 80,
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: grafica['descripcion'],
        child: InkWell(
          onTap: () {
            setState(() {
              _tipoGraficaSeleccionada = grafica['tipo'];
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: seleccionada ? Colors.purple[700] : Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: seleccionada ? Colors.purple[700]! : Colors.purple[200]!,
              ),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  grafica['icono'],
                  color: seleccionada ? Colors.white : Colors.purple[700],
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  grafica['titulo'],
                  style: TextStyle(
                    fontSize: 10,
                    color: seleccionada ? Colors.white : Colors.purple[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construye la gráfica seleccionada
  Widget _buildGraficaSeleccionada() {
    final datos = _datosGraficas[_tipoGraficaSeleccionada];

    if (datos == null || (datos is List && datos.isEmpty)) {
      return _buildPlaceholderSinDatos();
    }

    // Seleccionar el widget de gráfica
    switch (_tipoGraficaSeleccionada) {
      case 'barras':
        return _buildGraficaBarras(datos);
      case 'lineas':
        return _buildGraficaLineas(datos);
      case 'area':
        return _buildGraficaArea(datos);
      case 'barrasDobles':
        return _buildGraficaBarrasDobles(datos);
      case 'radar':
        return _buildGraficaRadar(datos);
      default:
        return Center(
          child: Text(
            'Gráfica no implementada',
            style: TextStyle(color: Colors.purple[600]),
          ),
        );
    }
  }

  Widget _buildGraficaBarras(dynamic datos) {
    double promedioGeneral = 0.0;
    if (datos is List && datos.isNotEmpty) {
      double suma = 0.0;
      for (final item in datos) {
        suma += (item['valor'] as num).toDouble();
      }
      promedioGeneral = suma / datos.length;
    }

    final List<BarChartGroupData> barGroups = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: promedioGeneral,
            color: _getColorPorValor(promedioGeneral),
            width: 40,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ];

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "Promedio General: ${promedioGeneral.toStringAsFixed(2)}",
                const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),

        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),

        titlesData: FlTitlesData(
          show: true,

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Promedio General',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1.0,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt()) {
                  return Row(
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple[600],
                        ),
                      ),
                      const SizedBox(width: 3),

                      const Icon(Icons.star, size: 12, color: Colors.amber),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        minY: 0,
        maxY: 5,
      ),
    );
  }

  Widget _buildGraficaLineas(dynamic datos) {
    final datosLimitados = datos is List && datos.length > 8
        ? datos.sublist(datos.length - 8)
        : datos;

    final List<FlSpot> spots = datosLimitados.asMap().entries.map<FlSpot>((
      entry,
    ) {
      final index = entry.key;
      final item = entry.value;
      return FlSpot(index.toDouble(), (item['calificacion'] as num).toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  "Calificación: ${spot.y.toStringAsFixed(1)}",
                  const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.purple[700]!,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: true),
          ),
        ],

        gridData: FlGridData(show: true),

        titlesData: FlTitlesData(
          show: true,

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < spots.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Renta ${value.toInt() + 1}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.purple,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1.0,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt()) {
                  return Text(
                    '${value.toInt()}⭐',
                    style: const TextStyle(fontSize: 10, color: Colors.purple),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),

        minY: 0,
        maxY: 5,
      ),
    );
  }

  Widget _buildGraficaArea(dynamic datos) {
    final datosLimitados = datos is List && datos.length > 8
        ? datos.sublist(datos.length - 8)
        : datos;

    final List<FlSpot> spots = datosLimitados.asMap().entries.map<FlSpot>((
      entry,
    ) {
      final index = entry.key;
      final item = entry.value;
      return FlSpot(
        index.toDouble(),
        (item['promedioAcumulado'] as num).toDouble(),
      );
    }).toList();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  "Renta ${touchedSpot.x.toInt() + 1}\n"
                  "Promedio: ${touchedSpot.y}",
                  const TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.purple[700]!,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple[700]!.withOpacity(0.3),
            ),
            dotData: FlDotData(show: false),
          ),
        ],

        gridData: FlGridData(show: true),

        titlesData: FlTitlesData(
          show: true,

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox.shrink();
                int index = value.toInt();
                if (index < 0 || index >= datosLimitados.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Renta ${index + 1}",
                    style: TextStyle(fontSize: 10, color: Colors.purple[700]),
                  ),
                );
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1.0,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt()) {
                  return Text(
                    '${value.toInt()}⭐',
                    style: TextStyle(fontSize: 10, color: Colors.purple[600]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        minY: 0,
        maxY: 5,
      ),
    );
  }

  Widget _buildGraficaBarrasDobles(dynamic datos) {
    final lista = datos is List ? datos : <dynamic>[];
    final datosLimitados = lista.length > 7
        ? lista.sublist(lista.length - 7)
        : lista;

    final List<BarChartGroupData> barGroups = List.generate(
      datosLimitados.length,
      (index) {
        final item = datosLimitados[index];
        final double califArrendador = (item['califArrendador'] as num)
            .toDouble()
            .clamp(0.0, 5.0);
        final double califCuarto = (item['califCuarto'] as num)
            .toDouble()
            .clamp(0.0, 5.0);
        final String nombre =
            item['nombre']?.toString() ?? 'Reseña ${index + 1}';
        final int indice = (item['indice'] as num?)?.toInt() ?? (index + 1);

        return BarChartGroupData(
          x: indice,
          groupVertically: false,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: califArrendador,
              color: Colors.blue,
              width: 12,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: califCuarto,
              color: Colors.green,
              width: 12,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        );
      },
    );

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = datosLimitados[groupIndex];
              final double califArrendador = (item['califArrendador'] as num)
                  .toDouble();
              final double califCuarto = (item['califCuarto'] as num)
                  .toDouble();
              final String nombre =
                  item['nombre']?.toString() ?? 'Reseña ${groupIndex + 1}';
              final int indice =
                  (item['indice'] as num?)?.toInt() ?? (groupIndex + 1);

              String texto = '';
              Color colorTexto = Colors.purple;

              if (rodIndex == 0) {
                texto =
                    'Calif. $indice - Arrendador\n${califArrendador.toStringAsFixed(1)} ⭐\n$nombre';
                colorTexto = Colors.blue;
              } else {
                texto =
                    'Calif. $indice - Cuarto\n${califCuarto.toStringAsFixed(1)} ⭐\n$nombre';
                colorTexto = Colors.green;
              }

              return BarTooltipItem(
                texto,
                TextStyle(
                  color: colorTexto,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),

        barGroups: barGroups,

        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 1),
        ),

        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 1),
        ),

        titlesData: FlTitlesData(
          show: true,

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 1 && index <= datosLimitados.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Calif. $index',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1.0,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == value.toInt() && value >= 0 && value <= 5) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple[600],
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, color: Colors.blue),
                      const SizedBox(width: 4),
                      const Text(
                        'Arrendador',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 10, height: 10, color: Colors.green),
                      const SizedBox(width: 4),
                      const Text(
                        'Cuarto',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            axisNameSize: 80,
          ),

          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        alignment: BarChartAlignment.spaceAround,
        groupsSpace: 24,
        minY: 0,
        maxY: 5,
      ),
    );
  }

  Widget _buildGraficaRadar(dynamic datos) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: RadarChart(
        RadarChartData(
          radarTouchData: RadarTouchData(),

          dataSets: [
            RadarDataSet(
              dataEntries: datos.map<RadarEntry>((item) {
                return RadarEntry(value: item['valor']?.toDouble() ?? 0.0);
              }).toList(),
              fillColor: Colors.purple[700]!.withOpacity(0.3),
              borderColor: Colors.purple[700]!,
              borderWidth: 2,
            ),
          ],

          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(color: Colors.grey[300]!, width: 1),

          titlePositionPercentageOffset: 0.12,

          getTitle: (index, angle) {
            final categoria = datos[index]['categoria'];
            final valor = (datos[index]['valor'] ?? 0).toStringAsFixed(1);
            return RadarChartTitle(text: '$categoria\n$valor⭐');
          },
          titleTextStyle: TextStyle(
            color: Colors.purple[700]!,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),

          tickCount: 6,
          ticksTextStyle: TextStyle(color: Colors.grey[600]!, fontSize: 10),
          tickBorderData: BorderSide(color: Colors.grey[300]!, width: 1),

          gridBorderData: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
    );
  }

  Widget _buildPlaceholderSinDatos() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.purple[300]),
          SizedBox(height: 16),
          Text(
            'No hay datos para mostrar',
            style: TextStyle(color: Colors.purple[600], fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega reseñas para ver las gráficas',
            style: TextStyle(color: Colors.purple[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Obtiene color según el valor de calificación
  Color _getColorPorValor(double valor) {
    if (valor >= 4.0) return Colors.green;
    if (valor >= 3.0) return Colors.orange;
    if (valor >= 2.0) return Colors.yellow[700]!;
    return Colors.red;
  }

  // Construye la vista de lista de reseñas
  Widget _buildVistaResenas() {
    return Expanded(
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
              ),
            )
          : _resenas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.reviews, size: 64, color: Colors.purple[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay reseñas aún',
                    style: TextStyle(color: Colors.purple[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sé el primero en compartir tu experiencia',
                    style: TextStyle(color: Colors.purple[500], fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _resenas.length,
              itemBuilder: (context, index) {
                final resena = _resenas[index];
                final fecha = DateTime.parse(resena['fechaReseña']).toLocal();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de la reseña con nombre y fecha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              resena['nombre'] ?? 'Anónimo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.purple[800],
                              ),
                            ),
                            Text(
                              _formatearFecha(fecha),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Calificación general con estrellas
                        if (resena['calificacionGeneral'] != null)
                          Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${resena['calificacionGeneral'].toStringAsFixed(1)}',
                                style: TextStyle(
                                  color: Colors.purple[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                        // Duración de la renta
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.purple[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${resena['duracionRenta']} meses',
                              style: TextStyle(
                                color: Colors.purple[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Comentario principal
                        Text(
                          resena['comentario'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),

                        // Comentario adicional sobre el arrendatario
                        if (resena['comentarioArrendatario'] != null &&
                            resena['comentarioArrendatario']
                                .toString()
                                .isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                'Sobre el arrendatario:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                resena['comentarioArrendatario'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
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
}
