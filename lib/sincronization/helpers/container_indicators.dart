
import 'package:flutter/material.dart';
import 'package:sales_force/sincronization/design_charger/striped_design.dart';





class ContainerIndicators extends StatelessWidget {
  final String text;
  final dynamic syncPercentagesIndicators; 
  const ContainerIndicators({super.key, required this.text, required this.syncPercentagesIndicators});

  @override
  Widget build(BuildContext context) {
    return    Container(
                  width: 155,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0EBFC),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            blurRadius: 7,
                            spreadRadius: 2)
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 155,
                            child:  Text(
                              text,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Poppins SemiBold',
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        child: Container(
                          width: 150,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0XFFA5F52B)),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Stack(
                            children: [
                              StripedContainer(
                                  syncPercentages: syncPercentagesIndicators ),
                              Center(
                                child: Text(
                                  '${syncPercentagesIndicators.toStringAsFixed(1)} %',
                                  style: TextStyle(
                                      shadows: const [
                                        Shadow(
                                            blurRadius: 15, color: Colors.grey)
                                      ],
                                      color: syncPercentagesIndicators == 100
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Poppins SemiBold'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
  }
}






