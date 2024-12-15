import 'dart:convert';


List<Map<String, dynamic>> extractRegionSalesVisit(String responseData) {

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('esta es la respuesta parsedResponse region sales $parsedResponse');

      dynamic isMap = parsedResponse['WindowTabData']['DataSet']['DataRow'];
      List<dynamic> dataRows;
      if(isMap is Map){

        
        dataRows = [isMap];

      }else{

        dataRows = isMap;
        
      }



    


  List<Map<String, dynamic>> regionSalesVisits = [];

  print('Esto es la respuesta del endpount Region Sales Visits $dataRows');


try {

  
  
  for (var row in dataRows) {

      print('Estos son los rows region sales $row');

    Map<String, dynamic> regionSalesV = {
      'c_sales_region_id': row['field'].firstWhere((field) => field['@column'] == 'C_SalesRegion_ID')['val'],
      'name': row['field'].firstWhere((field) => field['@column'] == 'Name')['val'],
      'cod': row['field'].firstWhere((field) => field['@column'] == 'Value')['val'],
      'sales_rep_id': row['field'].firstWhere((field) => field['@column'] == 'SalesRep_ID')['val'],
    };

    regionSalesVisits.add(regionSalesV);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("Estos son las regions de ventas disponibles des este usuario idempiere $regionSalesVisits");

  return regionSalesVisits;
}