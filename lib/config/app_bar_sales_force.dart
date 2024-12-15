
import 'package:flutter/material.dart';


class AppBars extends StatelessWidget {

  final String labelText;
  const AppBars({
    super.key,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(170),
      child: ClipRRect(
      
        child: GestureDetector(
         
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          
          child: AppBar(
            elevation:  0,
              leading: IconButton(
          icon: Image.asset('lib/assets/Atras@3x.png', width: 25, height: 25, color: Colors.black, ), // Reemplaza 'tu_imagen.png' con la ruta de tu imagen en los assets
          onPressed: () {
            // Acción al presionar el botón de flecha hacia atrás
            Navigator.pop(context);
          },
        ),
            backgroundColor: const Color.fromARGB(255, 227, 245, 235), 
            flexibleSpace: Stack(
              children: [
               
                 Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          labelText,
                          style: const TextStyle(
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}