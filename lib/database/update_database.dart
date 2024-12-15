import 'package:sales_force/database/create_database.dart';

Future<void> updateProduct(Map<String, dynamic> updatedProduct) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'products',
      updatedProduct,
      where: 'id = ?',
      whereArgs: [updatedProduct['id']],
    );
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
  }
}

Future<void> updatePlanVisitState({
  required int id,
  required String newState,
}) async {
  try {
    final db = await DatabaseHelper.instance.database;

    print('Esto es el date: $id o es el newstate: $newState');
    if (db == null) {
      print('Error: db is null');
      return;
    }

    // Verificar los parámetros
    if (newState.isEmpty) {
      print('Error: Uno o más parámetros no son válidos.');
      return;
    }

    // Verificar si la entrada existe antes de actualizar
    List<Map<String, dynamic>> results = await db.query(
      'plan_visits',
      where: 'id = ?',
      whereArgs: [id],
    );

    print('Esto es results $results');
    if (results.isEmpty) {
      print(
          'Error: No se encontró ningún registro que coincida con los parámetros proporcionados.');
      return;
    } else {
      print('Registro encontrado: $results');
    }

    // Actualizar el estado
    int count = await db.update(
      'plan_visits',
      {'state': newState},
      where: 'id = ? ',
      whereArgs: [id],
    );

    if (count > 0) {
      print("Se actualizó correctamente.");
    } else {
      print("Error: No se pudo actualizar el registro.");
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> updateClient(Map<String, dynamic> updatedClient) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'clients',
      updatedClient,
      where: 'id = ?',
      whereArgs: [updatedClient['id']],
    );
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
  }
}

Future<int> updateVisitState(int id, String dateEnd ,String newState) async {
    final db = await DatabaseHelper.instance.database;

      if(db != null) {
      return await db.update(
      'visit_customer',
      {'state': newState,
        'end_date': dateEnd
      },
      
      where: 'id = ?',
      whereArgs: [id],
    );
      }

      return 0;
  }

  Future<int> updateRecordCustomerVisitId(int id, int recordCustomerId) async {
    final db = await DatabaseHelper.instance.database;

      if(db != null) {
      return await db.update(
      'visit_customer',
      {
        'record_customer_visit_id': recordCustomerId,
      },
      
      where: 'id = ?',
      whereArgs: [id],
    );
      }

      return 0;
  }

Future<void> updateProvider(Map<String, dynamic> updatedProvider) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'providers',
      updatedProvider,
      where: 'id = ?',
      whereArgs: [updatedProvider['id']],
    );
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
  }
}

Future<void> updateProductMProductIdAndCodProd(
    int productId, int newMProductId, int newCodProduct) async {
  final db = await DatabaseHelper.instance.database;
  print(
      "esto es el valor de me produc id $newMProductId y el valor de newcodprodu $newCodProduct");
  if (db != null) {
    await db.update(
      'products',
      {
        'm_product_id': newMProductId,
        'cod_product': newCodProduct,
      },
      where: 'id = ?',
      whereArgs: [productId],
    );
    print('Product updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future<void> updateCustomerCBPartnerIdAndCodClient(
  int customerId,
  int cBPartnerId,
  int newCodClient,
  int cLocationId,
  int cBparnetLocationId,
) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'clients',
      {
        'c_bpartner_id': cBPartnerId,
        'cod_client': newCodClient,
        'c_location_id': cLocationId,
        'c_bpartner_location_id': cBparnetLocationId,
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
    print('Customer updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future<void> updateVendorCBPartnerIdAndCodId(
  int vendorId,
  int cBPartnerId,
  int newCodVendor,
  int cLocationId,
  int cBparnetLocationId,
) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'providers',
      {
        'c_bpartner_id': cBPartnerId,
        'cod_client': newCodVendor,
        'c_location_id': cLocationId,
        'c_bpartner_location_id': cBparnetLocationId,
      },
      where: 'id = ?',
      whereArgs: [vendorId],
    );
    print('proveedor updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future<void> updateCBPartnerIdAndCodVendor(
  int customerId,
  int cBPartnerId,
  int newCodClient,
  int cLocationId,
  int cBparnetLocationId,
) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'providers',
      {
        'c_bpartner_id': cBPartnerId,
        'c_code_id': newCodClient,
        'c_location_id': cLocationId,
        'c_bpartner_location_id': cBparnetLocationId,
      },
      where: 'id = ?',
      whereArgs: [customerId],
    );
    print('Proveedor updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future updateOrdereSalesForStatusSincronzed(
    int orderId, String newStatus) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'orden_venta',
      {
        'status_sincronized': newStatus,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print('order Sales updated successfully');
    return 1;
  } else {
    print('Error: db is null');
  }
}

