import 'dart:async';

import 'package:sales_force/config/app_bar_sales_force.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/presentation/clients/add_clients.dart';
import 'package:sales_force/presentation/clients/clients_details.dart';
import 'package:sales_force/presentation/clients/filter_dialog_clients.dart';
import 'package:flutter/material.dart';

class Clients extends StatefulWidget {
  const Clients({super.key});

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
  String _filter = "Todos";
  late ScrollController _scrollController;
  bool _showAddButton = true;
  late List<Map<String, dynamic>> clients = [];
  late List<Map<String, dynamic>> searchClient = [];
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredClients = [];
  final int _pageSize = 10;
  String input = "";
  bool _isLoading = false;
  bool _hasMoreProducts = true;

  Future<void> _loadClients() async {
    final clientes = await getClientsScreen(page: 1, pageSize: _pageSize);

    print("Estoy obteniendo Clientes $clientes");
    setState(() {
      clients = clientes;
      searchClient = clientes;
    });
  }

  Future<void> _loadMoreClients() async {
    if (_isLoading || !_hasMoreProducts) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> newData = await getClientsScreen(
          page: (clients.length ~/ _pageSize) + 1, pageSize: _pageSize);

      print('New data $newData');

      if (newData.isNotEmpty) {
        setState(() {
          for (var client in newData) {
            bool exists = clients
                .any((existingClient) => existingClient['id'] == client['id']);
            print('esto es exist $exists');
            print('Este es el cliente que sigue $client');
            if (!exists) {
              clients = [...clients, client];
            } else {
              setState(() {
                _hasMoreProducts = false;
              });
            }
          }
          _hasMoreProducts = newData.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreProducts = false;
        });
      }

      print(
          "esto es el valor de clientes despues de agrgarle el siguiente $clients");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreClients();
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      if (_showAddButton) {
        setState(() {
          _showAddButton = false;
        });
      }
    } else {
      if (!_showAddButton) {
        setState(() {
          _showAddButton = true;
        });
      }
    }
  }

  showFilterOptionsClients(BuildContext context) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    Completer<dynamic> completer = Completer<dynamic>();


  showMenu(
    shape: RoundedRectangleBorder( // Redondear los bordes del menú emergente
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(
  width: 5,
  color: Colors.grey.withOpacity(0.5), // Establece el color transparente como punto inicial del gradiente
        )
      ),
    elevation: 0,
    shadowColor: Colors.black,
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(
        const Offset(20, 380), // Punto de inicio en la esquina superior izquierda
        const Offset(150, 240), // Punto de fin en la esquina superior izquierda
      ),
      overlay.localToGlobal(Offset.zero) & overlay.size, // Tamaño del overlay
    ),
    items: <PopupMenuEntry>[
      
      PopupMenuItem(
          
          child: ListTile(
          title:   Padding(
            padding: const EdgeInsets.all(8.0),
            child:  Row(
              children: [
                Image.asset('lib/assets/Check@3x.png', width: 25,
                  color: const Color(0xFF00722D),
                ),
                SizedBox(width: MediaQuery.of(context).size.width *0.02,),
                const Text('Filtrar por Grupo', style: TextStyle(fontFamily: 'Poppins Regular',),),
              ],
            ),
          ),
          onTap: ()  {
                        Navigator.pop(context); // Cerrar el menú

            _showFilterOptions(context);
          },
                  ),
      ),
      PopupMenuItem(
        child: ListTile(
          title:  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset('lib/assets/Check@3x.png', width: 25, color: const Color(0xFF00722D),),
                SizedBox(width: MediaQuery.of(context).size.width *0.02,),
                const Text('Filtrar por Region', style: TextStyle(fontFamily: 'Poppins Regular') ,),
              ],
            ),
          ),
          onTap: () {
                        Navigator.pop(context); // Cerrar el menú

            _showFilterOptionsRegion(context);
          },
        ),
      ),
    ],
    color: Colors.white
  );

  
  
