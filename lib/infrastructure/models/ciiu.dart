class Ciiu {


    final dynamic codeCiiu;
    final dynamic lcoIsiCid;
    final dynamic name;

  Ciiu({required this.codeCiiu, required this.lcoIsiCid, required this.name});



  Map<String, dynamic> toMap(){

      return {
        "cod_ciiu":codeCiiu,
        "lco_isic_id": lcoIsiCid,
        "name":name
      };

  }



}