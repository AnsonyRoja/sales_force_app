import 'package:flutter/material.dart';
import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/presentation/products/utils/switch_generated_names_select.dart';




class CustomerDetailsSalesOrders extends StatefulWidget {
  final String clientName;
  final String rucCbpartner;
  final String emailCustomer;
  final String phoneCustomer;
  final dynamic cBPartnerId;
  final List<Map<String, dynamic>>? namePriceList;
  final TextEditingController numeroReferenciaController;
  final TextEditingController fechaController;
  final TextEditingController descripcionController;
  final Future<void> Function(BuildContext) selectDate;
  final Function(Map, int) onAddressCustomerChanged; 
  final Function(Map, int) onWareHouseChanged; 
  

  

  const CustomerDetailsSalesOrders({super.key, required this.cBPartnerId ,required this.clientName, required this.rucCbpartner, required this.emailCustomer,
  required this.phoneCustomer, required this.namePriceList, required  this.numeroReferenciaController, required this.fechaController,
  required this.descripcionController, required this.selectDate, required this.onAddressCustomerChanged, required this.onWareHouseChanged});

  @override
  State<CustomerDetailsSalesOrders> createState() => _CustomerDetailsSalesOrdersState();
}

class _CustomerDetailsSalesOrdersState extends State<CustomerDetailsSalesOrders> {

  //Listas 

    final List<Map<String, dynamic>> _addressCustomerGroupList = [];
    final List<Map<String, dynamic>> _wareHouseList = [];
    int adOrgID = 0; 

  //Select ID 

  int _selectedBPartnerLocationId = 0;
  int _selectedMWareHouseId = 0; 

  // STRING

  Map _addressCustomerNameText = {};
  String _wareHouseText = '';


