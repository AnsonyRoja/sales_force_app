import 'dart:convert';


List<Map<String, dynamic>> extractVisitsConcepts(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('esta es la respuesta parsedResponse  $parsedResponse');
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']] : parsedResponse['WindowTabData']['DataSet']['DataRow'] ;

  List<Map<String, dynamic>> visitsConcepts = [];

  print('Esto es la respuesta del endpoint de los conceptos de visita $dataRows');


try {

  
  
  for (var row in dataRows) {

      print('Estos son los rows $row');

    Map<String, dynamic> visitsC = {
      'gss_customer_visit_concept_id': row['field'].firstWhere((field) => field['@column'] == 'GSS_CustomerVisitConcept_ID')['val'],
      'value': row['field'].firstWhere((field) => field['@column'] == 'Value')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],

    };

    visitsConcepts.add(visitsC);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son los conceptos disponibles en idempiere $visitsConcepts");

  return visitsConcepts;
}