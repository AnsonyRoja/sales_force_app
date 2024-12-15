import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/insert_database.dart';
import 'package:sales_force/infrastructure/models/order_sales_model.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/sincronization/ExtractData/extract_order_sales_inprocess.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/sincronization_screen.dart';

sincronizationOrderSalesInProcess(setState) async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
  

  var map = await getRuta();
  var variablesLogin = await getLogin();
  final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/query_data');
  final request = await httpClient.postUrl(uri);

  final info = await getApplicationSupportDirectory();
  print("esta es la ruta ${info.path}");

  final String filePathEnv = '${info.path}/.env';
  final File archivo = File(filePathEnv);
  String contenidoActual = await archivo.readAsString();
  print('Contenido actual del archivo:\n$contenidoActual');

  // Convierte el contenido JSON a un mapa
  Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

  var role = jsonData["RoleID"];
  var orgId = jsonData["OrgID"];
  var clientId = jsonData["ClientID"];
  var wareHouseId = jsonData["WarehouseID"];
  var language = jsonData["Language"];

  // Configurar el cuerpo de la solicitud en formato JSON
  final requestBody = {
    "ModelCRUDRequest": {
      "ModelCRUD": {
        "serviceType": "getOrderAPP",
        "DataRow": {
              "field": [
                {
                  "@column": "SalesRep_ID",
                  "val": variablesLogin['userId']
                }
              ]
            }
      },
      "ADLoginRequest": {
        "user": variablesLogin['user'],
        "pass": variablesLogin['password'],
        "lang": language,
        "ClientID": clientId,
        "RoleID": role,
        "OrgID": orgId,
        "WarehouseID": wareHouseId,
        "stage": 9
      }
    }
  };

  // Convertir el cuerpo a JSON
  final jsonBody = jsonEncode(requestBody);

  // Establecer las cabeceras de la solicitud
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Accept', 'application/json');

  // Escribir el cuerpo en la solicitud
  request.write(jsonBody);


  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  dynamic orderSalesInProcess =  extractOrderSalesInProcessData(responseBody);
  print('Estos son las ordenes registradas en idempiere $orderSalesInProcess');
  await syncOrderSalesInProcess(orderSalesInProcess,setState); 

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;

}

