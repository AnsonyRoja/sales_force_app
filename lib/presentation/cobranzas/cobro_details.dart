import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:flutter/material.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/cobranzas/idempiere/update_cobro.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';

class CobroDetails extends StatefulWidget {
  final Map<String, dynamic> cobro;
  const CobroDetails({super.key, required this.cobro});

  @override
  State<CobroDetails> createState() => _CobroDetailsState();
}

class _CobroDetailsState extends State<CobroDetails> {
  String isConversion = "";
  TextEditingController montoController = TextEditingController();
  TextEditingController conversionController = TextEditingController();
  bool enableButon = true;

  // dolares a bolivares 
   generatedConversion() {

    if(montoController.text.isEmpty){
      setState(() {
      conversionController.text = "0.0";
        
      });
      return;
    }else if( double.parse(montoController.text) < 0){
      montoController.text = "0.0";
    }
    
    double conversion = widget.cobro['tasa_conversion'];
    double amount = double.parse(montoController.text).toDouble();
    double toConversion = amount / conversion;

    print(
        'esto es la conversion ss 1 $toConversion esto es $amount y esto es $conversion');
  setState(() {
    conversionController.text = toConversion.toStringAsFixed(4).toString();
  });
  }

// bolivares a dolares
  generatedConversionUsd() {

     if(montoController.text.isEmpty){
      setState(() {
      conversionController.text = "0.0";
      });
      return;
    }else if( double.parse(montoController.text) < 0){
      montoController.text = "0.0";
      return;
    }
   
    double conversion = widget.cobro['tasa_conversion'];
    double amount = double.parse(montoController.text).toDouble();
    double toConversion = amount * conversion;

    print('esto es la conversion ss 2 $toConversion esto es $amount y esto es $conversion');
    setState(() {
    conversionController.text = toConversion.toStringAsFixed(4).toString();
    });

  }


  initListPrice(lP) async {
    if(lP == 0 ){

      return;

    }
    dynamic mPriceList = await typeOfCurrencyIs(lP);
    Map firstPriceoOfList = mPriceList.first;

    print("Esto es el firstprice $firstPriceoOfList");
    if (firstPriceoOfList['c_currency_id'] == 100) {
      setState(() {
        isConversion = "USD";
      });
    } else if (firstPriceoOfList['c_currency_id'] == 205) {
      setState(() {
        isConversion = "BS";
      });
    }
    ;
  }

