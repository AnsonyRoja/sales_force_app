import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/center_costs.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/ExtractData/extract_center_cost.dart';

sincronizationCenterCosts() async {
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
        "serviceType": "getCostCenter",
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
  dynamic states =  extractCenterCost(responseBody);



            print('Estos son los estados registrados desde idempiere $states');


  await syncCenterCosts(states); 

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;

}


Future<void> syncCenterCosts(List<Map<String, dynamic>> centerCost) async {
      final db = await DatabaseHelper.instance.database;
    



      if (db != null) {
        // Itera sobre los datos de los productos recibidos
        for (Map<String, dynamic> centerC in centerCost) {
          // Construye un objeto Product a partir de los datos recibidos
          CenterCosts centerCts = CenterCosts(

                cElementValueId: centerC['c_element_value_id'],
                name: centerC['name'],
                value: centerC['value']

          );
          

                   
                   print('esto es el valor que tiene la variable pricelist ${centerCts.toMap()}');



          // Convierte el objeto Product a un mapa
          Map<String, dynamic> centerCosMap = centerCts.toMap();


          // Consulta si el producto ya existe en la base de datos local por su nombre
          List<Map<String, dynamic>> existingState= await db.query(
            'center_costs',
            where: 'c_element_value_id = ?',
            whereArgs: [centerCts.cElementValueId],
          );

          if (existingState.isNotEmpty) {

            await db.update(
              'center_costs',
              centerCosMap,
              where: 'c_element_value_id = ?',
              whereArgs: [centerCts.cElementValueId],
            );
            print('Tabla de Center Cost actualizado: ${centerCts.name}');
          } else {

            await db.insert('center_costs', centerCosMap);
            print('Centro de costo insertado: ${centerCts.name}');
          }
        }
        print('Sincronización of center cost  completed.');
      } else {
        // Manejar el caso en el que db sea null
        print('Error: db is null');
      }
    }

