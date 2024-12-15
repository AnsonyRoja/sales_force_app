invoke(option, newValue, data) {
  switch (option) {

    case 'obtenerNombreWareHouse' :

    Map<String, dynamic> wareHouse = data.firstWhere(
        (wh) => wh['m_warehouse_id'] == newValue,
      );

        Map objWareHouseOrg = {

            "wareHouseName": wareHouse['name'] ,
            "orgId": wareHouse['ad_org_id'],  
            "adClientId":wareHouse['ad_client_id']

        };


      return wareHouse.isNotEmpty ? objWareHouseOrg : '';

    case 'obtenerNombreAddressCustomer':
      Map<String, dynamic>? address = data.firstWhere(
        (ad) => ad['c_bpartner_location_id'] == newValue,
      );

      Map obj = {

        'name': address!['name'],
        'region_sales':address['c_sales_region_id']
        

      };

      return obj.isNotEmpty ? obj : '';
     case 'obtenerNombreAddressCustomerOnlyName':
      Map<String, dynamic> address = data.firstWhere(
        (ad) => ad['c_bpartner_location_id'] == newValue,
      );

      if (address.isNotEmpty) {
        return address['name'];
      } else {
        return '';
      }

    case 'obtenerNombrePriceList':
      Map<String, dynamic>? priceList = data.firstWhere(
        (categoria) => categoria['m_pricelist_id'] == newValue,
      );

      return priceList != null ? priceList['price_list_name'] : '';
    case 'obtenerNombreConceptsVisits':
      Map<String, dynamic>? conceptsVisits = data.firstWhere(
        (concept) => concept['gss_customer_visit_concept_id'] == newValue,
      );

      return conceptsVisits != null ? conceptsVisits['name'] : '';

    case 'obtenerNombreRegionSalesVisits':
      Map<String, dynamic>? salesRegion = data.firstWhere(
        (sr) => sr['c_sales_region_id'] == newValue,
      );

      return salesRegion != null ?  {'name':salesRegion['name'], 'sales_red_id' : salesRegion['sales_rep_id']} : '';

    case 'obtenerNombreCat':

      // Buscar la categoría en _categoriesList que coincide con el ID dado
      Map<String, dynamic>? categoria = data.firstWhere(
        (categoria) => categoria['pro_cat_id'] == newValue,
      );

      // Si se encuentra la categoría, devolver su nombre, de lo contrario devolver una cadena vacía
      return categoria != null ? categoria['categoria'] : '';
    case 'obtenerNombreCurrencyType':

      // Buscar la categoría en _categoriesList que coincide con el ID dado
      Map<String, dynamic>? currency = data.firstWhere(
        (currency) => currency['c_currency_id'] == newValue,
      );

      // Si se encuentra la categoría, devolver su nombre, de lo contrario devolver una cadena vacía
      return currency != null ? currency['iso_code'] : '';

    case 'obtenerNombreProductGroup':
      Map<String, dynamic>? productGroup = data.firstWhere(
        (productGroupList) => productGroupList['product_group_id'] == newValue,
      );

      print("Esto es el nombre product Group $productGroup");

      return productGroup != null ? productGroup['product_group_name'] : '';

    case 'obtenerNombreProductType':
      Map<String, dynamic>? productType = data.firstWhere(
        (productTypeList) => productTypeList['product_type'] == newValue,
      );

      return productType != null ? productType['product_type_name'] : '';
    case 'obtenerNombreImpuesto':
      Map<String, dynamic>? impuesto = data.firstWhere(
        (taxlist) => taxlist['tax_cat_id'] == newValue,
      );

      // Si se encuentra la categoría, devolver su nombre, de lo contrario devolver una cadena vacía
      return impuesto != null ? impuesto['tax_cat_name'] : '';
    case 'obtenerNombreUm':
      Map<String, dynamic>? um = data.firstWhere(
        (umList) => umList['um_id'] == newValue,
      );

      return um != null ? um['um_name'] : '';

    case 'obtenerNombreCountry':
      Map<String, dynamic>? country = data.firstWhere(
        (countryList) => countryList['c_country_id'] == newValue,
      );
      return country != null ? country['country'] : '';

    case 'obtenerNombreState':
      Map<String, dynamic>? state = data.firstWhere(
        (stateList) => stateList['c_region_id'] == newValue,
      );

      return state != null ? state['name'] : '';

    case 'obtenerNombreCountryVendor':
      Map<String, dynamic>? country = data.firstWhere(
        (countryList) => countryList['c_country_id'] == newValue,
      );

      return country != null ? country['country_name'] : '';

    case 'obtenerNombreGroup':
      Map<String, dynamic>? groupTercero = data.firstWhere(
        (group) => group['c_bp_group_id'] == newValue,
      );

      return groupTercero != null ? groupTercero['group_bp_name'] : '';

    case 'obtenerNombreGroupVendor':
      Map<String, dynamic>? groupTercero = data.firstWhere(
        (group) => group['c_bp_group_id'] == newValue,
      );

      return groupTercero != null ? groupTercero['groupbpname'] : '';

    case 'obtenerNombreTax':
      Map<String, dynamic>? nombreTaxType = data.firstWhere(
        (taxType) => taxType['lco_tax_id_typeid'] == newValue,
      );

      return nombreTaxType != null ? nombreTaxType['tax_id_type_name'] : '';

    case 'obtenerNombreTaxVendor':
      Map<String, dynamic>? nombreTaxType = data.firstWhere(
        (taxType) => taxType['lco_tax_id_type_id'] == newValue,
      );

      return nombreTaxType != null ? nombreTaxType['tax_id_type_name'] : '';

    case 'obtenerNombreCiiu':
      Map<String, dynamic>? nombreCiiuCode = data.firstWhere(
        (ciiu) => ciiu['lco_isic_id'] == newValue,
      );

      print('este es el nombre de el codigo ciiu $nombreCiiuCode');
      return nombreCiiuCode != null ? nombreCiiuCode['name'] : '';

    case 'obtenerNombreTaxPayerVendor':
      Map<String, dynamic>? nombreTaxPayer = data.firstWhere(
        (taxPayer) => taxPayer['lco_taxt_payer_type_id'] == newValue,
      );

      return nombreTaxPayer != null
          ? nombreTaxPayer['tax_payer_type_name']
          : '';

    case 'obtenerNombreTaxPayer':
      Map<String, dynamic>? nombreTaxPayer = data.firstWhere(
        (taxPayer) => taxPayer['lco_tax_payer_typeid'] == newValue,
      );

      return nombreTaxPayer != null
          ? nombreTaxPayer['tax_payer_type_name']
          : '';

    case 'obtenerNombreTypePerson':
      Map<String, dynamic>? nombreTypePerson = data.firstWhere(
        (typePerson) => typePerson['lve_person_type_id'] == newValue,
      );

      return nombreTypePerson != null
          ? nombreTypePerson['person_type_name']
          : '';

    case 'obtenerNombreBankAccount':
      Map<String, dynamic>? nombreBankAccount = data.firstWhere(
        (typePerson) => typePerson['c_bank_account_id'] == newValue,
      );

      return nombreBankAccount != null ? nombreBankAccount['bank_name'] : '';

    default:
  }
}
