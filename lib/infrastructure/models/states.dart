class StatesVnz {


    final dynamic cRegionId;
    final dynamic name;
    final dynamic cCountryId;


  StatesVnz({required this.cRegionId, required this.name, required this.cCountryId});



  Map<String, dynamic> toMap(){

      return {
        "c_region_id":cRegionId,
        "name": name,
        "c_country_id":cCountryId,
  
      };

  }



}