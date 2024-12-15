import 'dart:convert';


List<Map<String, dynamic>> extractWareHouse(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('esta es la respuesta parsedResponse  $parsedResponse');
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']] : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> allWareHouse = [];

  print('Esto es la respuesta del endpoint ware house $dataRows');


try {

  
  
  for (var row in dataRows) {

      print('Estos son los rows ware house $row');

    Map<String, dynamic> wareHouse = {
      'ad_client_id': row['field'].firstWhere((field) => field['@column'] == 'AD_Client_ID')['val'],
      'ad_org_id': row['field'].firstWhere((field) => field['@column'] == 'AD_Org_ID')['val'],
      'm_warehouse_id': row['field'].firstWhere((field) => field['@column'] == 'M_Warehouse_ID')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'WarehouseName')['val'],
      'value': row['field'].firstWhere((field) => field['@column'] == 'WarehouseValue')['val'],

    };

    allWareHouse.add(wareHouse);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son las regions de ventas disponibles des este usuario idempiere $allWareHouse");

  return allWareHouse;
}