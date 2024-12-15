import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sales_force/database/gets_database.dart';

class CobrosProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _cobros = [];
  List<Map<String, dynamic>> _filteredCobros = [];
  bool _isLoading = false;
  bool _hasMoreCobros = true;
  final int _pageSize = 15;

  List<Map<String, dynamic>> get cobros => _cobros;
  List<Map<String, dynamic>> get filteredCobros => _filteredCobros;
  bool get isLoading => _isLoading;
  bool get hasMoreCobros => _hasMoreCobros;

  Future<void> fetchCobros({required int page, required int pageSize}) async {
    if (_isLoading || !_hasMoreCobros) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newData = await getCobros(page: page, pageSize: pageSize);

      if (newData.isNotEmpty) {
        _cobros.addAll(newData);
        _filteredCobros = _cobros;
        _hasMoreCobros = newData.length == pageSize;
      } else {
        _hasMoreCobros = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCobros(String query) {
    _filteredCobros = _cobros.where((cobro) {
      final clientName = cobro['client_name'].toString().toLowerCase();
      final orderNumber = cobro['orden_venta_nro'].toString().toLowerCase();
      final documentNo = cobro['documentno'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return clientName.contains(searchQuery) ||
          orderNumber.contains(searchQuery) ||
          documentNo.contains(searchQuery);
    }).toList();

    notifyListeners();
  }

  void filterByMaxPrice(double maxPrice) {
    _filteredCobros = _cobros.where((cobro) {
      double monto = cobro['pay_amt'];
      return monto <= maxPrice;
    }).toList();

    _filteredCobros.sort((a, b) {
      double montoA = a['pay_amt'];
      double montoB = b['pay_amt'];
      return montoB.compareTo(montoA);
    });

    notifyListeners();
  }

  void sortByDateRange(DateTime start, DateTime end) {
    _filteredCobros = _cobros.where((cobro) {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      try {
        if (cobro['date'] != null && cobro['date'] != '') {
          final ventaDate = dateFormat.parse(cobro['date']);
          return ventaDate.isAfter(start.subtract(const Duration(days: 1))) &&
              ventaDate.isBefore(end.add(const Duration(days: 1)));
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }).toList();

    _filteredCobros.sort((a, b) {
      
      final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
      final DateTime dateA = inputFormat.parse(a['date']);
      final DateTime dateB = inputFormat.parse(b['date']);
      final String formattedDateA =
          '${dateA.year}-${dateA.month.toString().padLeft(2, '0')}-${dateA.day.toString().padLeft(2, '0')}';
      final String formattedDateB =
          '${dateB.year}-${dateB.month.toString().padLeft(2, '0')}-${dateB.day.toString().padLeft(2, '0')}';
      return formattedDateA.compareTo(formattedDateB);
    });

    notifyListeners();
  }
}
