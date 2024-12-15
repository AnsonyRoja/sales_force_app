import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:location/location.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/presentation/screen/visits/providers/visits_planned_providers.dart';
import 'package:sales_force/presentation/screen/visits/providers/visits_providers.dart';
import 'package:sales_force/presentation/screen/visits/selects/selects_visits_create_unplanned.dart';

class AddUnplannedVisits extends StatefulWidget {
  const AddUnplannedVisits({
    super.key,
  });

  @override
  State<AddUnplannedVisits> createState() => _AddUnplannedVisitsState();
}

class _AddUnplannedVisitsState extends State<AddUnplannedVisits> {
  final _formKey = GlobalKey<FormState>();
  dynamic addressend;

  //STRING
  String _textAddressRegionSales = "";

  //id
  int _selectAddressRegionSales = 0;

  final List<Map<String, dynamic>> _listAddressSalesRegion = [];

  showSelectionDialog(identifier) {
    switch (identifier) {
      case 'addressSalesRegion':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)),
              title: const Text('Selecciona una dirección del cliente'),
              content: const Text(
                  'Por favor selecciona una dirección para continuar.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      case 'thereAreCoordinates':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)),
              title: const Text('Aviso Importante'),
              content: const Text(
                  'Por favor, carga las coordenadas del dispositivo para continuar.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      case 'motivo':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Selecciona un motivo de visita'),
              content: const Text(
                  'Por favor selecciona un motivo de visita para continuar.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

      case 'sales_region_customer':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Selecciona una Region de Ventas'),
              content: const Text(
                  'Para continuar, selecciona una zona de ventas. Esto nos permitirá cargar la lista de clientes correspondientes a esa zona.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );

      case 'region_sales':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Selecciona una Región de Ventas'),
              content: const Text(
                  'Por favor selecciona una Región de ventas para continuar.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
    }
  }

  dynamic latitude = 0;
  dynamic longitude = 0;
  TextEditingController fechaLocalControllerStart = TextEditingController();
  TextEditingController fechaIdempiereControllerStart = TextEditingController();
  TextEditingController observacionController = TextEditingController();
  TextEditingController clientNameController =
      TextEditingController(); // Nuevo controlador para el nombre del cliente seleccionado
  String selectedClientName =
      ''; // Variable de estado para almacenar el nombre del cliente seleccionado
  TextEditingController searchController =
      TextEditingController(); // Controlador para el campo de búsqueda
  List<Map<String, dynamic>> filteredClients = []; // Lista filtrada de clientes
  dynamic idPlanVisits;
  int bpartnerID = 0;
  String? nameCustomer;
  List<Map<String, dynamic>> customer = [];
  var clientId;
  var orgId;
  int salesRepId = 0;
  dynamic gssCvpId;
// Lists

  final List<Map<String, dynamic>> _listConceptsVisits = [];
  final List<Map<String, dynamic>> _regionSalesVisits = [];

// Selected

  int _selectedConceptsVisits = 0;
  int _selectedRegionSalesVisits = 0;

// Texts

  String _textConceptsVisits = "";
  String _textRegionSalesVisits = "";

  void _showProgressIndicatorDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Guardando coordenadas..."),
            ],
          ),
        );
      },
    );
    await getCurrentLocation(); // Ejecuta la función para obtener la ubicación

    Navigator.of(context).pop();
  }

  void _showClientSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStates) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o RIF/CI',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setStates(() {
                          filteredClients = customer.where((client) {
                            var name = client['bp_name'].toLowerCase();
                            var ruc = client['ruc'].toLowerCase();
                            var searchTerm = value.toLowerCase();
                            return name.contains(searchTerm) ||
                                ruc.contains(searchTerm);
                          }).toList();
                        });
                        print(
                            'Estos son los clientes disponibles ${filteredClients}');
                      },
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: filteredClients.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime date =
                        DateTime.parse(filteredClients[index]['date_calendar']);
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(date);

                    print(
                        'esto es el cliente que se le cambio el estado a visited ${filteredClients[index]}');

                    return ListTile(
                      title: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                filteredClients[index]['bp_name'],
                                style: const TextStyle(
                                    fontFamily: 'Poppins SemiBold',
                                    color: Colors.black),
                              ),
                              Text(
                                filteredClients[index]['ruc'],
                                style: const TextStyle(
                                    fontFamily: 'Poppins Regular'),
                              ),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                    fontFamily: 'Poppins Regular',
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        setStates(() {
                          selectedClientName =
                              filteredClients[index]['bp_name'];
                          clientNameController.text =
                              selectedClientName; // Asignar el nombre al TextField
                        });
                        setState(() {
                          bpartnerID = filteredClients[index]['c_bpartner_id'];
                          nameCustomer = filteredClients[index]['bp_name'];
                          idPlanVisits = filteredClients[index]['id'];
                          addressend =
                              filteredClients[index]['c_bpartner_location_id'];
                        });
                        print('esto es el addreesend $addressend');
                        bool clientExists = _listAddressSalesRegion.any(
                            (client) =>
                                client['c_bpartner_id'] == bpartnerID &&
                                client['c_bpartner_location_id'] == addressend);

                        // Forma 1, Si existe un cbpartnertlocationId
                        if (addressend != "{@nil=true}") {
                          print('Entre aqui cuando no es null addreesend $addressend clientExist $clientExists');

                          if (clientExists) {
                            print('Eentre en clientes ');
                            if (_listAddressSalesRegion.isNotEmpty) {
                              _listAddressSalesRegion.clear();
                              _listAddressSalesRegion.add({
                                'c_bpartner_location_id': 0,
                                'name': 'Dirección'
                              });
                            }

                          print('Este es el valor de addressend ansony $addressend');
                            getClientAddressesForLocationId(addressend)
                                .then((value) {
                                  print('necesito saber cual es tu valor $value');
                              setState(() {
                                _listAddressSalesRegion.removeWhere((client) =>
                                    client['c_bpartner_id'] == bpartnerID &&
                                    client['c_bpartner_location_id'] ==
                                        addressend);
                                _listAddressSalesRegion.addAll(value);

                                _selectAddressRegionSales = addressend;
                              });
                            });
                          } else {
                            if (_listAddressSalesRegion.isNotEmpty) {
                              _listAddressSalesRegion.clear();
                              _listAddressSalesRegion.add({
                                'c_bpartner_location_id': 0,
                                'name': 'Dirección'
                              });
                            }

                            getClientAddressesForLocationId(addressend)
                                .then((value) {
                                  print('Este es el valor de getclientAddreses $value');
                              setState(() {
                                _listAddressSalesRegion.addAll(value);

                                if(value.isNotEmpty){

                                _selectAddressRegionSales = addressend;
                                }
                              });
                            });
                          } 
                          setState(() {
                           
                            
                                 _selectAddressRegionSales = 0 ;
                          });

                        } else {
                          // Forma 2, si no existe una direccion por defecto
                          print('Entre aqui en la forma 2');
                          _selectAddressRegionSales = 0;
                          if (_listAddressSalesRegion.isNotEmpty) {
                            _listAddressSalesRegion.clear();
                            _listAddressSalesRegion.add({
                              'c_bpartner_location_id': 0,
                              'name': 'Dirección'
                            });
                          }

                          getClientAddressesBySalesRegion(
                                  bpartnerID, _selectedRegionSalesVisits)
                              .then((value) {
                                print('Este es el valor de getClient address sales $value');
                            setState(() {
                              _listAddressSalesRegion.removeWhere((client) =>
                                  client['c_bpartner_id'] == bpartnerID &&
                                  client['c_bpartner_location_id'] ==
                                      addressend);
                              _listAddressSalesRegion.addAll(value);
                            });
                          });
                        }

                        print('Esto es el objeto de listAddressSalesRegion $_listAddressSalesRegion');

                        Navigator.of(context).pop(); // Cerrar el dialog
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  loadVariablesEnv() async {
    final info = await getApplicationSupportDirectory();

    final String filePathEnv = '${info.path}/.env';
    final File archivo = File(filePathEnv);

    String contenidoActual = await archivo.readAsString();
    print('Contenido actual del archivo:\n$contenidoActual');

    // Convierte el contenido JSON a un mapa
    Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

    setState(() {
      orgId = jsonData["OrgID"];
      clientId = jsonData["ClientID"];
    });

    print('Estas son las variables de entorno $orgId, $clientId');
  }

  loadList() async {
    List<Map<String, dynamic>> getConceptsVisit = await getConceptsVisits();
    List<Map<String, dynamic>> getSalesRegionVisits =
        await getRegionSalesVisits();

    print('Visits concepts $getConceptsVisit');


    _listConceptsVisits
        .add({'gss_customer_visit_concept_id': 0, 'name': 'Motivo de Visita'});
    _regionSalesVisits
        .add({'c_sales_region_id': 0, 'name': 'Región de ventas'});
    _listAddressSalesRegion
        .add({'c_bpartner_location_id': 0, 'name': 'Dirección'});
    print('Region sales visits $getSalesRegionVisits');

    setState(() {
      _listConceptsVisits.addAll(getConceptsVisit);
      _regionSalesVisits.addAll(getSalesRegionVisits);
    });
  }

  getCurrentLocation() async {
    Location location = Location();

    LocationData _locationData;

    _locationData = await location.getLocation();

    print('Esto es la localization $_locationData');

    setState(() {
      latitude = _locationData.latitude;
      longitude = _locationData.longitude;
    });

// String googleMapsUrl = 'https://www.google.com/maps?q=$latitude,$longitude';

//   Uri googleUrl = Uri.parse(googleMapsUrl);

    // await launchUrl(googleUrl);

    print('Esto es la latitude $latitude y la longitud $longitude');
  }

  loadCustomerSalesRegion(salesRegionId) async {
    customer = await getCustomerForSalesRegion(salesRegionId);

    setState(() {
      filteredClients = customer;
      _selectAddressRegionSales = 0; // Reiniciar selección de dirección
      _textAddressRegionSales = 'Dirección'; // Reiniciar texto de dirección
      _listAddressSalesRegion.clear();
      _listAddressSalesRegion
          .add({'c_bpartner_location_id': 0, 'name': 'Dirección'});
    });
    print('Esto es el custuomer $customer && este es el valor de listaddresssalesregion $_listAddressSalesRegion');
  }

  @override
  void initState() {
    fechaLocalControllerStart.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    fechaIdempiereControllerStart.text =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    filteredClients =
        customer; // Inicializar la lista filtrada con todos los clientes al inicio

    print('${fechaLocalControllerStart.text}');

    print('estos son los clientes que hay  disponibles ${customer}');

    loadList();
    loadVariablesEnv();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.9;
    final heightScreen = MediaQuery.of(context).size.height * 0.9;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 245, 235),
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(
              label: 'Crear Nueva visita',
            )),
        body: Center(
          child: Container(
            width: mediaScreen,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: heightScreen * 0.05,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Fecha',
                          style: TextStyle(
                            fontFamily: 'Poppins Regular',
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                          height: heightScreen * 0.01,
                        ),
                        Container(
                          width: mediaScreen * 0.9,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 2,
                                    spreadRadius: 7)
                              ]),
                          child: TextField(
                            readOnly: true,
                            controller: fechaLocalControllerStart,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none)),
                            style: const TextStyle(
                                color: Color.fromARGB(138, 43, 41, 41),
                                fontFamily: 'Poppins Regular'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: heightScreen * 0.04,
                    ),
                    Container(
                      width: mediaScreen * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalles',
                            style: TextStyle(
                                fontFamily: 'Poppins Bold', fontSize: 18),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(
                            height: heightScreen * 0.03,
                          ),
                          CustomDropdownButtonFormFieldCreatedVisits(
                            identifier: 'regionSalesVisits',
                            selectedIndex: _selectedRegionSalesVisits,
                            dataList: _regionSalesVisits,
                            text: _textRegionSalesVisits,
                            onSelected: (newValue, textConcepts) {
                              setState(() {
                                nameCustomer = '';
                                clientNameController.clear();
                                _selectedRegionSalesVisits = newValue ?? 0;
                                _textRegionSalesVisits =
                                    textConcepts['name'].toString();
                                salesRepId = textConcepts['sales_red_id'];
                              });

                              print(
                                  'este es el valor seleccionado $_selectedRegionSalesVisits && $_textRegionSalesVisits este es el representante comercial $salesRepId');
                              print(
                                  'Este es el balor de bpartnerId $bpartnerID y el nombre del cliente $nameCustomer');
                              loadCustomerSalesRegion(
                                  _selectedRegionSalesVisits);
                            },
                          ),
                          SizedBox(
                            height: heightScreen * 0.06,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: mediaScreen * 0.15,
                                height: heightScreen * 0.07,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      padding: WidgetStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              vertical: 7.0, horizontal: 5.0)),
                                      alignment: Alignment.center,
                                      backgroundColor:
                                          const WidgetStatePropertyAll(
                                              Color(0XFF0C5A74)),
                                    ),
                                    onPressed: () {
                                      if (customer.isEmpty ||
                                          _selectedRegionSalesVisits == 0) {
                                        showSelectionDialog(
                                            'sales_region_customer');
                                      } else {
                                        print(
                                            'customer $customer && _selectregion  $_selectedRegionSalesVisits');
                                        _showClientSelectionDialog();
                                      }
                                    },
                                    child: const Center(
                                        child: Icon(
                                            Icons.person_outline_rounded))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  width: mediaScreen * 0.9,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                        )
                                      ]),
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: clientNameController,
                                    decoration: InputDecoration(
                                      hintText: 'Selecciona un cliente',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(35),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(35),
                                          borderSide: BorderSide.none),
                                      errorStyle: const TextStyle(
                                          fontFamily: 'Poppins Regular'),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 20),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Tienes que seleccionar un cliente";
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: heightScreen * 0.06,
                          ),
                          CustomDropdownButtonFormFieldCreatedVisits(
                            identifier: 'addressRegionSalesPlanned',
                            selectedIndex: _selectAddressRegionSales,
                            dataList: _listAddressSalesRegion,
                            text: _textAddressRegionSales,
                            onSelected: (newValue, textAddressSalesRegion) {
                              setState(() {
                                _selectAddressRegionSales = newValue ?? 0;
                                _textAddressRegionSales =
                                    textAddressSalesRegion;
                              });

                              print(
                                  'este es el valor seleccionado $_selectAddressRegionSales && este es region sales $_textAddressRegionSales');
                            },
                          ),
                          SizedBox(
                            height: heightScreen * 0.06,
                          ),
                          CustomDropdownButtonFormFieldCreatedVisits(
                            identifier: 'conceptsVisits',
                            selectedIndex: _selectedConceptsVisits,
                            dataList: _listConceptsVisits,
                            text: _textConceptsVisits,
                            onSelected: (newValue, textConcepts) {
                              setState(() {
                                _selectedConceptsVisits = newValue ?? 0;
                                _textConceptsVisits = textConcepts;
                              });

                              print(
                                  'este es el valor seleccionado $_selectedConceptsVisits && $_textConceptsVisits');
                            },
                          ),
                          SizedBox(
                            height: heightScreen * 0.06,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Observacion',
                                style: TextStyle(
                                  fontFamily: 'Poppins Regular',
                                ),
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(
                                height: heightScreen * 0.01,
                              ),
                              Container(
                                width: mediaScreen * 0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          blurRadius: 7,
                                          spreadRadius: 2)
                                    ]),
                                child: TextField(
                                  maxLines: 3,
                                  controller: observacionController,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none)),
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: heightScreen * 0.06,
                          ),
                          const Text(
                            'Coordenadas en el mapa',
                            style: TextStyle(
                                fontFamily: 'Poppins Bold', fontSize: 16),
                          ),
                          SizedBox(
                            height: heightScreen * 0.02,
                          ),
                          Container(
                            width: mediaScreen * 0.9,
                            height: heightScreen * 0.1,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35))),
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                            Color.fromARGB(
                                                255, 176, 165, 165))),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirmar Guardado"),
                                        content: const Text(
                                            "¿Desea guardar las coordenadas actuales?"),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text("Cancelar"),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Cierra el diálogo
                                            },
                                          ),
                                          TextButton(
                                            child: const Text("Guardar"),
                                            onPressed: () async {
                                              Navigator.of(context)
                                                  .pop(); // Cierra el diálogo de confirmación
                                              _showProgressIndicatorDialog(); // Muestra el indicador de progreso
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Image.asset(
                                  'lib/assets/Mapa@3x.png',
                                  width: 45,
                                )),
                          ),
                          SizedBox(
                            height: heightScreen * 0.06,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: heightScreen * 0.03,
                    ),
                    Container(
                        width: mediaScreen * 0.9,
                        height: heightScreen * 0.1,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: const WidgetStatePropertyAll(
                                    Color(0XFF00722D)),
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(35)))),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                print(
                                    'este es el valor de sales Region $_selectedRegionSalesVisits');
                                if (_selectedConceptsVisits == 0) {
                                  showSelectionDialog('motivo');
                                  return;
                                } else if (_selectedRegionSalesVisits == 0) {
                                  showSelectionDialog('region_sales');
                                  return;
                                } else if (latitude == 0.0 &&
                                    longitude == 0.0) {
                                  showSelectionDialog('thereAreCoordinates');
                                  return;
                                } else if (_selectAddressRegionSales == 0) {
                                  showSelectionDialog('addressSalesRegion');
                                  return;
                                }

                                _saveVisitCustomer();
                              }
                            },
                            child: const Text(
                              'Crear',
                              style: TextStyle(
                                  fontFamily: 'Poppins Bold', fontSize: 18),
                            )))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveVisitCustomer() async {
    setState(() {});
    String visitDate = fechaIdempiereControllerStart.text;
    int orgIds = orgId;
    int clientIds = clientId;
    int salesRId = salesRepId;
    String observacion = observacionController.text;
    dynamic latitde = latitude ?? 0.0;
    dynamic longitud = longitude ?? 0.0;
    String coordinates = '$latitde, $longitud';
    int concepVisit = _selectedConceptsVisits;
    String motivo = _textConceptsVisits;
    int salesRegionVisits = _selectedRegionSalesVisits;
    int? customerId = bpartnerID;
    String? bPartnerName = nameCustomer;

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      int visitId = await db.insert('visit_customer', {
        'c_bpartner_id': customerId,
        'direccion': _textAddressRegionSales,
        'c_bpname': bPartnerName,
        'c_bpartner_location_id': _selectAddressRegionSales,
        'c_sales_region_id': salesRegionVisits,
        'coordinates': coordinates,
        'description': observacion,
        'end_date': '',
        'sales_rep_id': salesRId,
        'visit_date': visitDate,
        'gss_customer_visit_concept_id': concepVisit,
        'motivo': motivo,
        'record_customer_visit_id': 0,
        'ad_client_id': clientIds,
        'ad_org_id': orgIds,
        'latitude': latitde,
        'longitud': longitud,
        'state': 'No Visits',
        'planned': 'NO'
      });

      if (visitId > 0) {
        // Actualizar el estado en la tabla plan_visits
        // await updatePlanVisitState(
        //   id: idPlanVisits,
        //   newState: 'Visits UnPlanned',
        // );
        print('Actualización del estado en plan_visits completada');
      } else {
        print('Error: No se pudo insertar el registro en visit_customer');
      }
    } else {
      print('Error: db is null');
    }

    fechaIdempiereControllerStart.clear();
    clientNameController.clear();
    observacionController.clear();
    setState(() {
      _listAddressSalesRegion.removeWhere((client) =>
          client['c_bpartner_location_id'] == _selectAddressRegionSales);
      _textConceptsVisits = "";
      bpartnerID = 0;
      nameCustomer = null;
      latitude = 0;
      longitude = 0;
      _selectedConceptsVisits = 0;
      _selectedRegionSalesVisits = 0;
      _selectAddressRegionSales = 0;
    });

    Provider.of<VisitsProvider>(context, listen: false).fetchVisits();
    Provider.of<VisitsPlannedProvider>(context, listen: false).fetchVisits();

    print('Data inserted successfully');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Visita creada con éxito'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }
}
