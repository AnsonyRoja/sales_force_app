import 'package:flutter/material.dart';
import 'package:sales_force/assets/nav_bar_bottom.dart';
import 'package:sales_force/config/banner_app_gss.dart';
import 'package:sales_force/config/fields_perfil.dart';
import 'package:sales_force/infrastructure/models/info_perfil.dart';
import 'package:sales_force/presentation/perfil/perfil_http.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:sales_force/presentation/screen/login/login_success.dart';
import 'package:sales_force/presentation/screen/login/progress_indicator.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  _PerfilState createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  InfPerfil? perfilData;
  final authenticated = AuthenticationService();
  bool redirect = false;
  bool login = false;
  bool showErrorMes = false;
  bool? token;
  CirclePainterGss? painter;

  Future<void> _loadPainter() async {
    final loadedPainter = await CirclePainterGss.load();
    setState(() {
      painter = loadedPainter;
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerPerfil();
    _loadPainter();
  }

  Future<void> obtenerPerfil() async {
    final user = await getLogin();

    while (perfilData == null) {
      print('esto es usuario $user');
      final inf =
          await infoP(username: user['user'], password: user['password']);
      print('esto es informacion $inf');

      if (inf == 'hay problemas con el internet' && user['auth'] == true) {
        setState(() {
          showErrorMes = true;
        });
      }

      if (inf == 'hay problemas con el internet' && user['auth'] == false) {
        setState(() {
          login = true;
        });
      }

      if (user['auth'] == false) {
        setState(() {
          login = true;
        });
      }

      if (inf == "La URL está mal escrita." && user['auth'] == false) {
        setState(() {
          redirect = true;
        });
      }
      if (inf["Error"] == "Error login - User invalid" &&
          user['auth'] == false) {
        setState(() {
          login = true;
        });
      }
      setState(() {
        perfilData = inf != null ? InfPerfil.fromJsonMap(inf) : null;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    print("esto es perfilData ${perfilData}");
  }

  @override
  Widget build(BuildContext context) {
    if (redirect) {
      authenticated.logout();
      Future.delayed(Duration.zero, () {
        setState(() {
          redirect = false;
        });
        Navigator.pushReplacementNamed(context, '/configuracion');
      });
    } else if (login) {
      authenticated.logout();
      Future.delayed(Duration.zero).then((_) {
        setState(() {
          login = false;
        });
        Navigator.pushReplacementNamed(context, '/');
      });
    }

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 227, 245, 235),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140), // Altura del AppBar
        child: painter == null
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                ),
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircularProgressIndicator()),
              )
            : ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(0), // Radio del borde redondeado
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
                      const Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 50,
                              left: 40), // Ajuste de la posición vertical
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 0),
                                child: Text(
                                  'Perfil',
                                  style: TextStyle(
                                    fontFamily: 'Poppins Bold',
                                    color: Colors.black,
                                    fontSize: 35, // Tamaño del texto
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color.fromARGB(
                      255, 227, 245, 235), // Color hexadecimal
                ),
              ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                      15.0), // Ajusta el valor según sea necesario
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.1), // Color y opacidad de la sombra
                      blurRadius: 10, // Radio de difuminado de la sombra
                      offset: const Offset(0, 5), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: perfilData != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                              width: 115,
                              height: 115,
                              alignment: Alignment
                                  .centerLeft, // Alinea el contenido a la izquierda

                              child: Image.asset('lib/assets/foto_grandep.png',
                                  height: 85,
                                  width: 85,
                                  color: const Color.fromRGBO(0, 0, 0, 0.5)),
                            ),
                          ),
                          if (perfilData != null)
                            Fields(
                                value: perfilData!.name,
                                heights: 5,
                                field: 'Usuario'),
                          if (perfilData != null)
                            Fields(
                                value: perfilData!.email,
                                heights: 5,
                                field: 'Correo electrónico'),
                          if (perfilData != null)
                            Fields(
                                value: perfilData!.phone,
                                heights: 5,
                                field: 'Teléfono'),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
            if (perfilData == null)
              showErrorMes
                  ? const Text(
                      'Error de conexión a Internet',
                      style: TextStyle(color: Colors.red),
                    )
                  : CustomProgressIndicator(),
            GestureDetector(
              onTap: () async {
                setState(() {
                  flag = true;
                  isSelected = true;
                  perfilIsSelected = false;
                  infoIsSelected = false;
                });

                authenticated.logout();

                await Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/Cerrar_Sesión.png',
                      width: 25,
                      height: 25,
                    ),
                    const SizedBox(
                        width:
                            5), // Espacio entre el icono y el texto (puedes eliminarlo si no lo necesitas
                    const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Color(
                            0xFFEC2641), // Puedes ajustar el color del texto según tus necesidades
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarBottom(),
    );
  }
}
