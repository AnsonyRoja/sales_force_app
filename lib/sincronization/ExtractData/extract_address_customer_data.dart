import 'dart:convert';

// Supongamos que tienes la clase Product definida como antes

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractAddressCustomerData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
   var dataRowObject = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']] : parsedResponse['WindowTabData']['DataSet']['DataRow'];
  List<dynamic> dataRows;

  // Asegúrate de que dataRowObject sea una lista
  if (dataRowObject is List) {
    dataRows = dataRowObject;
  } else if (dataRowObject is Map) {
    // Si es un mapa, conviértelo en una lista con un solo elemento
    dataRows = [dataRowObject];
  } else {
    print("Tipo inesperado para 'DataRow': ${dataRowObject.runtimeType}");
    return [];
  }

  // Crea una lista para almacenar los datos de los productos
  List<Map<String, dynamic>> addressCustomerData = [];

  print('Esto es la respuesta del erp Address Customer ${dataRows}');

  // Itera sobre cada DataRow y extrae los datos relevantes de los productos

try {

  
  
  for (var row in dataRows) {
    Map<String, dynamic> addressData = {
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
      'c_bpartner_location_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_Location_ID')['val'],
      'c_sales_region_id': row['field'].firstWhere((field) => field['@column'] == 'C_SalesRegion_ID')['val'],
      'c_bpartner_id':row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_ID')['val'],

    };

    addressCustomerData.add(addressData);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}


  print("esto es addressCustomerData $addressCustomerData");

  return addressCustomerData;
}