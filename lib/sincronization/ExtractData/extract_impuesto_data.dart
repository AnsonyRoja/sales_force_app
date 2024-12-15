import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractImpuestoData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']] : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  // Crea una lista para almacenar los datos de los productos
  List<Map<String, dynamic>> impuestosData = [];

  print('Esto es la respuesta del erp impuesto $dataRows');

  // Itera sobre cada DataRow y extrae los datos relevantes de los productos

try {

  
  
  for (var row in dataRows) {
    Map<String, dynamic> impuestoData = {
      'c_tax_id': row['field'].firstWhere((field) => field['@column'] == 'C_Tax_ID')['val'],
      'tax_indicator': row['field'].firstWhere((field) => field['@column'] == 'TaxIndicator')['val'],
      'rate': row['field'].firstWhere((field) => field['@column'] == 'Rate')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
      'c_tax_category_id': row['field'].firstWhere((field) => field['@column'] == 'C_TaxCategory_ID')['val'],
      'iswithholding': row['field'].firstWhere((field) => field['@column'] == 'IsWithholding')['val']
     // Asegúrate de convertir la cantidad a un tipo numérico adecuado
      // Añade otros campos que necesites sincronizar
    };

    // Agrega los datos del producto a la lista
    impuestosData.add(impuestoData);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("esto es impuestosData $impuestosData");

  return impuestosData;
}