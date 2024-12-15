import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/config/search_key_idempiere.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/insert_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/clients/select_customer.dart';
import 'package:sales_force/presentation/cobranzas/idempiere/create_cobro.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:sizer/sizer.dart';

class Cobro extends StatefulWidget {
  final int orderId;
  final dynamic cOrderId;
  final dynamic documentNo;
  final dynamic idFactura;
  final dynamic listPriceOrder;
  final dynamic isTaxWithHoldingIva;
  const Cobro(
      {super.key,
      required this.orderId,
      required this.cOrderId,
      required this.documentNo,
      required this.idFactura,
      required this.listPriceOrder,
      required this.isTaxWithHoldingIva
      });

  @override
  State<Cobro> createState() => _CobroState();
}

class _CobroState extends State<Cobro> {
  late Future<Map<String, dynamic>> _ordenVenta;
  TextEditingController numRefController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController observacionController = TextEditingController();
  TextEditingController montoConversionController = TextEditingController();
  final TextEditingController _saldoConversion = TextEditingController();
  final TextEditingController _fechaIdempiereController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> orderData = {};
  String? paymentTypeValue = 'Efectivo';
  String? coinValue = "\$";
  String? typeDocumentValue = "Cobro";
  dynamic cBPartnerIds = 0;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> bankAccountsList = [];
  List<Map<String, dynamic>> typeCoinsList = [];
  List<Map<String, dynamic>> cobrosList = [];
  late Future<void> _bankAccFuture;
  bool disabledButton = true;
  List<Map<String, dynamic>> conversionMap = [];
  DateTime? now;
  double tasaConversion = 0.0000;
  late List<dynamic> clientsSales = [];
  Future<Map<String, dynamic>>? _currencyData;
  dynamic listPrice = 0;

  // Selecteds

  int _selectsBankAccountId = 0;
  String _selectTypePayment = "X";
  int _selectCurrencyId = 0;

  //Texts

  String _bankAccountText = "";
  String _currencyText = "";

  List<Map<String, dynamic>> uniqueISOsAndCurrencyId = [];

  double parseFormattedNumber(dynamic formattedNumber) {
    if (formattedNumber is String) {
      // Eliminar puntos (separador de miles) y cambiar comas a puntos (separador decimal)
      String cleanedNumber =
          formattedNumber.replaceAll('.', '').replaceAll(',', '.');
      return double.parse(cleanedNumber.replaceAll(
          '\$', '')); // Elimina el signo de moneda si está presente
    } else if (formattedNumber is int) {
      return formattedNumber.toDouble();
    } else if (formattedNumber is double) {
      return formattedNumber;
    } else {
      throw ArgumentError('Tipo no soportado para el saldo total');
    }
  }

  void _loadCurrentDate() {
    now = DateTime.now();
    final formattedDate = DateFormat('dd/MM/yyyy').format(now!);

    dateController.text =
        formattedDate; // Asigna la fecha actual al controlador del campo de texto
  }

  Future<Map<String, dynamic>>? _loadCurrencyIs() async {
    print('esto es el clientsales $clientsSales');
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();

      setState(() {
        variablesG = response;
      });
    }
    final typeCurrency = await typeOfCurrencyIs(
        widget.listPriceOrder == '{@nil: true}'
            ? variablesG[0]['m_pricelist_id']
            : widget.listPriceOrder);

    print('esto es el tipo de moneda $typeCurrency');

