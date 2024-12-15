import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractCustomersData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]:parsedResponse['WindowTabData']['DataSet']['DataRow'];

  // Crea una lista para almacenar los datos de los productos
  List<Map<String, dynamic>> customersData = [];

  print('Esto es la respuesta del erp customer $dataRows');

  // Itera sobre cada DataRow y extrae los datos relevantes de los productos

try {

  
  
  for (var row in dataRows) {
    Map<String, dynamic> customerData = {
      'c_bpartner_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_ID')['val'],
      'cod_client': row['field'].firstWhere((field) => field['@column'] == 'Value')['val'],
      'bp_name': row['field'].firstWhere((field) => field['@column'] == 'BPName')['val'],
      'c_bp_group_id': row['field'].firstWhere((field) => field['@column'] == 'C_BP_Group_ID')['val'],
      'group_bp_name': row['field'].firstWhere((field) => field['@column'] == 'groupbpname')['val'],
      'lco_tax_id_typeid':row['field'].firstWhere((field) => field['@column'] == 'LCO_TaxIdType_ID')['val'],
      'tax_id_type_name': row['field'].firstWhere((field) => field['@column'] == 'TaxIdTypeName')['val'],
      'email': row['field'].firstWhere((field) => field['@column'] == 'EMail')['val'],
      'c_bpartner_location_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_Location_ID')['val'],
      'is_bill_to':row['field'].firstWhere((field) => field['@column'] == 'IsBillTo')['val'],
      'phone': row['field'].firstWhere((field) => field['@column'] == 'Phone')['val'],
      'c_location_id': row['field'].firstWhere((field) => field['@column'] == 'C_Location_ID')['val'],
      'city': row['field'].firstWhere((field) => field['@column'] == 'City')['val'],
      'region': row['field'].firstWhere((field) => field['@column'] == 'RegionName')['val'],
      'country': row['field'].firstWhere((field) => field['@column'] == 'CountryName')['val'],
      'code_postal': row['field'].firstWhere((field) => field['@column'] == 'Postal')['val'],
      'c_city_id': row['field'].firstWhere((field) => field['@column'] == 'C_City_ID')['val'],
      'c_region_id': row['field'].firstWhere((field) => field['@column'] == 'C_Region_ID')['val'],
      'c_country_id': row['field'].firstWhere((field) => field['@column'] == 'C_Country_ID')['val'],
      'ruc': row['field'].firstWhere((field) => field['@column'] == 'TaxID')['val'],
      'address' : row['field'].firstWhere((field) => field['@column'] == 'Address')['val'],
      'lco_tax_payer_typeid': row['field'].firstWhere((field) => field['@column'] == 'LCO_TaxPayerType_ID')['val'],
      'tax_payer_type_name': row['field'].firstWhere((field) => field['@column'] == 'TaxPayerTypeName')['val'],
      'lve_person_type_id': row['field'].firstWhere((field) => field['@column'] == 'LVE_PersonType_ID')['val'],
      'person_type_name': row['field'].firstWhere((field) => field['@column'] == 'PersonTypeName')['val'],
      'm_pricelist_id': row['field'].firstWhere((field) => field['@column'] == 'M_PriceList_ID')['val'],
      'c_payment_term_id': row['field'].firstWhere((field) => field['@column'] == 'C_PaymentTerm_ID')['val'],
      'delivery_rule': row['field'].firstWhere((field) => field['@column'] == 'DeliveryRule')['val'],
      'delivery_via_rule': row['field'].firstWhere((field) => field['@column'] == 'DeliveryViaRule')['val'],
      'invoice_rule': row['field'].firstWhere((field) => field['@column'] == 'InvoiceRule')['val'], 
      'payment_rule': row['field'].firstWhere((field) => field['@column'] == 'PaymentRule')['val']

    };


    print('Esto es el customer pricelist ${row['field'][29]['val']}');
         
             
    // Agrega los datos del producto a la lista
    customersData.add(customerData);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("esto es customer data $customersData");

  return customersData;
}