import 'package:flutter/material.dart';

class ServicesCheckboxGroup extends StatefulWidget {
  final List<String> selectedServices;
  final ValueChanged<List<String>> onServicesChanged;

  const ServicesCheckboxGroup({
    Key? key,
    required this.selectedServices,
    required this.onServicesChanged,
  }) : super(key: key);

  @override
  _ServicesCheckboxGroupState createState() => _ServicesCheckboxGroupState();
}

class _ServicesCheckboxGroupState extends State<ServicesCheckboxGroup> {
  final List<String> _availableServices = [
    'WiFi',
    'Agua',
    'Luz',
    'Cocina',
    'Lavandería',
    'Parqueadero',
    'Aire acondicionado',
    'Calefacción',
    'TV',
    'Internet'
  ];

  void _onServiceToggled(String service, bool selected) {
    List<String> updatedServices = List.from(widget.selectedServices);
    
    if (selected) {
      updatedServices.add(service);
    } else {
      updatedServices.remove(service);
    }
    
    widget.onServicesChanged(updatedServices);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios incluidos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.green[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona los servicios que incluye la habitación',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableServices.map((service) {
            final isSelected = widget.selectedServices.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              onSelected: (selected) => _onServiceToggled(service, selected),
              selectedColor: Colors.green[700],
              checkmarkColor: Colors.white,
              backgroundColor: Colors.green[50],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}