    return typeCurrency.first;
  }

  Future<void> _getBankAcc() async {
    print('Entre aqui... ${widget.orderId}');
    List<Map<String, dynamic>> bankAccounts = await getBankAccounts();
    List<Map<String, dynamic>> cobros =
        await getCobrosByOrderId(widget.orderId);

    cobrosList.addAll(cobros);

    print('Cobros unicos $cobros');

    bankAccountsList.add({
      'c_bank_account_id': 0,
      'bank_name': 'Selecciona una Cuenta Bancaria'
    });

    uniqueISOsAndCurrencyId
        .add({'c_currency_id': 0, 'iso_code': 'Selecciona un tipo de moneda'});

    for (var account in bankAccounts) {
      if (!uniqueISOsAndCurrencyId
          .any((element) => element['iso_code'] == account['iso_code'])) {
        setState(() {
          uniqueISOsAndCurrencyId.add({
            'iso_code': account['iso_code'],
            'c_currency_id': account['c_currency_id']
          });
        });
      }
    }

    setState(() {
      bankAccountsList.addAll(bankAccounts);
    });

    print(
        "estos son las cuentas agregadas desde la base de datos $bankAccounts");
  }

  initV() async {
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();
      setState(() {
        variablesG = response;
      });
    }
  }

  initConversionRate() async {
    List<Map<String, dynamic>> response = await getRateConversion();

    print(
        'Esto es la respuesta de getRateConversion $response && ${dateController.text}');

    DateFormat formmater = DateFormat('dd/MM/yyyy');
      String dateString = dateController.text;
      DateTime date;

     try {
    date = formmater.parse(dateString);
  } catch (e) {
    print('Error al parsear la fecha: $e');
    return;
  }

    List<Map<String, dynamic>> result = response.where(
      (element) {
          DateTime validFrom = DateTime.parse(element['valid_from']);
          DateTime validTo = DateTime.parse(element['valid_to']);

        return date.isAfter(validFrom) && date.isBefore(validTo) ||
           date.isAtSameMomentAs(validFrom) || date.isAtSameMomentAs(validTo);
      },
    ).toList();

    setState(() {
      conversionMap.addAll(result);
    });

      tasaConversion = conversionMap
        .map((e) => (e['multiply_rate'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);

    print('este es el conversionMap ${conversionMap}');
  }

  generatedConversion() {
    print('conversionMap $conversionMap');
     double highestMultiplyRate = conversionMap
        .map((e) => (e['multiply_rate'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);


    print('Esto es el highesMultiPlyRate 1 $highestMultiplyRate');


    double conversion = double.parse(highestMultiplyRate.toStringAsFixed(4));
    double amount = double.parse(montoController.text).toDouble();
    double toConversion = amount / conversion;

    setState(() {
      tasaConversion = conversion;
    });

    print(
        'esto es la conversion ss 1 $toConversion esto es $amount y esto es $conversion');

    return toConversion.toStringAsFixed(4);
  }

  generatedConversionUsd() {
    print('conversionMap $conversionMap');
        double highestMultiplyRate = conversionMap
        .map((e) => (e['multiply_rate'] as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    print('Esto es el highesMulplyRate 2 $highestMultiplyRate');

    double conversion = double.parse(highestMultiplyRate.toStringAsFixed(4));
    double amount = double.parse(montoController.text).toDouble();
    double toConversion = amount * conversion;

    setState(() {
      tasaConversion = conversion;
    });

    print(
        'esto es la conversion ss 2 $toConversion esto es $amount y esto es $conversion');

    return toConversion.toStringAsFixed(4);
  }

  initListPrice(lP) async {
    dynamic mPriceList = await typeOfCurrencyIs(lP);
    Map firstPriceoOfList = mPriceList.first;
    print('Este es el precio de lista $firstPriceoOfList');

    if (firstPriceoOfList['c_currency_id'] == 100) {
      return "USD";
    } else if (firstPriceoOfList['c_currency_id'] == 205) {
      return "BS";
    }
    ;
  }

  @override
  void initState() {
    initConversionRate();
    initV();
    _ordenVenta = _loadOrdenVentasForId();

    // numRefController.text = cobrosList[0]['documentno'];

    setState(() {
      montoController.text = "0";
    });
    _loadCurrentDate();
    _bankAccFuture = _getBankAcc();

    _fechaIdempiereController.text =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);

    super.initState();
  }

  Future<Map<String, dynamic>> _loadOrdenVentasForId() async {
    return await getOrderWithProducts(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final screenMax = MediaQuery.of(context).size.width * 0.9;
    final heightScreen = MediaQuery.of(context).size.height * 1;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Cobro')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: FutureBuilder(
            future: _ordenVenta,
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final clientData = snapshot.data!['client'][0];
                orderData = snapshot.data!['order'];
                clientsSales = snapshot.data!['client'];
                print("Esto es snapshot data ${snapshot.data}");
                listPrice = widget.listPriceOrder == '{@nil: true}'
                    ? variablesG[0]['m_pricelist_id']
                    : widget.listPriceOrder;
                print('lista de precio $listPrice');

                print('Esto es istaxWithHolding ${widget.isTaxWithHoldingIva}');

                cBPartnerIds = orderData['c_bpartner_id'];
                _currencyData = _loadCurrencyIs();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SizedBox(
                        width: screenMax,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: screenMax * 0.85,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    8), // Establece el radio de los bordes
                              ),
                              child: const Text(
                                'Datos Del Cliente',
                                style: TextStyle(
                                    fontFamily: 'Poppins Bold', fontSize: 18),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: screenMax * 0.85,
                              height: heightScreen * 0.37,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        blurRadius: 7,
                                        spreadRadius: 2)
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: screenMax * 0.40,
                                            height: heightScreen * 0.15,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Nombre',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins Bold',
                                                      fontSize: 18),
                                                  textAlign: TextAlign.start,
                                                ),
                                                SizedBox(
                                                  height: heightScreen * 0.02,
                                                ),
                                                Flexible(
                                                    child: Text(
                                                  '${clientData['bp_name']}',
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins Regular'),
                                                ))
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                              width: screenMax * 0.35,
                                              height: heightScreen * 0.15,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'RIF/CI',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Poppins Bold',
                                                        fontSize: 18),
                                                  ),
                                                  SizedBox(
                                                    height: heightScreen * 0.02,
                                                  ),
                                                  Flexible(
                                                      child: Text(
                                                    clientData['ruc'] ==
                                                            '{@nil: true}'
                                                        ? ''
                                                        : clientData['ruc']
                                                            .toString(),
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins Regular'),
                                                  ))
                                                ],
                                              ))
                                        ],
                                      ),
                                      SizedBox(
                                          width: screenMax,
                                          child: const Text(
                                            'Detalles',
                                            style: TextStyle(
                                                fontFamily: 'Poppins Bold',
                                                fontSize: 18),
                                            textAlign: TextAlign.left,
                                          )),
                                      SizedBox(
                                        height: heightScreen * 0.02,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins SemiBold',
                                                    color: Colors.black),
                                                children: [
                                                  const TextSpan(
                                                      text: 'Correo: '),
                                                  TextSpan(
                                                    text: clientData['email'] !=
                                                            '{@nil: true}'
                                                        ? clientData['email']
                                                        : "",
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins Regular'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins SemiBold',
                                                    color: Colors.black),
                                                children: [
                                                  const TextSpan(
                                                      text: 'Telefono: '),
                                                  TextSpan(
                                                    text: clientData['phone'] !=
                                                            '{@nil: true}'
                                                        ? clientData['phone']
                                                            .toString()
                                                        : '',
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            'Poppins Regular'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      FutureBuilder(
                                        future: _currencyData,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Text("");
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            final currentCurrency = snapshot.data;
                                                          
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins SemiBold',
                                                          color: Colors.black),
                                                      children: [
                                                        const TextSpan(
                                                            text: 'Saldo: '),
                                                        TextSpan(
                                                          text: orderData[
                                                                      'saldo_total'] !=
                                                                  '{@nil: true}'
                                                              ? '${currentCurrency!['price_list_name'].toString().toLowerCase().contains('bs') ? 'Bs.' : '\$'} ${orderData['saldo_total'].toString()}'
                                                              : '',
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  'Poppins Regular'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins SemiBold',
                                                    color: Colors.black),
                                                children: [
                                                  const TextSpan(
                                                      text: 'Tasa de Conversion: '),
                                                  TextSpan(
                                                    text: tasaConversion.toStringAsFixed(4),
                                                    style:  TextStyle(
                                                        color:  orderData['doc_status'] == 'CO' ?  Color(0xFF00722D): orderData['doc_status'] == 'PR' || orderData['doc_status'] == 'IP' || orderData['doc_status'] == 'En Proceso'  ?
                                                                       const Color.fromARGB(255, 167, 153, 34) : orderData['doc_status'] == 'VO'? Colors.red : Colors.black,
                                                        fontFamily:
                                                            'Poppins Regular'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                       Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins SemiBold',
                                                    color: Colors.black),
                                                children: [
                                                  const TextSpan(
                                                      text: 'Estado: '),
                                                  TextSpan(
                                                    text: orderData['doc_status'] == 'CO' ?
                                                                      "Completado": orderData['doc_status'] == 'PR' || orderData['doc_status'] == 'IP' ?  "En Proceso" 
                                                                      : orderData['doc_status'] == "VO" ? "Anulado": orderData['doc_status'] ?? ""
                                                                          .toString(),
                                                    style:  TextStyle(
                                                        color:  orderData['doc_status'] == 'CO' ?  Color(0xFF00722D): orderData['doc_status'] == 'PR' || orderData['doc_status'] == 'IP' || orderData['doc_status'] == 'En Proceso'  ?
                                                                       const Color.fromARGB(255, 167, 153, 34) : orderData['doc_status'] == 'VO'? Colors.red : Colors.black,
                                                        fontFamily:
                                                            'Poppins Regular'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: heightScreen * 0.02,
                            ),
                            SizedBox(
                                width: screenMax * 0.85,
                                child: const Text(
                                  'Detalles de Orden',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Bold', fontSize: 18),
                                  textAlign: TextAlign.start,
                                )),
                            SizedBox(
                              height: heightScreen * 0.02,
                            ),
                            CustomTextInfo(
                              label: "Orden N°",
                              value: orderData['documentno'].toString() != ""
                                  ? orderData['documentno'].toString()
                                  : "" ,
                              mediaScreen: screenMax,
                              heightScreen: heightScreen,
                            ),
                            orderData['documentno_factura'] != null
                                ? SizedBox(
                                    height: heightScreen * 0.02,
                                  )
                                : Container(),
                            orderData['documentno_factura'] != null && orderData['documentno_factura'] != '{@nil=true}'
                                ? CustomTextInfo(
                                    label: "N° Documento, Factura",
                                    value: orderData['documentno_factura']
                                                .toString() !=
                                            ""
                                        ? orderData['documentno_factura']
                                            .toString()
                                        : "",
                                    mediaScreen: screenMax,
                                    heightScreen: heightScreen,
                                  )
                                : Container(),
                            SizedBox(
                              height: heightScreen * 0.015,
                            ),
                            CustomTextInfo(
                              label: "Fecha",
                              value: orderData['fecha'].toString(),
                              mediaScreen: screenMax,
                              heightScreen: heightScreen,
                            ),
                            SizedBox(
                              height: heightScreen * 0.015,
                            ),
                            Column(
                              children: [
                                Container(
                                  width: screenMax * 0.85,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        8), // Establece el radio de los bordes
                                  ),
                                  child: const Text(
                                    'Cobranza',
                                    style: TextStyle(
                                        fontFamily: 'Poppins Bold',
                                        fontSize: 18),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                SizedBox(
                                  height: heightScreen * 0.015,
                                ),
                                Container(
                                  width: screenMax,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: heightScreen * 0.1,
                                        width: screenMax * 0.85,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  blurRadius: 7,
                                                  spreadRadius: 2)
                                            ]),
                                        child: TextFormField(
                                          controller: numRefController,
                                          decoration: const InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.red)),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                15)),
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.red)),
                                            labelText: "Numero de Referencia",
                                            labelStyle: TextStyle(
                                                fontFamily: 'Poppins Regular'),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 25),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                      SizedBox(
                                        height: heightScreen * 0.013,
                                      ),
                                      FutureBuilder<void>(
                                          future: _bankAccFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              return Column(
                                                children: [
                                                  CustomDropdownButtonFormField(
                                                    identifier:
                                                        'selectTypeAccountBank',
                                                    selectedIndex:
                                                        _selectsBankAccountId,
                                                    dataList: bankAccountsList,
                                                    text: _bankAccountText,
                                                    onSelected: (newValue,
                                                        bankAccText) {
                                                      setState(() {
                                                        _selectsBankAccountId =
                                                            newValue ?? 0;
                                                        _bankAccountText =
                                                            bankAccText;
                                                      });
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        heightScreen * 0.013,
                                                  ),
                                                  CustomDropdownButtonFormField(
                                                    identifier:
                                                        'selectTypeCoins',
                                                    selectedIndex:
                                                        _selectCurrencyId,
                                                    dataList:
                                                        uniqueISOsAndCurrencyId,
                                                    text: _currencyText,
                                                    onSelected: (newValue,
                                                        currectText) {
                                                      setState(() {
                                                        _selectCurrencyId =
                                                            newValue ?? 0;
                                                        _currencyText =
                                                            currectText;
                                                      });
                                                          print('Esto es el valor de la moneda $_selectCurrencyId');
                                                    },
                                                  )
                                                ],
                                              );
                                            }
                                          }),
                                      SizedBox(
                                        height: heightScreen * 0.013,
                                      ),
                                      Container(
                                        height: heightScreen * 0.1,
                                        width: screenMax * 0.85,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 7,
                                                spreadRadius: 2,
                                                color: Colors.grey
                                                    .withOpacity(0.5))
                                          ],
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          value: paymentTypeValue,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              paymentTypeValue = newValue;
                                            });
                        
                                            if (newValue ==
                                                'Depósito Directo') {
                                              setState(() {
                                                _selectTypePayment = 'A';
                                              });
                                            } else if (newValue ==
                                                'Tarjeta de Crédito') {
                                              setState(() {
                                                _selectTypePayment = 'C';
                                              });
                                            } else if (newValue == "Cheque") {
                                              setState(() {
                                                _selectTypePayment = 'K';
                                              });
                                            } else if (newValue == "Cuenta") {
                                              setState(() {
                                                _selectTypePayment = 'T';
                                              });
                                            } else if (newValue == 'Efectivo') {
                                              setState(() {
                                                _selectTypePayment = 'X';
                                              });
                                            } else if (newValue ==
                                                'Débito Directo') {
                                              setState(() {
                                                _selectTypePayment = 'D';
                                              });
                                            }
                        
                                            print(
                                                'Este es el valor de paymentTypeValue $paymentTypeValue && este es el valor de $_selectTypePayment');
                                          },
                                          items: <String>[
                                            'Depósito Directo',
                                            'Tarjeta de Crédito',
                                            'Cheque',
                                            'Cuenta',
                                            'Efectivo',
                                            'Débito Directo'
                                          ].map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins Regular'),
                                              ),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            errorStyle: const TextStyle(
                                                fontFamily: 'Poppins Regular'),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 25),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            labelText: 'Tipo de Pago',
                                            labelStyle: const TextStyle(
                                                fontFamily: 'Poppins Regular'),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: heightScreen * 0.013,
                                      ),
                                      Container(
                                        height: heightScreen * 0.1,
                                        width: screenMax * 0.85,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  blurRadius: 7,
                                                  spreadRadius: 2)
                                            ]),
                                        child: TextFormField(
                                          readOnly: true,
                                          controller: dateController,
                                          decoration: const InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            labelText: "Fecha",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 25),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: heightScreen * 0.013,
                                      ),
                                      Container(
                                        height: heightScreen * 0.1,
                                        width: screenMax * 0.85,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  blurRadius: 7,
                                                  spreadRadius: 2)
                                            ]),
                                        child: TextFormField(
                                          controller: montoController,
                                          decoration: const InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.red)),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                15)),
                                                    borderSide: BorderSide(
                                                        width: 1,
                                                        color: Colors.red)),
                                            labelText: "Monto",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 25),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty ||
                                                value == '0' ||
                                                value.contains('-') ||
                                                value.contains(',')) {
                                              return "El monto tiene caracteres invalidos, esta vacio";
                                            }
                        
                                            return null;
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: heightScreen * 0.013,
                                      ),
                                      Container(
                                        height: heightScreen * 0.1,
                                        width: screenMax * 0.85,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  blurRadius: 7,
                                                  spreadRadius: 2)
                                            ]),
                                        child: TextFormField(
                                          controller: observacionController,
                                          decoration: const InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                borderSide: BorderSide(
                                                    width: 25,
                                                    color: Colors.white)),
                                            labelText: "Observacion",
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 25),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: heightScreen * 0.025,
                                ),
                                ElevatedButton(
                                  onPressed:  orderData['doc_status'] == 'CO' && orderData['status_sincronized'] ==
                                              'Enviado' &&
                                          orderData['saldo_total'] > 0 &&
                                          disabledButton || orderData['saldo_total'] > 0 && disabledButton && orderData['doc_status'] == 'CO' && orderData['documentno'] != "" && orderData['c_order_id'] != null 
                                      ? () async {

                                         


                                          bool thereInternet = await checkInternetConnectivity();

                                            if(!thereInternet){
                                           
                                             showDialog(context: context, builder: (context) {

                                                    return AlertDialog(
                                                        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15)) ,
                                                        title: Text('Sin Acceso a Internet'),
                                                        content: Text('No se pudo conectar al servicio del ERP'),

                                                    );


                                                }, );

                                              return;

                                            }

                                            if(orderData['id_factura'] != '{@nil=true}' && orderData['id_factura'] != null && widget.isTaxWithHoldingIva == 'Y'){

                                                 showDialog(context: context, builder: (context) {

                                                    return AlertDialog(
                                                        shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15)) ,
                                                        title: Container(
                                                          width: 60.sp,
                                                          height: 30.sp,
                                                          decoration: BoxDecoration(
                                                            color: Colors.yellow,
                                                            borderRadius: BorderRadius.circular(15)
                                                          ) ,
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text('Advertencia', style: TextStyle(fontFamily: 'Poppins Bold') , textAlign: TextAlign.center,),
                                                          )),
                                                        content: Text('Esta Factura, No posee un comprobante de retencion asociado', style: TextStyle(fontFamily: 'Poppins SemiBold'),),

                                                    );


                                                }, );
                                                
                                            }
                                          

                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              disabledButton = false;
                                            });
                                            await _createCobro();
                        
                                            setState(() {
                                              _ordenVenta =
                                                  _loadOrdenVentasForId();
                                            });
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (const Color(0xFF00722D)),
                                    foregroundColor:
                                        Colors.white, // Color de fondo verde
                                    minimumSize: Size(screenMax * 0.85, 50),
                                    // Ancho máximo y altura de 50
                                  ),
                                  child: const Text(
                                    'Crear Cobro',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily:
                                            'Poppins Bold'), // Tamaño de fuente 16
                                  ),
                                ),
                                SizedBox(
                                  height: heightScreen * 0.025,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _createCobro() async {

    dynamic listpricesResult = await initListPrice(listPrice);

      print('este es la lista de precio $listpricesResult este es el $_currencyText');

    if (conversionMap.isEmpty &&
            listpricesResult == "USD" &&
            _currencyText.toLowerCase().contains('bs') ||
        conversionMap.isEmpty &&
            listpricesResult == "BS" &&
            _currencyText.toLowerCase().contains('usd')) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'No existe ninguna tasa registrada, por favor sincronice la aplicacion'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );

      setState(() {
        disabledButton = true;
      });
      return;
    }
   
    if (conversionMap.isNotEmpty) {
        DateTime validFrom = DateTime.parse(conversionMap[0]['valid_from']);
    DateTime validTo = DateTime.parse(conversionMap[0]['valid_to']);
    DateTime dateControllerDate = DateFormat('dd/MM/yyyy').parse(dateController.text);
    String conversionDate = DateFormat('dd/MM/yyyy').format(validTo);
      bool isWithinRange = dateControllerDate.isAfter(validFrom) && dateControllerDate.isBefore(validTo) ||
      dateControllerDate.isAtSameMomentAs(validFrom) || dateControllerDate.isAtSameMomentAs(validTo);


    print('Fecha del conversionDate $conversionDate');
    if (_currencyText.toLowerCase().contains('bs') &&
          listpricesResult == 'USD' &&
        isWithinRange ) {
      montoConversionController.text = generatedConversion().toString();

      print('Entre aqui en el primer if');

      // setState(() {
      //   disabledButton = true;
      // });
    } else if (_currencyText.toLowerCase().contains('usd') &&
        listpricesResult == 'BS' &&
        isWithinRange ) {
      montoConversionController.text = generatedConversionUsd().toString();

      print("entre aqui en el segundo if");
    }
    if (dateControllerDate.isBefore(validFrom) || dateControllerDate.isAfter(validTo)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('La fecha de la tasa esta vencida.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );

      setState(() {
        disabledButton = true;
      });

      return;
    }else{
      print('este es el valor de conversiondate $conversionDate');
    }
    }

    final dynamic bankAccountId = _selectsBankAccountId;
    final dynamic cDocTypeId = variablesG[0]['c_doctypereceipt_id'];
    final dynamic dateTrx = _fechaIdempiereController.text;
    final dynamic description = observacionController.text;
    final dynamic cBPartnerId = cBPartnerIds;
    final double payAmt = montoConversionController.text != ''
        ? double.parse(montoConversionController.text)
        : double.parse(montoController.text);
    final double payAmtToConversion =
        !_currencyText.toLowerCase().contains('usd') ||
                !_currencyText.toLowerCase().contains('bs')
            ? double.parse(montoController.text)
            : 0.0;
    final dynamic currencyId = _selectCurrencyId;
    final dynamic cOrderId = widget.cOrderId;
    final dynamic cInvoiceId = widget.idFactura;
    final dynamic tenderType = _selectTypePayment;
    final String typeMoney = _currencyText;
    final String bankAccount = _bankAccountText;
    final String tenderTypeT = paymentTypeValue!;

    print('Esto es el valor de currencyId $currencyId');

     bool isExist  = await isExistCobro(bankAccountId,dateController.text, currencyId, payAmt ,numRefController.text);

        print('Existe el cobro ? $isExist');

        if(isExist){
      
        showDialog(context: context, builder: (context) {

                return AlertDialog(
                    shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(15)) ,
                    title: Text('Cobro Duplicado'),
                    content: Text('Este Cobro ya se encuentra registrado'),

                );


            }, );
              setState(() {
              disabledButton = true;
             });

          return;

        }


    print(
        "este es el montoconversioncontroller ${montoConversionController.text} && esto es el montocontroller ${montoController.text}");

    print('payAmt ${payAmt} && payAmtConversion ${payAmtToConversion}');

    print(
        'Esto es numRef ${numRefController.text} es currencyId $currencyId y este es el orderId $cOrderId y este es el id de la factura $cInvoiceId');

    final String date = dateController.text;

    final int saleOrderId = widget.orderId;

    final double saldoTotal;

    if (orderData['saldo_total'] is double) {
      saldoTotal = orderData['saldo_total'];
    } else if (orderData['saldo_total'] is String) {
      saldoTotal = double.parse(orderData['saldo_total']);
    } else {
      throw Exception('El tipo de saldo_total no es ni double ni String');
    }

    if (payAmt > saldoTotal) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'El cobro no puede ser mayor al saldo total de la orden.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
      setState(() {
        disabledButton = true;
      });
    } else if (payAmt <= 0 || saldoTotal <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('El cobro no puede ser menor o igual a 0.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } else {
      Map<String, dynamic> cobro = {
        "c_bankaccount_id": bankAccountId,
        "c_doctype_id": cDocTypeId,
        "date_trx": dateTrx,
        "description": description,
        "c_bpartner_id": cBPartnerId,
        "pay_amt": payAmtToConversion != 0.0
            ? payAmtToConversion.toStringAsFixed(4)
            : payAmt,
        "c_currency_id": _selectCurrencyId,
        "c_order_id": cOrderId,
        "c_invoice_id": cInvoiceId,
        "tender_type": tenderType,
        "c_number_ref": numRefController.text,
       
      };

      print('esto es el cobro $cobro');

      int cobroId = await insertCobro(
          cBankAccountId: bankAccountId,
          cDocTypeId: cDocTypeId,
          dateTrx: dateTrx,
          date: date,
          description: description,
          cBPartnerId: cBPartnerId,
          payAmt: payAmt.toStringAsFixed(4),
          cCurrencyId: _selectCurrencyId,
          cOrderId: cOrderId,
          cInvoiceId: cInvoiceId,
          documentNo: 0,
          tenderType: tenderType,
          saleOrderId: saleOrderId,
          bankAccountT: bankAccount,
          cCurrencyIso: typeMoney,
          tenderTypeName: tenderTypeT,
          payAmtConversion: payAmtToConversion,
          tasaConversion: tasaConversion,
          listPrice: widget.listPriceOrder,
          numberInvoiced: orderData['documentno_factura'],
          );

      // setState(() {

      // _loadOrdenVentasForId();

      // });f

      dynamic response = await createCobroIdempiere(cobro); 
      
      print('Esto es response  $response');

      dynamic numDoc = searchKey(response['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][0]['outputFields']['outputField'][1], '@value');

      dynamic paymentId = searchKey(response['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][0]['outputFields']['outputField'][0], '@value');
            dynamic docStatus = searchKey(response, '@Text');

      print('Esto es cobroId $cobroId, y numdoc $numDoc paymentID $paymentId');

      await updateDocumentNoCobro(cobroId, numDoc, paymentId, docStatus);

      print('NumDoc $numDoc');
      print("esto es el cobro $cobro y la respuesta $response");

      numRefController.clear();
      montoController.clear();
      observacionController.clear();
      montoConversionController.clear();

      setState(() {
        _selectCurrencyId = 0;
        _selectsBankAccountId = 0;
        disabledButton = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cobro creado con éxito')));
    }
  }
}

class CustomTextInfo extends StatelessWidget {
  final String label;
  final String value;
  final double mediaScreen;
  final double heightScreen;

  const CustomTextInfo(
      {super.key,
      required this.label,
      required this.value,
      required this.mediaScreen,
      required this.heightScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mediaScreen * 0.85,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 7,
                spreadRadius: 2)
          ],
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(
              height: 5,
            ),
            Text(
              value,
              style: const TextStyle(fontFamily: 'Poppins Regular'),
            ),
          ],
        ),
      ),
    );
  }
}
