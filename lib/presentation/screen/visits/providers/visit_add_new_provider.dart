import 'package:flutter/material.dart';
import 'package:sales_force/database/gets_database.dart';

class VisitsNewProvider with ChangeNotifier {
  List<dynamic> _visits = [];

  List<dynamic> get visits => _visits;

  void updateVisits(List<dynamic> newVisits) {
    _visits = newVisits;
    notifyListeners();
  }

  Future<void> fetchVisits() async {
    _visits = await getVisitCustomersYes();
    notifyListeners();
  }
}
