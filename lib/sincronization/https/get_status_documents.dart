



import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';

Future<void> sincronizationStatusDocumentsOrder() async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };

  // Obtener las órdenes de venta
  List<Map<String, dynamic>> orderSales = await getSalesOrdersHeader();

  var map = await getRuta();
  var variablesLogin = await getLogin();
  final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/query_data');

  final info = await getApplicationSupportDirectory();
  print("esta es la ruta ${info.path}");

  final String filePathEnv = '${info.path}/.env';
  final File archivo = File(filePathEnv);
  String contenidoActual = await archivo.readAsString();
  print('Contenido actual del archivo:\n$contenidoActual');

  Map<String, dynamic> jsonData = jsonDecode(contenidoActual);
  var role = jsonData["RoleID"];
  var orgId = jsonData["OrgID"];
  var clientId = jsonData["ClientID"];
  var wareHouseId = jsonData["WarehouseID"];
  var language = jsonData["Language"];

  // Iterar sobre las órdenes de venta
  for (var order in orderSales) {
      final request = await httpClient.postUrl(uri);

      // Configurar el cuerpo de la solicitud en formato JSON
      final requestBody = {
        "ModelCRUDRequest": {
          "ModelCRUD": {
            "serviceType": "getOrderStatusDocumentAPP",
            "DataRow": {
              "field": [
                {
                  "@column": "C_Order_ID",
                  "val": order['c_order_id']
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

      // Obtener la respuesta de iDempiere
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final parsedJson = jsonDecode(responseBody);
      print('ParsedJson en Search Order Sales $parsedJson');
      final dataRow = parsedJson['WindowTabData']['DataSet']['DataRow'];
      print('esto es el dataRow Order Sales $dataRow');
      print("Esta es la respuesta Get status document order $parsedJson");

      

      // Aquí deberías extraer los datos de la factura del JSON de respuesta
      
      var docStatus = dataRow['field'][2]['val']; 

      print('Esto es el estado del documento $docStatus');
      // Actualizar la base de datos con los nuevos datos de la factura

          await updateStatusOrder(order['id'], docStatus);

      
    
  }
}
