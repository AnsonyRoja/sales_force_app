class RegionSalesVisits {


    final dynamic cSalesRegionId;
    final dynamic name;
    final dynamic cod;
    final dynamic salesRepId;


  RegionSalesVisits({required this.cSalesRegionId, required this.name, required this.cod, this.salesRepId});



  Map<String, dynamic> toMap(){

      return {
        "c_sales_region_id":cSalesRegionId,
        "name": name,
        "cod":cod,
        "sales_rep_id": salesRepId
  
      };

  }



}