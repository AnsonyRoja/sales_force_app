import 'package:flutter/material.dart';
import 'package:sales_force/database/gets_database.dart'; // Asegúrate de que el archivo esté en el path correcto

void showFilterOptionsCobros(
  BuildContext context,
  double screenMax,
  Future<List<Map<String, dynamic>>> cobrosFuture,
  List<Map<String, dynamic>> cobros,
  List<Map<String, dynamic>> filteredCobros,
  List<Map<String, dynamic>> filteredCobroCopy,
  Function setState,
  int pageSize,
  Function showMaxPriceDialog,
  Function showDateRangePicker,
) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  showMenu(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          width: 5,
          color: Colors.grey.withOpacity(0.5),
        )),
    elevation: 2,
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromPoints(
        const Offset(20, 180),
        const Offset(175, 240),
      ),
      overlay.localToGlobal(Offset.zero) & overlay.size,
    ),
    items: <PopupMenuEntry>[
      PopupMenuItem(
        child: ListTile(
          title: Row(
            children: [
              Image.asset(
                'lib/assets/Check@3x.png',
                width: 25,
                color: const Color(0XFF00722D),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              const Text(
                'Mostrar Todos',
                style: TextStyle(fontFamily: 'Poppins Regular'),
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            cobrosFuture = getCobros(page: cobros.length ~/ pageSize + 1, pageSize: pageSize);
            cobrosFuture.then((data) {
              setState(() {
                cobros = data;
                filteredCobros = cobros;
                filteredCobroCopy = cobros;
              });
            });
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          title: Row(
            children: [
              Icon(Icons.attach_money, color: const Color(0XFF00722D)),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              const Text(
                'Filtrar Por el monto Mayor',
                style: TextStyle(fontFamily: 'Poppins Regular'),
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            showMaxPriceDialog(context, screenMax);
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          title: Row(
            children: [
              Image.asset(
                'lib/assets/Calendario.png',
                width: 25,
                color: const Color(0XFF00722D),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.02,
              ),
              SizedBox(
                width: 180,
                child: const Text(
                  'Ordenar por un rango de fecha',
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            showDateRangePicker(context);
          },
        ),
      ),
    ],
  );
}
