import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/infrastructure/models/plan_visits.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:sales_force/presentation/screen/visits/idempiere/add_visit_customer_http.dart';
import 'package:sales_force/presentation/screen/visits/planned_visits/add_planned_visits.dart';
import 'package:sales_force/presentation/screen/visits/providers/visit_add_new_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sizer/sizer.dart';

class VisitsDetails extends StatefulWidget {
  final List<PlanVisits> customersPlanVisit;
  const VisitsDetails({super.key, required this.customersPlanVisit});

  @override
  State<VisitsDetails> createState() => _VisitsDetailsState();
}

class _VisitsDetailsState extends State<VisitsDetails> {
  DateTime _focusedDay = DateTime.now();
  bool _showAddButton = true;
  late ScrollController _scrollController;
  DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
  TextEditingController fechaIdempiereControllerEnd = TextEditingController();

  DateTime truncateToDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;

    List<String> parts = input.split(' ');
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].length > 2 && i > 0) {
        parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
      }
    }

    String union = parts.join(' ');

    return union[0].toUpperCase() + union.substring(1);
  }

  void _scrollListener() {
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

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    print('Esto es el customer ${widget.customersPlanVisit}');
    Provider.of<VisitsNewProvider>(context, listen: false).fetchVisits();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.9;
    final screenHight = MediaQuery.of(context).size.height * 0.9;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Stack(
          children: [
            const AppBarSample(label: "Detalles de Visitas"),
            Positioned(
              left: 16,
              right: 16,
              top: 90,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = truncateToDate(
                                _focusedDay.subtract(const Duration(days: 1)));
                          });
                        },
                        icon: Image.asset('lib/assets/Izq.png'),
                      ),
                      Text(
                        capitalize(DateFormat('EEEE, d MMMM', 'es')
                            .format(_focusedDay)),
                        style: const TextStyle(
                            fontSize: 18, fontFamily: 'Poppins Bold'),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedDay = truncateToDate(
                                _focusedDay.add(const Duration(days: 1)));
                          });
                        },
                        icon: Image.asset('lib/assets/Der.png'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: mediaScreen * 0.05),
            child: Consumer<VisitsNewProvider>(
              builder: (context, visitsProvider, child) {
                if (visitsProvider.visits.isEmpty) {
                  return const Center(child: Text('No hay datos disponibles.'));
                } else {
                  Map<DateTime, List> groupedVisits = {};

                  for (var visit in visitsProvider.visits) {
                    DateTime visitDate;
                    try {
                      visitDate = format.parse(visit['visit_date']);
                    } catch (e) {
                      print('Error parsing date: $e');
                      continue;
                    }

                    DateTime visitDay = truncateToDate(visitDate);

                    if (!groupedVisits.containsKey(visitDay)) {
                      groupedVisits[visitDay] = [];
                    }
                    groupedVisits[visitDay]!.add(visit);
                  }

                  final filteredVisits =
                      groupedVisits[truncateToDate(_focusedDay)] ?? [];
                  print(
                      'Esto es el filteredVisits para $_focusedDay: $filteredVisits');

                  return Container(
                    margin: EdgeInsets.only(top: mediaScreen * 0.05),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredVisits.length,
                      itemBuilder: (context, index) {
                        final visit = filteredVisits[index];
                        final DateTime visitDate =
                            DateTime.parse(visit['visit_date']);
                        final String formattedDate =
                            DateFormat('dd/MM/yyyy hh:mm a').format(visitDate);

                        String? formattedEndDate;

                        if (visit['end_date'] != "") {
                          final DateTime visitEndDate =
                              DateTime.parse(visit['end_date']);
                          formattedEndDate = DateFormat('dd/MM/yyyy hh:mm a')
                              .format(visitEndDate);
                        }

                        print('Visits $visit');
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: mediaScreen * 0.95,
                                height:
                                    visit['end_date'] != '' ? 38.3.h : 35.7.h,
                                constraints: BoxConstraints(
                                    minHeight: screenHight * 0.1),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(35),
                                    boxShadow: [
                                      BoxShadow(
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          color: Colors.grey.withOpacity(0.5))
                                    ]),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 25),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Cliente',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 15),
                                            ),
                                            SizedBox(
                                              height: screenHight * 0.01,
                                            ),
                                            Text(
                                              '${visit['c_bpname']}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      'Poppins Regular'),
                                            ),
                                            SizedBox(
                                              height: screenHight * 0.01,
                                            ),
                                            const Text(
                                              'Detalles',
                                              style: TextStyle(
                                                  fontFamily: 'Poppins Bold',
                                                  fontSize: 15),
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Dirección:',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Poppins SemiBold',
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ' ${visit['direccion']}',
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins Regular',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Motivo:',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Poppins SemiBold',
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ${visit['motivo']}',
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins Regular',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  const TextSpan(
                                                    text: 'Observación:',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Poppins SemiBold',
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ' ${visit['description']}',
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins Regular',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(children: [
                                              const Text(
                                                'Coordenadas:',
                                                style: TextStyle(
                                                  fontFamily:
                                                      'Poppins SemiBold',
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: visit['latitude'] !=
                                                            0.0 &&
                                                        visit['longitud'] != 0.0
                                                    ? () async {
                                                        String googleMapsUrl =
                                                            'https://www.google.com/maps?q=${visit['latitude']},${visit['longitud']}';

                                                        await launchUrlString(
                                                            googleMapsUrl);
                                                      }
                                                    : null,
                                                child: Text(
                                                  ' Ir al Mapa',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Poppins Regular',
                                                    color: visit['latitude'] !=
                                                                0.0 &&
                                                            visit['longitud'] !=
                                                                0.0
                                                        ? const Color.fromARGB(
                                                            255, 78, 161, 230)
                                                        : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Fecha de visita: ',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Poppins SemiBold'),
                                                ),
                                                Text(formattedDate)
                                              ],
                                            ),
                                            visit['end_date'] != ""
                                                ? Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Fin de visita: ',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Poppins SemiBold'),
                                                      ),
                                                      Text(formattedEndDate ??
                                                          "")
                                                    ],
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 77.8,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                                shape: WidgetStatePropertyAll(
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(35))),
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        visit['state'] ==
                                                                'Visits'
                                                            ? Colors.green
                                                            : Colors.grey)),
                                            onPressed:
                                                visit['state'] == 'No Visits'
                                                    ? () {
                                                        if (visit['state'] ==
                                                            'No Visits') {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            35)),
                                                                title: Text(
                                                                  'Marca visita del cliente',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins SemiBold'),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                content: Text(
                                                                  '${visit['c_bpname']}',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'Poppins Regular'),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                                actions: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop(); // Cierra el diálogo
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          'Volver',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Poppins SemiBold',
                                                                              color: Colors.red),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: mediaScreen *
                                                                            0.1,
                                                                      ),
                                                                      TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            fechaIdempiereControllerEnd.text =
                                                                                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                                                                          });
                                                                          bool
                                                                              flag =
                                                                              await checkInternetConnectivity();

                                                                          if (flag) {
                                                                            // Si hay conexión a Internet, actualiza el estado de la visita y crea la visita en Idempiere
                                                                            updateVisitState(
                                                                                visit['id'],
                                                                                fechaIdempiereControllerEnd.text,
                                                                                'Visits');
                                                                            addVisitCustomerIdempiere(visit,
                                                                                fechaIdempiereControllerEnd.text);
                                                                          } else {
                                                                            // Si no hay conexión a Internet, simplemente retorna
                                                                            return;
                                                                          }

                                                                          Provider.of<VisitsNewProvider>(context, listen: false)
                                                                              .fetchVisits();
                                                                          Navigator.of(context)
                                                                              .pop(); // Cierra el diálogo
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          'Sí, Registrar visita',
                                                                          style:
                                                                              TextStyle(fontFamily: 'Poppins SemiBold'),
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        }
                                                      }
                                                    : null,
                                            child: visit['state'] == 'Visits'
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Visitado',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins Bold',
                                                            color: Colors.white,
                                                            fontSize: 19),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(
                                                          width: mediaScreen *
                                                              0.05),
                                                      Image.asset(
                                                        'lib/assets/Check@2x.png',
                                                        width: 25,
                                                        color: Colors.white,
                                                      )
                                                    ],
                                                  )
                                                : const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Marcar Visita',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Poppins Bold',
                                                            fontSize: 19),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  )),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            )
                          ],
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          if (_showAddButton)
            Positioned(
              top: screenHight * 0.75,
              right: mediaScreen * 0.05,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPlannedVisits(
                            customerVisitPlanned: widget.customersPlanVisit,
                          )),
                ),
                child: Image.asset(
                  'lib/assets/Agg@2x.png',
                  width: 75,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
