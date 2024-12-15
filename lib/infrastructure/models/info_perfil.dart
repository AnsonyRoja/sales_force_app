class InfPerfil {
  final dynamic name;
  final dynamic email;
  final dynamic phone;
  final dynamic code;

  InfPerfil({this.name, this.email, this.phone, this.code });

  factory InfPerfil.fromJsonMap(Map json) {
    // Obtener el valor del campo 'phone' del mapa
    try {

      if(json["Error"] == "Error login - User invalid" ){
            return InfPerfil(
      name: "null",
      email: "null",
      phone: "null",
      code: "null",
    );

      }
      
      
      print("esto es el mapa json $json");
    final phoneValue = json['DataSet']['DataRow']['field'][4]['val'];
    final nameValue = json['DataSet']['DataRow']['field'][2]['val'];
    final emailValue = json['DataSet']['DataRow']['field'][3]['val'];
    final id = json['DataSet']['DataRow']['field'][0]['val'];

    // Validar si el valor es numérico
    final phone =
        phoneValue is String ? phoneValue.toString() : 'Número no disponible';
    final name =
        nameValue is String ? nameValue.toString() : 'Nombre no disponible';
    final email =
        emailValue is String ? emailValue.toString() : 'Correo no disponible';

    final code = id is int ? id.toString() : 'id no disponible';

    return InfPerfil(
      name: name,
      email: email,
      phone: phone,
      code: code,
    );

     } catch (e) {
      print('esto es el error de infoperfil $e');
        return InfPerfil(
      name: "null",
      email: "null",
      phone: "null",
      code: "null",
    );
    }
  }
}
