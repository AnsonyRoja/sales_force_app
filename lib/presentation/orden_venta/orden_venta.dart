import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/insert_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/orden_venta/product_selection.dart';
import 'package:sales_force/presentation/orden_venta/widgets/customer_details_sales_orders.dart';
import 'package:sales_force/presentation/orden_venta/widgets/product_list_items.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:sizer/sizer.dart'; // Importa la librería de formateo de fechas

class OrdenDeVentaScreen extends StatefulWidget {
  final dynamic clientId;
  final String clientName;
  final dynamic cBPartnerId;
  final dynamic cBPartnerLocationId;
  final String rucCbpartner;
  final String emailCustomer;
  final String phoneCustomer;
  final dynamic mPriceListId;
  final dynamic cPaymentTermId;
  final dynamic deliveryRule;
  final dynamic deliveryViaRUle;
  final dynamic invoiceRule;
  final dynamic paymentRule;

  const OrdenDeVentaScreen(
      {super.key,
      required this.clientId,
      required this.clientName,
      required this.cBPartnerId,
      required this.cBPartnerLocationId,
      required this.rucCbpartner,
      required this.emailCustomer,
      required this.phoneCustomer,
      required this.mPriceListId,
      required this.cPaymentTermId,
      required this.deliveryRule,
      required this.invoiceRule,
      required this.paymentRule,
      required this.deliveryViaRUle,
      });

  @override
  _OrdenDeVentaScreenState createState() => _OrdenDeVentaScreenState();
}