return completer.future;
  
}

  void _showFilterOptions(BuildContext context) async {
    final selectedFilter = await showDialog<String>(
      context: context,
      builder: (context) => FilterGroups(),
    );

    print("abc Esto es el valor del select $selectedFilter");

    if (selectedFilter != null) {
      setState(() {
        _filter = selectedFilter;

        _applyFilter();
        print("Esto es el filter $_filter");
      });
    }
  }

  void _showFilterOptionsRegion(BuildContext context) async {
    final selectedFilter = await showDialog<String>(
      context: context,
      builder: (context) => FilterRegions(),
    );

    print("XYZ Esto es el valor del select $selectedFilter");

    if (selectedFilter != null) {
      setState(() {
        _filter = selectedFilter;
        _applyFilterByRegion();
        print("Esto es el filter $_filter");
      });
    }
  }

  Future<void> _searchAndFilterClients(String input) async {
    print("Estoy entrando en el input cuando no está vacío");
    List<Map<String, dynamic>> dbResults = await getClientsByNameOrRUC(input);

    setState(() {
      searchClient = dbResults;
      print("Estos son los clientes por grupo $clients $input");
      _applyFilter();
    });
  }

  void _applyFilter() async {
    print('Entre aqui en apply filter');
    if (_filter.isNotEmpty && _filter != "Todos") {
      print('esto es el filter 2 $_filter');
      print(
          'Esto es el valor de searchclient antes de filtrarlo $searchClient');

      searchClient = await getClientsByGroup(_filter);

      setState(() {});

      print("Este es el searchClient nuevo $_filter $searchClient");
    } else if (_filter == 'Todos') {
      print('Entre aqui en todos $_filter');

      searchController.text = '';

      setState(() {
        searchClient = clients;
      });
    }
  }

  void _applyFilterByRegion() async {
    print('Entre aqui en apply filter');
    if (_filter.isNotEmpty && _filter != "Todos") {
      print('esto es el filter 2 $_filter');
      print(
          'Esto es el valor de searchclient antes de filtrarlo $searchClient');

      searchClient = await getClientsByRegion(_filter);

      setState(() {});

      print("Este es el searchClient nuevo $_filter $searchClient");
    } else if (_filter == 'Todos') {
      print('Entre aqui en todos $_filter');

      searchController.text = '';

      setState(() {
        searchClient = clients;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadClients();
    _scrollController = ScrollController();

    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (input == "" && _filter == 'Todos') {
      searchClient = clients.toList();
    }

    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final screenHight = MediaQuery.of(context).size.height * 0.8;

    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const AppBars(labelText: 'Clientes'),
              Positioned(
                left: 16,
                right: 16,
                top: 160,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 300,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          35.0), // Ajusta el radio de las esquinas
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey
                              .withOpacity(0.2), // Color de la sombra
                          spreadRadius: 2, // Extensión de la sombra
                          blurRadius: 3, // Difuminado de la sombra
                          offset:
                              const Offset(0, 2), // Desplazamiento de la sombra
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _filter = '';
                        }

                        setState(() {
                          input = value;
                          _searchAndFilterClients(value);
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 20.0),
                        hintText: 'Nombre del Cliente o CI',
                        labelStyle: const TextStyle(
                            color: Colors.black, fontFamily: 'Poppins Regular'),
                        suffixIcon: Image.asset('lib/assets/Lupa.png'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(255, 227, 245, 235),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Image.asset(
                          'lib/assets/filtro@3x.png',
                          width: 25,
                          height: 35,
                          color: Color(0XFF00722D),
                        ),
                        onPressed: () {
                          showFilterOptionsClients(context);
                        },
                      ),
                      IconButton(
                          onPressed: () {
                            _loadClients();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0XFF00722D),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: searchClient.length,
                      itemBuilder: (context, index) {
                        final client = searchClient[index];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenMax,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 50,
                                              width: screenMax,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0C5A74),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 2,
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  client['bp_name'].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 55,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: screenMax * 0.9,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'RIF/CI: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  client['ruc'] ==
                                                                          '{@nil: true}'
                                                                      ? ''
                                                                      : client[
                                                                              'ruc']
                                                                          .toString(),
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Poppins Regular'),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ))
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Correo: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  '${!client['email'].toString().contains('{@nil: true}') ? client['email'] : 'Sin Registro'}',
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Poppins Regular'),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                )),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Teléfono: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  '${client['phone'] is int ? client['phone'] : ''}',
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'Poppins Regular'),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _verMasClient(
                                                            client['id']
                                                                .toString());
                                                      },
                                                      child: Row(
                                                        children: [
                                                          const Text('Ver',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0XFF00722D))),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'lib/assets/Lupa-2@2x.png',
                                                            width: 25,
                                                            color: Color(
                                                                0XFF00722D),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // if (_showAddButton)
            //   Positioned(
            //       top: screenHight * 0.75,
            //       right: screenMax * 0.05,
            //       child: GestureDetector(
            //         onTap: () => Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //               builder: (context) => const AddClientsForm()),
            //         ),
            //         child: Image.asset(
            //           'lib/assets/Agg@2x.png',
            //           width: 80,
            //         ),
            //       )),
          ],
        ),
      ),
    );
  }

  void _verMasClient(String clientId) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final client = await db.query(
        'clients',
        where: 'id = ?',
        whereArgs: [int.parse(clientId)],
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClientDetailsScreen(client: client.first)),
      );
    } else {
      print('Error: db is null');
    }
  }
}