Future<void> syncOrderSalesInProcess(List<Map<String, dynamic>> orderSalesInProcess, Function setState) async {
  final db = await DatabaseHelper.instance.database;

  double contador = 0;
  print('Esto es orderSales Datas $orderSalesInProcess');

  if (db != null) {
    // Itera sobre los datos de las órdenes recibidas
    for (Map<String, dynamic> orderSalesInProces in orderSalesInProcess) {
      print('Esto es sales order in process header ${orderSalesInProces['header']}');

      dynamic orderSalesHeader = orderSalesInProces['header'];
      int? clientId = await getCustomerId(orderSalesHeader['c_bpartner_id']);
      String dateOrdered = orderSalesHeader['date_ordered'];

      DateTime parsedDate = DateTime.parse(dateOrdered);
      String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);

      print('Fecha de creación formateada: $formattedDate');

      List<dynamic> products = orderSalesInProces['products'];
      List<dynamic> cargos = orderSalesInProces['charges'];
            List<dynamic> charger = [];


      print('Productos: ${orderSalesInProces['products']}');

        double saldoNeto = 0.0;
        double saldoExento = 0.0;
       
        String? warehouseName;
        String? addressName;

        int locationId = orderSalesHeader['c_bpartner_location_id'];
        addressName = await getAddressName(locationId);


          print('Estos son los cargos en la sincronizacion $cargos');

      dynamic documentDiscount;

      for (var discount in cargos) {

        print('Esto es el discount $discount');
        if (discount['quantity'] == -1) {
         documentDiscount = await getDiscountDocumentsForChargerId(discount['c_charge_id']);
 
         for (var disc in documentDiscount) {

            Map<String, dynamic> modifiableDisc = Map<String, dynamic>.from(disc);

            modifiableDisc['total_importe'] = discount['price'];

            charger.add(modifiableDisc); 
          
          }

            // ahora aqui quisiera que recorriera descuento por descuento y le agregara la propiedad total que seria el discount['price']


          print('Estos son los discount de esta orden ${documentDiscount}');
        }
      }
      print('Esto es el charger $charger header ${orderSalesHeader['c_order_id']}');

        
      print('cargo id en total $cargos');
        // Itera sobre los productos y calcula el saldo neto y el saldo exento
        for (var product in products) {
          // Convertir los valores a double
          double qtyEntered = double.tryParse(product['quantity'].toString()) ?? 0.0;
          double priceActual = double.tryParse(product['price'].toString()) ?? 0.0;

          print('Qty Entered: $qtyEntered');
          print('Price Actual: $priceActual');

          // Calcula y acumula el saldo neto para esta orden
          saldoNeto += qtyEntered * priceActual;

          // Obtener el producto_id desde la base de datos
          int? productId = await getProductId(product['m_product_id']);
          product['id'] = productId ?? 0; // Valor por defecto si no se encuentra el producto

          // Obtener el tax_cat_id y calcular el saldo exento
          int? taxCatId = await getTaxCategoryId(product['m_product_id']);
          if (taxCatId != null) {
            double taxRate = await getTaxRate(taxCatId);
            print('Tax Rate: $taxRate');

            // Calcular el saldo exento si no tiene impuesto
            if (taxRate == 0.0) {
              saldoExento += qtyEntered * priceActual;
            }
          } else {
            saldoExento += qtyEntered * priceActual;
          }

          // Obtener el nombre del almacén desde la base de datos
          warehouseName = await getWarehouseName(product['m_warehouse_id']);
          print('Nombre del almacén: $warehouseName');
          product['warehouse_name'] = warehouseName ?? 'Desconocido'; // Valor por defecto
        }

        print('Productos procesados: ${orderSalesInProces['products']}');
        print('Suma neta de la orden: $saldoNeto');
        print('Saldo Exento: $saldoExento');

        // Itera sobre los cargos y calcula los descuentos
       
        

        
          double parseToDouble(dynamic value) {
            if (value is String) {
              return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
            } else if (value is double || value is int) {
              return value.toDouble();
            } else {
              return 0.0;
            }
          }

       String formatNumber(dynamic number) {
  final formatter = NumberFormat('#,##0.0000', 'es_ES');
  return formatter.format(parseToDouble(number));


}


        if(orderSalesHeader['descripcion'] != '{@nil=true}'){

          orderSalesHeader['descripcion'] = '';
        } 

        print('esto es ordersales c invoice id ${orderSalesHeader['c_invoice_id']} && esto es ${orderSalesHeader['documentno_invoice']}');

          dynamic cInvoiceIdUp = orderSalesHeader['c_invoice_id'] != '{@nil: true}'.toString() ?  null : orderSalesHeader['c_invoice_id']; 

          print('Esto es el c_invoice_id $cInvoiceIdUp');

        // Crear modelo de la orden de venta
        OrderSalesModel orderSalesModel = OrderSalesModel(
          clienteId: clientId,
          documentNo: orderSalesHeader['documentno'],
          fecha: formattedDate,
          saldoNeto: formatNumber(orderSalesHeader['total_lines']),
          productos: products,
          cBPartnerId: orderSalesHeader['c_bpartner_id'],
          cBPartnerLocationId: orderSalesHeader['c_bpartner_location_id'],
          cDocTypeTargetId: orderSalesHeader['c_doctypetarget_id'],
          adClientId: orderSalesHeader['ad_client_id'],
          adOrgId: orderSalesHeader['ad_org_id'],
          mWareHouseId: orderSalesHeader['m_warehouse_id'],
          paymentRule: orderSalesHeader['payment_rule'],
          dateOrdered: orderSalesHeader['date_ordered'],
          salesRepId: orderSalesHeader['salesrep_id'],
          usuarioId: orderSalesHeader['salesrep_id'],
          saldoExento: formatNumber(orderSalesHeader['exentorder']) ,
          mWareHouseNameDispatch: warehouseName ?? '',
          saldoImpuesto: formatNumber(orderSalesHeader['tax_amt']),
          statusSincronized: orderSalesHeader['status_sincronized'],
          descPagoEfectivo: 0,
          descProntoPago: 0,
          totalDesc: 0,
          cargos: jsonEncode(charger),
          address: addressName,
          descripcion: orderSalesHeader['descripcion'],
          monto: formatNumber(orderSalesHeader['grand_total']),
          cInvoiceId: orderSalesHeader['c_invoice_id'] != '{@nil: true}'.toString() || orderSalesHeader['c_invoice_id'] != '{@nil=true}' ? orderSalesHeader['c_invoice_id'] : null ,
          documentNoInvoice: orderSalesHeader['documentno_invoice'] != '{@nil: true}' || orderSalesHeader['{@nil=true}']? orderSalesHeader['documentno_invoice'] : null,
          docStatus: orderSalesHeader['doc_status'],
          cOrderId: orderSalesHeader['c_order_id'],
          dueDate: orderSalesHeader['due_date'],
          mPriceListId: orderSalesHeader['m_price_list_id']
        
        );

       
        // Incrementar el contador y actualizar el estado
        contador++;
        setState(() {
          syncPercentageOrderSales = (contador / orderSalesInProcess.length) * 100;
        });

          print('esto es el ordersalesModel ${orderSalesModel.toMap()}');
        // Insertar la orden en la base de datos
        final orderId = await insertOrderSincro(orderSalesModel.toMap());
        print('Orden insertada con ID: $orderId');
 
    }
  }
}
