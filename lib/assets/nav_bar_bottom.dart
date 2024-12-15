import 'package:flutter/material.dart';

    bool isSelected = true;
    bool perfilIsSelected = false;
    bool infoIsSelected = false;
class NavBarBottom extends StatefulWidget {
  const NavBarBottom({super.key});

  @override
  State<NavBarBottom> createState() => _NavBarBottomState();
}

class _NavBarBottomState extends State<NavBarBottom> {

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
     
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2), // Color y opacidad de la sombra
          blurRadius: 10, // Radio de difuminado de la sombra
          offset: const Offset(0, -3),
        )
        
      ],
      color: Colors.white,
      ),
      child: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Para distribuir los iconos equitativamente
          children: [
                  
                   GestureDetector(
                      onTap: () async {
                        setState(() {
                            infoIsSelected = false;
                            isSelected = false;
                            perfilIsSelected = true;
                        });
                        await Navigator.pushReplacementNamed(context, '/perfil');
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => const Perfil()));
                      },
                      child: Container(
                        width: 40,
                        height: 50,
                        decoration: BoxDecoration(
                        color: perfilIsSelected ? const Color.fromARGB(23, 0, 217, 255) : Colors.transparent,
                        borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Image.asset(
                          'lib/assets/foto_grandep.png', // Ruta a tu imagen
                          width: 40.0, // Ajusta el ancho según tus necesidades
                          height: 40.0, // Ajusta la altura según tus necesidades
                          color: perfilIsSelected ? colors.primary : null,

                        ),
                      ),
                    ),


              GestureDetector(
                        onTap: () async {
                          setState(() {
                              
                              isSelected = true;
                              perfilIsSelected = false;
                              infoIsSelected = false;
                          });
                        
                          await Navigator.pushReplacementNamed(context, '/home');
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
                        },
                        child: Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                          color: isSelected ? const  Color.fromARGB(23, 0, 217, 255) : Colors.transparent,
                          borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Image.asset(
                            'lib/assets/Home.png', // Ruta a tu imagen
                            width: 10.0, // Ajusta el ancho según tus necesidades
                            height: 15.0, // Ajusta la altura según tus necesidades
                            color: isSelected ? colors.primary : null,
                          ),
                        ),
                      ),


       GestureDetector(
  onTap: () async {
     setState(() {
                            infoIsSelected = true;
                            isSelected = false;
                            perfilIsSelected = false;
                        });
    await Navigator.pushReplacementNamed(context, '/informacion');
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const Informacion()));
  },
  child: Container(
        width: 40,
        height: 50,
        decoration: BoxDecoration(
        color: infoIsSelected ?  const Color.fromARGB(23, 0, 217, 255) : Colors.transparent,
        borderRadius: BorderRadius.circular(5.0),
        ),
    child: Image.asset(
      'lib/assets/info.png', // Ruta a tu imagen
      width: 24.0, // Ajusta el ancho según tus necesidades
      height: 24.0, // Ajusta la altura según tus necesidades
      color: infoIsSelected ? colors.primary : null,
      
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
