import 'dart:convert';

List<Map<String, dynamic>> extractOrderSalesInProcessData(String responseData) {
  // Decodifica la respuesta JSON
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  // Extrae la lista de DataRow de la respuesta
  List<dynamic> dataRows = parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']] : parsedResponse['WindowTabData']['DataSet']['DataRow'];

  Map<String, Map<String, dynamic>> orderSalesData = {};

  for (var row in dataRows) {
    String documentNo = row['field'].firstWhere((field) => field['@column'] == 'DocumentNo')['val'];
    
    if (!orderSalesData.containsKey(documentNo)) {
      // Si el documento no está en el mapa, agrega la cabecera
      orderSalesData[documentNo] = {
        'header': {
          'cliente_id': 0,
          'c_order_id': row['field'].firstWhere((field) => field['@column'] == 'C_Order_ID')['val'],
          'c_doctypetarget_id': row['field'].firstWhere((field) => field['@column'] == 'C_DocTypeTarget_ID')['val'],
          'ad_client_id': row['field'].firstWhere((field) => field['@column'] == 'AD_Client_ID')['val'],
          'ad_org_id': row['field'].firstWhere((field) => field['@column'] == 'AD_Org_ID')['val'],
          'm_warehouse_id': row['field'].firstWhere((field) => field['@column'] == 'M_Warehouse_ID')['val'],
          'documentno': row['field'].firstWhere((field) => field['@column'] == 'DocumentNo')['val'],
          'payment_rule': row['field'].firstWhere((field) => field['@column'] == 'PaymentRule')['val'],
          'date_ordered': row['field'].firstWhere((field) => field['@column'] == 'DateOrdered')['val'],
          'salesrep_id': row['field'].firstWhere((field) => field['@column'] == 'SalesRep_ID')['val'],
          'c_bpartner_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_ID')['val'],
          'c_bpartner_location_id': row['field'].firstWhere((field) => field['@column'] == 'C_BPartner_Location_ID')['val'],
          'descripcion': row['field'].firstWhere((field) => field['@column'] == 'Description')['val'],
          'c_invoice_id': row['field'].firstWhere((field) => field['@column'] == 'C_Invoice_ID')['val'],
          'documentno_invoice': row['field'].firstWhere((field) => field['@column'] == 'documentnoinvoice')['val'],
          'total_lines': row['field'].firstWhere((field) => field['@column'] == 'TotalLines')['val'],
          'exentorder': row['field'].firstWhere((field) => field['@column'] == 'exentorder')['val'],
          'tax_amt': row['field'].firstWhere((field) => field['@column'] == 'TaxAmt')['val'],
          'grand_total': row['field'].firstWhere((field) => field['@column'] == 'GrandTotal')['val'],
          'ad_user_id': row['field'].firstWhere((field) => field['@column'] == 'AD_User_ID')['val'],
          'status_sincronized': row['field'].firstWhere((field) => field['@column'] == 'status_sincronized')['val'],
          'doc_status': row['field'].firstWhere((field) => field['@column'] == 'DocStatus')['val'],
          'due_date': row['field'].firstWhere((field) => field['@column'] == 'due_date')['val'],
          'm_price_list_id': row['field'].firstWhere((field) => field['@column'] == 'M_PriceList_ID')['val']
        },
        'products': [],
        'charges': []
      };
    }

    print(' esto vendria siendo el m_product_id ${row['field'].firstWhere((field) => field['@column'] == 'M_Product_ID')['val']}');

    // Añadir productos o cargos a la lista correspondiente
    if (row['field'].firstWhere((field) => field['@column'] == 'M_Product_ID')['val'] != '{@nil: true}' && row['field'].firstWhere((field) => field['@column'] == 'QtyEntered')['val'] != -1) {
      orderSalesData[documentNo]!['products'].add({
        'orden_venta_id': 0,
        'id': 0,
        'm_product_id': row['field'].firstWhere((field) => field['@column'] == 'M_Product_ID')['val'],
        'price_entered': row['field'].firstWhere((field) => field['@column'] == 'PriceEntered')['val'],
        'price': row['field'].firstWhere((field) => field['@column'] == 'PriceActual')['val'],
        'quantity': row['field'].firstWhere((field) => field['@column'] == 'QtyEntered')['val'],
        'ad_client_id': row['field'].firstWhere((field) => field['@column'] == 'ad_client_orderline')['val'],
        'ad_org_id': row['field'].firstWhere((field) => field['@column'] == 'ad_org_orderline')['val'],
        'm_warehouse_id': row['field'].firstWhere((field) => field['@column'] == 'm_warehouseorderline_id')['val'],
      });
    } else {
      orderSalesData[documentNo]!['charges'].add({
        'c_charge_id': row['field'].firstWhere((field) => field['@column'] == 'C_Charge_ID')['val'],
        'price_entered': row['field'].firstWhere((field) => field['@column'] == 'PriceEntered')['val'],
        'price': row['field'].firstWhere((field) => field['@column'] == 'PriceActual')['val'],
        'quantity': row['field'].firstWhere((field) => field['@column'] == 'QtyEntered')['val'],
        'ad_client_orderline': row['field'].firstWhere((field) => field['@column'] == 'ad_client_orderline')['val'],
        'ad_org_orderline': row['field'].firstWhere((field) => field['@column'] == 'ad_org_orderline')['val'],
        'm_warehouseorderline_id': row['field'].firstWhere((field) => field['@column'] == 'm_warehouseorderline_id')['val'],
      });
    }
  }


  // Convertir el resultado en una lista de Mapas
  List<Map<String, dynamic>> result = orderSalesData.values.toList();

  print('Estos son los cargos ${result[1]['charges']}');

  print('Estos son los productos ${result[1]['products']}');

  print("Estas son las ordenes en su estructura correspondiente ${result[1]}");

  return result;
}
