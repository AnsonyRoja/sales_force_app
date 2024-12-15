import 'package:sales_force/presentation/products/utils/switch_generated_names_select.dart';
import 'package:flutter/material.dart';

class CustomDropdownButtonFormFieldCreatedVisits extends StatelessWidget {
  final String identifier;
  final int selectedIndex;
  final String text;
  final List<Map<String, dynamic>> dataList;
  final Function(dynamic, dynamic) onSelected;

  const CustomDropdownButtonFormFieldCreatedVisits(
      {super.key,
      required this.identifier,
      required this.selectedIndex,
      required this.dataList,
      required this.text,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.9;


    print('Esto es el dataList $identifier al seleccionar una region $dataList');
    switch (identifier) {
      case 'addressRegionSalesPlanned':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.9,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    spreadRadius: 2),
              ]),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
                .where((addressList) =>
                    addressList['c_bpartner_location_id'] is int &&
                    addressList['name'] != '')
                .map<DropdownMenuItem<int>>((address) {
              print('tax $address');
              return DropdownMenuItem<int>(
                value: address['c_bpartner_location_id'] as int,
                child: Text(
                  address['name'] as String,
                  style: const TextStyle(
                      fontFamily: 'Poppins Regular',
                      overflow: TextOverflow.ellipsis),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el address region sales ${dataList}');
              String nameAddress =
                  invoke('obtenerNombreAddressCustomerOnlyName', newValue, dataList);
              print("esto es el nombre del concepto seleccionado $nameAddress");
              onSelected(newValue, nameAddress);
            },
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color:
                          Colors.red)), // Añade un borde rojo cuando hay error
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color:
                          Colors.red)), // Añade un borde rojo cuando hay error
            ),
          ),
        );

      case 'conceptsVisits':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.9,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    spreadRadius: 2),
              ]),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
                .where((groupList) =>
                    groupList['gss_customer_visit_concept_id'] is int &&
                    groupList['name'] != '')
                .map<DropdownMenuItem<int>>((group) {
              print('tax $group');
              return DropdownMenuItem<int>(
                value: group['gss_customer_visit_concept_id'] as int,
                child: Text(
                  group['name'] as String,
                  style: const TextStyle(
                      fontFamily: 'Poppins Regular',
                      overflow: TextOverflow.ellipsis),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el concept visits ${dataList}');
              String nameGroup =
                  invoke('obtenerNombreConceptsVisits', newValue, dataList);
              print("esto es el nombre del concepto seleccionado $nameGroup");
              onSelected(newValue, nameGroup);
            },
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color:
                          Colors.red)), // Añade un borde rojo cuando hay error
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color:
                          Colors.red)), // Añade un borde rojo cuando hay error
            ),
          ),
        );
      case 'regionSalesVisits':
        return Container(
          height: mediaScreen * 0.22,
          width: mediaScreen * 0.9,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    spreadRadius: 2),
              ]),
          child: DropdownButtonFormField<int>(
            icon: Image.asset('lib/assets/Abajo.png'),
            value: selectedIndex,
            items: dataList
                .where((groupList) =>
                    groupList['c_sales_region_id'] is int &&
                    groupList['name'] != '')
                .map<DropdownMenuItem<int>>((group) {
              print('tax $group');
              return DropdownMenuItem<int>(
                value: group['c_sales_region_id'] as int,
                child: Text(
                  group['name'] as String,
                  style: const TextStyle(
                      fontFamily: 'Poppins Regular',
                      overflow: TextOverflow.ellipsis),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              print('esto es el concept visits ${dataList}');
              dynamic nameGroup =
                  invoke('obtenerNombreRegionSalesVisits', newValue, dataList);
              print("esto es el nombre de la region seleccionada $nameGroup");
              onSelected(newValue, nameGroup);
            },
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color:
                          Colors.red)), // Añade un borde rojo cuando hay error
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      color:
                          Colors.red)), // Añade un borde rojo cuando hay error
            ),
          ),
        );

      default:
        return DropdownButtonFormField<int>(
          value: selectedIndex,
          items: dataList
              .where((defaults) => defaults['key'] is int)
              .map<DropdownMenuItem<int>>((defaults) {
            return DropdownMenuItem<int>(
              value: defaults['key'] as int,
              child: Text(defaults['value'] as String),
            );
          }).toList(),
          onChanged: (newValue) {
            onSelected(newValue, 'Nada');
          },
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value == 0) {
              return 'Por favor crea el idenficiador del select';
            }
            return null;
          },
        );
    }
  }
}
