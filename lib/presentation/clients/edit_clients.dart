import 'package:sales_force/config/app_bar_sampler.dart';
import 'package:sales_force/database/list_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/presentation/clients/select_customer.dart';
import 'package:flutter/material.dart';

class EditClientScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const EditClientScreen({super.key, required this.client});

  @override
  _EditClientScreenState createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _nameController = TextEditingController();
  final _rucController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _cityController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BuildContext? currentContext;
  //List
  List<Map<String, dynamic>> _countryList = [];
  List<Map<String, dynamic>> _groupList = [];
  List<Map<String, dynamic>> _taxTypeList = [];
  List<Map<String, dynamic>> _taxPayerList = [];
  List<Map<String, dynamic>> _typePersonList = [];

  // SELECTED
  int _selectedCountryIndex = 0;
  int _selectedGroupIndex = 0;
  int _selectedTaxType = 0;
  int _selectedTaxPayer = 0;
  int _seletectedTypePerson = 0;
// Text

  String _countryText = '';
  String _groupText = '';
  String _taxTypeText = '';
  String _taxPayerText = '';
  String _typePersonText = '';
  

  loadList() async {
    List<Map<String, dynamic>> getCountryGroup = await listarCountryGroup();
    List<Map<String, dynamic>> getGroupTercero = await listarGroupTercero();
    List<Map<String, dynamic>> getTaxType = await listarTaxType();
    List<Map<String, dynamic>> getTaxPayer = await listarTaxPayer();
    
    // List<Map<String, dynamic>> getTypePerson = await listarTypePerson();
    print('Esta es la respuesta $getCountryGroup');
    print('Esta es la respuesta de getGroupTercero $getGroupTercero');
    print('Esto es getTaxType $getTaxType');
    print('Estos son los taxPayers $getTaxPayer');
    // print('Estos son los type person $getTypePerson');

    _countryList.add({'c_country_id': 0, 'country': 'Selecciona un País'});
    _groupList
        .add({'c_bp_group_id': 0, 'group_bp_name': 'Selecciona un Grupo'});
    _taxTypeList.add({
      'lco_tax_id_typeid': 0,
      'tax_id_type_name': 'Selecciona un tipo de impuesto'
    });
    _taxPayerList.add({
      'lco_tax_payer_typeid': 0,
      'tax_payer_type_name': 'Selecciona un tipo de contribuyente'
    });
    // _typePersonList.add({
    //   'lve_person_type_id': 0,
    //   'person_type_name': 'Selecciona un tipo de Persona'
    // });

    setState(() {
      _countryList.addAll(getCountryGroup);
      _groupList.addAll(getGroupTercero);
      _taxTypeList.addAll(getTaxType);
      _taxPayerList.addAll(getTaxPayer);
      // _typePersonList.addAll(getTypePerson);
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product details
    print("this client ${widget.client}");
    
    loadList();
    _selectedCountryIndex = widget.client['c_country_id'] != '{@nil=true}' ? widget.client['c_country_id'] : 0 ;
    _countryText = widget.client['country'] != '{@nil=true}' ? widget.client['country'] : '' ;
    // _seletectedTypePerson = widget.client['lve_person_type_id'];
    // _typePersonText = widget.client['person_type_name'].toString();
    _selectedTaxPayer = widget.client['lco_tax_payer_typeid'] != '{@nil=true}' ?  widget.client['lco_tax_payer_typeid']:0;
    _taxPayerText = widget.client['tax_payer_type_name'].toString() != '{@nil=true}' ? widget.client['tax_payer_type_name'].toString() : '';
    _selectedGroupIndex = widget.client['c_bp_group_id'];
    _groupText = widget.client['group_bp_name'].toString();
    _selectedTaxType = widget.client['lco_tax_id_typeid'];
    _taxTypeText = widget.client['tax_id_type_name'].toString();
    _nameController.text = widget.client['bp_name'].toString();
    _rucController.text = widget.client['ruc'].toString();
    _correoController.text = widget.client['email'].toString() == '{@nil: true}' ? '' : widget.client['email'].toString();
    _telefonoController.text = widget.client['phone'].toString() == '{@nil: true}' ? '' : widget.client['phone'].toString();
    _direccionController.text = widget.client['address'].toString() == '{@nil: true}' ? '' : widget.client['address'].toString();
    _cityController.text = widget.client['city'].toString() == '{@nil: true}' ? '' : widget.client['city'].toString();
    _codePostalController.text = widget.client['code_postal'].toString() == '{@nil=true}' ? '' : widget.client['code_postal'].toString();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width *0.8;
  
    setState(() {
      
     currentContext = context;
    });
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 227, 245, 235),
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBarSample(label: 'Editar Cliente'))  ,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Align(
              alignment: Alignment.center ,
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SizedBox(
                  width: mediaScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 05),
                      SizedBox(
                          width: mediaScreen * 0.95,
                          child: const Text(
                            "Datos del Cliente",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18),
                            
                          ),
                        ),
                        const SizedBox(height: 10,),
                      _buildTextFormField('Nombre', _nameController,1, mediaScreen, false),
                      _buildTextFormField('Ruc', _rucController, 1, mediaScreen, false),
                      _buildTextFormField('Correo', _correoController, 1, mediaScreen, false),
                      _buildTextFormField('Telefono', _telefonoController, 1, mediaScreen, false),
                        const SizedBox(height: 10,),

                      CustomDropdownButtonFormField(
                        identifier: 'groupBp',
                        selectedIndex: _selectedGroupIndex,
                        dataList: _groupList,
                        text: _groupText,
                        onSelected: (newValue, groupText) {
                          setState(() {
                            _selectedGroupIndex = newValue ?? 0;
                            _groupText = groupText;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomDropdownButtonFormField(
                        identifier: 'taxType',
                        selectedIndex: _selectedTaxType,
                        dataList: _taxTypeList,
                        text: _taxTypeText,
                        onSelected: (newValue, taxTypeText) {
                          setState(() {
                            _selectedTaxType = newValue ?? 0;
                            _taxTypeText = taxTypeText;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomDropdownButtonFormField(
                        identifier: 'taxPayer',
                        selectedIndex: _selectedTaxPayer,
                        dataList: _taxPayerList,
                        text: _taxPayerText,
                        onSelected: (newValue, taxPayerText) {
                          setState(() {
                            _selectedTaxPayer = newValue ?? 0;
                            _taxPayerText = taxPayerText;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      // CustomDropdownButtonFormField(
                      //   identifier: 'typePerson',
                      //   selectedIndex: _seletectedTypePerson,
                      //   dataList: _typePersonList,
                      //   text: _typePersonText,
                      //   onSelected: (newValue, tyPersonText) {
                      //     setState(() {
                      //       _seletectedTypePerson = newValue ?? 0;
                      //       _typePersonText = tyPersonText;
                      //     });
                      //   },
                      // ),
                      const SizedBox(height: 10,),
                         SizedBox(
                          width: mediaScreen * 0.95,
                          child: const Text(
                            "Domicilio Fiscal",
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.black, fontFamily: 'Poppins Bold', fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        CustomDropdownButtonFormField(identifier: 'selectCountry', selectedIndex: _selectedCountryIndex, dataList: _countryList, text: _countryText, onSelected: (newValue, countryTex) {
                            setState(() {
                              _selectedCountryIndex = newValue ?? 0;
                              _countryText = countryTex;
                            });
                        },),
                      const SizedBox(height: 10,),
                    _buildTextFormField('Dirección', _direccionController, 2, mediaScreen, true),
                    _buildTextFormField('Ciudad', _cityController, 1, mediaScreen, false),
                    _buildTextFormField('Codigo Postal', _codePostalController, 1, mediaScreen, false),
                     Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Container(
                        
                        decoration: BoxDecoration(
                          
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 7,
                                  spreadRadius: 2)
                            ]),
                        width: mediaScreen * 0.95,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {

                                   String newName = _nameController.text;
                                    dynamic newRuc = _rucController.text;
                                    String newCorreo = _correoController.text;
                                    dynamic newTelefono = _telefonoController.text;
                                    String newGrupo = _groupText;
                                    String taxType = _taxTypeText;
                                    String taxPayer = _taxPayerText;
                                    String personType = _typePersonText;
                                    String newDireccion = _direccionController.text;
                                    String newCity = _cityController.text;
                                    String newCode = _codePostalController.text;


            int selectedGroupId = _selectedGroupIndex;
            int selectedTaxId = _selectedTaxType;
            int selectedTaxPayerId = _selectedTaxPayer;
            int selectedPersonType = _seletectedTypePerson;
            // Crear un mapa con los datos actualizados del producto
            Map<String, dynamic> updatedClient = {
              'id': widget
                  .client['id'], // Asegúrate de incluir el ID del producto
              'bp_name': newName,
              'ruc': newRuc,
              'email': newCorreo,
              'phone': newTelefono,
              'c_bp_group_id': selectedGroupId,
              'group_bp_name': newGrupo,
              'lco_tax_id_typeid': selectedTaxId,
              'tax_id_type_name': taxType,
              'lco_tax_payer_typeid': selectedTaxPayerId,
              'tax_payer_type_name': taxPayer,
              'lve_person_type_id': selectedPersonType,
              'person_type_name': personType,
              'address': newDireccion,
              'city':newCity,
              'code_postal': newCode,
            };

            // Actualizar el producto en la base de datos
            await updateClient(updatedClient);

                               showDialog(
                              context: currentContext!,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 20),
                                  backgroundColor: Colors.white,
                                  // Center the title, content, and actions using a Column
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize
                                        .min, // Wrap content vertically
                                    children: [
                                      Image.asset('lib/assets/Check@2x.png',
                                          width: 50,
                                          height:
                                              50), // Adjust width and height
                                      const Text('Cliente Actualizado',
                                          style: TextStyle(
                                              fontFamily: 'Poppins Bold')),
                                      TextButton(
                                        onPressed: () => {
                                          Navigator.pop(context),
                                          Navigator.pop(context),
                                          Navigator.pop(context)

                                        },
                                        child: const Text('Volver'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(int.parse('0xFF7531FF')),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text(
                            'Actualizar',
                            style: TextStyle(fontFamily: 'Poppins SemiBold', fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),  
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, int maxLin, double screenMedia, bool isDir) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: isDir ? screenMedia * 0.25: screenMedia * 0.20,
        width: screenMedia * 0.95,
        decoration:BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5) ,
                  blurRadius: 7,
                  spreadRadius: 2
                )
              ]
        ) ,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            
            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide.none, // Color del borde
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 25,
                              ), // Color del borde cuando está enfocado
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
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
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.red)),
            labelText: label,
            errorStyle: const TextStyle(fontFamily: 'Poppins Regular'),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          ),
          maxLines: maxLin ,
          validator: (value) {


               if (value == null || value.isEmpty) {
                      return 'El campo $label no puede ir vacio';
                }
              if(label =='Correo' && !value.contains('@')){
                return 'Debe introducir un correo valido';
              }

              return null;
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _rucController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
