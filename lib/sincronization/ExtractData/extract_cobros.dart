import 'dart:convert';

// Función para procesar la respuesta de iDempiere y extraer los datos de los productos
List<Map<String, dynamic>> extractCobrosData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]:parsedResponse['WindowTabData']['DataSet']['DataRow'];

  // Crea una lista para almacenar los datos de los productos
  List<Map<String, dynamic>> cobrosData = [];

  print('Esto es la respuesta del erp Cobros $dataRows');

  // Itera sobre cada DataRow y extrae los datos relevantes de los productos

try {

  
  
  for (var row in dataRows) {
    Map<String, dynamic> cobroDatas = {
      'ad_client_id': row['field'].firstWhere((field) => field['@column'] == 'AD_Client_ID')['val'],
      'ad_org_id': row['field'].firstWhere((field) => field['@column'] == 'AD_Org_ID')['val'],
      'c_payment_id': row['field'].firstWhere((field) => field['@column'] == 'C_Payment_ID')['val'],
      'c_bank_account_id': row['field'].firstWhere((field) => field['@column'] == 'C_BankAccount_ID')['val'],
      'bank_account_name': row['field'].firstWhere((field) => field['@column'] == 'bankaccountname')['val'],
      'c_doc_type_id':row['field'].firstWhere((field) => field['@column'] == 'C_DocType_ID')['val'],
      'date_trx': row['field'].firstWhere((field) => field['@column'] == 'DateTrx')['val'],
      'description': row['field'].firstWhere((field) => field['@column'] == 'Description')['val'],
      'c_bpartner_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_ID')['val'],
      'pay_amt_bs':row['field'].firstWhere((field) => field['@column'] == 'payamtbs')['val'],
      'pay_amt_usd': row['field'].firstWhere((field) => field['@column'] == 'payamtusd')['val'],
      'tasa_cambio': row['field'].firstWhere((field) => field['@column'] == 'Rate')['val'],
      'date': row['field'].firstWhere((field) => field['@column'] == 'date')['val'],
      'm_price_list_id': row['field'].firstWhere((field) => field['@column'] == 'M_PriceList_ID')['val'],
      'c_currency_id': row['field'].firstWhere((field) => field['@column'] == 'C_Currency_ID')['val'],
      'c_order_id': row['field'].firstWhere((field) => field['@column'] == 'C_Order_ID')['val'],
      'c_invoice_id': row['field'].firstWhere((field) => field['@column'] == 'C_Invoice_ID')['val'],
      'documentno_invoice': row['field'].firstWhere((field) => field['@column'] == 'documentnoinvoice')['val'],
      'documentno_cobro': row['field'].firstWhere((field) => field['@column'] == 'DocumentNo')['val'],
      'tender_type': row['field'].firstWhere((field) => field['@column'] == 'TenderType')['val'],
      'tender_typename': row['field'].firstWhere((field) => field['@column'] == 'tendertypename')['val'],
      'doc_status': row['field'].firstWhere((field) => field['@column'] == 'DocStatus')['val'],
      'sales_rep_id': row['field'].firstWhere((field) => field['@column'] == 'SalesRep_ID')['val'],
      // 'person_type_name': row['field'][23]['val'],

     // Asegúrate de convertir la cantidad a un tipo numérico adecuado
      // Añade otros campos que necesites sincronizar
    };


    // print('Esto es tax payer type ${row['field'][26]['val']}');
         
             
    // Agrega los datos del producto a la lista
    cobrosData.add(cobroDatas);
  }
} catch (e) {

  print("ESTE ES EL ERROR $e");
  
}

  print("esto es Cobros Data $cobrosData");

  return cobrosData;
}