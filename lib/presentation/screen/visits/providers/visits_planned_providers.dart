import 'package:flutter/material.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/infrastructure/models/plan_visits.dart';

class VisitsPlannedProvider with ChangeNotifier {
  List<PlanVisits> _visits = [];

  List<PlanVisits> get visits => _visits;

  Future<void> fetchVisits() async {
    try {
      List visitList = await getPlanVisits();
      _visits = visitList.map((data) => PlanVisits.fromJson(data)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching visits: $e');
    }
  }
}
