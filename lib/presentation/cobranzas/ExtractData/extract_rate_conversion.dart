import 'dart:convert';


List<Map<String, dynamic>> extractGetRateConversionData(String responseData) {

  print('responsedata $responseData');

  Map<String, dynamic> parsedResponse = jsonDecode(responseData);
  List<Map<String, dynamic>> getRateConversionData = [];

  if(parsedResponse['WindowTabData']['@NumRows'] == 0){


      return getRateConversionData;



  }

  dynamic dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];


  print('Esto es la respuesta del erp en conversion ${dataRows}');


try {

  dynamic rows = [];

    if(dataRows is Map){

        rows.add(dataRows);

    }else{

        rows = dataRows;

    }
  

      rows.forEach((rows){

        Map<String, dynamic> getRateConversion = {

          'valid_from': rows['field'].firstWhere((field) => field['@column'] == 'ValidFrom')['val'],
          'valid_to': rows['field'].firstWhere((field) => field['@column'] == 'ValidTo')['val'],
          'multiply_rate': rows['field'].firstWhere((field) => field['@column'] == 'MultiplyRate')['val'],
          'c_currency_id_to': rows['field'].firstWhere((field) => field['@column'] == 'C_Currency_ID_To')['val']

        };
      
      getRateConversionData.add(getRateConversion);

      });





} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("esto es getrateconversionData $getRateConversionData");

  return getRateConversionData;
}