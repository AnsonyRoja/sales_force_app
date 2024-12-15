import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:flutter/material.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';

class ProductSelectionScreen extends StatefulWidget {
  final dynamic mPriceListId;

  const ProductSelectionScreen({super.key, required this.mPriceListId});

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Map<String, dynamic>>? products; // Lista de productos
  List<Map<String, dynamic>> filteredProducts =
      []; // Lista de productos filtrados
  List<Map<String, dynamic>> selectedProducts =
      []; // Lista de productos seleccionados
  Map<String, double> productQuantities =
      {}; // Mapa para almacenar las cantidades seleccionadas por producto
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    print('mepricelistid ${widget.mPriceListId}');
    print('Estas son las variables globales $variablesG');

    final productList = await getProductsInPriceList(
        widget.mPriceListId == "{@nil: true}"
            ? variablesG[0]['m_pricelist_id']
            : widget.mPriceListId); // Obtener todos los productos

    // Filtrar los productos con precio igual a '{@nil=true}'
    final filteredList = productList
        .where((product) => product['pricelistsales'] != '{@nil=true}')
        .toList();

    print('Esto es el productList $productList');

    if (productList.isEmpty) {
      _showNoProductsDialog();
    }

    setState(() {
      products = filteredList;
      filteredProducts = filteredList;
    });
  }

  void _showNoProductsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin productos disponibles'),
          content: const Text(
              'No hay productos disponibles en esta lista de precios.'),
          actions: [
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the screen if necessary
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;
    final colorTheme = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Productos')),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: mediaScreen * 0.05,
              ),
              Container(
                width: mediaScreen * 0.98,
                height: mediaScreen * 0.18,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 7,
                          spreadRadius: 2,
                          color: Colors.grey.withOpacity(0.5))
                    ]),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      filteredProducts = products!
                          .where((product) => product['name']
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                          .toList();
                    });

                    print('Esto es el filtro de productos $filteredProducts');
                  },
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        fontFamily: 'Poppins Regular', color: Colors.black),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 20),
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
                    labelText: 'Nombre del producto',
                    suffixIcon: Image.asset('lib/assets/Lupa.png'),
                  ),
                  style: const TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ),
              SizedBox(
                height: mediaScreen * 0.05,
              ),
              Expanded(
                child: filteredProducts.isNotEmpty
                    ? SizedBox(
                        width: mediaScreen,
                        child: ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final productName = filteredProducts[index]['name'];
                            final productPrice = filteredProducts[index]
                                        ['pricelistsales'] ==
                                    '{@nil=true}'
                                ? 0
                                : filteredProducts[index]['pricelistsales'];
                            final mProductId =
                                filteredProducts[index]['m_product_id'];

                            final isSelected = selectedProducts.any(
                                (product) => product['name'] == productName);
                            final double quantity =
                                productQuantities[productName] ?? 0;

                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              shadowColor: Colors.grey.withOpacity(0.5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0xff00722D)
                                              .withOpacity(0.5)
                                          : Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 7),
                                    child: Text(productName,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins Bold')),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Stock: ',
                                            style: TextStyle(
                                                fontFamily: 'Poppins SemiBold'),
                                          ),
                                          Text(
                                              '${filteredProducts[index]['quantity']}'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Precio: ',
                                            style: TextStyle(
                                                fontFamily: 'Poppins SemiBold'),
                                          ),
                                          Text(
                                              '\$ ${productPrice != '{@nil=true}' ? productPrice.toStringAsFixed(4) : 0}')
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Cantidad Seleccionada: ',
                                            style: TextStyle(
                                                fontFamily: 'Poppins SemiBold'),
                                          ),
                                          Text(quantity.toString())
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    final double? selectedQuantity =
                                        await _showQuantityPickerDialog(context,
                                            productName, quantity, colorTheme);

                                    _controller.text = selectedQuantity.toString();

                                    if (selectedQuantity != null) {
                                      if (selectedQuantity >= 0) {
                                        final selectedProductIndex =
                                            selectedProducts.indexWhere(
                                                (product) =>
                                                    product['name'] ==
                                                    productName);
                                        final double newQuantity =
                                            selectedQuantity;

                                        final selectedProduct = {
                                          "id": filteredProducts[index]['id'],
                                          "name": productName,
                                          "quantity_avaible":
                                              filteredProducts[index]
                                                  ['quantity'],
                                          "quantity": newQuantity,
                                          "price": productPrice,
                                          "impuesto": filteredProducts[index]
                                              ['tax_rate'],
                                          'm_product_id': mProductId
                                        };

                                        setState(() {
                                          print(
                                              "que tiene newquantity $newQuantity");
                                          if (isSelected) {
                                            selectedProducts[
                                                    selectedProductIndex] =
                                                selectedProduct;
                                          } else {
                                            selectedProducts.add(selectedProduct);
                                          }
                                          productQuantities[productName] =
                                              newQuantity;
                                        });
                                      } else {
                                        setState(() {
                                          selectedProducts.removeWhere(
                                              (product) =>
                                                  product['name'] ==
                                                  productName);
                                          productQuantities.remove(productName);
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          ),
        ),
        // Muestra un indicador de carga mientras se cargan los productos
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context,
                selectedProducts); // Devuelve los productos seleccionados al presionar el botón de regresar
          },
          backgroundColor: const Color(0xff00722D),
          foregroundColor: Colors.white,
          child: const Icon(Icons.check),
        ),
      ),
    );
  }

  Future<double?> _showQuantityPickerDialog(BuildContext context,
      String productName, double quantity, Color colorTheme) {
    double selectedQuantity =
        quantity; // Inicializar selectedQuantity con la cantidad pasada por parámetro


    return showModalBottomSheet<double>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(25), topLeft: Radius.circular(25))
      ),
      context: context,
      isScrollControlled:
          true, // Permitir que el contenido haga scroll si es necesario

      builder: (BuildContext context) {
           FocusNode quantityFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        FocusScope.of(context).requestFocus(quantityFocusNode));
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            // Envolver el contenido con SingleChildScrollView
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Seleccione la cantidad de $productName',
                        style: const TextStyle(
                          fontFamily: 'Poppins SemiBold',
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
                          Expanded(
                            child: TextField(
                          
                              focusNode: quantityFocusNode,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins Regular',
                                fontSize: 20,
                              ),
                              keyboardType: TextInputType.number,
                              
                              onChanged: (value) {
                                setState(() {
                                  double newQuantity =
                                      double.tryParse(value) ?? selectedQuantity;
                                  
                                  if (newQuantity >= 0) {
                                    selectedQuantity = newQuantity;
                                  }
                                });
                              },
                              decoration: const InputDecoration(
                                hintText: 'Cantidad',
                                hintStyle: TextStyle(fontFamily: 'Poppins Regular'),
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                      
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                            backgroundColor:
                                const WidgetStatePropertyAll(Color(0xFF00722D)),
                            foregroundColor:
                                const WidgetStatePropertyAll(Colors.white)),
                        onPressed: () {
                          Navigator.pop(context, selectedQuantity);
                        },
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(fontFamily: 'Poppins Bold'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
