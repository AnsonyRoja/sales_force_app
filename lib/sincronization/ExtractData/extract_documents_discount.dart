import 'dart:convert';


List<Map<String, dynamic>> extractDiscountDocuments(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('esta es la respuesta parsedResponse  $parsedResponse');
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> discountDocuments = [];

  print('Esto es la respuesta del endpoint de descuentos en los documentos $dataRows');


try {

  
  for (var row in dataRows) {

      print('Estos son los rows $row');

    Map<String, dynamic> discount = {
      
      'm_discount_schema_id': row['field'].firstWhere((field) => field['@column'] == 'M_DiscountSchema_ID')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
      'discount': row['field'].firstWhere((field) => field['@column'] == 'Discount')['val'],
      'limit_discount': row['field'].firstWhere((field) => field['@column'] == 'Limit_Discount')['val'],
      'c_charge_id': row['field'].firstWhere((field) => field['@column'] == 'C_Charge_ID')['val'],
      'rate': row['field'].firstWhere((field) => field['@column'] == 'Rate')['val'],

    };

    discountDocuments.add(discount);

  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son los descuentos disponibles desde idempiere $discountDocuments");

  return discountDocuments;
}