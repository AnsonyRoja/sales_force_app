import 'package:sales_force/config/app_bar_sales_force.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:sales_force/presentation/screen/ventas/ventas_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Ventas extends StatefulWidget {
  const Ventas({super.key});

  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  String _filter = "";
  DateTimeRange? _selectedDateRange; // Declare and initialize to null

  late List<Map<String, dynamic>> ventas = [];
  List<Map<String, dynamic>> filteredVentas = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController inputValue = TextEditingController();
  Future<Map<String, dynamic>>? _currencyData;


  String input = "";
  int? searchValue;

    
  Future<Map<String, dynamic>>? _loadCurrencyIs(listPrice) async {

    if (variablesG.isEmpty) {
                    List<Map<String, dynamic>> response =
                        await getPosPropertiesV();
              
                    setState(() {
                      variablesG = response;
                    });
                    
                  }    
    final typeCurrency = await typeOfCurrencyIs(listPrice == '{@nil: true}' ? variablesG[0]['m_pricelist_id'] : listPrice );
      
     
      return typeCurrency.first;
  
  }

  

  Future<void> _loadVentas() async {
    final ventasData =
        await getAllOrdersWithClientNames(); // Cambiar a la función de obtener ventas

    print("Esto es la venta Data $ventasData");

    setState(() {

      ventas = ventasData;
      filteredVentas = ventasData;

    });
  }

  @override
  void initState() {
    _loadVentas();
    super.initState();
  }

  double parseNumberToDouble(String number) {
  number = number.replaceAll('.', '').replaceAll(',', '.');
  return double.parse(number);
}

  void _filterByMaxPrice(double maxPrice) {
    setState(() {
        filteredVentas = ventas.where((venta) {
    double monto = parseNumberToDouble(venta['monto']);
    return monto <= maxPrice;
  }).toList();

  filteredVentas.sort((a, b) {
    double montoA = parseNumberToDouble(a['monto']);
    double montoB = parseNumberToDouble(b['monto']);
    return montoB.compareTo(montoA);
  }); 
    });
  }

  void _showDateRangePicker(BuildContext context) async {
    // Enhanced user experience with custom date range and better initial selection
    final picked = await showDateRangePicker(
      context: context,
      locale: const Locale("es", "ES"), 
      initialDateRange: DateTimeRange(
        start: DateTime.now()
            .subtract(const Duration(days: 7)), // Default to past week
        end: DateTime.now(),
      ),
      firstDate:
          DateTime(2010), // Adjust minimum year based on your requirements
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // Extend to a year from now
    );

    print("esto es picked $picked");
    if (picked != null) {
      print("Entre aqui");
      setState(() {
        _selectedDateRange = picked;
        _sortByDateRange(picked.start, picked.end);
      });
    }
  }

  void _sortByDateRange(DateTime start, DateTime end) {
    // Guardar start y end en variables locales
    final startDate = start;
    final endDate = end;

    print("fecha start $start y fecha end $end");
    setState(() {
      filteredVentas = ventas.where((venta) {
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        try {
          if (venta['fecha'] != null && venta['fecha'] != '') {
            print("ventas  ${venta['fecha']}");
            final ventaDate = dateFormat.parse(venta['fecha']);
            return ventaDate
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                ventaDate.isBefore(endDate.add(const Duration(days: 1)));
          } else {
            // La fecha está en blanco, por lo tanto, no cumple con la condición
            return false;
          }
        } catch (e) {
          print('Error al parsear la fecha: $e');
          return false; // O maneja el error de otra manera
        }
      }).toList();
      print("entre aqui para el sort o algoritmo de ordenamiento");
      print("FItered Ventas $filteredVentas ");
      // Ordena las ventas dentro del rango de fechas seleccionado
      filteredVentas.sort((a, b) {
        final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
        final DateTime dateA = inputFormat.parse(a['fecha']);
        final DateTime dateB = inputFormat.parse(b['fecha']);

        // Formatea las fechas como "yyyy-mm-dd" antes de compararlas
        final String formattedDateA =
            '${dateA.year}-${dateA.month.toString().padLeft(2, '0')}-${dateA.day.toString().padLeft(2, '0')}';
        final String formattedDateB =
            '${dateB.year}-${dateB.month.toString().padLeft(2, '0')}-${dateB.day.toString().padLeft(2, '0')}';

        return formattedDateA.compareTo(formattedDateB);
      });
    });
  }


  void _showMaxPriceDialog(BuildContext context, screenMedia) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          title: const Text('Ingrese el monto máximo'),
          content: Container(
            width: screenMedia,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 7,
                      spreadRadius: 2)
                ]),
            child: TextField(
              controller: inputValue, // Controlador para el campo de entrada
              keyboardType: TextInputType
                  .number, // Teclado numérico para ingresar el monto
              decoration: const InputDecoration(
                  hintText: 'Ingrese el monto máximo',
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(width: 1, color: Colors.white))
                      ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                inputValue.clear();
              },
              child: const Text('Cancelar', style: TextStyle(fontFamily: 'Poppins SemiBold', color: Colors.red),),
            ),
            TextButton(
              onPressed: () {
                // Obtener el valor ingresado por el usuario

                final double maxPrice = double.tryParse(inputValue.text) ??
                    0.0; // Convertir a double
                print("esto es el maxprice ${inputValue.text}");
                _filterByMaxPrice(maxPrice);
                Navigator.of(context).pop();
                inputValue.clear();
              },
              child: const Text('Aceptar', style: TextStyle(fontFamily: 'Poppins SemiBold', color: Color(0xFF7531ff)),),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context, colorPrimary, screenMax) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      shape: RoundedRectangleBorder(
          // Redondear los bordes del menú emergente
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            width: 5,
            color: Colors.grey.withOpacity(
                0.5), // Establece el color transparente como punto inicial del gradiente
          )),
      elevation: 2,
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          const Offset(20, 250), // Punto de inicio en la esquina superior izquierda
        const Offset(155, 240),  // Punto de fin en la esquina superior izquierda
        ),
        overlay.localToGlobal(Offset.zero) & overlay.size, // Tamaño del overlay
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            title: Row(
              children: [
                Image.asset(
                  'lib/assets/Check@3x.png',
                  width: 25,
                  color: const Color(0xFF00722D),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                const Text(
                  'Mostrar Todos',
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              _loadVentas();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Row(
              children: [
                Image.asset(
                  'lib/assets/Check@3x.png',
                  width: 25,
                  color: const Color(0xFF00722D),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                const Text(
                  'Filtrar Por el monto Mayor',
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              _showMaxPriceDialog(context, screenMax);
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Row(
              children: [
                Image.asset(
                  'lib/assets/Check@3x.png',
                  width: 25,
                  color: const Color(0xFF00722D),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                SizedBox(
                  width: 180,
                  child: const Text(
                    'Ordenar por un rango de fecha',
                    style: TextStyle(fontFamily: 'Poppins Regular'),
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              _showDateRangePicker(context);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final colorPrimary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {

          FocusScope.of(context).requestFocus(FocusNode());

      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 245, 235), 
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const AppBars(
                  labelText: 'Ventas',
                ),
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
                            9.0), // Ajusta el radio de las esquinas
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
                          if (searchController.text.isNotEmpty) {
                            setState(() {
                              _filter = "";
                            });
                          }
      
                          setState(() {
                            input = value.toLowerCase();
                            setState(() {
                              filteredVentas = ventas.where((venta) {
                                final numeroReferencia = venta['id'].toString();
                                final nombreCliente = venta['nombre_cliente']
                                    .toString()
                                    .toLowerCase();
                                final orderSale = venta['documentno'].toString();
                                return numeroReferencia.contains(input) ||
                                    nombreCliente.contains(input) ||
                                    orderSale.contains(input);
                              }).toList();
                            });
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 20.0),
                          hintText: 'Nombre del producto',
                          labelStyle: const TextStyle(
                              color: Colors.black, fontFamily: 'Poppins Regular'),
                          suffixIcon: Image.asset('lib/assets/Lupa.png'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {

                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    IconButton(
                      icon: Image.asset(
                        'lib/assets/filtro@3x.png',
                        width: 25,
                        height: 35,
                        color: Color(0XFF00722D),
                      ),
                      onPressed: () {
                        _showFilterOptions(context, colorPrimary, screenMax);
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredVentas.length,
                        itemBuilder: (context, index) {
                          final venta = filteredVentas[index];
      
                          print('Estas son las venta $venta');
                          _currencyData = _loadCurrencyIs(venta['m_price_list_id']);

      
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenMax,
                                  decoration: BoxDecoration(
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 170,
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
                                                      const EdgeInsets.all(15.0),
                                                  child: Text(
                                                   venta['documentno_factura'] != null && venta['documentno_factura'] != '{@nil=true}'
                                                    ? 'N° ${venta['documentno_factura'].toString()}'
                                                    : (venta['documentno'] == ''
                                                    ? 'N° ${venta['ruc'].toString()}'
                                                    : 'N° ${venta['documentno'].toString()}'),    
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Poppins Bold',
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.start,
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
                                                  width: screenMax * 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Nombre: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    '${venta['nombre_cliente']}',
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
                                                                'Fecha: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    '${venta['fecha']}',
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  )),
                                                            ],
                                                          ),

                                                          FutureBuilder(future: _currencyData, builder: (context, snapshot) {

                                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                                    return const CircularProgressIndicator();
                                                                  } else if (snapshot.hasError) {
                                                                    return Text('Error: ${snapshot.error}');
                                                                  } else {

                                                                final  currentCurrency = snapshot.data;

                                                                    return   Row(
                                                            children: [
                                                              const Text(
                                                                'Monto: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    '${venta['monto']} ${currentCurrency!['price_list_name'].toString().toLowerCase().contains('bs') ? 'Bs.': '\$'} ',
                                                                    style: const TextStyle(
                                                                        fontFamily:
                                                                            'Poppins Regular'),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ))
                                                            ],
                                                          );

                                                              }

                                                          },),
                                                        
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                'Descripción: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.40,
                                                                  child: Text(
                                                                    venta['descripcion']
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
                                                                'Estado: ',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Poppins SemiBold'),
                                                              ),
                                                              SizedBox(
                                                                  width:
                                                                      screenMax *
                                                                          0.35,
                                                                  child: Text(
                                                                    venta['doc_status'] == 'CO' ?
                                                                    "Completado": venta['doc_status'] == 'IP' || venta['doc_status'] == 'PR' ? "En Proceso" 
                                                                    : venta['doc_status'] == "VO" ? "Anulado": venta['doc_status'] ?? ""
                                                                        .toString(),
                                                                    style:  TextStyle(color: venta['doc_status'] == 'CO' || venta['doc_status'] == "Completado" ?  Color(0xFF00722D): venta['doc_status'] == 'PR' || venta['doc_status'] == 'IP' || venta['doc_status'] == 'En Proceso' ?
                                                                     const Color.fromARGB(255, 167, 153, 34) : venta['doc_status'] == 'VO'? Colors.red : Colors.black,
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
                                                          Navigator.of(context)
                                                              .push(
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  VentasDetails(
                                                                      ventaId:
                                                                          venta[
                                                                              'id'],
                                                                      nameClient:
                                                                          venta[
                                                                              'nombre_cliente'],
                                                                      saldoTotal:
                                                                          venta[
                                                                              'saldo_total'],
                                                                      rucClient:
                                                                          venta['ruc'],
                                                                      emailClient:
                                                                          venta['email'],
                                                                      phoneClient:
                                                                          venta['phone'].toString()
      
                                                                      ),
                                                            ),
                                                          );
                                                        },
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text('Ver',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF00722D))),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Image.asset(
                                                                'lib/assets/Lupa-2@2x.png',
                                                                width: 25,
                                                                color: Color(0XFF00722D),
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
            ),
          ],
        ),
      ),
    );
  }
}
