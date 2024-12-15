import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/config/search_key_idempiere.dart';
import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';

updateCobroIdempiere(cobro, monto) async {
  
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };
    
try {


   initV() async {
    if (variablesG.isEmpty) {

      List<Map<String, dynamic>> response = await getPosPropertiesV();
      print('variables Entre aqui');
        variablesG = response;
    
    }
  }
 
  await initV();

    print('variables globales $variablesG');
    print('Esto es cobro ${cobro}');
  

  var map = await getRuta();
  var variablesLogin = await getLogin();
  final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/update_data');
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
            "serviceType": "UpdateCollectionAmount",
            "RecordID": cobro['c_payment_id'],
            "TableName": "C_Payment",
            "DataRow": {

              "field": [
                {
                  "@column": "PayAmt",
                  "val": monto
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


  final jsonBody = jsonEncode(requestBody);

    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.headers.set('Accept', 'application/json');

    request.write(jsonBody);

  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();


  final parsedJson = jsonDecode(responseBody);


      print("esta es la respuesta $parsedJson");
      return parsedJson;
        } catch (e) {
          return 'este es el error e $e';
      }


}





setDocActionCobrosIdempiere(cobro) async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  try {
    // Inicializa variables globales si están vacías
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();
      print('variables Entre aqui');
      variablesG = response;
    }

    print('variables globales $variablesG');
    print('Esto es cobro ${cobro}');

    var map = await getRuta();
    var variablesLogin = await getLogin();
    final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/set_docaction');
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
      "ModelSetDocActionRequest": {
        "ModelSetDocAction": {
          "serviceType": "completeCobro",
          "recordID": cobro['c_payment_id'],
          "docAction": "PR"
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

    print('Cuerpo de la solicitud: $jsonBody');

    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.headers.set('Accept', 'application/json');

    request.write(jsonBody);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    final parsedJson = jsonDecode(responseBody);
    dynamic docStatus = searchKey(parsedJson, '@value');

    await updateStatusCobros(cobro['id'], docStatus);

    print("Respuesta del setDocAction: $parsedJson");
    return parsedJson;
  } catch (e) {
    print('Error: $e');
    return 'Error: $e';
  }
}

Future<Map<String, dynamic>> setDocActionAprobar(cobro) async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  try {
    // Inicializa variables globales si están vacías
    if (variablesG.isEmpty) {
      List<Map<String, dynamic>> response = await getPosPropertiesV();
      print('variables Entre aqui');
      variablesG = response;
    }

    print('variables globales $variablesG');
    print('Esto es cobro ${cobro}');

    var map = await getRuta();
    var variablesLogin = await getLogin();
    final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/set_docaction');
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
      "ModelSetDocActionRequest": {
        "ModelSetDocAction": {
          "serviceType": "completeCobro",
          "recordID": cobro['c_payment_id'],
          "docAction": "AP" // Estado "Aprobar"
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

    print('Cuerpo de la solicitud: $jsonBody');

    request.headers.set('Content-Type', 'application/json; charset=utf-8');
    request.headers.set('Accept', 'application/json');

    request.write(jsonBody);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    final parsedJson = jsonDecode(responseBody);
    dynamic docStatus = searchKey(parsedJson, '@value');

    await updateStatusCobros(cobro['id'], docStatus);

    print("Respuesta del setDocAction: $parsedJson");
    return parsedJson;
  } catch (e) {
    print('Error: $e');
    return {'error': e.toString()};
  }
}




