import 'package:sales_force/config/app_bar_sales_force.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/presentation/products/add_products.dart';
import 'package:sales_force/presentation/products/filter_dialog.dart';
import 'package:sales_force/presentation/products/products_details.dart';
import 'package:flutter/material.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String _filter = "";
  List<Map<String, dynamic>> products = [];
  dynamic filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  String input = "";
  late ScrollController _scrollController;
  bool _showAddButton = true;
  final int _pageSize = 25; // Tamaño de cada página
  bool _isLoading = false;
  bool _hasMoreProducts = true;

  late List<Map<String, dynamic>> taxes =
      []; // Lista para almacenar los impuestos

  Future<void> _loadProducts() async {
    final productos = await getProductsScreen(
        page: 1, pageSize: _pageSize); // Obtener todos los productos
    // final inserccion = await DatabaseHelper.instance.insertTaxData(); // Obtener todos los productos
    print("Estoy obteniendo products $products");

    setState(() {
      products = productos;
      filteredProducts = productos;
      _hasMoreProducts = productos.length == _pageSize;
    });
  }

  Future<void> _deleteBaseDatos() async {
    await DatabaseHelper.instance.deleteDatabases();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMoreProducts();
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

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMoreProducts) return;

      setState(() {
        _isLoading = true;
      });

    try {
      final List<Map<String, dynamic>> newData = await getProductsScreen(
          page: (products.length ~/ _pageSize) + 1, pageSize: _pageSize);

      print('New data $newData');

      if (newData.isNotEmpty) {
        setState(() {
          for (var prod in newData) {
            bool exists = products
                .any((existingProduct) => existingProduct['id'] == prod['id']);
            if (!exists) {
              products = [...products, prod];
            }
          }
          _hasMoreProducts = newData.length == _pageSize;
        });
      } else {
        setState(() {
          _hasMoreProducts = false; // No hay más productos para cargar
        });
      }
      print(
          "esto es el valor de productos despues de agrgarle el siguiente $products");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFilterOptions(BuildContext context) async {
    final selectedFilter = await showDialog<String>(
      context: context,
      builder: (context) => FilterCategories(
        products: products,
      ), // Reemplaza YourFilterDialog con tu widget de filtro
    );

    print("Esto es el valor del select $selectedFilter");

    if (selectedFilter != null) {
      setState(() {
        _filter = selectedFilter;
        print("Esto es el filter $_filter");
      });
    }
  }

  @override
  void initState() {
    _loadProducts();
    _scrollController = ScrollController();

    _scrollController.addListener(_scrollListener);
    print('Esto es el montaje');
    // _deleteBaseDatos();
    super.initState();
    // sincronizationProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (input == "") {
      filteredProducts = products.toList();
    }

    if (_filter != "" && input == "") {
      setState(() {
        if (_filter == "Todos") {
          searchController.clear();
          input = "";

          filteredProducts = products.toList();
        } else {
          filteredProducts = products
              .where((product) => product['categoria'] == _filter)
              .toList();
        }
        input = ""; // Limpiar el campo de búsqueda al filtrar por categoría
      });
    } else if (input != "") {
      setState(() {
        filteredProducts = products
            .where((product) =>
                product['name'].toLowerCase().contains(input.toLowerCase()))
            .toList();
      });
    }

    if (_filter != "" && _filter != "Todos") {
      filteredProducts =
          products.where((product) => product['categoria'] == _filter).toList();
      searchController.clear();
      input = "";
    } else if (_filter == "Todos") {
      searchController.clear();
      input = "";

      filteredProducts = products.toList();
    }

    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final screenHeight = MediaQuery.of(context).size.height * 0.8;

    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          // Verificar si hay un teclado visible
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(170),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const AppBars(
                labelText: 'Productos',
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
                      onChanged: (value) async {
                        setState(() {
                          input = value;
                          _filter =
                              ''; // Limpia el filtro para evitar conflictos
                        });

                        if (value.isNotEmpty) {
                          // Si el texto de búsqueda no está vacío
                          List<Map<String, dynamic>> searchResults = products
                              .where((product) => product['name']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();

                          if (searchResults.isNotEmpty) {
                            // Si se encontraron productos, actualiza filteredProducts
                            setState(() {
                              filteredProducts = searchResults;
                            });
                          } else {
                            // Si no se encontraron productos, realiza una búsqueda en la base de datos
                            List<Map<String, dynamic>> dbResults =
                                await getProductByName(value);
                            print("esto es dbresult $dbResults");
                            setState(() {
                              products = dbResults;
                            });
                          }
                        } else {
                          products = await getProductsScreen(
                              page: (products.length ~/ _pageSize) + 1,
                              pageSize: _pageSize);
                          setState(() {
                            filteredProducts = products.toList();
                          });
                        }
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
          ),
        ),

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
                        ),
                        onPressed: () {
                          _showFilterOptions(context);
                        },
                      ),
                      IconButton(
                          onPressed: () {
                            _loadProducts();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFF7531ff),
                          ))
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        if (index >= filteredProducts.length) {
                          return _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox();
                        }

                        final product = filteredProducts[index];

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
                                                color: const Color(0xFFF0EBFC),
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
                                                  product['categoria'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 18,
                                                    color: Colors.black,
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
                                                              'Nombre: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  '${product['name']}',
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
                                                              'Stock: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  '${product['quantity'] is int ? product['quantity'] : 0}',
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
                                                              'Precio: ',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Poppins SemiBold'),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    screenMax *
                                                                        0.45,
                                                                child: Text(
                                                                  '${product['price'] is double ? product['price'] : 0}\$',
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
                                                        _verMasProducto(
                                                            '${product['id']}');
                                                      },
                                                      child: Row(
                                                        children: [
                                                          const Text('Ver',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF7531FF))),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                              'lib/assets/Lupa-2@2x.png',
                                                              width: 25),
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
                  //esto para abajo es el navbar bottom
                ],
              ),
            ),
            if (_showAddButton)
              Positioned(
                  top: screenHeight * 0.75,
                  right: screenMax * 0.05,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProductForm()),
                    ),
                    child: Image.asset(
                      'lib/assets/Agregar@3x.png',
                      width: 80,
                    ),
                  )),
          ],
        ),
        // bottomNavigationBar: CustomBottomNavigationBar(
        //   onAddPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const AddProductForm()),
        //     );
        //   },
        //   onRefreshPressed: () {
        //     _loadProducts();
        //   },
        //   onBackPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
    );
  }

  void _verMasProducto(String productId) async {
    print('productId: $productId'); // Añade esta línea para depurar

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [int.parse(productId)],
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product.first)),
      );
    } else {
      print('Error: db is null');
    }
  }
}
