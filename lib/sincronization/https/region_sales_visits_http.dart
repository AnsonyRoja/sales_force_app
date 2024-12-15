import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/region_sales.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:sales_force/sincronization/ExtractData/extract_region_sales.dart';

sincronizationRegionSalesVisits() async {
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
        "serviceType": "getSalesRegion",
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
  dynamic regionSalesVisits =  extractRegionSalesVisit(responseBody);



            print('Estos son las regiones de ventas  este usuario  $regionSalesVisits');


  await syncRegionSales(regionSalesVisits); 

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;

}


Future<void> syncRegionSales(List<Map<String, dynamic>> regionSalesVisits) async {
      final db = await DatabaseHelper.instance.database;
    



      if (db != null) {
        // Itera sobre los datos de los productos recibidos
        for (Map<String, dynamic> regionSalesV in regionSalesVisits) {
          // Construye un objeto Product a partir de los datos recibidos
          RegionSalesVisits regionSV = RegionSalesVisits(

              cSalesRegionId: regionSalesV['c_sales_region_id'],
              name: regionSalesV['name'],
              cod: regionSalesV['cod'],
              salesRepId: regionSalesV['sales_rep_id']

          );
          

                   
                   print('esto es el valor que tiene la variable RegionSv ${regionSV.toMap()}');



          // Convierte el objeto Product a un mapa
          Map<String, dynamic> regionSvMap = regionSV.toMap();


          // Consulta si el producto ya existe en la base de datos local por su nombre
          List<Map<String, dynamic>> existingRegionSv= await db.query(
            'region_sales_visits',
            where: 'c_sales_region_id= ?',
            whereArgs: [regionSV.cSalesRegionId],
          );

          print('Esto es el existing region $existingRegionSv');

          if (existingRegionSv.isNotEmpty) {

            await db.update(
              'region_sales_visits',
              regionSvMap,
              where: 'c_sales_region_id = ?',
              whereArgs: [regionSV.cSalesRegionId],
            );
            print('Tabla de Region Sales Visits actualizado: ${regionSV.salesRepId}');
          } else {

            await db.insert('region_sales_visits', regionSvMap);
            print('Region de venta insertado: ${regionSV.name}');
          }
        }
        print('Sincronización of Region Sales Visits  completed.');
      } else {
        // Manejar el caso en el que db sea null
        print('Error: db is null');
      }
    }

