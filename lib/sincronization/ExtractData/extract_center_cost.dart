import 'dart:convert';


List<Map<String, dynamic>> extractCenterCost(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('esta es la respuesta parsedResponse  $parsedResponse');
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> centersCosts = [];

  print('Esto es la respuesta del endpount price sales list $dataRows');


try {

  
  
  for (var row in dataRows) {

      print('Estos son los rows $row');

    Map<String, dynamic> centerCost = {
      'c_element_value_id': row['field'].firstWhere((field) => field['@column'] == 'C_ElementValue_ID')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
      'value': row['field'].firstWhere((field) => field['@column'] == 'Value')['val'],

    };

    centersCosts.add(centerCost);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son los Centros de costos disponibles desde idempiere $centersCosts");

  return centersCosts;
}