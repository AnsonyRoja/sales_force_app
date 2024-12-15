import 'dart:convert';


List<Map<String, dynamic>> extractStates(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('esta es la respuesta parsedResponse  $parsedResponse');
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> states = [];

  print('Esto es la respuesta del endpount price sales list $dataRows');


try {

  
  
  for (var row in dataRows) {

      print('Estos son los rows $row');

    Map<String, dynamic> state = {
      'c_region_id': row['field'].firstWhere((field) => field['@column'] == 'C_Region_ID')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
      'c_country_id': row['field'].firstWhere((field) => field['@column'] == 'C_Country_ID')['val'],

    };

    states.add(state);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son los estados disponibles desde idempiere $states");

  return states;
}