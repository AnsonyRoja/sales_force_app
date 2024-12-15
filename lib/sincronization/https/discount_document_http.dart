import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/discount_documents.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/ExtractData/extract_documents_discount.dart';

sincronizationDiscountDocument() async {
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


  Map<String, dynamic> jsonData = jsonDecode(contenidoActual);

  var role = jsonData["RoleID"];
  var orgId = jsonData["OrgID"];
  var clientId = jsonData["ClientID"];
  var wareHouseId = jsonData["WarehouseID"];
  var language = jsonData["Language"];

  final requestBody = {
    "ModelCRUDRequest": {
      "ModelCRUD": {
        "serviceType": "getDocumentDiscount",
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

  final jsonBody = jsonEncode(requestBody);

  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Accept', 'application/json');

  request.write(jsonBody);


  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  dynamic discountDocuments =  extractDiscountDocuments(responseBody);



            print('Estos son los descuentos registrados desde idempiere $discountDocuments');


  await syncDiscountDocuments(discountDocuments); 

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;

}


Future<void> syncDiscountDocuments(List<Map<String, dynamic>> discountDocuments) async {
      final db = await DatabaseHelper.instance.database;
    



      if (db != null) {

        for (Map<String, dynamic> discountDocument in discountDocuments) {

          DiscountDocuments discountDocuments = DiscountDocuments(

              mDiscountShemaId: discountDocument['m_discount_schema_id'],
              name: discountDocument['name'],
              discount : discountDocument['discount'],
              limitDiscount: discountDocument['limit_discount'],
              cChargeId: discountDocument['c_charge_id'],
              rate: discountDocument['rate']

          );
                   
        print('esto es el valor que tiene la variable dicountDocuments ${discountDocuments.toMap()}');

          Map<String, dynamic> discountsDocumentsToMap = discountDocuments.toMap();


          List<Map<String, dynamic>> existingDiscountDocument= await db.query(
            'discount_documents',
            where: 'c_charge_id = ?',
            whereArgs: [discountDocuments.cChargeId],
          );

          if (existingDiscountDocument.isNotEmpty) {

            await db.update(
              'discount_documents',
              discountsDocumentsToMap,
              where: 'c_charge_id = ?',
              whereArgs: [discountDocuments.cChargeId],
            );
            print('Tabla de Descuento actualizada: ${discountDocuments.name}');
          } else {

            await db.insert('discount_documents', discountsDocumentsToMap);
            print('Descuento insertado: ${discountDocuments.name}');
          }
        }
        print('Sincronización of Discount Documents  completed.');
      } else {
        // Manejar el caso en el que db sea null
        print('Error: db is null');
      }
    }

