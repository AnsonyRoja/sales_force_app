class VisitsConceptsIdempiere {


    final dynamic gssCustomerVisitConceptId;
    final dynamic value;
    final dynamic name;


  VisitsConceptsIdempiere({required this.gssCustomerVisitConceptId, required this.name, required this.value});



  Map<String, dynamic> toMap(){

      return {
        "gss_customer_visit_concept_id":gssCustomerVisitConceptId,
        "value": value,
        "name":name,
  
      };

  }



}