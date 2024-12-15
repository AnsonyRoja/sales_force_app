import 'dart:convert';


List<Map<String, dynamic>> extractPriceSalesList(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']] : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> priceSalesListsData = [];

  print('Esto es la respuesta del endpount price sales list $dataRows');


try {

  
  
  for (var row in dataRows) {

      print('Estos son los rows $row');

    Map<String, dynamic> priceSalesListData = {
      'm_pricelist_id': row['field'].firstWhere((field) => field['@column'] == 'M_PriceList_ID')['val'],
      'price_list_name': row['field'].firstWhere((field) => field['@column'] == 'PriceListName')['val'],
      'c_currency_id': row['field'].firstWhere((field) => field['@column'] == 'C_Currency_ID')['val'],
      'm_product_id':row['field'].firstWhere((field) => field['@column'] == 'M_Product_ID')['val'],
      'price_list': row['field'].firstWhere((field) => field['@column'] == 'PriceList')['val']

    };

    priceSalesListsData.add(priceSalesListData);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son las actividades comerciales del proveedor disponibles desde idempiere $priceSalesListsData");

  return priceSalesListsData;
}