Future updateOrderePurchaseForStatusSincronzed(
    int orderId, String newStatus) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'orden_compra',
      {
        'status_sincronized': newStatus,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print('order purchase updated successfully');
    return 1;
  } else {
    print('Error: db is null');
  }
}

Future updateMProductIdOrderCompra(int orderId, int mProductId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    await db.update(
      'orden_compra_lines',
      {
        'm_product_id': mProductId,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
    print('order purchase updated successfully');
    return 1;
  } else {
    print('Error: db is null');
  }
}

Future<void> actualizarDocumentNo(
    int id, Map<String, dynamic> nuevoDocumentNoAndCOrderId) async {
  final db = await DatabaseHelper.instance.database;

  print(
      'Entre aqui en actualizacion de orden de venta $id Y $nuevoDocumentNoAndCOrderId');

  int resultado = await db!.update(
    'orden_venta',
    {
      'documentno': nuevoDocumentNoAndCOrderId['documentno'],
      'c_order_id': nuevoDocumentNoAndCOrderId['c_order_id'],
      'doc_status': nuevoDocumentNoAndCOrderId['doc_status']
    },
    where: 'id = ?',
    whereArgs: [id],
  );

  if (resultado == 1) {
    print('Actualización exitosa.');
  } else {
    print('La actualización falló.');
  }
}

Future<void> actualizarDocumentNoVendor(
    int id, Map<String, dynamic> nuevoDocumentNoAndCOrderId) async {
  final db = await DatabaseHelper.instance.database;

  int resultado = await db!.update(
    'orden_compra',
    {
      'documentno': nuevoDocumentNoAndCOrderId['documentno'],
      'c_order_id': nuevoDocumentNoAndCOrderId['c_order_id']
    },
    where: 'id = ?',
    whereArgs: [id],
  );

  if (resultado == 1) {
    print('Actualización exitosa.');
  } else {
    print('La actualización falló.');
  }
}

Future<void> updateDocumentNoCobro(
  int cobrorId,
  dynamic documentNo,
  int paymentId,
  dynamic docStatus,
) async {
  final db = await DatabaseHelper.instance.database;

  print('Este es el cobroId $cobrorId y este es el documentno $documentNo');

  if (db != null) {
    await db.update(
      'cobros',
      {
        'documentno': documentNo,
        'c_payment_id': paymentId,
        'doc_status': docStatus
      },
      where: 'id = ?',
      whereArgs: [cobrorId],
    );

    print('Cobro updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future<void> updateNumberInvoiceAndDocumentNo(
  int orderSalesId,
  dynamic documentNo,
  dynamic invoiceId,
  dynamic docStatus,
  dynamic isTaxWithholdingIVA,
) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'orden_venta',
      {'id_factura': invoiceId, 'documentno_factura': documentNo, 'doc_status':docStatus, 'is_tax_with_holding_iva': isTaxWithholdingIVA},
      where: 'id = ?',
      whereArgs: [orderSalesId],
    );

    print('Orden de venta updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future<void> updateStatusOrder(
  int orderSalesId,

  dynamic docStatus,
) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'orden_venta',
      {'doc_status':docStatus},
      where: 'id = ?',
      whereArgs: [orderSalesId],
    );

    print('Orden de venta updated successfully');
  } else {
    print('Error: db is null');
  }
}

Future<void> updateStatusCobros(
  int cobroId,
  dynamic docStatus,
) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    await db.update(
      'cobros',
      {'doc_status':docStatus},
      where: 'id = ?',
      whereArgs: [cobroId],
    );

    print('Cobro Status updated successfully');
  } else {
    print('Error: db is null');
  }
}



Future<void> updateAmmountAndConversionCobros(
  dynamic cobroId,
  double payAmt,
  double payAmtBs,
) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    int count = await db.update(
      'cobros',
      {
        'pay_amt': payAmt,
        'pay_amt_bs': payAmtBs,
      },
      where: 'id = ?',
      whereArgs: [cobroId],
    );

    if (count > 0) {
      print('Cobro status updated successfully');
    } else {
      print('No rows were updated');
    }
  } else {
    print('Error: db is null');
  }
}
