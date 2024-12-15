import 'package:flutter/widgets.dart';
import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/presentation/cobranzas/cobro_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_force/presentation/cobranzas/helpers/extend_cobros_list.dart';

class CobrosList extends StatefulWidget {
  const CobrosList({super.key});

  @override
  State<CobrosList> createState() => _CobrosListState();
}

class _CobrosListState extends State<CobrosList> {
  late Future<List<Map<String, dynamic>>> _cobrosFuture;
  List<Map<String, dynamic>> cobros = [];
  List<Map<String, dynamic>> filteredCobros = [];
  List<Map<String, dynamic>> filteredCobroCopy = [];
  final int _pageSize = 15 ; // Tamaño de cada página
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMoreCobros = true;
  final TextEditingController _searchController = TextEditingController();
  TextEditingController inputValue = TextEditingController();
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';


  getCobroForId() async {

  final payment = await getCobrosForId('15');

      print('Este es el cobro $payment');
  }

    Future<void> _refreshCobros() async {

  setState(() {
_cobrosFuture =
        getCobros(page: cobros.length ~/ _pageSize + 1, pageSize: _pageSize);
    });

  // Esperar a que la actualización se complete
  await _cobrosFuture.then((data) {
    setState(() {
      cobros = data;
      filteredCobros = cobros;
      filteredCobroCopy = cobros;
    });
  });

  _filterCobros(_searchQuery); // Aplicar el filtro de búsqueda después de refrescar

 
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
   getCobroForId();

    _cobrosFuture =
        getCobros(page: cobros.length ~/ _pageSize + 1, pageSize: _pageSize);
    _cobrosFuture.then((data) {
      setState(() {
        cobros = data;
        filteredCobros = cobros;
        filteredCobroCopy = cobros;
      });
    });
  }

Future<void> _loadMoreCobros() async {
  if (_isLoading || !_hasMoreCobros) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final List<Map<String, dynamic>> newData = await getCobros(
      page: (cobros.length ~/ _pageSize) + 1, 
      pageSize: _pageSize
    );

    print('New data $newData');

    if (newData.isNotEmpty) {
      setState(() {
        for (var cob in newData) {
          bool exists = cobros.any((existingCobros) => existingCobros['id'] == cob['id']);
          if (!exists) {
            cobros = [...cobros, cob];
            filteredCobros = [...filteredCobros, cob];
            filteredCobroCopy = [...filteredCobros];
          }
        }
        _hasMoreCobros = newData.length == _pageSize;
      });
    } else {
      setState(() {
        _hasMoreCobros = false;
      });
    }
    print("Esto es el valor de cobros después de agregar el siguiente: $cobros");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _onScroll() {
    print('Entre aqui ');
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreCobros();
    }
  }

  void _filterCobros(String query)  async {
        _searchQuery = query; // Almacenar la consulta de búsqueda

    List<Map<String, dynamic>> filtered = await getCobrosForSearchBar(query);

  setState(() {
    filteredCobros = filtered;
    filteredCobroCopy = filtered;
  });
  }

  double parseNumberToDouble(String number) {
    number = number.replaceAll('.', '').replaceAll(',', '.');
    return double.parse(number);
  }

  void _filterByMaxPrice(double maxPrice) {
    setState(() {
      filteredCobros = cobros.where((cobro) {
        double monto = cobro['pay_amt'];
        return monto <= maxPrice;
      }).toList();

      filteredCobros.sort((a, b) {
        double montoA = a['pay_amt'];
        double montoB = b['pay_amt'];
        return montoB.compareTo(montoA);
      });
    });
  }

    @override
  void didChangeDependencies() {
    _refreshCobros();
    super.didChangeDependencies();
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
                      borderSide: BorderSide(width: 1, color: Colors.white))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                inputValue.clear();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                    fontFamily: 'Poppins SemiBold', color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {

                final double maxPrice = double.tryParse(inputValue.text) ??
                    0.0; // Convertir a double
                print("esto es el maxprice ${inputValue.text}");
                _filterByMaxPrice(maxPrice);
                Navigator.of(context).pop();
                inputValue.clear();
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                    fontFamily: 'Poppins SemiBold', color: Color(0xFF00722D)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _sortByDateRange(DateTime start, DateTime end) {
    // Guardar start y end en variables locales
    final startDate = start;
    final endDate = end;

    print("fecha start $start y fecha end $end este es el filteredCobroCopy $filteredCobroCopy");
    setState(() {
      filteredCobros = filteredCobroCopy.where((cobro) {
        print('el cobro es $cobro');
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        try {
          if (cobro['date'] != null && cobro['date'] != '') {
            
            print("ventas  ${cobro['date']}");

            final ventaDate = dateFormat.parse(cobro['date']);
            return ventaDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
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
      print("FItered Ventas $filteredCobros ");
      // Ordena las ventas dentro del rango de fechas seleccionado
      filteredCobros.sort((a, b) {
        final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
        final DateTime dateA = inputFormat.parse(a['date']);
        final DateTime dateB = inputFormat.parse(b['date']);

        // Formatea las fechas como "yyyy-mm-dd" antes de compararlas
        final String formattedDateA =
            '${dateA.year}-${dateA.month.toString().padLeft(2, '0')}-${dateA.day.toString().padLeft(2, '0')}';
        final String formattedDateB =
            '${dateB.year}-${dateB.month.toString().padLeft(2, '0')}-${dateB.day.toString().padLeft(2, '0')}';

        return formattedDateA.compareTo(formattedDateB);
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

  void _showFilterOptions(BuildContext context, screenMax) {
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
          const Offset(
              20, 180), // Punto de inicio en la esquina superior izquierda
          const Offset(
              175, 240), // Punto de fin en la esquina superior izquierda
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
                  color: const Color(0XFF00722D),
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
                
                 _cobrosFuture =
                getCobros(page: cobros.length ~/ _pageSize + 1, pageSize: _pageSize);
                _cobrosFuture.then((data) {
                setState(() {
                  cobros = data;
                  filteredCobros = cobros;
                  filteredCobroCopy = cobros;
                });
              });

            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Row(
              children: [
                Icon(Icons.attach_money, color: const Color(0XFF00722D),),
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
                  'lib/assets/Calendario.png',
                  width: 25,
                  color: const Color(0XFF00722D),
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
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 245, 235), 
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Lista de Cobros'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.035,
                ),
                Container(
                  width: screenMax,
                  height: screenMax * 0.19,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 7,
                        spreadRadius: 2,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCobros,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(
                        fontFamily: 'Poppins Regular',
                        color: Colors.black,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 28,
                        horizontal: 20,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide.none, // Color del borde
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 25,
                        ), // Color del borde cuando está enfocado
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 25,
                        ), // Color del borde cuando no está enfocado
                      ),
                      label: SizedBox(
                          width: screenMax * 0.97,
                          child: Text('Buscar por nombre o numero de orden')),
                      suffixIcon: Image.asset('lib/assets/Lupa.png'),
                    ),
                    style: const TextStyle(fontFamily: 'Poppins Regular'),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.025,
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
                        _showFilterOptions(context, screenMax);
                      },
                      alignment: Alignment.bottomLeft,
                    ),

                    IconButton(
                      icon: Icon(Icons.refresh,
                        color: Color(0XFF00722D),),
                       
                      onPressed: () {
                        _refreshCobros();
                      },
                      alignment: Alignment.bottomLeft,
                      ),
                    
                    
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.025,
                ),
               CobrosListExtend(
                cobrosFuture: _cobrosFuture,
                filteredCobros: filteredCobros,
                scrollController: _scrollController,
                isLoading: _isLoading,
                screenMax: screenMax,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
