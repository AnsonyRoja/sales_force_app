class DiscountDocuments {


    final dynamic mDiscountShemaId;
    final dynamic name;
    final dynamic discount;
    final dynamic limitDiscount;
    final dynamic cChargeId;
    final dynamic rate; 

  DiscountDocuments({required this.mDiscountShemaId, required this.name, required this.discount, required this.limitDiscount, required this.cChargeId, required this.rate});



  Map<String, dynamic> toMap(){

      return {
        "m_discount_schema_id":mDiscountShemaId,
        "name": name,
        "discount":discount,
        "limit_discount" : limitDiscount,
        "c_charge_id" : cChargeId,
        'rate': rate
      };

  }



}