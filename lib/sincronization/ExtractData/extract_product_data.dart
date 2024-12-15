import 'dart:convert';

// Supongamos que tienes la clase Product definida como antes

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractProductData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]: parsedResponse['WindowTabData']['DataSet']['DataRow'];

  // Crea una lista para almacenar los datos de los productos
  List<Map<String, dynamic>> productsData = [];

  print('Esto es la respuesta del erp products $dataRows');

  // Itera sobre cada DataRow y extrae los datos relevantes de los productos

try {

  
  
  for (var row in dataRows) {
    Map<String, dynamic> productData = {
      'cod_product': row['field'].firstWhere((field) => field['@column'] == 'Value')['val'],
      'm_product_id': row['field'].firstWhere((field) => field['@column'] == 'M_Product_ID')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
      'price':row['field'].firstWhere((field) => field['@column'] == 'PriceList')['val'],
      'quantity':row['field'].firstWhere((field) => field['@column'] == 'QtyOnHand')['val'],
      'pro_cat_id':row['field'].firstWhere((field) => field['@column'] == 'M_Product_Category_ID')['val'] ,
      'categoria':row['field'].firstWhere((field) => field['@column'] == 'category_name')['val'].toString(),
      'product_type':row['field'].firstWhere((field) => field['@column'] == 'ProductType')['val'],
      'product_type_name':row['field'].firstWhere((field) => field['@column'] == 'producttype_name')['val'],
      'total_sold': 0,
      'tax_cat_id':row['field'].firstWhere((field) => field['@column'] == 'C_TaxCategory_ID')['val'],
      'tax_cat_name': row['field'].firstWhere((field) => field['@column'] == 'taxcategory_name')['val'],
      'product_group_id':row['field'].firstWhere((field) => field['@column'] == 'FTU_ProductGroup_ID')['val'],
      'product_group_name': row['field'].firstWhere((field) => field['@column'] == 'FTU_ProductGroup_Name')['val'],
      'um_id':row['field'].firstWhere((field) => field['@column'] == 'C_UOM_ID')['val'],
      'um_name':row['field'].firstWhere((field) => field['@column'] == 'UOMName')['val'],
      'quantity_sold': 0,
      'pricelistsales': row['field'].firstWhere((field) => field['@column'] == 'pricelistsales')['val'],
     // Asegúrate de convertir la cantidad a un tipo numérico adecuado
      // Añade otros campos que necesites sincronizar
    };

    // Agrega los datos del producto a la lista
    productsData.add(productData);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}


  print("esto es productsData $productsData");

  return productsData;
}