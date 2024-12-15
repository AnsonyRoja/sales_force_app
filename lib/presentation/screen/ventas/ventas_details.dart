import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/cobranzas/cobro.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class VentasDetails extends StatefulWidget {
  final int ventaId;
  final String nameClient;
  final dynamic saldoTotal;
  final String rucClient;
  final String emailClient;
  final String phoneClient;
  const VentasDetails({
    super.key,
    required this.ventaId,
    required this.nameClient,
    required this.saldoTotal,
    required this.rucClient,
    required this.emailClient,
    required this.phoneClient,
  });

  @override
  State<VentasDetails> createState() => _VentasDetailsState();
}

class _VentasDetailsState extends State<VentasDetails> {
  late Future<Map<String, dynamic>> _ventaData;
  late List<dynamic> clientsSales = [];
  Future<Map<String, dynamic>>? _currencyData;

  bool bottonEnable = true;

  Future<Map<String, dynamic>>? _loadCurrencyIs(mPriceListId) async {
    print('esto es el clientsales $clientsSales');
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();

      setState(() {
        variablesG = response;
      });
    }
    final typeCurrency = await typeOfCurrencyIs(
        mPriceListId == '{@nil: true}'
            ? variablesG[0]['m_pricelist_id']
            : mPriceListId);

    print('esto es el tipo de moneda $typeCurrency');

