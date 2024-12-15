import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:sales_force/config/url.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/infrastructure/models/cobros_model.dart';
import 'package:sales_force/infrastructure/models/vendors.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/sincronization/ExtractData/extract_cobros.dart';
import 'package:sales_force/sincronization/ExtractData/extract_vendors_data.dart';
import 'package:sales_force/sincronization/sincronizar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sales_force/sincronization/sincronization_screen.dart';

sincronizationCobros(setState) async {
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
        "serviceType": "getPaymentAPP",
        "DataRow": {
              "field": [
                {
                  "@column": "SalesRep_ID",
                  "val": variablesLogin['userId'],
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
  dynamic cobros =  extractCobrosData(responseBody);
  print('Estos son los proveedores registrados en idempiere $cobros');
  await syncCobros(cobros,setState); 

  final parsedJson = jsonDecode(responseBody);
  print("esta es la respuesta $parsedJson");
  return parsedJson;

}



Future<void> syncCobros( cobrosData,setState) async {
      final db = await DatabaseHelper.instance.database;
    
       double contador = 0;
print('Esto es Cobros Datas $cobrosData');

      if (db != null) {
        // Itera sobre los datos de los productos recibidos
        for (Map<String, dynamic> cobroData in cobrosData) {
          // Construye un objeto Product a partir de los datos recibidos

          try {
            
         
          print('Vendor data $cobroData');

            dynamic currencyId = cobroData['c_currency_id'];
            
            dynamic cOrderId = cobroData['c_order_id'] ;
            dynamic invoiceId  = cobroData['c_invoice_id'];   
            dynamic mPriceListId = cobroData['m_price_list_id'];
          
            dynamic payAmt;
            dynamic payAmtBs;

              List orderIdLocal = [];

                    if(cOrderId == '{@nil: true}' || invoiceId is int){
                          
                          print('Esto es el Primer orderId local $cOrderId y el invoice id $invoiceId');
                          

                      orderIdLocal = await getSalesOrdersHeaderForIdInvoice(invoiceId);

                    }else if(cOrderId is int){

                      print('Esto es el orderId local $cOrderId');

                      orderIdLocal = await getSalesOrdersHeaderForId(cOrderId);

                    }
                        

                    
              dynamic currencyIso;
              dynamic listPrice;
              currencyIso = await getCurrencyIsoForCobro(currencyId);

               if(cOrderId is int && mPriceListId is int || invoiceId is int && mPriceListId is int )  {


              listPrice = await typeOfCurrencyIsForFirsResult(mPriceListId);

              print('Esto es la lista de precio $listPrice');

              print('Esto es el currency Iso $currencyIso');

              if(listPrice['c_currency_id'] != 100 && currencyIso['iso_code'].toString().toLowerCase().contains('usd')){


                      payAmt = cobroData['pay_amt_usd'];
                      payAmtBs = cobroData['pay_amt_bs'];



              }else if(listPrice['c_currency_id'] == 100 && currencyIso['iso_code'].toString().toLowerCase().contains('bs.')) {


                  payAmtBs = cobroData['pay_amt_usd'];
                  payAmt = cobroData['pay_amt_bs'];


              }else if( listPrice['c_currency_id'] == 205 && currencyIso['iso_code'].toString().toLowerCase().contains('bs.')){

                  payAmt = cobroData['pay_amt_bs'];
                  payAmtBs = cobroData['pay_amt_bs'];

              }else if(listPrice['c_currency_id'] == 100 && currencyIso['iso_code'].toString().toLowerCase().contains('usd')){

                payAmt = cobroData['pay_amt_usd'];
                payAmtBs = cobroData['pay_amt_usd'];
              }

              } else{

                  cobroData['c_order_id'] = 0;
                  cobroData['c_invoice_id'] = 0;
                  cobroData['documentno_invoice'] = 0;
                  
                  if(cobroData['c_currency_id'] == 100){

                  payAmt = cobroData['pay_amt_usd'];
                  payAmtBs = cobroData['pay_amt_usd'];

                  }else{

                      payAmt = cobroData['pay_amt_bs'];
                  payAmtBs = cobroData['pay_amt_bs'];
 

                  }


              } 
              if(orderIdLocal.isEmpty){

                  orderIdLocal.add({'id': 0});

              }

        print('Esto es orderIDLocal $orderIdLocal');

        DateTime date = DateTime.parse(cobroData['date']);

        String formattedDate = DateFormat('dd/MM/yyyy').format(date);



          CobrosSync cobro = CobrosSync(
            adClientId: cobroData['ad_client_id'],
            adOrgId: cobroData['ad_org_id'],
            cPaymentId: cobroData['c_payment_id'],
            cBankAccountId: cobroData['c_bank_account_id'],
            bankAccountName: cobroData['bank_account_name'],
            cDocTypeId: cobroData['c_doc_type_id'],
            dateTrx: cobroData['date_trx'],
            description: cobroData['description'] == '{@nil: true}' ? "": cobroData['description'] ,
            cBPartnerId: cobroData['c_bpartner_id'],
            payAmtBs: payAmt,
            payAmtUsd: payAmtBs,
            tasaConversion: cobroData['tasa_cambio'],
            date: formattedDate,
            mPriceListid: cobroData['m_price_list_id'],
            cCurrencyId: cobroData['c_currency_id'],
            cOrderId: cobroData['c_order_id'],
            orderIdLocal: orderIdLocal[0]['id'], 
            cInvoiceId: cobroData['c_invoice_id'],
            documentNoInvoice: cobroData['documentno_invoice'],
            documentNoCobros: cobroData['documentno_cobro'],
            tenderType: cobroData['tender_type'],
            tenderTypeName: cobroData['tender_typename'],
            docStatus: cobroData['doc_status'],
            salesRepId: cobroData['sales_rep_id'],
            cCurrencyIso: currencyIso['iso_code'], 
  
          );
          
            contador++;

         
            
                    setState(() {
                      
                          syncPercentageCobros = (contador / cobrosData.length) * 100;

                    });


          // Convierte el objeto Product a un mapa
          Map<String, dynamic> cobroMap = cobro.toMap();

          print('Esto es CobroMap $cobroMap');

          // Consulta si el producto ya existe en la base de datos local por su nombre
          List<Map<String, dynamic>> existingCobro= await db.query(
            'cobros',
            where: 'documentno = ?',
            whereArgs: [cobro.documentNoCobros],
          );

          if (existingCobro.isNotEmpty) {
            // Si el producto ya existe, actualiza sus datos
            await db.update(
              'cobros',
              cobroMap,
              where: 'documentno = ?',
              whereArgs: [cobro.documentNoCobros],
            );
            print('Cobro actualizado: ${cobro.documentNoCobros}');
          } else {
            // Si el producto no existe, inserta un nuevo registro en la tabla de productos
            await db.insert('cobros', cobroMap);
            print('Cobro insertado: ${cobro.documentNoCobros }');
          }
          } catch (e) {

                print('Este es el error $e');
                continue;

          }
        }
        print('Sincronización de Cobros completada.');
      } else {
        // Manejar el caso en el que db sea null
        print('Error: db is null');
      }

      
    }

