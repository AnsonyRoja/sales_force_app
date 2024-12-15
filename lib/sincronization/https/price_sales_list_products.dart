import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/price_sales_product.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/sincronization/ExtractData/extract_price_sales_list.dart';
import 'package:path_provider/path_provider.dart';

sincronizationPriceSalesListProducts() async {
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
        "serviceType": "getProductPriceSalesAPP",
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
  dynamic priceSalesList = extractPriceSalesList(responseBody);

  print(
      'Estos son los precios de las lista de los productos disponibles en idempiere $priceSalesList');

  await syncPriceSalesListProduct(priceSalesList);

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;
}

Future<void> syncPriceSalesListProduct(
    List<Map<String, dynamic>> priceSalesList) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Itera sobre los datos de los productos recibidos
    for (Map<String, dynamic> priceSaleList in priceSalesList) {
      // Construye un objeto Product a partir de los datos recibidos
      PriceSalesList priceList = PriceSalesList(
          mPriceListId: priceSaleList['m_pricelist_id'],
          priceListName: priceSaleList['price_list_name'],
          cCurrencyId: priceSaleList['c_currency_id'],
          mProductId: priceSaleList['m_product_id'],
          priceList: priceSaleList['price_list']);

      print(
          'esto es el valor que tiene la variable pricelist ${priceList.toMap()}');

      // Convierte el objeto Product a un mapa
      Map<String, dynamic> priceListToMap = priceList.toMap();

      // Consulta si el producto ya existe en la base de datos local por su nombre
      List<Map<String, dynamic>> existingPriceList = await db.query(
        'price_sales_list',
        where: 'm_pricelist_id = ? AND m_product_id = ?',
        whereArgs: [priceList.mPriceListId, priceList.mProductId],
      );

      if (existingPriceList.isNotEmpty) {
        await db.update(
          'price_sales_list',
          priceListToMap,
          where: 'm_pricelist_id = ? AND m_product_id = ?',
          whereArgs: [priceList.mPriceListId, priceList.mProductId],
        );
        print('Price List actualizado: ${priceList.priceListName}');
      } else {
        await db.insert('price_sales_list', priceListToMap);
        print('Price List insertado: ${priceList.priceListName}');
      }
    }
    print('Sincronización of Price list  completed.');
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
  }
}
