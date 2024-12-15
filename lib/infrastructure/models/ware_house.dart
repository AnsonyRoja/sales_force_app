class WareHouse {


    final dynamic adClientId;
    final dynamic adOrgId;
    final dynamic mWareHouseId;
    final dynamic name;
    final dynamic wareHouseValue;


  WareHouse({required this.adClientId, required this.adOrgId, required this.mWareHouseId, this.name, required this.wareHouseValue});



  Map<String, dynamic> toMap(){

      return {

        "ad_client_id":adClientId,
        "ad_org_id": adOrgId,
        "m_warehouse_id":mWareHouseId,
        "value":wareHouseValue,
        "name": name
  
      };

  }

}