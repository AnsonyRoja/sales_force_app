import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/ware_house.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/ExtractData/extract_warehouse.dart';

sincronizationWareHouse() async {
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
        "serviceType": "getWarehouseAPP",
        "DataRow": {
            "field": [
              {
                "@column": "AD_User_ID",
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
  dynamic allWareHouse =  extractWareHouse(responseBody);



            print('Estos son los almacenes registrados de este usuario  $allWareHouse');


  await syncWareHouse(allWareHouse); 

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;

}


Future<void> syncWareHouse(List<Map<String, dynamic>> wareHouses) async {
      final db = await DatabaseHelper.instance.database;
    



      if (db != null) {
        // Itera sobre los datos de los productos recibidos
        for (Map<String, dynamic> wareHouse in wareHouses) {
          // Construye un objeto Product a partir de los datos recibidos
          WareHouse wareHouseObject = WareHouse(

              adClientId: wareHouse['ad_client_id'],
              name: wareHouse['name'],
              adOrgId: wareHouse['ad_org_id'],
              mWareHouseId: wareHouse['m_warehouse_id'],
              wareHouseValue: wareHouse['value']

          );
          

                   
                   print('esto es el valor que tiene la variable RegionSv ${wareHouseObject.toMap()}');



          // Convierte el objeto Product a un mapa
          Map<String, dynamic> wareHouseMap = wareHouseObject.toMap();


          // Consulta si el producto ya existe en la base de datos local por su nombre
          List<Map<String, dynamic>> existingWareHouse= await db.query(
            'm_warehouse',
            where: 'm_warehouse_id = ?',
            whereArgs: [wareHouseObject.mWareHouseId],
          );

          print('Esto es el existing wareHouse $existingWareHouse');

          if (existingWareHouse.isNotEmpty) {

            await db.update(
              'm_warehouse',
              wareHouseMap,
              where: 'm_warehouse_id = ?',
              whereArgs: [wareHouseObject.mWareHouseId],
            );
            print('Tabla de ware house actualizado: ${wareHouseObject.name}');
          } else {

            await db.insert('m_warehouse', wareHouseMap);
            print('Ware House insertado Correctamente: ${wareHouseObject.name}');
          }
        }
        print('Sincronización De Ware House Almacen completed.');
      } else {
        // Manejar el caso en el que db sea null
        print('Error: db is null');
      }
    }