class _OrdenDeVentaScreenState extends State<OrdenDeVentaScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController numeroReferenciaController = TextEditingController();
  TextEditingController fechaController = TextEditingController();
  TextEditingController fechaIdempiereController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController saldoNetoController = TextEditingController();
  TextEditingController saldoImpuestoController = TextEditingController();
  TextEditingController saldoExentoController = TextEditingController();
  TextEditingController descProntoPagoController = TextEditingController();
  TextEditingController descPagoEfectivoController = TextEditingController();
  TextEditingController descTotalController = TextEditingController();
    List<TextEditingController> _discountControllers = [];


  Future? _futureDiscountDocuments;
  List<bool> _selectedDiscounts = [];
  List<Map<String, dynamic>> _discounts = [];
  double _userDiscount = 0.0;
  double _limitDiscount = 0.0;
  bool _isListenerPaused = false;
  List<Map<String, dynamic>> importes = [];
  List<Map<String, dynamic>> selectedProducts = [];
  DateTime selectedDate = DateTime.now();
  double? saldoNeto;
  double? totalImpuesto;
  Map<String, dynamic> infoUserForOrder = {};
  bool isDragging = false;
  dynamic priceList = 0;
  dynamic namePriceList;
  bool enableButton = true;
  bool isProntoPagoChecked = false;
  bool isPagoEnEfectivoChecked = false;
  double subtotal = 0.0;
  double totalDiscount = 0.0;
  double totalDiscount2 = 0.0;
  String _addressCustomerNameText = '';
  Map _wareHouseText = {};
  int _selectedBPartnerLocationId = 0;
  int _selectedWareHouseId = 0;
  int salesRegionId = 0;
  int mDiscountShemaId = 0;

  void priceOfList() async {
    print('Esto es el mpricelist ${widget.mPriceListId}');
    final whoIsListPrice = await typeOfCurrencyIs(
        widget.mPriceListId == '{@nil: true}'
            ? variablesG[0]['m_pricelist_id']
            : widget.mPriceListId);

    print('Esto es la lista de precio $whoIsListPrice');

    setState(() {
      namePriceList = whoIsListPrice;
      priceList = widget.mPriceListId == '{@nil: true}'
          ? variablesG[0]['m_pricelist_id']
          : widget.mPriceListId;
    });
  }

 void _showDiscountModal(BuildContext context) async {
  _discounts = await getDiscountDocuments();

  if (_discounts.isEmpty) {
    // Manejar el caso donde no hay descuentos disponibles
    return;
  }

  _selectedDiscounts = List<bool>.filled(_discounts.length, false);
  _discountControllers = List.generate(_discounts.length, (_) => TextEditingController());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Selecciona los Descuentos'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ..._discounts.asMap().entries.map((entry) {
                    int index = entry.key;
                    var discount = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text(discount['name']),
                            value: _selectedDiscounts[index],
                            onChanged: (bool? value) {

                              setState(() {
                                _selectedDiscounts[index] = value!;
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 100,
                          child: TextField(
                            controller: _discountControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Descuento',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              double enteredValue = double.tryParse(value) ?? 0.0;
                              if (enteredValue > discount['limit_discount']) {
                                setState(() {
                                  _discountControllers[index].text = discount['limit_discount'].toString();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('El descuento no puede superar el límite de ${discount['limit_discount']}%'),
                                    ),
                                  );
                                });
                              }else if(enteredValue < 0) { 

                                _discountControllers[index].text = "0";

                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Aplicar'),
                onPressed: () {
                  List<Map<String, dynamic>> appliedDiscounts = [];
                  
                  for (int i = 0; i < _discounts.length; i++) {
                    if (_selectedDiscounts[i]) {
                      double discountValue = double.tryParse(_discountControllers[i].text) ?? 0.0;
                      appliedDiscounts.add({
                        'id': _discounts[i]['id'],
                        'name': _discounts[i]['name'],
                        'value': discountValue,
                        'limit_discount': _discounts[i]['limit_discount'],
                        'c_charge_id': _discounts[i]['c_charge_id'],
                        'rate':_discounts[i]['rate']
                      });
                    }
                  }
                                    _updateImportes(); // Actualizar importes después de aplicar descuentos

                  print('Descuentos aplicados: $appliedDiscounts');
                  // Aquí puedes usar los descuentos aplicados para calcular el importe
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}



  dynamic calcularMontoTotal() {

    double total = 0;
    double totalNeto = 0;
    double suma = 0;
    double saldoExento = 0;

    final formatter = NumberFormat('#,##0.00', 'es_ES');

    for (var product in selectedProducts) {
      double price =
          double.tryParse(product['price'].toString().replaceAll(',', '.')) ??
              0;
      double quantity = double.tryParse(product['quantity'].toString()) ?? 0;
      double impuesto = double.tryParse(product['impuesto'].toString()) ?? 0;

      if (impuesto == 0.0) {
        saldoExento += price * quantity;
        
      }

      total += price * quantity * (impuesto / 100);
      totalNeto += (price * quantity);
   
    }

    saldoExentoController.text =
        ' ${priceList == 1000002 ? "Bs" : priceList == 1000003 ? "\$" : '\$'}  ${formatter.format(saldoExento)}';

    saldoNetoController.text = '\$ ${formatter.format(totalNeto)}';

      // Aplicar todos los descuentos seleccionados
  double totalDiscounts = 0;
  double calculatedDiscount = 0;
  double totalImporteCargo = 0;
  
  for (var discount in importes) {
  print('discounts $discount');
  if (discount['quantity'] == -1) {
    double discountValue = double.tryParse(discount['price'].toString().replaceAll(',', '.')) ?? 0;

    print('Esto es el valor desc $discountValue && saldo neto $totalNeto');

     calculatedDiscount = totalNeto * (discountValue / 100);


      print('calculo descuento $calculatedDiscount');
    

    totalDiscounts += (calculatedDiscount * (discount['rate'] / 100)); 

    // Guarda el importe calculado del descuento en el campo 'price'
    discount['total_importe'] = formatter.format(calculatedDiscount);
    mDiscountShemaId = discount['m_discount_schema_id'];
    totalImporteCargo += double.parse(discount['total_importe'].toString().replaceAll(',', '.'));
  }
}

    setState(() {
      
    });

    double taxAmt =  total - totalDiscounts ;

    suma = totalNeto - totalImporteCargo + taxAmt;

    montoController.text = '\$ ${formatter.format(suma)}';

    saldoImpuestoController.text = '\$ ${formatter.format(taxAmt)}';

    String parseFormatNumber = formatter.format(suma);

    return parseFormatNumber;

  }



  double calcularSaldoTotalProducts(dynamic price, dynamic quantity) {
    double prices;
    double quantitys;

    // Verificar si quantity es un String
    if (quantity is String || price is String) {
      // Intentar convertir el String a un número
      try {
        quantitys = double.parse(quantity).toDouble();
        prices = double.parse(price).toDouble();
      } catch (e) {
        print('Error al convertir quantity a double: $e');
        // Si hay un error, establecer quantitys como 0
        prices = 0.0;
        quantitys = 0.0;
      }
    } else {
      // Si quantity no es un String, asumir que es numérico
      quantitys = quantity.toDouble();
      prices = price.toDouble();
    }
    double sum = prices * quantitys;

    print('price $price & quantity is $quantity');
    print('Suma es $sum');
    return sum;
  }

  double calcularSaldoNetoProducto(cantidadProducts, price) {
    double multi =
        (cantidadProducts as num).toDouble() * (price as num).toDouble();

    saldoNeto = multi;

    return multi;
  }

  double calcularMontoImpuesto(impuesto, monto) {
    double montoImpuesto = monto * impuesto / 100;

    totalImpuesto = montoImpuesto;

    print(
        'El monto $monto y el impuesto $impuesto y el monto impuesto seria $montoImpuesto');
    return montoImpuesto;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: currentDate,
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        fechaController.text = DateFormat('dd/MM/yyyy')
            .format(selectedDate); // Formato día/mes/año
      });
    }
  }

  void _addOrUpdateProduct(List<Map<String, dynamic>> products) {
    for (var product in products) {
      int index = selectedProducts
          .indexWhere((element) => element['name'] == product['name']);
      if (index != -1) {
        // Si el producto ya existe, actualizar la cantidad
        setState(() {
          selectedProducts[index]['quantity'] += product['quantity'];
        });
      } else {
        // Si el producto no existe, verificar la disponibilidad antes de agregarlo
        final availableQuantity = product['quantity_avaible'] ??
            0; // Obtener la cantidad disponible del producto
    
        print("cantidad disponible $availableQuantity");

        setState(() {
            
            selectedProducts.add(product);
              _updateWareHouse(_wareHouseText, _selectedWareHouseId);
          });

      }
    }
  }

  void _removeProduct(int index) {
    setState(() {
      selectedProducts.removeAt(index);
      montoController.text = '\$ ${calcularMontoTotal()}';
    });
  }

    void _updateAddressCustomer(Map obj, int id) {
    setState(() {
      _addressCustomerNameText = obj['name'];
      salesRegionId = obj['region_sales'];
      _selectedBPartnerLocationId = id;
    });
    
    print('Esto es el objeto mapa de direccion con su region de venta $obj');

  }

  void _updateWareHouse(Map obje, int id  ){

      setState(() {
        _wareHouseText = obje; 
        _selectedWareHouseId = id;
      });

      if(selectedProducts.isNotEmpty){

          for(var products in selectedProducts){

              products['m_warehouse_id'] = id;
              products['ad_org_id'] = obje['orgId'];
              products['ad_client_id'] = obje['adClientId'];

          }

      }
    
    print('Este es el valor de wareHouseText $_wareHouseText y este es el valor de select $_selectedWareHouseId y este es e valor de $selectedProducts');

  }



  initGetUser() async {
    final info = await getApplicationSupportDirectory();
    print("esta es la ruta ${info.path}");

    final String filePathEnv = '${info.path}/.env';
    final File archivo = File(filePathEnv);
    String contenidoActual = await archivo.readAsString();

    Map<String, dynamic> infoLogin = await getLogin();
    Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

    var orgId = jsonData["OrgID"];
    var clientId = jsonData["ClientID"];
    var wareHouseId = jsonData["WarehouseID"];

    print('Esto es infologin $infoLogin');

    // Map<String, dynamic> getUser = await getUsers(username, password);

    setState(() {
      infoUserForOrder = {
        'orgid': orgId,
        'clientid': clientId,
        'warehouseid': wareHouseId,
        'userId': infoLogin['userId']
      };
    });

    print('infouserFororder $infoUserForOrder');
  }

  initV() async {
    
      if(variablesG.isEmpty){

      List<Map<String, dynamic>> response = await getPosPropertiesV();
      setState(() {
        variablesG = response;
      });

      }
    
  }

  void _updateSubtotal() {
    // Eliminar el símbolo de dólar, puntos de miles y reemplazar la coma por un punto
    print('Esto es el texto ${saldoNetoController.text}');
    String cleanedText = saldoNetoController.text.replaceAll('\$', '').replaceAll('.', '').replaceAll(',', '.');
    // Convertir el texto limpio a double
    subtotal = double.tryParse(cleanedText) ?? 0.0;
  }

  void _calculateTotalDiscount() {
    totalDiscount = 0.0;
    totalDiscount2 = 0.0;
    descProntoPagoController.clear();
    descPagoEfectivoController.clear(); 
    descPagoEfectivoController.text = "\$ 0.00";
    descProntoPagoController.text = "\$ 0.00";
   


        final formatter = NumberFormat('#,##0.00', 'es_ES');

    if (isProntoPagoChecked) {
      String discountString = variablesG[0]['discount1'];
      double discount = double.tryParse(discountString) ?? 0.0;
      totalDiscount = subtotal * discount / 100;
      descProntoPagoController.text =  '\$ ${formatter.format(totalDiscount)}';
    }

    if (isPagoEnEfectivoChecked) {
      String discountString = variablesG[0]['discount2'];
      double discount = double.tryParse(discountString) ?? 0.0;
      totalDiscount2 = subtotal * discount / 100;
       descPagoEfectivoController.text =  '\$ ${formatter.format(totalDiscount2)}';

    }

    descTotalController.text = '\$ ${formatter.format(totalDiscount + totalDiscount2)}';

  }


          void _updateImportes() {
  setState(() {
    // Eliminar todos los descuentos existentes en importes
    importes.removeWhere((item) => item['name'].toString().contains("Desc"));

    print('Esto es la seleccion $_selectedDiscounts');
    // Agregar los descuentos seleccionados en el modal
    for (int i = 0; i < _selectedDiscounts.length; i++) {
      if (_selectedDiscounts[i]) {
        double discountValue = double.tryParse(_discountControllers[i].text) ?? 0.0;
        Map<String, dynamic> importe = {
          "name": "${_discounts[i]['name']} Desc ${discountValue.toStringAsFixed(2)}%",
          "quantity": -1,
          "price": discountValue.toStringAsFixed(4),
          "m_product_id": 0,
          "c_charge_id": _discounts[i]['c_charge_id'], 
          "rate": _discounts[i]['rate'], 
          "total_importe": 0,
          "m_discount_schema_id": _discounts[i]['m_discount_schema_id'],
        };

        importes.add(importe);
      
      }
    }

    // // Asegurarse de que los descuentos de Pronto Pago y Pago en Efectivo se manejen correctamente
    // if (isProntoPagoChecked) {
    //   importes.removeWhere((item) => item['name'] == "Pronto Pago Desc 3%");
    //   Map<String, dynamic> prontoPagoImporte = {
    //     "name": "Pronto Pago Desc 3%",
    //     "quantity": -1,
    //     "price": totalDiscount.toStringAsFixed(4),
    //     "m_product_id": 0,
    //     "c_charge_id": variablesG[0]['c_chargediscount1_id']
    //   };
    //   importes.add(prontoPagoImporte);
    // }

    // if (isPagoEnEfectivoChecked) {
    //   importes.removeWhere((item) => item['name'] == "Pago en Efectivo Desc 7%");
    //   Map<String, dynamic> pagoEfectivoImporte = {
    //     "name": "Pago en Efectivo Desc 7%",
    //     "quantity": -1,
    //     "price": totalDiscount2.toStringAsFixed(4),
    //     "m_product_id": 0,
    //     "c_charge_id": variablesG[0]['c_chargediscount2_id']
    //   };
    //   importes.add(pagoEfectivoImporte);
    // }

    calcularMontoTotal();
  });
}



void _pauseListener() {
  _isListenerPaused = true;

  // Restaurar el listener después de 2 segundos
  Future.delayed(Duration(seconds: 2), () {
    _isListenerPaused = false;
  });
}


  @override
  void initState() {
    initV();
    initGetUser();
    priceOfList();
    print('Este es el valor de client id ${widget.clientId}');
    print('variables globales $variablesG');
    fechaController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    print("Esto es el id ${widget.clientId}");
    print("Esto es el name ${widget.clientName}");
    fechaIdempiereController.text =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);

    _futureDiscountDocuments = getDiscountDocuments();
      
    saldoNetoController.addListener(() {
        if (_isListenerPaused) return; 
     
      setState(() {
        _updateSubtotal();
        _calculateTotalDiscount();
        _updateImportes();
        _updateWareHouse(_wareHouseText, _selectedWareHouseId);
      });
    });

    

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;

    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.black;
      }

      return Colors.white;
    }

    Color getColorBg(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.white;
      }

      return const Color(0xFF00722D);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 227, 245, 235),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Orden de Venta')),
        body: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: mediaScreen,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomerDetailsSalesOrders(
                      cBPartnerId: widget.cBPartnerId,
                      clientName: widget.clientName,
                      rucCbpartner: widget.rucCbpartner,
                      emailCustomer: widget.emailCustomer,
                      phoneCustomer: widget.phoneCustomer,
                      namePriceList: namePriceList,
                      numeroReferenciaController: numeroReferenciaController,
                      fechaController: fechaController,
                      descripcionController: descripcionController,
                      selectDate: _selectDate,
                      onAddressCustomerChanged: _updateAddressCustomer,
                      onWareHouseChanged: _updateWareHouse,
                    ),               
                    SizedBox(
                      height: mediaScreen * 0.08,
                    ),
                    SizedBox(
                      width: mediaScreen,
                      child: const Text(
                        "Productos",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins Bold',
                            fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: mediaScreen * 0.05,
                    ),
                    Container(
                      width: mediaScreen,
                      height: mediaScreen * 0.5,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 7,
                                spreadRadius: 2),
                          ]),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nombre',
                                      style: TextStyle(
                                          fontFamily: 'Poppins Bold',
                                          fontSize: 15),
                                    ),
                                    Text('Cant.',
                                        style: TextStyle(
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 15)),
                                    Text('Precio',
                                        style: TextStyle(
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 15))
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap:
                                      true, // Asegura que el ListView tome solo el espacio que necesita
                                  itemCount: selectedProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = selectedProducts[index];
                
                                    print('Esto es el product $product');
                
                                    return ProductListItem(
                                          product: product,
                                          index: index,
                                          mediaScreen: mediaScreen,
                                          onRemove: () {
                                            setState(() {
                                              _removeProduct(index);
                                            });
                                          },
                                          onDecrease: () {
                                            setState(() {
                                              if (product['quantity'] > 0) {
                                                product['quantity'] -= 1;
                                                calcularMontoTotal();
                                              }
                                            });
                                          },
                                          onIncrease: () {
                                            setState(() {
                                              product['quantity'] += 1;
                                              calcularMontoTotal();
                                            });
                                          },
                                          calcularSaldoTotalProducts: calcularSaldoTotalProducts,
                                        );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: mediaScreen,
                                height: mediaScreen * 0.13,
                              )
                            ],
                          ),
                          Positioned(
                            top: mediaScreen * 0.40,
                            left: mediaScreen * 0.45,
                            child: GestureDetector(
                                onTap: () async {
                                  final selectedProductsResult =
                                      await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductSelectionScreen(
                                                mPriceListId:
                                                    widget.mPriceListId)),
                                  );
                                  print(
                                      "Cantidad de productos $selectedProductsResult");
                                  if (selectedProductsResult != null) {
                                    setState(() {
                                      _addOrUpdateProduct(selectedProductsResult);
                
                                      montoController.text =
                                          '\$ ${calcularMontoTotal()}';
                                    });
                                  }
                                },
                                child: Image.asset(
                                  'lib/assets/Más@3x.png',
                                  color: Color(0XFF00722D),
                                  width: 23,
                                )),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 15.sp,),
                    selectedProducts.isNotEmpty ?  SizedBox(
                      height: 35.sp ,
                      width: 250.sp,
                      child: ElevatedButton(
                        
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          backgroundColor: WidgetStatePropertyAll(Color(0XFF00722D))  ),
                        onPressed: (){    

                            print('Entre aqui');
                          
                          _showDiscountModal(context);
                      
                      } , child: Text('Agg Dscto', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 14.sp),)),
                    ): Container(),

                    SizedBox(
                      height: mediaScreen * 0.1,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: mediaScreen,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SubTotal',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      fontSize: 18),
                                ),
                                Text(
                                  saldoNetoController.text,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      fontSize: 18),
                                )
                              ],
                            ),
                            ListView.builder(
                        shrinkWrap: true,
                        itemCount: importes.length,
                        itemBuilder: (context, index) {
                          var discount = importes[index];
                          print('Esto es el descuento $discount');
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                discount['name'].toString().substring(8,25),
                                style: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),
                              ),
                              Text(
                                '\$ ${discount['total_importe']}',
                                style: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),
                              ),
                            ],
                            );}),
                          
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Exento',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      fontSize: 18),
                                ),
                                Text(
                                  saldoExentoController.text,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      fontSize: 18),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Impuesto',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      fontSize: 18),
                                ),
                                Text(
                                  saldoImpuestoController.text,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Regular',
                                      fontSize: 18),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Bold', fontSize: 18),
                                ),
                                Text(
                                  montoController.text,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins Bold', fontSize: 18),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: mediaScreen * 0.1,
                    ),
                    SizedBox(
                      width: mediaScreen,
                      height: mediaScreen * 0.15,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            textStyle: WidgetStateProperty.all<TextStyle>(
                                const TextStyle(fontFamily: 'Poppins Bold')),
                            foregroundColor:
                                WidgetStateProperty.resolveWith(getColor),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15))),
                            animationDuration: Duration.zero,
                            elevation: WidgetStateProperty.all(0.5),
                            backgroundColor:
                                WidgetStateProperty.resolveWith(getColorBg)),
                        onPressed: enableButton == true ? () async {
                          if (infoUserForOrder.isNotEmpty && _formKey.currentState!.validate() ) {
                            if (selectedProducts.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'La orden debe tener productos adjuntos.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                              context); // Cerrar el diálogo
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                
                              return;
                            }
                            setState(() {
                              enableButton = false;
                            });

                            // Generar una function que me retorne las 2 diferentes estructuras de datos
                            // una para la base de datos local y la otra para el envio del endpoint
                            // de creacion en idempiere
                            
                            final order = {
                              'cliente_id': widget.clientId,
                              'documentno': numeroReferenciaController.text,
                              'fecha': fechaController.text,
                              'descripcion': descripcionController.text,
                              'monto': montoController.text.substring(2),
                              'saldo_neto': saldoNetoController.text.substring(2),
                              'productos': selectedProducts,
                              'c_bpartner_id': widget.cBPartnerId,
                              'c_bpartner_location_id':_selectedBPartnerLocationId,
                              'c_doctypetarget_id': variablesG[0]
                                  ['c_doc_type_order_id'],
                              'ad_client_id': infoUserForOrder['clientid'],
                              'ad_org_id': infoUserForOrder['orgid'],
                              'm_warehouse_id': infoUserForOrder['warehouseid'],
                              'paymentrule': 'P',
                              'date_ordered': fechaIdempiereController.text,
                              'salesrep_id': infoUserForOrder['userId'],
                              'usuario_id': infoUserForOrder['userId'],
                              'saldo_exento':
                                  saldoExentoController.text.substring(2),
                              'm_warehouse_name_dispatch' : _wareHouseText['wareHouseName'],
                              'saldo_impuesto':
                                  saldoImpuestoController.text.substring(2),
                              'status_sincronized': 'Borrador',
                              'desc_prontopago': descProntoPagoController.text.substring(2),
                              'desc_pagoefectivo': descPagoEfectivoController.text.substring(2),
                              'total_desc': descTotalController.text.substring(2),
                              'cargos': jsonEncode(importes),
                              'address': _addressCustomerNameText,
                              'm_price_list_id': widget.mPriceListId,
                              'is_tax_with_holding_iva': 'N'

                            };
                
                            final orderId = await insertOrder(order);
                
                            final orderSales = {
                              'client': [
                                {'list_price': priceList, 'id':widget.clientId}
                              ],
                              'order': {
                                'id': orderId,
                                'documentno': numeroReferenciaController.text,
                                'fecha': fechaController.text,
                                'descripcion': descripcionController.text,
                                'monto': montoController.text.substring(2),
                                'saldo_neto':
                                    saldoNetoController.text.substring(2),
                                'c_bpartner_id': widget.cBPartnerId,
                                'c_bpartner_location_id': _selectedBPartnerLocationId,
                                'c_doctypetarget_id': variablesG[0]
                                    ['c_doc_type_order_id'],
                                'ad_client_id': infoUserForOrder['clientid'],
                                'ad_org_id': infoUserForOrder['orgid'],
                                'm_warehouse_id': infoUserForOrder['warehouseid'],
                                'paymentrule': 'P',
                                'date_ordered': fechaIdempiereController.text,
                                'salesrep_id': infoUserForOrder['userId'],
                                'usuario_id': infoUserForOrder['userId'],
                                'sales_region': salesRegionId,
                                'saldo_exento':
                                    saldoExentoController.text.substring(2),
                                'saldo_impuesto':
                                    saldoImpuestoController.text.substring(2),
                                'status_sincronized': 'Borrador',
                                'cargos': jsonEncode(importes),
                                'c_payment_term_id': widget.cPaymentTermId,
                                'delivery_rule': widget.deliveryRule,
                                'delivery_via_rule': widget.deliveryViaRUle,
                                'invoice_rule': widget.invoiceRule,
                                'payment_rule': widget.paymentRule,
                                'm_discount_schema_id': mDiscountShemaId,
                              },
                              'products': selectedProducts,
                            };

                           await createOrdenSalesIdempiere(orderSales)
                                .then((value) {
                              if (orderId is Map<String, dynamic> &&
                                  orderId.containsKey('failure')) {
                                if (orderId['failure'] == -1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        orderId['Error'],
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                print(
                                    'orderId no es un mapa válido o no contiene la propiedad "failure", en pocas palabras no hay un error');
                              }
                
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Orden de venta guardada correctamente con ID: $orderId'),
                                ),
                              );
                
                              _pauseListener();
                            
                              saldoNetoController.clear();
                              saldoExentoController.clear();
                              montoController.clear();
                              // Limpiar la lista de productos seleccionados después de guardar la orden
                              setState(() {
                              
                              numeroReferenciaController.clear();
                              descripcionController.clear();
                              saldoImpuestoController.clear();
                              descPagoEfectivoController.clear();
                              descProntoPagoController.clear();
                              descTotalController.clear();
                              isProntoPagoChecked = false;
                              isPagoEnEfectivoChecked = false;
                              importes.clear();
                                selectedProducts.clear();
                                enableButton = true;
                              });
                
                              if (value == false) {
                                String newValue = 'Por Enviar';
                
                                updateOrdereSalesForStatusSincronzed(
                                    orderId, newValue);
                              } else {
                                String newValue = 'Enviado';
                                 updateOrdereSalesForStatusSincronzed(
                                    orderId, newValue);
                              }
                            });
                          }
                        }: null ,
                        child: const Text('Agregar Orden'),
                      ),
                    ),
                    SizedBox(
                      height: mediaScreen * 0.1,
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
}
