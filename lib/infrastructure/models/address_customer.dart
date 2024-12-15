
class AddressCustomer {


    final dynamic cBPartnerID;
    final dynamic name;
    final dynamic cSalesRegionID;
    final dynamic cBPartnerLocationID;
  


  AddressCustomer({required this.cBPartnerID, required this.name, required this.cSalesRegionID, required this.cBPartnerLocationID});



  Map<String, dynamic> toMap(){

      return {
        "c_bpartner_id":cBPartnerID,
        "name": name,
        "c_sales_region_id":cSalesRegionID,
        "c_bpartner_location_id": cBPartnerLocationID,
  
      };

  }



}