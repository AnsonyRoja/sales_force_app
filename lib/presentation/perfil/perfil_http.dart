import 'package:sales_force/config/get_users.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

Future infoP({required String username, required String password}) async {
  // Simula una solicitud de autenticación a un servidor o base de datos.
  //  await Future.delayed(const Duration(seconds: 2)); // Simulación de tiempo de espera.
try {

  dynamic response = await getUsers(username, password);

  if (response.statusCode == 200) {
    // La solicitud fue exitosa, puedes procesar la respuesta aquí.

    final responseBody = await response.transform(utf8.decoder).join();

    final parsedJson = jsonDecode(responseBody);

    print("esta es la info del perfil $parsedJson");

    final windowTabData = parsedJson['WindowTabData'];

    return windowTabData;

  }
  
} catch (e) {
  print("error en infoP $e");
  print('Error al leer o analizar el archivo JSON: ${e.toString().contains("Network is unreachable")}}');
if(e.toString().contains("Network is unreachable") || e.toString().contains('Connection refused')){

      return 'hay problemas con el internet';

}
else if (e.toString().contains('No host specified in URI')) {
    // Manejar el error específico y devolver un mensaje personalizado
    print('Error en getDocuments: La URL está mal escrita. Detalles: $e');
    return 'La URL está mal escrita.';
    
  }

}

}



Future getLogin() async {

  final info = await getApplicationSupportDirectory();
  final String filePath = '${info.path}/.login.json';
  final File configFile = File(filePath);


  try {
    final String content = await configFile.readAsString();
    final mapaConfig = json.decode(content);

    // Ahora, 'mapaConfig' contiene el mapa con la información del archivo JSON
    // Puedes acceder a la URL como 'mapaConfig["URL"]'
   
    return mapaConfig;
    
  } catch (e) {
    // Maneja cualquier error que pueda ocurrir al leer o analizar el archivo
    print('Error al leer o analizar el archivo JSON: $e');

    return {"error": e};
  }
}
