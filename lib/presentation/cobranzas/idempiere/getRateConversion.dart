import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/presentation/cobranzas/ExtractData/extract_rate_conversion.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';

getRateConversion() async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
  

 if(await checkInternetConnectivity() == false){

      return false;
      

  }

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

  print('estas son as variablesLogin $variablesLogin, y estas son las variables dentro del archivo json $jsonData');

  // Configurar el cuerpo de la solicitud en formato JSON
  final requestBody = {
    "ModelCRUDRequest": {
      "ModelCRUD": {
        "serviceType": "getRateConversion",
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
  dynamic rateConversion =  extractGetRateConversionData(responseBody);

  print('Estos son las tasas de cambio disponibles y registradas en idempiere $rateConversion');

  await syncRateConversion(rateConversion); // Obtener todos los productos

  final parsedJson = jsonDecode(responseBody);
  
  print("esta es la respuesta $parsedJson");

  return parsedJson;

}



Future<void> syncRateConversion(getRateConversion) async {
      final db = await DatabaseHelper.instance.database;
    

      if (db != null) {
        // Itera sobre los datos de los productos recibidos
        for (Map<String, dynamic> rateConversion in getRateConversion) {
          // Construye un objeto Product a partir de los datos recibidos
        dynamic objeto = {

            'valid_from': rateConversion['valid_from'],
            'valid_to': rateConversion['valid_to'],
            'multiply_rate':rateConversion['multiply_rate'],
            'c_currency_id_to': rateConversion['c_currency_id_to']
            
          };
       
          
         


          // Consulta si el producto ya existe en la base de datos local por su nombre
          List<Map<String, dynamic>> existingPosPropertieData = await db.query(
            'rate_conversion',
            where: 'c_currency_id_to = ?',
            whereArgs: [objeto['c_currency_id_to']],
          );

          if (existingPosPropertieData.isNotEmpty) {
            // Si el producto ya existe, actualiza sus datos
            await db.update(
              'rate_conversion',
              objeto,
              where: 'c_currency_id_to = ?',
              whereArgs: [objeto['c_currency_id_to']],
            );

            print('rate conversion actualizado: ${objeto['c_currency_id_to']}');
            
          } else {
            // Si el producto no existe, inserta un nuevo registro en la tabla de productos
            await db.insert('rate_conversion', objeto);
            print('rate conversion insertado: ${objeto['c_currency_id_to']}');
          }
        }
        print('Sincronización de rate conversion completada.');
      } else {
        // Manejar el caso en el que db sea null
        print('Error: db is null');
      }
    }






// Future<List<Map<String, dynamic>>> getPosPropertiesV() async {
//   try {
//     // Obtener la referencia de la base de datos
//     final db = await DatabaseHelper.instance.database;

//     if (db != null) {
//       // Realizar la consulta SQL parametrizada excluyendo el campo de ID
//       final List<Map<String, dynamic>> result = await db.rawQuery('''
//         SELECT
//           country_id,
//           tax_payer_type_natural,
//           tax_payer_type_juridic,
//           person_type_juridic,
//           person_type_natural,
//           m_warehouse_id,
//           c_doc_type_order_id,
//           c_conversion_type_id,
//           c_paymentterm_id,
//           c_bankaccount_id,
//           c_bpartner_id,
//           c_doctypepayment_id,
//           c_doctypereceipt_id,
//           city,
//           address1,
//           m_pricelist_id,
//           c_doc_type_order_co,
//           m_price_saleslist_id,
//           c_currency_id,
//           doc_status_receipt,
//           doc_status_invoice_so,
//           doc_status_order_so,
//           doc_status_order_po,
//           c_doc_type_target_fr
//         FROM posproperties
//         WHERE country_id > ?
//       ''', [0]);

//       // Retornar el resultado de la consulta
//       return result;
//     } else {
//       // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
//       print('Error: db is null');
//       return [];
//     }
//   } catch (e) {
//     // Manejar cualquier excepción que pueda ocurrir durante la ejecución de la consulta
//     print('Error fetching POS properties: $e');
//     return [];
//   }
// }