    return typeCurrency.first;
  }

  @override
  void initState() {
    super.initState();

    _ventaData = _loadVentasForId(widget.ventaId);
  }

  _updateAndCreateOrders() async {
    dynamic isTrue = await createOrdenSalesIdempiere(_ventaData);

    if (isTrue == false) {
      return false;
    } else {
      return true;
    }
  }

  double calcularSaldoTotalProducts(
      dynamic price, dynamic quantity, dynamic impuesto) {
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

    return sum;

  }

  Future<Map<String, dynamic>> _loadVentasForId(ordenId) async {
    return await getOrderWithProducts(ordenId);
  }

  @override
  Widget build(BuildContext context) {
    final screenMax = MediaQuery.of(context).size.width * 0.8;
    final heightScreen = MediaQuery.of(context).size.height * 0.9;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 227, 245, 235),
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Orden de Venta')),
      body: Align(
        alignment: Alignment.topCenter,
        child: FutureBuilder(
          future: _ventaData,
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              clientsSales = snapshot.data!['client'];
              final ventaData = snapshot.data!['order'];
              final mPriceListID = snapshot.data!['order']['m_price_list_id'];
              final productsData = snapshot.data!['products'];
              print("Esto es lo que hay productsData ${snapshot.data}");
              print("esto es ventas data $ventaData");
              final uploadCargos = jsonDecode(snapshot.data!['order']['cargos']);

              print('estos son los taxwitholding ${ventaData['is_tax_with_holding_iva'].toString()}');

              print("Esto es snapshot data ${snapshot.data}");

              _currencyData = _loadCurrencyIs(mPriceListID);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: heightScreen * 0.015,
                      ),
                      Container(
                        width: screenMax,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              8), // Establece el radio de los bordes
                        ),
                        child: const Text(
                          'Datos Del Cliente',
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins Bold',
                              fontSize: 18),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        height: heightScreen * 0.05,
                      ),
                      Container(
                        width: screenMax,
                        height: screenMax * 0.9,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 7,
                                  spreadRadius: 2,
                                  color: Colors.grey.withOpacity(0.5))
                            ]),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: screenMax * 0.5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Nombre',
                                            style: TextStyle(
                                                fontFamily: 'Poppins Bold',
                                                fontSize: 18),
                                          ),
                                          Text(widget.nameClient.length > 25
                                              ? widget.nameClient
                                                  .substring(0, 25)
                                              : widget.nameClient)
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenMax * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'RIF/CI',
                                            style: TextStyle(
                                                fontFamily: 'Poppins Bold',
                                                fontSize: 18),
                                          ),
                                          Text(widget.rucClient.length > 15
                                              ? widget.rucClient
                                                  .substring(0, 15)
                                              : (widget.rucClient ==
                                                      '{@nil: true}'
                                                  ? ''
                                                  : widget.rucClient)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width: screenMax,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Detalles',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Bold',
                                        fontSize: 18),
                                    textAlign: TextAlign.start,
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Correo: ',
                                    style: TextStyle(
                                        fontFamily: 'Poppins SemiBold'),
                                  ),
                                  Text(
                                    widget.emailClient == '{@nil: true}'
                                        ? ''
                                        : widget.emailClient,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins Regular'),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Telefono: ',
                                    style: TextStyle(
                                        fontFamily: 'Poppins SemiBold'),
                                  ),
                                  Text(
                                    widget.phoneClient == '{@nil: true}'
                                        ? ''
                                        : widget.phoneClient,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins Regular'),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder(
                              future: _currencyData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final currentCurrency = snapshot.data;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Lista de Precios: ',
                                          style: TextStyle(
                                              fontFamily: 'Poppins SemiBold'),
                                        ),
                                        Text(
                                          currentCurrency!['price_list_name'],
                                          style: const TextStyle(
                                              fontFamily: 'Poppins Regular'),
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                             Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estado: ',
                                    style: TextStyle(
                                        fontFamily: 'Poppins SemiBold'),
                                  ),
                                  Text(  ventaData['doc_status'] == 'CO' ?
                                  "Completado": ventaData['doc_status'] == 'PR' || ventaData['doc_status'] == 'IP' ? "En Proceso" 
                                  : ventaData['doc_status'] == "VO" ? "Anulado": ventaData['doc_status'] ?? ""
                                      .toString(),
                                    style:  TextStyle(color: ventaData['doc_status'] == 'CO' ? const Color.fromARGB(255, 9, 140, 77): ventaData['doc_status'] == 'PR' || ventaData['doc_status'] == 'IP' || ventaData['doc_status'] == 'En Proceso' ? const Color.fromARGB(255, 167, 153, 34) : ventaData['doc_status'] == 'VO'? Colors.red : Colors.black,
                                        fontFamily: 'Poppins Regular'),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: heightScreen * 0.05,
                      ),
                      Container(
                        width: screenMax,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Orden N°",
                                style: TextStyle(fontFamily: 'Poppins Regular'),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                ventaData['documentno'] != ''
                                    ? ventaData['documentno'].toString()
                                    : ventaData['id'].toString(),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: heightScreen * 0.025,
                      ),
                      Container(
                        width: screenMax,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Fecha",
                                style: TextStyle(fontFamily: 'Poppins Regular'),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                ventaData['fecha'].toString(),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: heightScreen * 0.025,
                      ),
                       Container(
                        width: screenMax,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Dirección",
                                style: TextStyle(fontFamily: 'Poppins Regular'),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                ventaData['address'].toString(),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: heightScreen * 0.025,
                      ),
                      Container(
                        width: screenMax,
                        height: screenMax * 0.25,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Descripción",
                                style: TextStyle(fontFamily: 'Poppins Regular'),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                ventaData['descripcion'].toString(),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: heightScreen * 0.025,
                      ),
                      SizedBox(
                        width: screenMax,
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
                        height: heightScreen * 0.025,
                      ),
                      Container(
                        width: screenMax,
                        height: screenMax * 0.5,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Container(
                                    width: 400,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Nombre',
                                          style: TextStyle(
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 15),
                                        ),
                                        Text(
                                          'Cant.',
                                          style: TextStyle(
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 15),
                                        ),
                                        Text(
                                          'Precio',
                                          style: TextStyle(
                                              fontFamily: 'Poppins Bold',
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: productsData.length,
                                    itemBuilder: (context, index) {
                                      final product = productsData[index];

                                      return Column(children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 0),
                                          child: SizedBox(
                                            width: screenMax * 0.95,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Image.asset(
                                                    'lib/assets/Check.png',
                                                    color: Color(0XFF00722D),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  SizedBox(
                                                      width: 50,
                                                      child: Text(
                                                          product['name'])),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.14,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        product['qty_entered']
                                                            .toString()),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.20,
                                                  ),
                                                  SizedBox(
                                                    width: screenMax * 0.35,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        FutureBuilder(
                                                          future: _currencyData,
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const CircularProgressIndicator();
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error: ${snapshot.error}');
                                                            } else {
                                                              final currentCurrency =
                                                                  snapshot.data;

                                                                      final formatter = NumberFormat('#,##0.00', 'es_ES');


                                                              print(
                                                                  'Esto es currency $currentCurrency');

                                                              return Flexible(
                                                                  child: Text(
                                                                      '${currentCurrency!['price_list_name'].toString().toLowerCase().contains('bs') ? 'Bs.' : '\$'} ${formatter.format(double.parse(product['price_actual'].toString()))}'));
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: _currencyData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final currentCurrency = snapshot.data;

                            return Container(
                                width: screenMax,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      8), // Establece el radio de los bordes
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('SubTotal',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Regular',
                                                  fontSize: 17)),
                                          Text(
                                            '${currentCurrency!['price_list_name'].toString().toLowerCase().contains('bs') ? 'Bs.' : '\$'} ${ventaData['saldo_neto']}',
                                            style: const TextStyle(
                                                fontFamily: 'Poppins Regular',
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      uploadCargos.length> 0 ? 
                                        ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: uploadCargos.length,
                                      itemBuilder: (context, index) {
                                        var discount = uploadCargos[index];
                                        print('Esto es el descuento $discount');
                                        return discount['name'] != null ? Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 135.sp,
                                              child: Text(
                                                discount['name'].toString(),
                                                style: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 18,overflow: TextOverflow.ellipsis),
                                              ),
                                            ),
                                            Text(
                                              '\$ ${discount['total_importe']}',
                                              style: const TextStyle(fontFamily: 'Poppins Regular', fontSize: 18),
                                            ),
                                          ],
                                          ): Container();
                                          }) : Container(),
                                        
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Exento',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Regular',
                                                  fontSize: 17)),
                                          Text(
                                            '${currentCurrency['price_list_name'].toString().toLowerCase().contains('bs') ? 'Bs.' : '\$'}${ventaData['saldo_exento']}',
                                            style: const TextStyle(
                                                fontFamily: 'Poppins Regular',
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Impuesto',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Regular',
                                                  fontSize: 17)),
                                          Text(
                                            '${currentCurrency['price_list_name'].toString().toLowerCase().contains('bs') ? 'Bs.' : '\$'} ${ventaData['saldo_impuesto']}',
                                            style: const TextStyle(
                                                fontFamily: 'Poppins Regular',
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Total',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 17)),
                                          Text(
                                            '${currentCurrency['price_list_name'].toString().toLowerCase().contains('bs') ? 'Bs.' : '\$'} ${ventaData['monto'].toString()}',
                                            style: const TextStyle(
                                                fontFamily: 'Poppins Bold',
                                                fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                          }
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ventaData['status_sincronized'] == 'Borrador'
                          ? Container(
                              width: screenMax,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: ventaData['status_sincronized'] ==
                                            'Borrador' &&
                                        bottonEnable == true
                                    ? const Color(0xFF00722D)
                                    : Colors
                                        .grey, // Color verde para el fondo del botón
                              ),
                              child: ElevatedButton(
                                onPressed: ventaData['status_sincronized'] ==
                                            'Borrador' &&
                                        bottonEnable == true 
                                    ? () async {
                                        setState(() {
                                          bottonEnable = false;
                                        });

                                        dynamic isTrue =
                                            await _updateAndCreateOrders();

                                        if (isTrue != false) {
                                          setState(() {
                                            bottonEnable = true;
                                          });

                                          String newValue = 'Enviado';
                                          await updateOrdereSalesForStatusSincronzed(
                                              ventaData['id'], newValue);
                                        } else {
                                          String newValue = 'Por Enviar';
                                          setState(() {
                                            bottonEnable = true;
                                          });
                                          updateOrdereSalesForStatusSincronzed(
                                              ventaData['id'], newValue);
                                        }

                                        if (mounted) {
                                          setState(() {
                                            _ventaData = _loadVentasForId(
                                                widget.ventaId);
                                          });
                                        }
                                      }
                                    : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(Colors
                                          .transparent), // Hace que el color de fondo del botón sea transparente
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text(
                                    'Comp y Enviar',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Texto blanco para que se destaque sobre el fondo verde
                                      fontFamily: 'Poppins Bold',
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      ventaData['status_sincronized'] == 'Por Enviar' || ventaData['documentno'] == '' && ventaData['c_order_id'] == null
                          ? Container(
                              width: screenMax,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: ventaData['status_sincronized'] ==
                                            'Por Enviar' &&
                                        bottonEnable == true || ventaData['documentno'] == '' && ventaData['c_order_id'] == null
                                    ? const Color(0xFF00722D)
                                    : Colors
                                        .grey, // Color verde para el fondo del botón
                              ),
                              child: ElevatedButton(
                                onPressed: ventaData['status_sincronized'] ==
                                            'Por Enviar' &&
                                        bottonEnable == true || ventaData['documentno'] == '' && ventaData['c_order_id'] == null
                                    ? () async {
                                        setState(() {
                                          bottonEnable = false;
                                        });

                                        dynamic isTrue =
                                            await _updateAndCreateOrders();

                                        print('is true $isTrue');
                                        if (isTrue != false) {
                                          String newValue = 'Enviado';
                                          await updateOrdereSalesForStatusSincronzed(
                                              ventaData['id'], newValue);

                                          setState(() {
                                            bottonEnable = true;
                                          });
                                        } else {
                                          String newValue = 'Por Enviar';
                                          updateOrdereSalesForStatusSincronzed(
                                              ventaData['id'], newValue);
                                          setState(() {
                                            bottonEnable = true;
                                          });
                                        }

                                        if (mounted) {
                                          setState(() {
                                            _ventaData = _loadVentasForId(
                                                widget.ventaId);
                                          });
                                        }
                                      }
                                    : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(Colors
                                          .transparent), // Hace que el color de fondo del botón sea transparente
                                  shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(15.0),
                                  child: Text(
                                    'Enviar',
                                    style: TextStyle(
                                      fontFamily: 'Poppins Bold',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: screenMax,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: widget.saldoTotal > 0 &&
                                  ventaData['status_sincronized'] == 'Enviado'
                              ? Colors.green
                              : Colors
                                  .grey, // Color verde para el fondo del botón
                        ),
                        child: ElevatedButton(
                          onPressed: widget.saldoTotal > 0 &&
                                  ventaData['status_sincronized'] == 'Enviado'
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Cobro(
                                        orderId: ventaData['id'],
                                        cOrderId: ventaData['c_order_id'],
                                        documentNo: ventaData['documentno'],
                                        idFactura: ventaData['id_factura'],
                                        listPriceOrder: ventaData['m_price_list_id'],
                                        isTaxWithHoldingIva: ventaData['is_tax_with_holding_iva'],
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(Colors
                                .transparent), // Hace que el color de fondo del botón sea transparente
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              'Cobrar',
                              style: TextStyle(
                                color: Colors
                                    .white, // Texto blanco para que se destaque sobre el fondo verde
                                fontFamily: 'Poppins Bold',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
