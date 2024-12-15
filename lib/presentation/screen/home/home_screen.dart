import 'package:flutter/widgets.dart';
import 'package:sales_force/assets/nav_bar_bottom.dart';
import 'package:sales_force/config/banner_app_gss.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/infrastructure/models/info_perfil.dart';
import 'package:sales_force/presentation/cobranzas/cobranzas_list.dart';
import 'package:sales_force/presentation/clients/clients_screen.dart';
import 'package:sales_force/presentation/precios/precios.dart';
import 'package:sales_force/presentation/screen/login/progress_indicator.dart';
import 'package:sales_force/presentation/screen/ventas/ventas.dart';
import 'package:sales_force/presentation/screen/visits/visits_screen.dart';
import 'package:sales_force/sincronization/sincronization_screen.dart';
import 'package:flutter/material.dart';

bool flag = false;
bool processingApproval = false;
bool actualizando = false;
String mensaje = '';
InfPerfil? perfilData;
List<Map<dynamic, dynamic>> variablesG = [];

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  final scrollController = ScrollController();
  String selectedOperationType = 'Todos';
  bool primeraActualizacion = true;
  bool closeScreen = false;
  var showErrorCon = false;
  String messageErrorCon = "Hay problemas de conexion";
  String mensajeSuc = "Se ha Aprobado correctamente";

  CirclePainterGss? painter;

  Future<void> _loadPainter() async {
    final loadedPainter = await CirclePainterGss.load();
    setState(() {
      painter = loadedPainter;
    });
  }




  @override
  void initState() {
    DatabaseHelper.instance.initDatabase();
    _loadPainter();

    print('Esto es la variable global de country_id ${variablesG}');
    super.initState();
    print("me monte");
  }

  @override
  void dispose() {
    print("me desmonte");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.85;

    if (closeScreen == false) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 227, 245, 235),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140), // Altura del AppBar
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50), // Radio del borde redondeado
            ),
            child: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: Stack(
                children: [
                  CustomPaint(
                    size: Size.infinite,
                    painter: painter,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 50,
                          left: 40), // Ajuste de la posición vertical
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 0),
                            child: Container(
                              margin: const EdgeInsets.only(top: 55),
                              child: const Text(
                                'Inicio',
                                style: TextStyle(
                                  fontFamily: 'Poppins ExtraBold',
                                  color: Colors.black,
                                  fontSize: 30, // Tamaño del texto
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 3.0,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor:
                  const Color.fromARGB(255, 227, 245, 235), // Color hexadecimal
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: mediaScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Clients(),
                              ));
                        },
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    spreadRadius: 2)
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          20), // Establece bordes redondeados
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'lib/assets/clientes@3x.png',
                                        width: 45,
                                        height: 45,
                                        fit: BoxFit.contain,
                                        color: const Color(0XFF00722D),
                                      ),
                                    )),
                                const Text(
                                  "Clientes",
                                  style:
                                      TextStyle(fontFamily: 'Poppins SemiBold'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Precios(),
                              ));
                        },
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    spreadRadius: 2)
                              ]),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          20), // Establece bordes redondeados
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        'lib/assets/Precios@3x.png',
                                        width: 45,
                                        height: 45,
                                        fit: BoxFit.contain,
                                        color: const Color(0XFF00722D),
                                      ),
                                    )),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Precios",
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Ventas(),
                              ));
                        },
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    spreadRadius: 2)
                              ]),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          20), // Establece bordes redondeados
                                    ),
                                    child: Center(
                                        child: Image.asset(
                                      'lib/assets/Ventas@3x.png',
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.contain,
                                      color: const Color(0XFF00722D),
                                    ))),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Ventas",
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Cobranzas(),
                              ));
                        },
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    spreadRadius: 2)
                              ]),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          20), // Establece bordes redondeados
                                    ),
                                    child: Center(
                                        child: Image.asset(
                                      'lib/assets/Cobranzas@3x.png',
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.contain,
                                      color: const Color(0XFF00722D),
                                    ))),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Cobranzas",
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VisitsScreen(),
                              ));
                        },
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    spreadRadius: 2)
                              ]),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          20), // Establece bordes redondeados
                                    ),
                                    child: Center(
                                        child: Image.asset(
                                      'lib/assets/Grupo 98@2x.png',
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.contain,
                                      color: const Color(0XFF00722D),
                                    ))),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Ruta de Clientes",
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SynchronizationScreen(),
                              ));
                        },
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 7,
                                    spreadRadius: 2)
                              ]),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          20), // Establece bordes redondeados
                                    ),
                                    child: Center(
                                        child: Image.asset(
                                      'lib/assets/Sincro@3x.png',
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.contain,
                                      color: const Color(0XFF00722D),
                                    ))),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "Sincronización",
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ),
            )),
        bottomNavigationBar: const NavBarBottom(),
      );
    } else {
      // authenticated.logout();
      // return const Configuracion();
      return CustomProgressIndicator();
    }
  }

  // _showFilterOptions(BuildContext context) {
  //   showFilterOptions(context, documentosPorTipo, selectedOperationType,
  //       (String selectedValue) {
  //     if (mounted) {
  //       setState(() {
  //         selectedOperationType = selectedValue;
  //       });
  //     }
  //   });
  // }
}
