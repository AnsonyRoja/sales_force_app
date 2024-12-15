import 'package:flutter/material.dart';
import 'package:sales_force/sincronization/config/clear_db.dart';

class EmptyDatabase extends StatelessWidget {
  const EmptyDatabase({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
            onPressed: () async {
     bool? confirm = await showDialog<bool>(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)) ,
           title: Text('Confirmación'),
           content: Text('¿Está seguro de que desea vaciar la base de datos?'),
           actions: <Widget>[
             TextButton(
               onPressed: () {
                 Navigator.of(context).pop(false); // Cierra el diálogo y devuelve false
               },
               child: Text('Cancelar', style: TextStyle(fontFamily: 'Poppins Regular')),
             ),
             TextButton(
               onPressed: () {
                 Navigator.of(context).pop(true); // Cierra el diálogo y devuelve true
               },
               child: Text('Confirmar', style: TextStyle(fontFamily: 'Poppins Bold')),
             ),
           ],
         );
       },
     );
    
     if (confirm == true) {
   
       await clearDatabase();
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Base de datos vaciada', style: TextStyle(fontFamily: 'Poppins Regular'))),
       );
     }
            },
            child: Text('Vaciar Base de Datos', style: TextStyle(fontFamily: 'Poppins Bold')),
          );
  }
}
