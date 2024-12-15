import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractBankAccountData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);
  List<Map<String, dynamic>> bankAccountsData = [];
  dynamic dataRows;

  print('Esto es el extractbankaccountdata $parsedResponse');


    if(parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ){

        dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

         
         Map<String, dynamic> bankAccountData = {
      'c_bank_id':  dataRows['field'].firstWhere((field) => field['@column'] == 'C_Bank_ID')['val'],
      'bank_name':  dataRows['field'].firstWhere((field) => field['@column'] == 'BankName')['val'],
      'routing_no': dataRows['field'].firstWhere((field) => field['@column'] == 'RoutingNo')['val'],
      'c_bank_account_id': dataRows['field'].firstWhere((field) => field['@column'] == 'C_BankAccount_ID')['val'],
      'account_no': dataRows['field'].firstWhere((field) => field['@column'] == 'AccountNo')['val'],
      'c_currency_id':dataRows['field'].firstWhere((field) => field['@column'] == 'C_Currency_ID')['val'],
      'iso_code': dataRows['field'].firstWhere((field) => field['@column'] == 'ISO_Code')['val']
     // Asegúrate de convertir la cantidad a un tipo numérico adecuado
      // Añade otros campos que necesites sincronizar

    };
    print('bankaccounts $bankAccountsData');
          bankAccountsData.add(bankAccountData);

    }else{

    dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'];

      try {
  
     for (var row in dataRows) {
      Map<String, dynamic> bankAccountData = {
      'c_bank_id': row['field'].firstWhere((field) => field['@column'] == 'C_Bank_ID')['val'],
      'bank_name': row['field'].firstWhere((field) => field['@column'] == 'BankName')['val'],
      'routing_no': row['field'].firstWhere((field) => field['@column'] == 'RoutingNo')['val'],
      'c_bank_account_id': row['field'].firstWhere((field) => field['@column'] == 'C_BankAccount_ID')['val'],
      'account_no': row['field'].firstWhere((field) => field['@column'] == 'AccountNo')['val'],
      'c_currency_id':row['field'].firstWhere((field) => field['@column'] == 'C_Currency_ID')['val'],
      'iso_code': row['field'].firstWhere((field) => field['@column'] == 'ISO_Code')['val']
     // Asegúrate de convertir la cantidad a un tipo numérico adecuado
      // Añade otros campos que necesites sincronizar

    };

    // Agrega los datos del producto a la lista
    bankAccountsData.add(bankAccountData);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

}


  // Crea una lista para almacenar los datos de los productos

  print('Esto es la respuesta de las bank accounts $dataRows');




  print("Estos son los bancos disponibles desde idempiere $bankAccountsData");

  return bankAccountsData;
}