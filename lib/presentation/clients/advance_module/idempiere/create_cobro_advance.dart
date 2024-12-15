import 'dart:convert';
import 'dart:io';

import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/config/url.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:path_provider/path_provider.dart';

createCobroAdvanceIdempiere(cobro) async {
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

    initV();

    print('variables globales $variablesG');
    print('Esto es Cobro ${cobro}');

    var map = await getRuta();
    var variablesLogin = await getLogin();
    final uri = Uri.parse(
        '${map['URL']}ADInterface/services/rest/composite_service/composite_operation');
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

    if (cobro['c_number_ref'] != '') {

        final requestBody = {
          "CompositeRequest": {
            "ADLoginRequest": {
              "user": variablesLogin['user'],
              "pass": variablesLogin['password'],
              "lang": language,
              "ClientID": clientId,
              "RoleID": role,
              "OrgID": orgId,
              "WarehouseID": wareHouseId,
              "stage": "9",
            },
            "serviceType": "UCCompositePayment",
            "operations": {
              "operation": [
                {
                  "TargetPort": "createUpdateData",
                  "ModelCRUD": {
                    "serviceType": "CreateReceiptAPP",
                    "TableName": "C_Payment",
                    "RecordID": "0",
                    "Action": "CreateUpdate",
                    "DataRow": {
                      "field": [
                        {"@column": "DocumentNo", "val": cobro['c_number_ref']},
                        {
                          "@column": "C_BankAccount_ID",
                          "val": cobro['c_bankaccount_id']
                        },
                        {
                          "@column": "C_DocType_ID",
                          "val": cobro['c_doctype_id'],
                        },
                        {
                          "@column": "DateTrx",
                          "val": cobro['date_trx'],
                        },
                        {"@column": "Description", "val": cobro['description']},
                        {
                          "@column": "C_BPartner_ID",
                          "val": cobro['c_bpartner_id']
                        },
                        {"@column": "PayAmt", "val": cobro['pay_amt']},
                        {
                          "@column": "C_Currency_ID",
                          "val": cobro['c_currency_id']
                        },
                        {"@column": "TenderType", "val": cobro['tender_type']},
                        {"@column": "IsPrepayment", "val": "Y"},
                        {
                          "@column": "SalesRep_ID",
                          "val": variablesLogin['userId']
                        }
                      ]
                    }
                  }
                },
                {
                  "TargetPort": "setDocAction",
                  "ModelSetDocAction": {
                    "serviceType": "completePaymentReceipt",
                    "tableName": "C_Payment",
                    "recordIDVariable": "@C_Payment.C_Payment_ID",
                    "docAction": variablesG[0]['doc_status_receipt']
                  }
                }
              ]
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
      

    } else {

      final requestBody = {
        "CompositeRequest": {
          "ADLoginRequest": {
            "user": variablesLogin['user'],
            "pass": variablesLogin['password'],
            "lang": language,
            "ClientID": clientId,
            "RoleID": role,
            "OrgID": orgId,
            "WarehouseID": wareHouseId,
            "stage": "9",
          },
          "serviceType": "UCCompositePayment",
          "operations": {
            "operation": [
              {
                "TargetPort": "createUpdateData",
                "ModelCRUD": {
                  "serviceType": "CreateReceiptAPP",
                  "TableName": "C_Payment",
                  "RecordID": "0",
                  "Action": "CreateUpdate",
                  "DataRow": {
                    "field": [
                      {
                        "@column": "C_BankAccount_ID",
                        "val": cobro['c_bankaccount_id']
                      },
                      {
                        "@column": "C_DocType_ID",
                        "val": cobro['c_doctype_id'],
                      },
                      {
                        "@column": "DateTrx",
                        "val": cobro['date_trx'],
                      },
                      {"@column": "Description", "val": cobro['description']},
                      {
                        "@column": "C_BPartner_ID",
                        "val": cobro['c_bpartner_id']
                      },
                      {"@column": "PayAmt", "val": cobro['pay_amt']},
                      {
                        "@column": "C_Currency_ID",
                        "val": cobro['c_currency_id']
                      },
                      {"@column": "TenderType", "val": cobro['tender_type']},
                      {"@column": "IsPrepayment", "val": "Y"},
                      {
                        "@column": "SalesRep_ID",
                        "val": variablesLogin['userId']
                      }
                    ]
                  }
                }
              },
              {
                "TargetPort": "setDocAction",
                "ModelSetDocAction": {
                  "serviceType": "completePaymentReceipt",
                  "tableName": "C_Payment",
                  "recordIDVariable": "@C_Payment.C_Payment_ID",
                  "docAction": variablesG[0]['doc_status_receipt']
                }
              }
            ]
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
    
  }
  } catch (e) {
    return 'este es el error e $e';
  }
}
