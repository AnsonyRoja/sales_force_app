import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/infrastructure/models/address_customer.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/sincronization/ExtractData/extract_address_customer_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/sincronization_screen.dart';

Future<void> sincronizationAddressCustomer(Function setState, mounted) async {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      return true;
    };

  List clients = await getClients();

  var map = await getRuta();
  var variablesLogin = await getLogin();
  final uri = Uri.parse('${map['URL']}ADInterface/services/rest/model_adservice/query_data');

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

  double totalClients = clients.length.toDouble();
  double clientsProcessed = 0;
    bool shouldContinue = true; // Variable de control


  for (var client in clients) {
    // Configurar el cuerpo de la solicitud en formato JSON
      if (!shouldContinue || !mounted) break; 


    try {
      
      // paso traerme las regiones por representante comercial
      // paso 2 traerme las direcciones de tercero por esas regiones // direcciones 
      // paso 3 traerme los terceros que estan asociados a esas direcciones  
  
    final requestBody = {
      "ModelCRUDRequest": {
        "ModelCRUD": {
          "serviceType": "getBPartnerLocationAddress",
          "DataRow": {
            "field": [
              {
                "@column": "C_BPartner_ID",
                "val": client['c_bpartner_id'],
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

    final request = await httpClient.postUrl(uri);
    
    // Establecer las cabeceras de la solicitud
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');

    // Escribir el cuerpo en la solicitud
    request.write(jsonBody);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    dynamic addressCustomerData = extractAddressCustomerData(responseBody);

      print('Estas son las direcciones registradas de los clientes $addressCustomerData');
    
    await syncAddressCustomer(addressCustomerData); // Obtener todos los productos

    clientsProcessed++;
    
    setState(() {
      syncPercentageAddressCustomers = (clientsProcessed / totalClients) * 100;
      
      if(syncPercentageAddressCustomers == 100){

          shouldContinue = false;
        
      }
    });
    
    await Future.delayed(Duration(milliseconds:50 ));
    final parsedJson = jsonDecode(responseBody);
    print("esta es la respuesta $parsedJson");
    } catch (e) {
        print('Error sincronizando cliente ${client['c_bpartner_id']}: $e');
      continue; // Continúa con el siguiente cliente
    }
  }

  print('Sincronización de direcciones completada.');
    
}

Future<void> syncAddressCustomer(List<Map<String, dynamic>> addressCustomerData) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Itera sobre los datos de los productos recibidos
    for (Map<String, dynamic> addressCustomer in addressCustomerData) {
      // Construye un objeto AddressCustomer a partir de los datos recibidos
      AddressCustomer address = AddressCustomer(
        cBPartnerID: addressCustomer['c_bpartner_id'],
        cBPartnerLocationID: addressCustomer['c_bpartner_location_id'],
        cSalesRegionID: addressCustomer['c_sales_region_id'],
        name: addressCustomer['name'],
      );

      // Convierte el objeto AddressCustomer a un mapa
      Map<String, dynamic> addressMap = address.toMap();

      // Consulta si la dirección ya existe en la base de datos local por su ID de ubicación
      List<Map<String, dynamic>> existingAddress = await db.query(
        'address_customers',
        where: 'c_bpartner_location_id = ? AND c_bpartner_id = ?',
        whereArgs: [address.cBPartnerLocationID, address.cBPartnerID],
      );

      if (existingAddress.isNotEmpty) {
        // Si la dirección ya existe, actualiza sus datos
        await db.update(
          'address_customers',
          addressMap,
          where: 'c_bpartner_location_id = ? AND c_bpartner_id = ?',
          whereArgs: [address.cBPartnerLocationID, address.cBPartnerID],
        );
        print('Dirección del cliente actualizada: ${address.name}');
      } else {
        // Si la dirección no existe, inserta un nuevo registro en la tabla de direcciones
        await db.insert('address_customers', addressMap);
        print('Dirección insertada correctamente: ${address.name}');
      }
    }
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
  }
}