  @override
  void initState() {
    initListPrice(widget.cobro['list_price_order']);
    if(isConversion == 'USD'){

    conversionController.text = widget.cobro['pay_amt_bs'].toString();
    montoController.text = widget.cobro['pay_amt'].toString();
    
    }else{
    
    conversionController.text = widget.cobro['pay_amt'].toString();
    montoController.text = widget.cobro['pay_amt_bs'].toString();

    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.8;
    final heightScreen = MediaQuery.of(context).size.height * 1;
    final bsToLowerCase = widget.cobro['c_currency_iso']
        .toString()
        .toLowerCase()
        .replaceAll('.', '');
    print('bs to lower case $bsToLowerCase');
    print('esto es el cobro ${widget.cobro}');
    return GestureDetector(
      onTap:  () {
         FocusScope.of(context).unfocus();
      } ,      
      child: Scaffold(
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: AppBarSample(label: 'Detalles del Cobro')),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                SizedBox(
                  height: heightScreen * 0.02,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: mediaScreen,
                    height: heightScreen * 0.60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              children: [
                                widget.cobro['c_currency_id'] != 205 &&
                                        isConversion != "BS"
                                        ? SizedBox(
                                            width: mediaScreen * 0.88,
                                            height: widget.cobro['doc_status'] == 'NA'  ? heightScreen * 0.128: heightScreen * 0.06,
                                            child: widget.cobro['doc_status'] == 'NA' ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Monto',
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins Bold',
                                                      fontSize: 18),
                                                ),
                                                SizedBox(height: heightScreen *0.01,),
                                            Container(
                                            width: mediaScreen * 0.9, // Aumentar el ancho para que sea más fácil de usar
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Añadir padding externo
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green.withOpacity(0.3), // Reducir la opacidad de la sombra
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                  offset: const Offset(0, 4), // Mover la sombra ligeramente hacia abajo
                                                )
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.attach_money, // Añadir un icono representativo
                                                  color: Colors.green,
                                                  size: 24.0,
                                                ),
                                                const SizedBox(width: 12.0), // Espacio entre el icono y el campo de texto
                                                Expanded(
                                                  child: TextFormField(
                                                    readOnly: enableButon == false ? true : false,
                                                    controller: montoController,
                                                    decoration: InputDecoration(
                                                      hintText: 'Ingrese el monto',
                                                      hintStyle: TextStyle(
                                                        fontFamily: 'Poppins Bold',
                                                        fontSize: 18,
                                                        color: Colors.grey.shade400, // Color del texto de sugerencia
                                                      ),
                                                      border: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins SemiBold',
                                                      color: Colors.green,
                                                      fontSize: 17,
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese un monto';
                                                      }

                                                      return null;

                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          ],
                                        ):   Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              '\$${widget.cobro['pay_amt']}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ), 
                                        
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          widget.cobro['c_currency_iso']
                                      .toString()
                                      .toLowerCase()
                                      .replaceAll('.', '') ==
                                  'bs' && widget.cobro['list_price'] != 0
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: mediaScreen * 0.88,
                                        height: widget.cobro['doc_status'] == 'NA' ? heightScreen * 0.12 : heightScreen * 0.08,
                                        child: widget.cobro['doc_status'] == 'NA' ? 
                                          Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto en Bolivares',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                              Container(
                                        width: mediaScreen * 0.9, // Aumentar el ancho para que sea más fácil de usar
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Añadir padding externo
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(0.3), // Reducir la opacidad de la sombra
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 4), // Mover la sombra ligeramente hacia abajo
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.money, // Añadir un icono representativo
                                              color: Colors.green,
                                              size: 24.0,
                                            ),
                                            const SizedBox(width: 12.0), // Espacio entre el icono y el campo de texto
                                            Expanded(
                                              child: TextFormField(
                                                readOnly: enableButon == false ? true : false ,
                                                controller: montoController,
                                                onChanged: (value) {
                                                    print('Entre aqui value $value');
                                                  
                                                  generatedConversion();

                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'Ingrese el monto',
                                                  hintStyle: TextStyle(
                                                    fontFamily: 'Poppins Bold',
                                                    fontSize: 18,
                                                    color: Colors.grey.shade400, // Color del texto de sugerencia
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17,
                                                ),
                                                keyboardType: TextInputType.number,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Por favor ingrese un monto';
                                                  }
                                                  // Puedes agregar validaciones adicionales aquí si es necesario
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          ],
                                        ):
                                         Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto en Bolivares',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              'Bs ${widget.cobro['pay_amt_bs']?? widget.cobro['pay_amt']}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          widget.cobro['c_currency_iso']
                                          .toString()
                                          .toLowerCase()
                                          .replaceAll('.', '') ==
                                      'bs' &&
                                  isConversion != "BS" && widget.cobro['list_price'] != 0 
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: mediaScreen * 0.88,
                                        height: heightScreen * 0.08,
                                        child: widget.cobro['doc_status'] == 'NA' ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto en Divisas',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              '\$ ${conversionController.text}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ): Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto en Divisas',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              '\$ ${widget.cobro['pay_amt']}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : widget.cobro['c_currency_iso']
                                          .toString()
                                          .toLowerCase()
                                          .replaceAll('.', '') ==
                                      'bs' &&
                                    widget.cobro['list_price'] == 0 
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: mediaScreen * 0.88,
                                        height: heightScreen * 0.08,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              'Bs ${widget.cobro['pay_amt']}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              children: [
                                widget.cobro['c_currency_id'] == 100 &&
                                        isConversion == "BS" 
                                    ? SizedBox(
                                        width: mediaScreen * 0.88,
                                        height: heightScreen * 0.08,
                                        child: widget.cobro['doc_status'] == 'NA' ? 
                                           Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto en Bolivares',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              'Bs. ${conversionController.text}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ):  
                                           Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Monto en Bolivares',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              'Bs. ${widget.cobro['pay_amt']}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: Row(
                              children: [
                                widget.cobro['c_currency_id'] == 100 &&
                                        isConversion == "BS"
                                    ? SizedBox(
                                        width: mediaScreen * 0.88,
                                        height: heightScreen * 0.15,
                                        child: widget.cobro['doc_status'] == 'NA' ? 

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                      'Monto',
                                                      style: TextStyle(
                                                          fontFamily: 'Poppins Bold',
                                                          fontSize: 18),
                                                    ),
                                                SizedBox(height: heightScreen *0.01,),
                                            Container(
                                            width: mediaScreen * 0.9, // Aumentar el ancho para que sea más fácil de usar
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Añadir padding externo
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green.withOpacity(0.3), // Reducir la opacidad de la sombra
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                  offset: const Offset(0, 4), // Mover la sombra ligeramente hacia abajo
                                                )
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.attach_money, // Añadir un icono representativo
                                                  color: Colors.green,
                                                  size: 24.0,
                                                ),
                                                const SizedBox(width: 12.0), // Espacio entre el icono y el campo de texto
                                                Expanded(
                                                  child: TextFormField(
                                                    onChanged: (value) {
                                                      
                                                      generatedConversionUsd();
                                                    },
                                                    readOnly: enableButon == false ? true : false  ,
                                                    controller: montoController,
                                                    decoration: InputDecoration(
                                                      hintText: 'Ingrese el monto',
                                                      hintStyle: TextStyle(
                                                        fontFamily: 'Poppins Bold',
                                                        fontSize: 18,
                                                        color: Colors.grey.shade400, // Color del texto de sugerencia
                                                      ),
                                                      border: InputBorder.none,
                                                    ),
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins SemiBold',
                                                      color: Colors.green,
                                                      fontSize: 17,
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Por favor ingrese un monto';
                                                      }
                                                      // Puedes agregar validaciones adicionales aquí si es necesario
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                                ],
                                              ):
                                        
                                         Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Montos',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 18),
                                            ),
                                            Flexible(
                                                child: Text(
                                              '\$ ${widget.cobro['pay_amt_bs']}',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins SemiBold',
                                                  color: Colors.green,
                                                  fontSize: 17),
                                            ))
                                          ],
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: mediaScreen * 0.88,
                                  height: heightScreen * 0.07,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Fecha',
                                        style: TextStyle(
                                            fontFamily: 'Poppins Bold', fontSize: 18),
                                      ),
                                      Flexible(
                                          child: Text(
                                        '${widget.cobro['date']}',
                                        style:
                                            const TextStyle(fontFamily: 'Poppins Regular'),
                                      ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: SizedBox(
                                width: mediaScreen,
                                child: const Text(
                                  'Detalles',
                                  style: TextStyle(
                                      fontFamily: 'Poppins Bold', fontSize: 18),
                                  textAlign: TextAlign.start,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'N° Documento: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins SemiBold',
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${widget.cobro['documentno']}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Cuenta Bancaria: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins SemiBold',
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${widget.cobro['c_bankaccount_name']}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: SizedBox(
                              width: mediaScreen,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Tipo de cambio: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins SemiBold',
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${widget.cobro['c_currency_iso']}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: SizedBox(
                              width: mediaScreen,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Tipo de Pago: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins SemiBold',
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${widget.cobro['tender_type_name']}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: SizedBox(
                              width: mediaScreen,
                              // height: heightScreen * 0.056 ,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Descripción: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins SemiBold',
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${widget.cobro['description'] == '{@nil=true}' ? "" : widget.cobro['description']}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: SizedBox(
                              width: mediaScreen,
                              // height: heightScreen * 0.056 ,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Tasa de conversión: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins SemiBold',
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${widget.cobro['tasa_conversion'] != '{@nil=true}' ? widget.cobro['tasa_conversion'] : ''  }',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            child: SizedBox(
                              width: mediaScreen,
                              // height: heightScreen * 0.056 ,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Estado: ',
                                      style: TextStyle(
                                        fontFamily: 'Poppins SemiBold',
                                      ),
                                    ),
                                    TextSpan(
                                      text:   widget.cobro['doc_status'] == 'CO' ?
                                                                      "Completado": widget.cobro['doc_status'] == 'IP' || widget.cobro['doc_status'] == 'PR' ? "En Proceso" 
                                                                      : widget.cobro['doc_status'] == "VO" ? "Anulado" : widget.cobro['doc_status'] == "NA" ? "Rechazado" : widget.cobro['doc_status'] == "AP" ? "Aprobado" : widget.cobro['doc_status'] ?? ""
                                                                          .toString(),
                                      style: TextStyle(
                                        fontFamily: 'Poppins Regular',
                                        overflow: TextOverflow.ellipsis,
                                        color: widget.cobro['doc_status'] == 'CO' || widget.cobro['doc_status'] == "Completado" || widget.cobro['doc_status'] == 'AP' ?  const Color(0xFF00722D): widget.cobro['doc_status'] == 'PR' || widget.cobro['doc_status'] == 'IP' || widget.cobro['doc_status'] == 'En Proceso' ?
                                                                        const Color.fromARGB(255, 167, 153, 34) : widget.cobro['doc_status'] == 'VO'? Colors.red : widget.cobro['doc_status'] == 'NA'? Colors.red: Colors.black ,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: heightScreen * 0.02,),
               widget.cobro['doc_status'] == 'NA' ? Column(
                  children: [
                    SizedBox(
                      width: mediaScreen,
                      height: heightScreen * 0.08,
                    
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: enableButon ? WidgetStatePropertyAll(Color(0XFF00722D)): WidgetStatePropertyAll(Colors.grey),
                          shape:  WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))) ),
                        onPressed: enableButon ? () async {
                          
                          setState(() {
                            enableButon = false;
                          });

                        bool isConection = await checkInternetConnectivity();

                                    
                                  if(isConection == false){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          title: const Row(
                                            children: [
                                              Icon(Icons.warning, color: Colors.red),
                                              SizedBox(width: 10),
                                              Text('Sin Conexión a Internet'),
                                            ],
                                          ),
                                          content: const Text(
                                            'Parece que no tienes conexión a Internet. '
                                            'Por favor, verifica tu conexión e intenta nuevamente.',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Aceptar',
                                                style: TextStyle(color: Colors.blue, fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  setState(() {
                                    enableButon = true;
                                  });  
                                  return;
                                }

                                    String saldoTotalString = widget.cobro['saldo_total'].toString();
                                    print('Esto es el saldo TotalString $saldoTotalString');
                                    double tasaConversion = double.parse(widget.cobro['tasa_conversion'].toString());
                                    double conversionValue = double.parse(conversionController.text);
                                     double montoValue = double.parse(montoController.text); 
                                    double saldoTotal = double.parse(saldoTotalString);

                                    if (tasaConversion > 0 && conversionValue > saldoTotal) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          title: const Row(
                                            children: [
                                              SizedBox(width: 10),
                                              Text('Error'),
                                            ],
                                          ),
                                          content:  Text(
                                            'El Monto del cobro no puede ser mayor al saldo total',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Aceptar',
                                                style: TextStyle(color: Colors.blue, fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  setState(() {
                                    enableButon = true;
                                  });  
                                  return;
                                } else if(tasaConversion == 0 && montoValue >saldoTotal){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          title: const Row(
                                            children: [
                                              SizedBox(width: 10),
                                              Text('Error'),
                                            ],
                                          ),
                                          content:  Text(
                                            'El Monto del cobro no puede ser mayor al saldo total',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Aceptar',
                                                style: TextStyle(color: Colors.blue, fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  setState(() {
                                    enableButon = true;
                                  });  
                                  return;
                                }

                                // si la tasa de conversion > 0 osea que si hay conversion, entonces se va actualizar el cobro
                                // en conversionController y montoControler como pay_amt_bs 


                                 

                                  if(widget.cobro['tasa_conversion'] > 0){

                                  updateAmmountAndConversionCobros(widget.cobro['id'], double.parse(conversionController.text), double.parse(montoController.text));

                                  }else{

                                  updateAmmountAndConversionCobros(widget.cobro['id'], double.parse(montoController.text), double.parse(montoController.text));

                                  }

                                await updateCobroIdempiere(widget.cobro, double.parse(montoController.text));
                                print('esta es la respuesta antes del setDocAction');
                                await setDocActionCobrosIdempiere(widget.cobro);
                                await setDocActionAprobar(widget.cobro);
                            
                                print('Esto es la conversion ${conversionController.text} y esto es el monto total del cobro ${montoController.text}');

                                   showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            title: const Row(
                                              children: [
                                                SizedBox(width: 10),
                                                Text('Éxito'),
                                              ],
                                            ),
                                            content: const Text(
                                              'Cobro editado con éxito',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Cierra el primer dialogo
                                                  Navigator.of(context).pop(); // Cierra el segundo dialogo (o la pantalla anterior)
                                                },
                                                child: const Text(
                                                  'Aceptar',
                                                  style: TextStyle(color: Colors.blue, fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                         
                        
                      }: null , child: const Text('Actualizar', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 18),)),
                    ),
                SizedBox(height: heightScreen * 0.02,),
                  ],
                ): Container(),
                

              ],
            ),
          ),
        ),
      ),
    );
  }
}
