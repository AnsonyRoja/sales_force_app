import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future infoLogin(username, password) async {

  final infoLog = await getApplicationSupportDirectory();
  final String filePath = '${infoLog.path}/.login.json';
  final File configFile = File(filePath);

  if (!(await configFile.exists())) {
    await configFile.create();
  }

  final Map<String, dynamic> jsonData = {
    
    "user": username,
    "password": password,
    "auth": false,   

  };

  final String newContent = json.encode(jsonData);

  try {
    await configFile.writeAsString(newContent);
    
    print('Se edito correctamente');
  } catch (e) {
    print('no se pudo escribir dentro del archivo.json');
  }
}


