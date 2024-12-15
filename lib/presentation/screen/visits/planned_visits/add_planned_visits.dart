import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/infrastructure/models/plan_visits.dart';
import 'package:sales_force/presentation/screen/visits/providers/visit_add_new_provider.dart';
import 'package:sales_force/presentation/screen/visits/providers/visits_planned_providers.dart';
import 'package:sales_force/presentation/screen/visits/selects/selects_visits_create_unplanned.dart';

class AddPlannedVisits extends StatefulWidget {
  final List<PlanVisits> customerVisitPlanned;
  const AddPlannedVisits({super.key, required this.customerVisitPlanned});

  @override
  State<AddPlannedVisits> createState() => _AddPlannedVisitsState();
}

class _AddPlannedVisitsState extends State<AddPlannedVisits> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fechaLocalControllerStart =
      TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  List<PlanVisits> filteredClients = [];
  TextEditingController searchController = TextEditingController();
  String selectedClientName = '';
  dynamic idPlanVisits;
  int bpartnerID = 0;
  dynamic addressend;
  String? nameCustomer;
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController observacionController = TextEditingController();
  final TextEditingController fechaIdempiereControllerStart =
      TextEditingController();
  dynamic latitude = 0;
  dynamic longitude = 0;
  var clientId;
  var orgId;
  int salesRepId = 0;
  // Lists
  final List<Map<String, dynamic>> _listConceptsVisits = [];
  final List<Map<String, dynamic>> _listAddressSalesRegion = [];
   final List<Map<String, dynamic>> _regionSalesVisits = [];
    List<PlanVisits> tempFilteredClients = [];
 

  //SELECTED
  int _selectedConceptsVisits = 0;
  int _selectedRegionSales = 0;
  int _selectAddressRegionSales = 0;
  int _selectedRegionSalesVisits = 0;

  //STRINGS

  String _textConceptsVisits = "";
  String _textAddressRegionSales = "";
  String _textRegionSalesVisits = "";

 loadCustomerSalesRegion(int salesRegionId) async {
  // Filtra los clientes que tienen el salesRepId específico

  setState(() {
   filteredClients = widget.customerVisitPlanned.where((client) {
      return client.cSalesRegionId == salesRegionId ;

  }).toList();
    _selectAddressRegionSales = 0; // Reiniciar selección de dirección
    _textAddressRegionSales = 'Dirección'; // Reiniciar texto de dirección
    _listAddressSalesRegion.clear();
    _listAddressSalesRegion
        .add({'c_bpartner_location_id': 0, 'name': 'Dirección'});

    // Agrega las regiones filtradas a la lista
   tempFilteredClients = List.from(filteredClients);

  });
}



  loadList() async {
    List<Map<String, dynamic>> getConceptsVisit = await getConceptsVisits();

     List clientIds = widget.customerVisitPlanned.map((client) => client.cBPartnerId).toList();

    List<Map<String, dynamic>> regions = await getRegionsForClients(clientIds);

    print('Visits concepts $getConceptsVisit');

    print('Estos son las regiones id $regions');

    _listConceptsVisits
        .add({'gss_customer_visit_concept_id': 0, 'name': 'Motivo de Visita'});
    _listAddressSalesRegion
        .add({'c_bpartner_location_id': 0, 'name': 'Dirección'});
         _regionSalesVisits
        .add({'c_sales_region_id': 0, 'name': 'Región de ventas'});

    setState(() {
      _listConceptsVisits.addAll(getConceptsVisit);
      _regionSalesVisits.addAll(regions);
    });
  }

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

  showSelectionDialog(identifier) {
    switch (identifier) {
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
      case 'motivo':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)),
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

      case 'isVisitedClient':
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)),
              title: const Text('Aviso Importante'),
              content: const Text(
                  'Este cliente ya ha sido visitado. Por favor, selecciona otro que aún no haya sido visitado en nuestro plan de visitas.'),
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

  void _showClientSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStates) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35)),
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
                      onChanged: (value)  {
                        print('esto es tempFilteredClients $tempFilteredClients');
                        setStates(() {
                          tempFilteredClients =
                              tempFilteredClients.where((client) {
                            print('client state ${client.state}');
                            var name = client.bPartnerName.toLowerCase();
                            var searchTerm = value.toLowerCase();
                            return name.contains(searchTerm) &&
                                client.state != 'Visits';
                          }).toList();
                        });
                      },
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: tempFilteredClients.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime date = tempFilteredClients[index].dateCalendar;
                    String formattedDate =
                        DateFormat('dd/MM/yyyy').format(date);
                    bool visited =
                        false; // Variable para indicar si el cliente ha sido visitado

                    isPlanVisited(tempFilteredClients[index].id).then((value) {
                      visited = value;

                      if (visited == true) {
                        setStates(() {
                          tempFilteredClients[index].state = 'Visits';
                        });
                      }
                    });

                    return ListTile(
                      title: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tempFilteredClients[index].state == 'Visits'
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                tempFilteredClients[index].bPartnerName,
                                style: TextStyle(
                                    fontFamily: 'Poppins SemiBold',
                                    color:
                                        tempFilteredClients[index].state == 'Visits'
                                            ? Colors.white
                                            : Colors.black),
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                    fontFamily: 'Poppins Regular',
                                    color:
                                        tempFilteredClients[index].state == 'Visits'
                                            ? Colors.white
                                            : Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () async {
                        _selectAddressRegionSales = 0;

                        isPlanVisited(tempFilteredClients[index].id).then((value) {
                          if (value == true) {
                            showSelectionDialog('isVisitedClient');
                            clientNameController.clear();
                          } else {
                            return;
                          }
                        });

                        setState(() {
                          selectedClientName =
                              tempFilteredClients[index].bPartnerName;
                          clientNameController.text = selectedClientName;
                        });
                        print(
                            'este es el estado que tiene este cliente ${tempFilteredClients[index].state}');
                        setState(() {
                          bpartnerID = tempFilteredClients[index].cBPartnerId;
                          nameCustomer = tempFilteredClients[index].bPartnerName;
                          idPlanVisits = tempFilteredClients[index].gssCvpId;
                          _selectedRegionSales =
                              tempFilteredClients[index].cSalesRegionId;
                          idPlanVisits = tempFilteredClients[index].id;
                          salesRepId = tempFilteredClients[index].salesRepId;
                          addressend =
                              tempFilteredClients[index].cBPartnerLocationId;

                          
                        });

                     
                        

                        bool clientExists = _listAddressSalesRegion.any(
                            (client) =>
                                client['c_bpartner_id'] == bpartnerID &&
                                client['c_bpartner_location_id'] == addressend);

                        // Forma 1, Si existe un cbpartnertlocationId
                        if (addressend != "{@nil=true}") {
                          print('Entre aqui cuando no es null ');

                          if (clientExists) {
                            if (_listAddressSalesRegion.isNotEmpty) {
                              _listAddressSalesRegion.clear();
                              _listAddressSalesRegion.add({
                                'c_bpartner_location_id': 0,
                                'name': 'Dirección'
                              });
                            }

                            getClientAddressesForLocationId(addressend)
                                .then((value) {
                              setState(() {
                                _listAddressSalesRegion.removeWhere((client) =>
                                    client['c_bpartner_id'] == bpartnerID &&
                                    client['c_bpartner_location_id'] ==
                                        addressend);
                                _listAddressSalesRegion.addAll(value);
                                setState(() {
                                  _selectAddressRegionSales = addressend;
                                });
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
                              setState(() {
                                _listAddressSalesRegion.addAll(value);
                                setState(() {
                                  if(value.isNotEmpty){
                                 
                                    _selectAddressRegionSales = addressend;

                                  }
                                });
                              });
                            });
                          }
                        } else {
                          // Forma 2, si no existe una direccion por defecto
                          if (_listAddressSalesRegion.isNotEmpty) {
                            _listAddressSalesRegion.clear();
                            _listAddressSalesRegion.add({
                              'c_bpartner_location_id': 0,
                              'name': 'Dirección'
                            });
                          }

                          getClientAddressesBySalesRegion(
                                  bpartnerID, _selectedRegionSales)
                              .then((value) {
                            setState(() {
                              _listAddressSalesRegion.removeWhere((client) =>
                                  client['c_bpartner_id'] == bpartnerID &&
                                  client['c_bpartner_location_id'] ==
                                      addressend);
                              _listAddressSalesRegion.addAll(value);
                            });
                          });
                        }

                        print(
                            'estas son las direcciones de este cliente esto es region sales $_selectedRegionSales Esto es el addressSend ${addressend.toString()}  es el bpartnerId $bpartnerID, este es el nombre del cliente $nameCustomer, y este el idPlanVisits $idPlanVisits');
                        Navigator.of(context).pop();
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


  void cargarSalesRion(List<int> clientIds)async {

     dynamic customer = await getRegionsForClients(clientIds);

      print('Esto es el cliente por region $customer');


}

  @override
  void initState() {
    fechaLocalControllerStart.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    fechaIdempiereControllerStart.text =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // filteredClients = widget.customerVisitPlanned.where((client) {
    //   return client.state != "Visits";
    // }).toList();
    
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
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(
            label: 'Crear Nueva visita',
          ),
        ),
        body: Center(
          child: Container(
            width: mediaScreen,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: heightScreen * 0.05),
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
                        SizedBox(height: heightScreen * 0.01),
                        Container(
                          width: mediaScreen * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 2,
                                spreadRadius: 7,
                              )
                            ],
                          ),
                          child: TextField(
                            readOnly: true,
                            controller: fechaLocalControllerStart,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                            style: const TextStyle(
                              color: Color.fromARGB(138, 43, 41, 41),
                              fontFamily: 'Poppins Regular',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightScreen * 0.05),
                    Container(
                      width: mediaScreen * 0.88,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detalles',
                            style: TextStyle(
                                fontFamily: 'Poppins Bold', fontSize: 18),
                            textAlign: TextAlign.start,
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
                                // salesRepId = textConcepts['sales_red_id'];
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
                            height: heightScreen * 0.03,
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
                                          vertical: 7.0, horizontal: 5.0),
                                    ),
                                    alignment: Alignment.center,
                                    backgroundColor: WidgetStateProperty.all(
                                        const Color(0XFF0C5A74)),
                                  ),
                                  onPressed: () {
                                      if (filteredClients.isEmpty ||
                                          _selectedRegionSalesVisits == 0) {
                                        showSelectionDialog(
                                            'sales_region_customer');
                                      } else {
                                        print(
                                            'customer $filteredClients && _selectregion  $_selectedRegionSalesVisits');
                                        _showClientSelectionDialog();
                                      }
                                  },
                                  child: const Center(
                                      child:
                                          Icon(Icons.person_outline_rounded)),
                                ),
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
                                    ],
                                  ),
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
                                        borderRadius: BorderRadius.circular(35),
                                        borderSide: BorderSide.none,
                                      ),
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
                        ],
                      ),
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
                          _textAddressRegionSales = textAddressSalesRegion;
                        });
                        print(
                            'este es el valor seleccionado $_selectAddressRegionSales && $_textAddressRegionSales');
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
                            style:
                                const TextStyle(fontFamily: 'Poppins Regular'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: heightScreen * 0.06,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Coordenadas en el mapa',
                          style: TextStyle(
                              fontFamily: 'Poppins Bold', fontSize: 16),
                          textAlign: TextAlign.left,
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
                                  backgroundColor: const WidgetStatePropertyAll(
                                      Color.fromARGB(255, 176, 165, 165))),
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
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _showProgressIndicatorDialog();
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
                          height: heightScreen * 0.09,
                        ),
                        Container(
                            width: mediaScreen * 0.9,
                            height: heightScreen * 0.1,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        const WidgetStatePropertyAll(
                                            Color(0XFF00722D)),
                                    shape: WidgetStatePropertyAll(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35)))),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    Provider.of<VisitsPlannedProvider>(context,
                                            listen: false)
                                        .fetchVisits();

                                    if (_selectedConceptsVisits == 0) {
                                      showSelectionDialog('motivo');
                                      return;
                                    } else if (latitude == 0.0 &&
                                        longitude == 0.0) {
                                      showSelectionDialog(
                                          'thereAreCoordinates');
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
                                ))),
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

  void _saveVisitCustomer() async {
    setState(() {});
    String visitDate = fechaIdempiereControllerStart.text;
    int orgIds = orgId;
    int clientIds = clientId;
    int salesRId = salesRepId;
    int directionLocationId = _selectAddressRegionSales;
    String observacion = observacionController.text;
    dynamic latitde = latitude ?? 0.0;
    dynamic longitud = longitude ?? 0.0;
    String coordinates = '$latitde, $longitud';
    int concepVisit = _selectedConceptsVisits;
    String motivo = _textConceptsVisits;
    int salesRegionVisits = _selectedRegionSales;
    int? customerId = bpartnerID;
    String? bPartnerName = nameCustomer;

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      int visitId = await db.insert('visit_customer', {
        'c_bpartner_id': customerId,
        'direccion': _textAddressRegionSales,
        'c_bpname': bPartnerName,
        'c_bpartner_location_id': directionLocationId,
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
        'planned': 'SI'
      });

      if (visitId > 0) {
        // Actualizar el estado en la tabla plan_visits
        await updatePlanVisitState(
          id: idPlanVisits,
          newState: 'Visits',
        );
        print('Actualización del estado en plan_visits completada');
      } else {
        print('Error: No se pudo insertar el registro en visit_customer');
      }
    } else {
      print('Error: db is null');
    }

    fechaIdempiereControllerStart.clear();
    clientNameController.clear();
    direccionController.clear();
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
      _selectedRegionSales = 0;
      _selectAddressRegionSales = 0;
    });

    Provider.of<VisitsNewProvider>(context, listen: false).fetchVisits();
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
