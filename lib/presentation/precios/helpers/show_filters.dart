import 'dart:async';

import 'package:flutter/material.dart';

 showFilterOptions(BuildContext context, products) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    Completer<dynamic> completer = Completer<dynamic>();



  showMenu(
    shape: RoundedRectangleBorder( // Redondear los bordes del menú emergente
        borderRadius: BorderRadius.circular(15), 
        side: BorderSide(
  width: 5,
  color: Colors.grey.withOpacity(0.5), // Establece el color transparente como punto inicial del gradiente
        )
      ),
    elevation: 0,
    shadowColor: Colors.black,
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(
        const Offset(20, 380), // Punto de inicio en la esquina superior izquierda
        const Offset(150, 240), // Punto de fin en la esquina superior izquierda
      ),
      overlay.localToGlobal(Offset.zero) & overlay.size, // Tamaño del overlay
    ),
    items: <PopupMenuEntry>[
      
      PopupMenuItem(
          
          child: ListTile(
          title:   Padding(
            padding: const EdgeInsets.all(8.0),
            child:  Row(
              children: [
                Image.asset('lib/assets/Check@3x.png', width: 25,
                  color: const Color(0xFF00722D),
                ),
                SizedBox(width: MediaQuery.of(context).size.width *0.02,),
                const Text('Filtrar por mayor precio', style: TextStyle(fontFamily: 'Poppins Regular',),),
              ],
            ),
          ),
          onTap: ()  {
            Navigator.pop(context);
            completer.complete(_filterByMaxPrice(products));

          },
                  ),
      ),
      PopupMenuItem(
        child: ListTile(
          title:  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset('lib/assets/Check@3x.png', width: 25, color: const Color(0xFF00722D),),
                SizedBox(width: MediaQuery.of(context).size.width *0.02,),
                const Text('Filtrar por menor precio', style: TextStyle(fontFamily: 'Poppins Regular') ,),
              ],
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            completer.complete(_filterByMinPrice(products));
          },
        ),
      ),
       PopupMenuItem(
        child: ListTile(
          title:  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.asset('lib/assets/Check@3x.png', width: 25,color: const Color(0xFF00722D),),
                SizedBox(width: MediaQuery.of(context).size.width *0.02,),
                SizedBox(
                  width: 160,
                  child: const Text('Ordenar por mas el vendido', style: TextStyle(fontFamily: 'Poppins Regular'), overflow: TextOverflow.clip,)),
              ],
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            completer.complete(_filterByMostSold(products));
          
          },
        ),
      ),
    ],
    color: Colors.white
  );

  
  
return completer.future;
  
}





 _filterByMaxPrice(products) {
  List<Map<String, dynamic>> sortedProducts = List.from(products); // Crear una nueva lista para evitar modificar la original
  print('Sorted Products $sortedProducts');
  sortedProducts.sort((a, b) {
    // Parsea los valores de price a double antes de compararlos
    double priceA = double.tryParse(a['pricelistsales'].toString()) ?? 0.0;
    double priceB = double.tryParse(b['pricelistsales'].toString()) ?? 0.0;
    return priceB.compareTo(priceA); // Ordena de forma descendente por precio
  });

    products = sortedProducts; // Actualiza la lista original con la lista ordenada

  return products;
}



  _filterByMinPrice(products) {
  List<Map<String, dynamic>> sortedProducts = List.from(products); // Crear una nueva lista para evitar modificar la original
  sortedProducts.sort((a, b) {

    double priceA = double.tryParse(a['pricelistsales'].toString()) ?? 0.0;
    double priceB = double.tryParse(b['pricelistsales'].toString()) ?? 0.0;


    return priceA.compareTo(priceB);

  }); // Ordena de forma ascendente por precio

    products = sortedProducts; // Actualiza la lista original con la lista ordenada
  
  return products;
}

 _filterByMostSold(products) {
  List<Map<String, dynamic>> sortedProducts = List.from(products);
  sortedProducts.sort((a, b) => b['quantity_sold'].compareTo(a['quantity_sold']));
  
    products = sortedProducts;
  return products;
}
