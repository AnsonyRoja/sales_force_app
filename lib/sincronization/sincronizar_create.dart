import 'package:sales_force/database/gets_database.dart';
import 'package:sales_force/database/update_database.dart';
import 'package:sales_force/infrastructure/models/clients.dart';
import 'package:sales_force/infrastructure/models/products.dart';
import 'package:sales_force/presentation/clients/idempiere/create_customer.dart';
import 'package:sales_force/presentation/products/idempiere/create_product.dart';
import 'package:sales_force/presentation/products/products_http.dart';
import 'package:sales_force/presentation/screen/ventas/idempiere/create_orden_sales.dart';
import 'package:sales_force/sincronization/https/add_visits_sync.dart';
import 'package:sales_force/sincronization/https/customer_http.dart';
import 'package:sales_force/sincronization/sincronization_screen.dart';

synchronizeProductsWithIdempiere(setState) async {
  List<Map<String, dynamic>> productsWithZeroValues =
      await getProductsWithZeroValues();

 if(await checkInternetConnectivity() == false){

      return;
      

  }

  await sincronizationProducts(setState);
  
  for (var productData in productsWithZeroValues) {
    Product product = Product(
      mProductId: productData['m_product_id'],
      productType: productData['product_type'],
      productTypeName: productData['product_type_name'],
      codProd: productData['cod_product'],
      prodCatId: productData['pro_cat_id'],
      taxName: productData['tax_cat_name'],
      productGroupId: productData['product_group_id'],
      produtGroupName: productData['product_group_name'],
      umId: productData['um_id'],
      umName: productData['um_name'],
      name: productData['name'],
      price: productData['price'],
      quantity: productData['quantity'],
      categoria: productData['categoria'],
      qtySold: productData['total_sold'],
      taxId: productData['tax_cat_id'],
      priceListSales: productData['pricelistsales'],
    );
    dynamic result = await createProductIdempiere(product.toMap());
    print('este es el $result');

    final mProductId =
        result['StandardResponse']['outputFields']['outputField'][0]['@value'];
    final codProdc =
        result['StandardResponse']['outputFields']['outputField'][1]['@value'];
    print('Este es el mp product id $mProductId && el codprop $codProdc');
    // Limpia los controladores de texto después de guardar el producto
    await updateProductMProductIdAndCodProd(
        productData['id'], mProductId, codProdc);
  }
}

synchronizeVisitsWithIdempiere(setState) async {
  List<Map<String, dynamic>> visitsCustomerWithZeroValue =
      await getVisitsWithZeroValues();
 
  int contador = 0;
  if(await checkInternetConnectivity() == false){

      return;
      

  }


  

  print('Estas son las visitas que no estan sincronizadas en cero $visitsCustomerWithZeroValue');



                  if(visitsCustomerWithZeroValue.isEmpty){


                    setState(() {
                      
                          syncPercentageVisits = 100;

                    });
                    

                  }
            


  
  for (var visitCustomer in visitsCustomerWithZeroValue) {

    print('Estas son las ordenes sales $visitCustomer');

    contador++;

    print('El valor del contador $contador');

     setState(() {
      syncPercentageVisits =  (contador / visitsCustomerWithZeroValue.length) * 100;

     });

    print('el valor de syncPercentageSelling $syncPercentageVisits');
   

     await addVisitCustomerIdempiereSync(visitCustomer);
   



  }

  
}

synchronizeCustomersWithIdempiere(setState) async {
  List<Map<String, dynamic>> customersWithZeroValues =
      await getCustomersWithZeroValues();

  await sincronizationCustomers(setState);

 if(await checkInternetConnectivity() == false){

      return;
      

  }

  print('Esto es custommer en cero $customersWithZeroValues');
  
  for (var customersData in customersWithZeroValues) {
    
    try {
      Customer customer = Customer(
          cbPartnerId: customersData['c_bpartner_id'],
          codClient: customersData['cod_client'],
          isBillTo: 'Y',
          address: customersData['address'],
          bpName: customersData['bp_name'],
          cBpGroupId: customersData['c_bp_group_id'],
          cBpGroupName: customersData['group_bp_name'],
          cBparnetLocationId: 0,
          cCityId: customersData['c_city_id'],
          cCountryId: customersData['c_country_id'],
          cLocationId: 0, 
          cRegionId: 0,
          city: customersData['city'],
          codePostal: customersData['code_postal'],
          country: customersData['country'],
          email: customersData['email'],
          lcoTaxIdTypeId: customersData['lco_tax_id_typeid'],
          lcoTaxPayerTypeId: customersData['lco_tax_payer_typeid'],
          lvePersonTypeId: customersData['lve_person_type_id'],
          personTypeName: customersData['person_type_name'],
          phone: customersData['phone'],
          region: customersData['region'],
          ruc: customersData['ruc'],
          taxIdTypeName: customersData['tax_id_type_name'],
          taxPayerTypeName: customersData['tax_payer_type_name'],
          mPriceListId: customersData['m_pricelist_id'],
          cPaymentTermId: customersData['c_payment_term_id'],
          deliveryRule: customersData['delivery_rule'],
          deliveryViaRule: customersData['delivery_via_rule'],
          invoiceRule: customersData['invoice_rule'],
          paymentRule: customersData['payment_rule']
      );

      dynamic result = await createCustomerIdempiere(customer.toMap());
      print('este es el $result');

      final cBParnertId =
          result['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][0]['outputFields']
          ['outputField'][0]['@value'];
      final newCodClient =
          result['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][0]['outputFields']
          ['outputField'][1]['@value'];
      final cLocationId =  result['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][1]['outputFields']
          ['outputField']['@value'];
      final cBPartnerLocationId = result['CompositeResponses']['CompositeResponse']
          ['StandardResponse'][2]['outputFields']
          ['outputField']['@value'];

      print('Esto es el codigo de partnert id  $cBParnertId, esto es el $newCodClient, esto es el $cLocationId y esto es el cbparnert location id $cBPartnerLocationId');

      await updateCustomerCBPartnerIdAndCodClient(
          customersData['id'], cBParnertId, newCodClient, cLocationId, cBPartnerLocationId );
    } catch (error) {
      print('Error al procesar cliente: $error');
      // Continuar con el siguiente cliente
      continue;
    }
  }
}




synchronizeOrderSalesWithIdempiere(setState) async {
  List<Map<String, dynamic>> orderSalesWithZeroValues =
      await obtenerOrdenesDeVentaConLineas();
 
  int contador = 0;


  // await sincronizationCustomers(setState);

 if(await checkInternetConnectivity() == false){

      return;
      

  }

  

  print('Esto es custommer en cero $orderSalesWithZeroValues');



                  if(orderSalesWithZeroValues.isEmpty){


                    setState(() {
                      
                          syncPercentageSelling = 100;

                    });
                    

                  }
            


  
  for (var orderSales in orderSalesWithZeroValues) {

    print('Estas son las ordenes sales $orderSales');

    contador++;

    print('El valor del contador $contador');

     setState(() {
      syncPercentageSelling =  (contador / orderSalesWithZeroValues.length) * 100;

     });

    print('el valor de syncPercentageSelling $syncPercentageSelling');

     await createOrdenSalesIdempiere(orderSales);
   
  }

  
}