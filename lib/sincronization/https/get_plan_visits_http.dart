import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/plan_visits.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/ExtractData/extract_plan_visits.dart';
import 'package:sqflite/sqflite.dart';

sincronizationPlanVisits() async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };

  var map = await getRuta();
  var variablesLogin = await getLogin();
  final uri = Uri.parse(
      '${map['URL']}ADInterface/services/rest/model_adservice/query_data');
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
        "serviceType": "getPlanVisitApp",
        "DataRow": {
          "field": [
            {"@column": "SalesRep_ID", "val": variablesLogin['userId']}
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
  dynamic pv = extractPlanVisits(responseBody);

  print('Estos son los estados registrados desde idempiere $pv');

  await syncPlanVisits(pv);

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;
}

Future<void> syncPlanVisits(List<Map<String, dynamic>> planVisits) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Itera sobre los datos de los productos recibidos
    for (Map<String, dynamic> planVisit in planVisits) {
      // Construye un objeto Product a partir de los datos recibidos
      PlanVisits planV = PlanVisits(
          adClientId: planVisit['ad_client_id'],
          adOrgId: planVisit['ad_org_id'],
          gssCvpId: planVisit['gss_cvp_id'],
          gssCvpLineId: planVisit['gss_cvp_line_id'],
          salesRepId: planVisit['sales_rep_id'],
          salesRepName: planVisit['sales_rep_name'],
          cBPartnerId: planVisit['c_bpartner_id'],
          bPartnerName: planVisit['bpartner_name'],
          cSalesRegionId: planVisit['c_sales_region_id'],
          salesRegion: planVisit['salesregion'],
          dateCalendar: planVisit['date_calendar'],
          dayNumber: planVisit['day_number'],
          weekNumber: planVisit['week_number'],
          cBPartnerLocationId: planVisit['c_bpartner_location_id'],
          state: planVisit['state']
          
          );

      print(
          'esto es el valor que tiene la variable Plan de visitas ${planV.toMap()}');

      // Convierte el objeto Product a un mapa
      Map<String, dynamic> planVMap = planV.toMap();
      print('esto es el planvmap $planVMap');

      List<Map<String, dynamic>> existingRecords = await db.query(
        'plan_visits',
        where: 'c_bpartner_id = ? AND date_calendar = ? ',
        whereArgs: [planV.cBPartnerId, planV.dateCalendar],
      );

      if (existingRecords.isEmpty) {
        // Inserta el nuevo registro si no existe
        await db.insert(
          'plan_visits',
          planVMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('Registro insertado: ${planV.toMap()}');
      } else {
        await db.update(
          'plan_visits',
          planVMap,
          where: 'c_bpartner_id = ? AND date_calendar = ? ',
          whereArgs: [planV.cBPartnerId, planV.dateCalendar],
        );
        print('Tabla de plan de visitas actualizado: ${planV.cSalesRegionId}');

        print(
            'Registro con id ${planV.bPartnerName} ya existe, y se actualizo.');
      }

      print(
          'Plan de Visitas insertada correctamente con su responsable : ${planV.salesRepName}');
    }
    print('Sincronización of State  completed.');
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
  }
}
