
class CenterCosts {


    final dynamic cElementValueId;
    final dynamic name;
    final dynamic value;


  CenterCosts({required this.cElementValueId, required this.name, required this.value});



  Map<String, dynamic> toMap(){

      return {
        "c_element_value_id":cElementValueId,
        "name": name,
        "value":value,
  
      };

  }



}