import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future getRuta() async {
  final info = await getApplicationSupportDirectory();
  final String filePath = '${info.path}/.config.json';
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
