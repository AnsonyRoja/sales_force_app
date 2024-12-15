import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales_force/config/app_bar_sales_force.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/infrastructure/models/plan_visits.dart';
import 'package:sales_force/presentation/screen/visits/helpers/date_header.dart';
import 'package:sales_force/presentation/screen/visits/helpers/initialize_locations.dart';
import 'package:sales_force/presentation/screen/visits/helpers/items_for_listview.dart';
import 'package:sales_force/presentation/screen/visits/providers/visits_planned_providers.dart';
import 'package:sales_force/presentation/screen/visits/unplanned_visits/unplanned_visits.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  Future<List<PlanVisits>>? getPlanVisi;
  TextEditingController searchController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _showAddButton = true;
  late ScrollController _scrollController;
  late List<DateTime> daysInMonth;
    bool _isAnimating = false;

 

  void _scrollListener() {
    
    if (_isAnimating) return;

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

   void _scrollToToday(double height) async {
       _isAnimating = true;

    
      while (!_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    int index = daysInMonth.indexWhere((day) =>
        day.year == DateTime.now().year &&
        day.month == DateTime.now().month &&
        day.day == DateTime.now().day);

    if (index > 5) {
      _scrollController.animateTo(
        index * height * 0.288,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    _isAnimating = true; 

  }



  @override
  void initState() {

    initLocationPermission();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    Provider.of<VisitsPlannedProvider>(context, listen: false).fetchVisits();
     
     
      daysInMonth = [];
      int daysInCurrentMonth = DateTime(
        _focusedDay.year,
        _focusedDay.month + 1,
        0,
      ).day;
      for (int i = 1; i <= daysInCurrentMonth; i++) {
        daysInMonth.add(DateTime(_focusedDay.year, _focusedDay.month, i));
      }

    super.initState();
  }

@override
  void dispose() {
    
    _scrollController.dispose();
    super.dispose();
  }

   void _onDateChanged(DateTime newDate) {
    setState(() {
      _focusedDay = newDate;
      daysInMonth = [];
      int daysInNewMonth = DateTime(
        newDate.year,
        newDate.month + 1,
        0,
      ).day;
      for (int i = 1; i <= daysInNewMonth; i++) {
        daysInMonth.add(DateTime(newDate.year, newDate.month, i));
      }
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.9;
    final screenHight = MediaQuery.of(context).size.height * 0.9;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 245, 235),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(170),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const AppBars(labelText: 'Ruta de Clientes'),
            Positioned(
              left: 16,
              right: 16,
              top: 160,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: DateHeader(focusedDay: _focusedDay, onDateChanged:_onDateChanged,) ,
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
            child: Consumer<VisitsPlannedProvider>(
              builder: (context, provider, child) {
                if (provider.visits.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  List<PlanVisits> planVisits = provider.visits;
                  print('Este es el plan de visitas ${planVisits}');
                  
                  // Agrupar visitas por día
                  Map<DateTime, List<PlanVisits>> groupedVisits = {};
                  planVisits.forEach((visit) {
                    DateTime visitDay = DateTime(
                      visit.dateCalendar.year,
                      visit.dateCalendar.month,
                      visit.dateCalendar.day,
                    );
                    if (!groupedVisits.containsKey(visitDay)) {
                      groupedVisits[visitDay] = [];
                    }
                    groupedVisits[visitDay]!.add(visit);
                  });

                  // Obtener lista de días del mes actual
                  List<DateTime> daysInMonth = [];
                  int daysInCurrentMonth = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                    0,
                  ).day;
                  for (int i = 1; i <= daysInCurrentMonth; i++) {
                    daysInMonth
                        .add(DateTime(_focusedDay.year, _focusedDay.month, i));
                  }

                    _scrollToToday(screenHight);
                     
                  return Container(
                    margin: EdgeInsets.only(
                        top: mediaScreen * 0.05), // Agregar margen superior

                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: daysInMonth.length,
                      itemBuilder: (context, index) {
                        final day = daysInMonth[index];



                        return ItemsForLisviewPlanVisits(day: day, groupedVisits: groupedVisits)  ;
                      
                      },
                    ),
                  );
                }
              },
            ),
          ),
          
            Positioned(
                top: screenHight * 0.69,
                right: mediaScreen * 0.05,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UnplannedVisits()),
                  ),
                  child: Icon(
                    Icons.add_location_alt_sharp,
                    color: Color(0XFF00722D),
                    size: 55,
                  ),
                )),
        ],
      ),
    );
  }
}
