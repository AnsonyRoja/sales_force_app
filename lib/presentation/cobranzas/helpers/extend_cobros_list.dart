import 'package:flutter/material.dart';
import 'package:sales_force/presentation/cobranzas/cobro_details.dart';

class CobrosListExtend extends StatelessWidget {
  final Future cobrosFuture;
  final List filteredCobros;
  final ScrollController _scrollController;
  final bool _isLoading;
  final double screenMax;

  const CobrosListExtend({
    super.key,
    required this.cobrosFuture,
    required this.filteredCobros,
    required ScrollController scrollController,
    required bool isLoading,
    required this.screenMax,
  })  : _scrollController = scrollController,
        _isLoading = isLoading;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        future: cobrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView.builder(
              controller: _scrollController,
              itemCount: filteredCobros.length + 1,
              itemBuilder: (context, index) {
                if (index == filteredCobros.length) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox();
                }

                final cobro = filteredCobros[index];

                print("estos son los cobros $cobro");

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
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 195,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          "N° ${cobro['nro_factura'] != null && cobro['nro_factura'] != '{@nil=true}' ? cobro['nro_factura'] :  cobro['orden_venta_nro']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 55,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: screenMax * 0.85,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Nombre: ',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Poppins SemiBold',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenMax * 0.35,
                                                      child: Text(
                                                        cobro['client_name']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Fecha: ',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Poppins SemiBold',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenMax * 0.35,
                                                      child: Text(
                                                        cobro['date'],
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Monto: ',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Poppins SemiBold',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenMax * 0.35,
                                                      child: Text(
                                                        cobro['c_currency_iso'].toString().toLowerCase().contains('bs')  && cobro['list_price_order'] == 0 ? 
                                                         "${cobro['pay_amt'] ?? cobro['pay_amt_bs']} Bs" : 
                                                        cobro['c_currency_iso']
                                                                    .toString()
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        'usd') &&
                                                                cobro['list_price_order'] ==
                                                                    1000002
                                                            ? "${cobro['pay_amt_bs']}\$"
                                                            : (cobro['c_currency_iso']
                                                                    .toString()
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        'bs')
                                                                ? "${cobro['pay_amt_bs'] ?? cobro['pay_amt']} Bs."
                                                                : "${cobro['pay_amt']} \$"),
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'N° Documento: ',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Poppins SemiBold',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenMax * 0.25,
                                                      child: Text(
                                                        cobro['documentno']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Estado: ',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Poppins SemiBold',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenMax * 0.25,
                                                      child: Text(
                                                         cobro['doc_status'] == 'CO' ?
                                                                    "Completado": cobro['doc_status'] == 'IP' || cobro['doc_status'] == 'PR' ? "En Proceso" 
                                                                    : cobro['doc_status'] == "VO" ? "Anulado" : cobro['doc_status'] == "NA" ? "Rechazado": cobro['doc_status'] == "AP" ? "Aprobado": cobro['doc_status'] ?? ""
                                                                        .toString(),
                                                        style:  TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                              color: cobro['doc_status'] == 'CO' || cobro['doc_status'] == "Completado" || cobro['doc_status'] == "AP" ?  Color(0xFF00722D): cobro['doc_status'] == 'PR' || cobro['doc_status'] == 'IP' || cobro['doc_status'] == 'En Proceso' ?
                                                                      Color.fromARGB(255, 167, 153, 34) : cobro['doc_status'] == 'VO'? Colors.red : cobro['doc_status'] == 'NA'? Colors.red: Colors.black,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      'Descripción: ',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Poppins SemiBold',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenMax * 0.25,
                                                      child: Text(
                                                        cobro['description']
                                                            .toString() == '{@nil=true}' ? "": cobro['description']
                                                            .toString() ,
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Poppins Regular',
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CobroDetails(
                                                              cobro: cobro),
                                                    ));
                                              },
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    'Ver',
                                                    style: TextStyle(
                                                      color: Color(0xFF00722D),
                                                    ),
                                                  ),
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
                                            ),
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
            );
          }
        },
      ),
    );
  }
}
