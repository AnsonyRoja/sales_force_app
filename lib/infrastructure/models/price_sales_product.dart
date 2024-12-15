class PriceSalesList {


    final dynamic mPriceListId;
    final dynamic priceListName;
    final dynamic cCurrencyId;
    final dynamic mProductId;
    final dynamic priceList;

  PriceSalesList({required this.mPriceListId, required this.priceListName, required this.cCurrencyId, this.mProductId, this.priceList});



  Map<String, dynamic> toMap(){

      return {
        "m_pricelist_id":mPriceListId,
        "price_list_name": priceListName,
        "c_currency_id":cCurrencyId,
        "m_product_id": mProductId,
        "price_list": priceList
      };

  }



}