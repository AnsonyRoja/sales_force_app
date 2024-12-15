import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:path_provider/path_provider.dart';

addVisitCustomerIdempiereSync(visit) async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };


   
  bool theresInternet = await checkInternetConnectivity();

  if(theresInternet == false ){

    return;
  } 

  var map = await getRuta();
  var variablesLogin = await getLogin();
  final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/create_data');
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

 
    final requestBody = {
    
     
          "ModelCRUDRequest": {
              "ModelCRUD": {
                  "serviceType": "CreateRecordVisitAPP",
                  "TableName": "GSS_CustomerVisitRecord",
                  "RecordID": "0",
                  "Action": "Create",
                  "DataRow": {
                      "field": [
                          {
                              "@column": "C_BPartner_ID",
                              "val": visit['c_bpartner_id']
                          },
                           {
                              "@column": "C_SalesRegion_ID",
                              "val": visit['c_sales_region_id']
                          },
                           {
                              "@column": "Coordinates",
                              "val": visit['coordinates'].toString()
                          },
                           {
                              "@column": "Description",
                              "val": visit['description']
                          },
                           {
                              "@column": "EndDate",
                              "val": visit['end_date']
                          },
                            {
                              "@column": "SalesRep_ID",
                              "val": visit['sales_rep_id']
                          },
                            {
                              "@column": "VisitDate",
                              "val": visit['visit_date']
                          },
                            {
                              "@column": "GSS_CustomerVisitConcept_ID",
                              "val": visit['gss_customer_visit_concept_id']
                          },
                         {
                              "@column": "AD_Client_ID",
                              "val": visit['ad_client_id']
                          },
                            {
                              "@column": "AD_Org_ID",
                              "val": visit['ad_org_id']
                          },
                          
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
                  "stage": "9"
              }
          }
      
            
    };

    print('Esto es el requestbody $requestBody');


  // Convertir el cuerpo a JSON
  final jsonBody = jsonEncode(requestBody);

  // Establecer las cabeceras de la solicitud
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Accept', 'application/json');

  // Escribir el cuerpo en la solicitud
  request.write(jsonBody);


  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  
  final parsedJson = jsonDecode(responseBody);
  
    if(parsedJson['StandardResponse']['@IsError'] == true){

        return;

    }

  print("esta es la respuesta $parsedJson");

  final recordCustomerVisitId = parsedJson['StandardResponse']['outputFields']['outputField'][2]['@value'];
  print('Este es el recorId customer visit $recordCustomerVisitId');

  updateRecordCustomerVisitId(visit['id'], recordCustomerVisitId);

  return parsedJson;

}
