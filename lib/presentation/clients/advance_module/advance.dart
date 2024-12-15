import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/config/search_key_idempiere.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/insert_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/clients/advance_module/idempiere/create_cobro_advance.dart';
import 'package:sales_force/presentation/clients/select_customer.dart';
import 'package:sales_force/presentation/cobranzas/idempiere/create_cobro.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Advance extends StatefulWidget {

  final Map<String, dynamic> customer;

  const Advance(
      {super.key, required this.customer});

  @override
  State<Advance> createState() => _CobroAdvance();
}

class _CobroAdvance extends State<Advance> {
  TextEditingController numRefController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController montoController = TextEditingController();
  TextEditingController observacionController = TextEditingController();
  final TextEditingController _fechaIdempiereController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> orderData = {};
  String? paymentTypeValue = 'Efectivo';
  String? coinValue = "\$";
  String? typeDocumentValue = "Cobro";
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> bankAccountsList = [];
  List<Map<String, dynamic>> typeCoinsList = [];
  List<Map<String, dynamic>> cobrosList = [];
  late Future<void> _bankAccFuture;
  bool disabledButton = true;
  DateTime? now;
  dynamic listPrice = 0;
    double tasaConversion = 0.0;
  List<Map<String, dynamic>> conversionMap = [];


  // Selecteds

  int _selectsBankAccountId = 0;
  String _selectTypePayment = "X";
  dynamic _selectTypeCoins = 0;
  int _selectCurrencyId = 0;

  //Texts

  String _bankAccountText = "";
  String _currencyText = "";

  List<Map<String, dynamic>> uniqueISOsAndCurrencyId = [];

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

  Future<void> _getBankAcc() async {

    List<Map<String, dynamic>> bankAccounts = await getBankAccounts();
  
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
    initConversionRate();
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();
      setState(() {
        variablesG = response;
      });
    }
  }






  @override
  void initState() {
    initV();
    print('Customer Client ${widget.customer}');
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
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical ,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
                    children: [
                      Padding(
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
                                                      '${widget.customer["bp_name"]}',
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
                                                        widget.customer['ruc'] ==
                                                                '{@nil: true}'
                                                            ? ''
                                                            : widget.customer['ruc']
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
                                                        text: widget.customer['email'] !=
                                                                '{@nil: true}'
                                                            ? widget.customer['email']
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
                                                        text: widget.customer['phone'] !=
                                                                '{@nil: true}'
                                                            ? widget.customer['phone']
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
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: heightScreen * 0.02,
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
                                        onPressed: disabledButton ? () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  setState(() {
                                                    disabledButton = false;
                                                  });
                                                  await _createCobro();
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
                      ),
                    ],
                  )
                
          
            ),
        ),
        ),
      );
    
  }

  Future<void> _createCobro() async {
 
    final dynamic bankAccountId = _selectsBankAccountId;
    final dynamic cDocTypeId = variablesG[0]['c_doctypereceipt_id'];
    final dynamic dateTrx = _fechaIdempiereController.text;
    final dynamic description = observacionController.text;
    final dynamic cBPartnerId = widget.customer['c_bpartner_id'];
    final double payAmt = double.parse(montoController.text);
    final dynamic currencyId = _selectTypeCoins;
    final dynamic tenderType = _selectTypePayment;
    final String typeMoney = _currencyText;
    final String bankAccount = _bankAccountText;
    final String tenderTypeT = paymentTypeValue!;

    print(
        "esto es el montocontroller ${montoController.text}");

    print('payAmt ${payAmt}');

    print(
        'Esto es numRef ${numRefController.text} es currencyId $currencyId y este es el orderId y este es el id de la factura');

    final String date = dateController.text;



      Map<String, dynamic> cobro = {
        "c_bankaccount_id": bankAccountId,
        "c_doctype_id": cDocTypeId,
        "date_trx": dateTrx,
        "description": description,
        "c_bpartner_id": cBPartnerId,
        "pay_amt": payAmt,
        "c_currency_id": _selectCurrencyId,
        "tender_type": tenderType,
        "c_number_ref": numRefController.text,
      };

      print('esto es el cobro $cobro');

      int cobroId = await insertAdvance(
          cBankAccountId: bankAccountId,
          cDocTypeId: cDocTypeId,
          dateTrx: dateTrx,
          date: date,
          description: description,
          cBPartnerId: cBPartnerId,
          payAmt: payAmt.toStringAsFixed(4),
          cCurrencyId: _selectCurrencyId,
          tenderType: tenderType,
          bankAccountT: bankAccount,
          cCurrencyIso: typeMoney,
          tenderTypeName: tenderTypeT,
          listPrice: listPrice,
          );

      // setState(() {

      // _loadOrdenVentasForId();

      // });f

      dynamic response = await createCobroAdvanceIdempiere(cobro);

      dynamic numDoc = searchKey(response['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][0]['outputFields']['outputField'][1], '@value');
       dynamic paymentId = searchKey(response['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][0]['outputFields']['outputField'][0], '@value');

      dynamic docStatus = searchKey(response, '@Text');

      print('Esto es cobroId $cobroId, y numdoc $numDoc');

      await updateDocumentNoCobro(cobroId, numDoc, paymentId, docStatus);

      print('NumDoc $numDoc');
      print("esto es el cobro $cobro y la respuesta $response");

      numRefController.clear();
      montoController.clear();
      observacionController.clear();

      setState(() {
        _selectCurrencyId = 0;
        _selectsBankAccountId = 0;
        disabledButton = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cobro creado con éxito')));
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
