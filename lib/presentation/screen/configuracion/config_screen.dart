import 'package:flutter/material.dart';
import 'package:sales_force/presentation/screen/configuracion/services/config_services.dart';
import 'package:sales_force/presentation/screen/login/login_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future addConfig(url, token) async {
  final info = await getApplicationSupportDirectory();
  print('Esto es temporal $info');
  final String filePath = '${info.path}/.config.json';

  print(filePath);

  final File configFile = File(filePath);

  await configFile.create();

  print("esto es el token $token");

  url.endsWith('/') ? url = url : url = '$url/';

  final Map<String, dynamic> jsonData = {"URL": url, "TOKEN": token};

  final String newContent = json.encode(jsonData);

  // final Map nuevo = json.decode(newContent);

  final String content = await configFile.readAsString();

  print("Esto es el content $content");

  try {
    await configFile.writeAsString(newContent);

    print("esto es el contenxt pasado $content");

    print('Contenido actualizado exitosamente en la ubicación de documentos.');
  } catch (e) {
    print('Error al escribir el archivo JSON: $e');
  }
}

// await dotenv.load(fileName: 'lib/assets/.env');

//         var acces = dotenv.env;

//         print('Esto es variables de entorno .env acces: $acces');

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  final TextEditingController textUrlController = TextEditingController();
  final TextEditingController textTokenController = TextEditingController();
  bool messageUrlInvalid = false;
  bool openButton = false;

  String mensajeConexion = '';

  @override
  void initState() {
    super.initState();
    textTokenController.addListener(() {
      String currentText = textTokenController.text;
      if (currentText != currentText.toUpperCase()) {
        textTokenController.value = textTokenController.value.copyWith(
          text: currentText.toUpperCase(),
          selection: TextSelection.fromPosition(
            TextPosition(offset: currentText.length),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final saludo = dotenv.env['Hola'];

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 227, 245, 235),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'lib/assets/Atras@3x.png',
            width: 25,
            height: 25,
            color: Colors.black,
          ), // Reemplaza 'tu_imagen.png' con la ruta de tu imagen en los assets
          onPressed: () {
            // Acción al presionar el botón de flecha hacia atrás
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          },
        ),

        backgroundColor:
            const Color.fromARGB(255, 227, 245, 235), // Color hexadecimal
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Cierra el teclado virtual
        },
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración',
                      style:
                          TextStyle(fontFamily: 'Poppins Bold', fontSize: 35),
                      textAlign: TextAlign.start,
                    ),
                    const Text(
                      'Configura el servidor',
                      style: TextStyle(fontFamily: 'Poppins Regular'),
                      textAlign: TextAlign.start,
                    ),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60),
                          Container(
                            width: 300,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  35.0), // Ajusta el radio de las esquinas
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2), // Color de la sombra
                                  spreadRadius: 2, // Extensión de la sombra
                                  blurRadius: 3, // Difuminado de la sombra
                                  offset: const Offset(
                                      0, 2), // Desplazamiento de la sombra
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: textUrlController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'https://', // Tu placeholder

                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 23.0, horizontal: 20.0),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                    borderSide: BorderSide(
                                        color: Colors.black), // Color del borde
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .green), // Color del borde cuando está enfocado
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(158, 157, 157,
                                            0.2)), // Color del borde cuando no está enfocado
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: openButton
                                        ? Image.asset(
                                            'lib/assets/Check.png', // Reemplaza con la ruta correcta de tu imagen
                                            width:
                                                20, // Ajusta el ancho de la imagen según tus preferencias
                                            height:
                                                20, // Ajusta la altura de la imagen según tus preferencias
                                          )
                                        : null,
                                  )),
                              onChanged: (value) {
                                if (!_isValidUrl(value)) {
                                  // Si la URL no es válida, no actualices el controlador
                                  // o puedes mostrar un mensaje de error si lo prefieres
                                  print('URL no válida');
                                  setState(() {
                                    messageUrlInvalid = true;
                                  });
                                } else {
                                  print('Esto es un valor: $value');

                                  setState(() {
                                    messageUrlInvalid = false;
                                  });
                                }
                                print(
                                    'Esto es un valor: ${textUrlController.text}');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (messageUrlInvalid)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'La URL ingresada no es válida. Asegúrate de comenzar con "https://" y evita espacios.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 15),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 8),
                          Container(
                            width: 300,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  35.0), // Ajusta el radio de las esquinas
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withOpacity(0.2), // Color de la sombra
                                  spreadRadius: 2, // Extensión de la sombra
                                  blurRadius: 3, // Difuminado de la sombra
                                  offset: const Offset(
                                      0, 2), // Desplazamiento de la sombra
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: textTokenController,
                              decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: 'Token', // Tu placeholder

                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 23.0, horizontal: 20.0),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                    borderSide: BorderSide(
                                        color: Colors.black), // Color del borde
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                    borderSide: BorderSide(
                                        color: Colors
                                            .green), // Color del borde cuando está enfocado
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(35.0)),
                                    borderSide: BorderSide(
                                        color: Color.fromRGBO(158, 157, 157,
                                            0.2)), // Color del borde cuando no está enfocado
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: openButton
                                        ? Image.asset(
                                            'lib/assets/Check.png', // Reemplaza con la ruta correcta de tu imagen
                                            width:
                                                20, // Ajusta el ancho de la imagen según tus preferencias
                                            height:
                                                20, // Ajusta la altura de la imagen según tus preferencias
                                          )
                                        : null,
                                  )),
                              onChanged: (value) async {
                                print(
                                    'Esto es un valor: ${textTokenController.text}');

                                bool resp = await verificarConexion(
                                    textUrlController.text,
                                    textTokenController.text,
                                    setState);
                                print('Esto es la respuesta: $resp');
                                if (resp == true) {
                                  setState(() {
                                    mensajeConexion = 'Conexión exitosa';
                                    openButton = true;
                                  });
                                } else {
                                  setState(() {
                                    mensajeConexion =
                                        'No se pudo realizar la conexión';
                                    openButton = false;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 25.0), // Agrega un margen superior de 10 unidades
                  child: Text(mensajeConexion,
                      style: TextStyle(
                          color: (mensajeConexion == 'Conexión exitosa' ||
                                  mensajeConexion ==
                                      'Se guardo la configuración')
                              ? Color(0XFF0C5A74)
                              : Colors.red)),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        right: 25.0), // Establece el margen entre los botones
                    child: GestureDetector(
                      onTap: () async {
                        String textoIngresado = textUrlController.text;
                        String textTokenIngresado = textTokenController.text;

                        try {
                          var verificon = await verificarConexion(
                                  textoIngresado, textTokenIngresado, setState)
                              .timeout(const Duration(seconds: 2));

                          if (verificon) {
                            setState(() {
                              mensajeConexion = 'Conexión exitosa';
                              openButton = true;
                            });
                          }
                        } catch (e) {
                          setState(() {
                            mensajeConexion = 'No se pudo realizar la conexión';
                            openButton = false;
                          });
                        }

                        textUrlController.text = textoIngresado;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          // Puedes ajustar el color según tus necesidades
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.settings,
                              color: Color(0xFF00722D),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Realizar Test',
                              style: TextStyle(
                                fontFamily:
                                    'Poppins Regular', // Reemplaza con el nombre definido en pubspec.yaml
                                fontSize: 12.0, // Tamaño de la fuente
                                // Peso de la fuente (por ejemplo, bold)
                                color: Color(0xFF00722D), // Color del texto
                              ), // Puedes ajustar el color del texto
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 300,
                    // Establece el margen entre los botones
                    child: ElevatedButton(
                      onPressed: openButton == false
                          ? null
                          : () async {
                              if (messageUrlInvalid == true ||
                                  mensajeConexion ==
                                      'No se pudo realizar la conexión') {
                                return;
                              } else {
                                String url = textUrlController.text;
                                String token = textTokenController.text;

                                if (url.isNotEmpty && token.isNotEmpty) {
                                  await addConfig(textUrlController.text,
                                      textTokenController.text);

                                  verificarDatosDeAcceso();
                                  textUrlController.clear();
                                  textTokenController.clear();
                                  setState(() {
                                    mensajeConexion =
                                        'Se guardo la configuración';
                                  });

                                  await Future.delayed(
                                      const Duration(seconds: 1));

                                  Navigator.pushReplacementNamed(context, '/');
                                } else {
                                  setState(() {
                                    mensajeConexion =
                                        'Ambos campos son obligatorios';
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Ajusta el radio de las esquinas
                          ),
                          backgroundColor: const Color(
                              0xFF00722D) // Ajusta el color de fondo del botón
                          ),
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontFamily:
                              'OpenSans', // Reemplaza con el nombre definido en pubspec.yaml
                          fontSize: 15.0, // Tamaño de la fuente
                          // Peso de la fuente (por ejemplo, bold)
                          color: Color.fromARGB(
                              255, 255, 254, 254), // Color del texto
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  bool _isValidUrl(String url) {
    // Expresión regular para validar una URL que comience con "https://"
    final RegExp urlRegExp = RegExp(r'^https://[^\s]+');

    return urlRegExp.hasMatch(url);
  }
}
