 import 'package:sales_force/database/create_database.dart';

Future<void> clearDatabase() async {

  final db = await DatabaseHelper.instance.database;

  if(db != null){

  await db.transaction((txn) async {
    // Elimina registros de todas las tablas
    await txn.delete('orden_venta');
    await txn.delete('orden_venta_lines');
    await txn.delete('clients');
    await txn.delete('visit_customer');
    await txn.delete('visits_concepts');
    await txn.delete('state');
    await txn.delete('price_sales_list');
    await txn.delete('region_sales_visits');
    await txn.delete('plan_visits');
    await txn.delete('products');
    await txn.delete('cobros');
    await txn.delete('posproperties');
    await txn.delete('tax');
    await txn.delete('bank_account_app');
    await txn.delete('rate_conversion');
    
  });


  // await db.close();
}

}