    void _loadSelectData() async {

        List<Map< String, dynamic>> address = await getClientAddresses(widget.cBPartnerId);
        List<Map< String, dynamic>> getWareHouse = await getAllWareHouse();

    print("Esto es address $address");
   print('Esto es el wareHouse $getWareHouse');

    _addressCustomerGroupList.add({'c_bpartner_location_id': 0, 'name': 'Dirección'});
    _wareHouseList.add({'m_warehouse_id': 0, 'name': 'Almacén'});



    setState(() {
      _addressCustomerGroupList.addAll(address);
      _wareHouseList.addAll(getWareHouse);
      
    });

  }


@override
void initState() {
  _loadSelectData();

  super.initState();
  
}


  
  @override
  Widget build(BuildContext context) {
  final mediaScreen = MediaQuery.of(context).size.width * 0.8;


    return   Column(
                    children: [
                      SizedBox(
                        height: mediaScreen * 0.05,
                      ),
                    SizedBox(
                      width: mediaScreen,
                      child: const Text(
                        "Datos del Cliente",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins Bold',
                            fontSize: 18),
                      ),
                    ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.9,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 7,
                              spreadRadius: 2,
                              color: Colors.grey.withOpacity(0.5))
                        ]),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: mediaScreen * 0.5,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nombre',
                                        style: TextStyle(
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 18),
                                      ),
                                      Text(widget.clientName.length > 25
                                          ? widget.clientName.substring(0, 25)
                                          : widget.clientName)
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: mediaScreen * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'RIF/CI',
                                        style: TextStyle(
                                            fontFamily: 'Poppins Bold',
                                            fontSize: 18),
                                      ),
                                      Text(widget.rucCbpartner.length > 15
                                          ? widget.rucCbpartner.substring(0, 15)
                                          : (widget.rucCbpartner ==
                                                  '{@nil: true}'
                                              ? ''
                                              : widget.rucCbpartner)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            width: mediaScreen,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Detalles',
                                style: TextStyle(
                                    fontFamily: 'Poppins Bold', fontSize: 18),
                                textAlign: TextAlign.start,
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Correo: ',
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                              Text(
                                widget.emailCustomer == '{@nil: true}'
                                    ? ''
                                    : widget.emailCustomer,
                                style: const TextStyle(
                                    fontFamily: 'Poppins Regular'),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Telefono: ',
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                              Text(
                                widget.phoneCustomer == '{@nil: true}'
                                    ? ''
                                    : widget.phoneCustomer,
                                style: const TextStyle(
                                    fontFamily: 'Poppins Regular'),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lista de precio: ',
                                style:
                                    TextStyle(fontFamily: 'Poppins SemiBold'),
                              ),
                              Text(widget.namePriceList != null &&
                                widget.namePriceList!.isNotEmpty
                                    ? widget.namePriceList![0]['price_list_name']
                                        .toString()
                                    : "",
                                style: const TextStyle(
                                    fontFamily: 'Poppins Regular'),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.08,
                  ),
                  SizedBox(
                    width: mediaScreen,
                    child: const Text(
                      "Detalles de Orden",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins Bold',
                          fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: TextField(
                      readOnly: true,
                      controller: widget.numeroReferenciaController,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(
                            fontFamily: 'Poppins Regular', color: Colors.black),
                        labelText: 'Orden N°',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide.none, // Color del borde
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando está enfocado
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando no está enfocado
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: TextField(
                      controller: widget.fechaController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide.none, // Color del borde
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando está enfocado
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando no está enfocado
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide:
                                const BorderSide(width: 1, color: Colors.red)),
                        labelText: 'Fecha',
                        labelStyle: const TextStyle(
                            fontFamily: 'Poppins Regular', color: Colors.black),
                        suffixIcon: IconButton(
                          onPressed: () => widget.selectDate(context),
                          icon: Image.asset('lib/assets/Calendario.png'),
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),

                    Container(
                      height: mediaScreen * 0.22,
                      width: mediaScreen,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2,
                            )
                          ]),
                      child: DropdownButtonFormField<int>(
                        icon: Image.asset('lib/assets/Abajo.png'),
                        value: _selectedMWareHouseId,
                        items: _wareHouseList
                            .where((wareHouse) => wareHouse['m_warehouse_id'] is int)
                            .map<DropdownMenuItem<int>>((wareHouse) {
                          return DropdownMenuItem<int>(
                            value: wareHouse['m_warehouse_id'] as int,
                            child: SizedBox(
                                width: mediaScreen * 0.7,
                                child: Text(
                                  wareHouse['m_warehouse_id'] != 0 ? '${wareHouse['value'].toString()} -' ' ${ wareHouse['name']}': wareHouse['name'].toString() ,
                                  style: const TextStyle(
                                      overflow: TextOverflow.clip,
                                      fontFamily: 'Poppins Regular', fontSize: 13),
                                )),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          Map nameWareHouse = invoke(
                              'obtenerNombreWareHouse',
                              newValue,
                              _wareHouseList);
                            print('Esto es el nombre del almacen $nameWareHouse');
                          setState(() {
                            _wareHouseText = nameWareHouse['wareHouseName'];
                            _selectedMWareHouseId = newValue as int;
                          });

                           widget.onWareHouseChanged(nameWareHouse, _selectedMWareHouseId);
                        },
                        decoration: InputDecoration(
                          errorStyle:
                              const TextStyle(fontFamily: 'Poppins Regular'),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Set desired border radius
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Maintain border radius on focus
                            borderSide: BorderSide
                                .none, // Change border color and thickness on focus (optional)
                          ),
                        ),
                        // validator: (value) {
                        //   if (value == null || value == 0) {
                        //     return 'Por favor, seleccione un Almacen.';
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                   Container(
                      height: mediaScreen * 0.22,
                      width: mediaScreen,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2,
                            )
                          ]),
                      child: DropdownButtonFormField<int>(
                        icon: Image.asset('lib/assets/Abajo.png'),
                        value: _selectedBPartnerLocationId,
                        items: _addressCustomerGroupList
                            .where((address) => address['c_bpartner_location_id'] is int)
                            .map<DropdownMenuItem<int>>((addressCustomer) {
                          return DropdownMenuItem<int>(
                            value: addressCustomer['c_bpartner_location_id'] as int,
                            child: SizedBox(
                                width: mediaScreen * 0.7,
                                child: Text(
                                  addressCustomer['name'] as String,
                                  style: const TextStyle(
                                      overflow: TextOverflow.clip,
                                      fontFamily: 'Poppins Regular'),
                                )),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          Map nombreAddressCustomer = invoke(
                              'obtenerNombreAddressCustomer',
                              newValue,
                              _addressCustomerGroupList);

                          setState(() {
                            _addressCustomerNameText = nombreAddressCustomer;
                            _selectedBPartnerLocationId = newValue as int;
                          });

                           widget.onAddressCustomerChanged(_addressCustomerNameText, _selectedBPartnerLocationId);
                        },
                        decoration: InputDecoration(
                          errorStyle:
                              const TextStyle(fontFamily: 'Poppins Regular'),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Set desired border radius
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Maintain border radius on focus
                            borderSide: BorderSide
                                .none, // Change border color and thickness on focus (optional)
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value == 0) {
                            return 'Por favor, seleccione una dirección.';
                          }
                          return null;
                        },
                      ),
                    ),
                  SizedBox(
                    height: mediaScreen * 0.05,
                  ),
                  Container(
                    width: mediaScreen,
                    height: mediaScreen * 0.28,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 7,
                              spreadRadius: 2)
                        ]),
                    child: TextField(
                      maxLines: 2,
                      controller: widget.descripcionController,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(
                            fontFamily: 'Poppins Regular', color: Colors.black),
                        labelText: 'Descripción',
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide.none, // Color del borde
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando está enfocado
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 25,
                          ), // Color del borde cuando no está enfocado
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: mediaScreen * 0.08,
                  ),
                    ],
                  );
  }
}












