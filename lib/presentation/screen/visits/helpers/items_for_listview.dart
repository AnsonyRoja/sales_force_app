import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sales_force/infrastructure/models/plan_visits.dart';
import 'package:sales_force/presentation/screen/visits/planned_visits/add_planned_visits.dart';
import 'package:sales_force/presentation/screen/visits/visits_details.dart';




class ItemsForLisviewPlanVisits extends StatelessWidget {
  final DateTime day;
  final  Map<DateTime, List<PlanVisits>> groupedVisits;

  const ItemsForLisviewPlanVisits({super.key, required this.day, required this.groupedVisits});

                @override
                Widget build(BuildContext context) {

                  final mediaScreen = MediaQuery.of(context).size.width * 0.9;
                  final heightScreen = MediaQuery.of(context).size.height * 0.9;
                  String dayOfWeek = DateFormat.EEEE('es').format(day); // 'es' para español
                  final formattedDate = DateFormat('dd/MM').format(day);
                  dayOfWeek = '${dayOfWeek[0].toUpperCase()}${dayOfWeek.substring(1)}'; // Poner la primera letra en mayúscula
                  final filteredVisits = groupedVisits[day] ?? [];
                  
                  return  Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: mediaScreen,
                            height: MediaQuery.of(context).size.height * 0.23,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadiusDirectional.circular(40),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7)
                                ]),
                            child: Row(
                              children: [
                                Container(
                                  width: mediaScreen * 0.2,
                                  height: heightScreen *0.4,
                                  decoration: BoxDecoration(
                                      color: filteredVisits
                                              .where((visit) =>
                                                  visit.state == "Visits")
                                              .isNotEmpty
                                          ? const Color(0XFF0C5A74)
                                          : const Color(0XFF00722D),
                                      borderRadius: BorderRadius.circular(80)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        dayOfWeek.substring(0, 3),
                                        style: const TextStyle(
                                            fontFamily: 'Poppins SemiBold',
                                            color: Colors.white),
                                      ),
                                      Text(formattedDate,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins SemiBold',
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: mediaScreen * 0.5,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 25),
                                    child: filteredVisits.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Clientes: ${filteredVisits.length}',
                                                style: const TextStyle(
                                                    fontFamily:
                                                        'Poppins SemiBold'),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                  'Visitados: ${filteredVisits.where((visit) => visit.state == "Visits").length}',
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins SemiBold')),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              Text(
                                                  'No Visitados: ${filteredVisits.where((visit) => visit.state == "No Visits").length}',
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Poppins SemiBold')),
                                            ],
                                          )
                                        : const Text(
                                            'No hay visitas registradas'),
                                  ),
                                ),
                                filteredVisits.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          print(
                                              'Este es la informacion del cliente de ese dia $filteredVisits');

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VisitsDetails(
                                                customersPlanVisit:
                                                    filteredVisits,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Text('Ver',
                                                style: TextStyle(
                                                    color: Color(0XFF00722D))),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Image.asset(
                                              'lib/assets/Lupa-2@2x.png',
                                              width: 25,
                                              color: const Color(0XFF00722D),
                                            ),
                                          ],
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: day.isBefore(DateTime.now()) ||
                                                day.isAtSameMomentAs(
                                                    DateTime.now())
                                            ? () {
                                                List<PlanVisits> pendingVisits =
                                                    [];
                                                groupedVisits.forEach(
                                                    (visitDay, visits) {
                                                  if (visitDay.isBefore(day) &&
                                                      visits
                                                          .where((visit) =>
                                                              visit.state ==
                                                              "No Visits")
                                                          .isNotEmpty) {
                                                    pendingVisits.addAll(
                                                        visits.where((visit) =>
                                                            visit.state ==
                                                            "No Visits"));
                                                  }
                                                });

                                                if (pendingVisits.isEmpty) {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        35)),
                                                        title: Text(
                                                            'Aviso Importante'),
                                                        content: Text(
                                                            'No tienes visitas pendientes programadas para fechas anteriores.'),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: Text('OK'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                  return;
                                                }

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    
                                                    builder: (context) =>
                                                        AddPlannedVisits(
                                                      customerVisitPlanned:
                                                          pendingVisits,
                                                    ),
                                                  ),
                                                );

                                                print(
                                                    'Pendientes de visitas ${pendingVisits.length}');

                                                print(
                                                    'Esta es la fecha de hoy $day');
                                                print(
                                                    'Este es la informacion del cliente de ese dia $filteredVisits');
                                                filteredVisits.forEach((value) {
                                                  print(
                                                      "este es el value de ese cliente ${value.bPartnerName}");
                                                  print(
                                                      'Esto es value de la fecha de la visita ${value.dateCalendar}');
                                                });
                                              }
                                            : null,
                                        child: Row(
                                          children: [
                                            Text('Crear',
                                                style: TextStyle(
                                                    color: day.isBefore(DateTime
                                                                .now()) ||
                                                            day.isAtSameMomentAs(
                                                                DateTime.now())
                                                        ? const Color(
                                                            0XFF00722D)
                                                        : Colors.grey)),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Image.asset(
                                              'lib/assets/Más@3x.png',
                                              width: 25,
                                              color: day.isBefore(
                                                          DateTime.now()) ||
                                                      day.isAtSameMomentAs(
                                                          DateTime.now())
                                                  ? const Color(0XFF00722D)
                                                  : Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      }
   }

