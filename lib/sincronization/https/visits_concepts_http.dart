import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/states.dart';
import 'package:sales_force/infrastructure/models/visits_concepts.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/ExtractData/extract_states.dart';
import 'package:sales_force/sincronization/ExtractData/extract_visits_concepts.dart';

sincronizationVisitsConcepts() async {
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
        "serviceType": "getCustomerVisitConcepts",
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
  dynamic visitsConcepts =  extractVisitsConcepts(responseBody);



            print('Estos son los conceptos de visitas registrados desde idempiere $visitsConcepts');


  await syncVisitsConcepts(visitsConcepts); 

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;

}


Future<void> syncVisitsConcepts(List<Map<String, dynamic>> visitsConcepts) async {
      final db = await DatabaseHelper.instance.database;
    



      if (db != null) {
        // Itera sobre los datos de los productos recibidos
        for (Map<String, dynamic> visitsC in visitsConcepts) {
          // Construye un objeto Product a partir de los datos recibidos
          VisitsConceptsIdempiere visitsConceptObj = VisitsConceptsIdempiere(

              gssCustomerVisitConceptId: visitsC['gss_customer_visit_concept_id'],
              value: visitsC['value'],
              name: visitsC['name']

          );
          

                   
                   print('esto es el valor que tiene la variable concepto de visita ${visitsConceptObj.toMap()}');



          // Convierte el objeto Product a un mapa
          Map<String, dynamic> visitsConceptsMap = visitsConceptObj.toMap();


          // Consulta si el producto ya existe en la base de datos local por su nombre
          List<Map<String, dynamic>> existingState= await db.query(
            'visits_concepts',
            where: 'gss_customer_visit_concept_id= ?',
            whereArgs: [visitsConceptObj.gssCustomerVisitConceptId],
          );

          if (existingState.isNotEmpty) {

            await db.update(
              'visits_concepts',
              visitsConceptsMap,
              where: 'gss_customer_visit_concept_id = ?',
              whereArgs: [visitsConceptObj.gssCustomerVisitConceptId],
            );
            print('Tabla de cenceptos de visitas actualizado: ${visitsConceptObj.name}');
          } else {

            await db.insert('visits_concepts', visitsConceptsMap);
            print('Concepto de visita insertado: ${visitsConceptObj.name}');
          }
        }
        print('Sincronización of Visits Concepts  completed.');
      } else {
        // Manejar el caso en el que db sea null
        print('Error: db is null');
      }
    }

