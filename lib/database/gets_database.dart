import 'package:sales_force/database/create_database.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

Future<List<Map<String, dynamic>>> getProductsInPriceList(
    dynamic priceListId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza una consulta que una las tablas "products" y "tax" utilizando una cláusula JOIN
    return await db.rawQuery('''
    SELECT p.*, t.rate AS tax_rate, pl.price_list_name, pl.price_list
    FROM products p 
    JOIN tax t ON p.tax_cat_id = t.c_tax_category_id
    INNER JOIN price_sales_list pl ON p.m_product_id = pl.m_product_id
    WHERE t.iswithholding = 'N' AND pl.m_pricelist_id = ?
  ''', [priceListId]);
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> typeOfCurrencyIs(
    dynamic mPriceListId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.rawQuery('''

      SELECT pl.price_list_name, pl.c_currency_id

      FROM price_sales_list pl 

      WHERE pl.m_pricelist_id = ?

''', [mPriceListId]);
  }

  return [];
}

Future<Map<String, dynamic>> typeOfCurrencyIsForFirsResult(dynamic mPriceListId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Realiza la consulta para obtener el primer resultado
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT pl.price_list_name, pl.c_currency_id
      FROM price_sales_list pl
      WHERE pl.m_pricelist_id = ?
    ''', [mPriceListId]);

    // Verifica si la lista de resultados no está vacía y devuelve el primer resultado
    if (result.isNotEmpty) {
      return result.first;
    } else {
      // Maneja el caso en el que no se encuentren resultados
      return {};
    }
  } else {
    // Maneja el caso en el que la base de datos sea null
    print('Error: db is null');
    return {};
  }
}

Future<List<Map<String, dynamic>>> getListPrice() async {
  Database? db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.query('price_sales_list');
  }

  return [];
}

Future<List<Map<String, dynamic>>> getConceptsVisits() async {
  Database? db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.query('visits_concepts');
  }

  return [];
}

Future<List<Map<String, dynamic>>> getRegionSalesVisits() async {
  Database? db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.query('region_sales_visits');
  }

  return [];
}

Future<List<Map<String, dynamic>>> getStatesVnz() async {
  Database? db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.query('state');
  }

  return [];
}

Future<List<Map<String, dynamic>>> getProductsScreen(
    {required int page, required int pageSize}) async {
  final db = await DatabaseHelper.instance.database;
  print('Esto es page $page y esto es pagesize $pageSize');
  if (db != null) {
    // Calcula el índice de inicio
    final int offset = (page - 1) * pageSize;

    // Realiza la consulta con paginación
    return await db.query('products', limit: pageSize, offset: offset);
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getProducts() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.query('products');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getTaxs() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.query('tax');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getBankAccounts() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "bank_account_app"
    return await db.query('bank_account_app');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<Map<String, dynamic>> getCurrencyIsoForCobro(dynamic currencyId) async {
  // Obtén la instancia de la base de datos
  final db = await DatabaseHelper.instance.database;

  // Verifica si la base de datos no es null
  if (db != null) {
    // Realiza la consulta para recuperar los registros que coincidan con el currencyId
    List<Map<String, dynamic>> result = await db.query(
      'bank_account_app', // Nombre de la tabla
      where: 'c_currency_id = ?', // Condición de la consulta
      whereArgs: [currencyId], // Argumentos para la condición
    );

    // Verifica si la lista de resultados no está vacía y devuelve el primer resultado
    if (result.isNotEmpty) {
      return result.first;
    } else {
      // Maneja el caso en el que no se encuentren resultados
      return {};
    }
  } else {
    // Maneja el caso en el que la base de datos sea null
    print('Error: db is null');
    return {};
  }
}


Future<List<Map<String, dynamic>>> getClients() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.query('clients');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getClientsOnlyGroupName() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.rawQuery('''SELECT  c.group_bp_name 
    FROM clients c
    ''');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getClientsOnlyRegionName() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.rawQuery('''SELECT  name 
    FROM region_sales_visits c 
    ''');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getClientAddresses(int cBPartnerId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.rawQuery('''
      SELECT ac.*
      FROM address_customers ac
      INNER JOIN clients c ON c.c_bpartner_id = ac.c_bpartner_id
      WHERE c.c_bpartner_id = ?
    ''', [cBPartnerId]);
  } else {
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getAllWareHouse() async {
    final db = await DatabaseHelper.instance.database;

    if(db != null) {

        return await db.query('m_warehouse');

    }else{

      print('Error: db is null');

        return [];

    }


}

Future<List<Map<String, dynamic>>> getClientAddressesForLocationId(
    int cBPartnerLocationId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.rawQuery('''
      SELECT ac.*
      FROM address_customers ac
      INNER JOIN clients c ON c.c_bpartner_id = ac.c_bpartner_id
      WHERE ac.c_bpartner_location_id = ?
    ''', [cBPartnerLocationId]);
  } else {
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getClientAddressesBySalesRegion(
    int cBPartnerId, int salesRegionId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.rawQuery('''
      SELECT ac.*
      FROM address_customers ac
      INNER JOIN clients c ON c.c_bpartner_id = ac.c_bpartner_id
      WHERE c.c_bpartner_id = ? AND ac.c_sales_region_id = ?
    ''', [cBPartnerId, salesRegionId]);
  } else {
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getClientsScreen(
    {required int page, required int pageSize}) async {
  final db = await DatabaseHelper.instance.database;

  print(
      'Esto es el numero de pagina $page y el tamano de items pr pagina $pageSize');

  final int offset = (page - 1) * pageSize;

  if (db != null) {
    return await db.query('clients', limit: pageSize, offset: offset);
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getClientsByNameOrRUC(String query) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    List<Map<String, dynamic>> result = await db.query(
      'clients',
      where: 'bp_name LIKE ? OR ruc LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result;
  } else {
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getProviders() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.query('providers');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}


Future<List<Map<String, dynamic>>> getDiscountDocumentsForChargerId(int chargerId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.query('discount_documents', where: 'c_charge_id = ? ', whereArgs: [chargerId]);
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}


Future<List<Map<String, dynamic>>> getDiscountDocuments() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.query('discount_documents');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}


Future<List<Map<String, dynamic>>> getClientsByGroup(dynamic name) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db
        .query('clients', where: 'group_bp_name = ?', whereArgs: [name]);
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getClientsByRegion(dynamic name) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "products"
    return await db.rawQuery('''
      SELECT c.*
      FROM address_customers ac
      INNER JOIN clients c ON c.c_bpartner_id = ac.c_bpartner_id 
      INNER JOIN region_sales_visits rsv on ac.c_sales_region_id = rsv.c_sales_region_id
      WHERE rsv.name = ?
    ''', [name]);
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getVisitCustomers() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "visit_customer" donde "planned" es "NO"
    return await db.query(
      'visit_customer',
      where: 'planned = ?',
      whereArgs: ['NO'],
    );
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getVisitCustomersYes() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todos los registros de la tabla "visit_customer" donde "planned" es "NO"
    return await db.query(
      'visit_customer',
      where: 'planned = ?',
      whereArgs: ['SI'],
    );
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<bool> isPlanVisited(int planVisitsId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> result = await db.query(
      'plan_visits',
      columns: ['state'],
      where: 'id = ?',
      whereArgs: [planVisitsId],
    );

    if (result.isNotEmpty) {
      String state = result.first['state'];
      return state == 'Visits';
    }
  }
  return false;
}

Future<List<Map<String, dynamic>>> getCobrosForId(id) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.query("cobros", where: 'id = ?', whereArgs: [id]);
  }

  return [];
}

Future<List<Map<String, dynamic>>> getCustomerForSalesRegion(int salesRegionId) async {
  dynamic response;
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta utilizando un JOIN para combinar las tablas "clients" y "plan_visits" y evita duplicados con DISTINCT
    response = await db.rawQuery('''
      SELECT DISTINCT c.c_bpartner_id, c.bp_name, c.ruc, pv.date_calendar, pv.state, pv.id, pv.c_bpartner_location_id
      FROM clients c
      JOIN plan_visits pv ON c.c_bpartner_id = pv.c_bpartner_id
      WHERE pv.c_sales_region_id = ? AND pv.state = 'No Visits'
    ''', [salesRegionId]);
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }

  // Filtra los datos para que no se repitan los c_bpartner_id
  // Set<int> uniquePartnerIds = {};
  // List<Map<String, dynamic>> filteredResponse = [];

  // for (var entry in response) {
  //   if (!uniquePartnerIds.contains(entry['c_bpartner_id'])) {
  //     uniquePartnerIds.add(entry['c_bpartner_id']);
  //     filteredResponse.add(entry);
  //   }
  // }

  return response;
}



Future<List<Map<String, dynamic>>> getRegionsForClients(List clientIds) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Convierte la lista de IDs de clientes a una cadena separada por comas
    String clientIdsString = clientIds.join(',');

    // Realiza la consulta utilizando un JOIN para combinar las tablas "clients" y "region_sales_visits"
    return await db.rawQuery('''
      SELECT DISTINCT rs.c_sales_region_id, rs.name
      FROM region_sales_visits rs
      JOIN plan_visits pv ON rs.c_sales_region_id = pv.c_sales_region_id
      WHERE pv.c_bpartner_id IN ($clientIdsString)
    ''');
  } else {
    print('Error: db is null');
    return [];
  }
}




Future<Map<String, dynamic>?> getProductById(int productId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar un registro específico de la tabla "products" basado en su ID
    List<Map<String, dynamic>> result =
        await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null; // Producto no encontrado
    }
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return null;
  }
}

Future<List<Map<String, dynamic>>> getProductByName(String productName) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar los registros específicos de la tabla "products" basados en el nombre del producto
    List<Map<String, dynamic>> result = await db
        .query('products', where: 'name LIKE ?', whereArgs: ['%$productName%']);
    return result; // Devuelve la lista de productos encontrados (puede estar vacía)
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return []; // Devuelve una lista vacía en caso de error
  }
}

Future<List<Map<String, dynamic>>> getAllOrdersWithClientNames() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Consultar todas las órdenes de venta con el nombre del cliente asociado
    List<Map<String, dynamic>> orders = await db.rawQuery('''
        SELECT o.*, c.bp_name AS nombre_cliente, c.ruc AS ruc, c.email AS email, c.phone AS phone, c.m_pricelist_id as list_price,
        ROUND(
            (CAST(REPLACE(REPLACE(o.monto, '.', ''), ',', '.') AS REAL) - COALESCE((SELECT SUM(pay_amt) FROM cobros WHERE sale_order_id = o.id), 0)),
            4
           ) AS saldo_total
        FROM orden_venta o
        INNER JOIN clients c ON o.cliente_id = c.id
      ''');

    // Formateador para el saldo total

    final formatter = NumberFormat('#,##0.00', 'es_ES');

    List<Map<String, dynamic>> ordersNew = orders.map((row) {
      // Crear una copia modificable de cada fila
      final Map<String, dynamic> newRow = Map<String, dynamic>.from(row);

      // Formatear el saldo total
      num saldoTotal = newRow['saldo_total'] ?? 0;
      newRow['saldo_total_formatted'] = formatter.format(saldoTotal);

      return newRow;
    }).toList();

    return ordersNew;
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getAllOrdersWithVendorsNames() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Consultar todas las órdenes de venta con el nombre del cliente asociado
    List<Map<String, dynamic>> orders = await db.rawQuery('''
        SELECT o.*, p.bpname AS nombre_proveedor, p.tax_id as ruc, p.phone as phone, p.email as email
        FROM orden_compra o
        INNER JOIN providers p ON o.proveedor_id = p.id
      ''');
    return orders;
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return [];
  }
}


Future<bool> isExistCobro(
    dynamic bankAccountId,
    dynamic date,
    dynamic coin,
    dynamic payAmt,
    dynamic documentNo,
    ) async {

  final db = await DatabaseHelper.instance.database;

    print('esto es el bankaccoutn $bankAccountId, date $date, coin $coin, $documentNo');

  if (db != null) {
    dynamic havedCobro = await db.query(
      'cobros',
      where: 'c_bankaccount_id = ? AND date = ? AND c_currency_id = ? AND pay_amt = ? AND documentno = ?',
      whereArgs: [bankAccountId, date, coin, payAmt, documentNo],
    );

    print('Este es el valor de havedCobro $havedCobro');

    if (havedCobro.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
  return false; // En caso de que `db` sea `null`
}


Future<Map<String, dynamic>> getOrderWithProducts(int orderId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    String sql = '''
          SELECT 
            o.*, 
         ROUND(
            (CAST(REPLACE(REPLACE(o.monto, '.', ''), ',', '.') AS REAL) - COALESCE((SELECT SUM(pay_amt) FROM cobros WHERE sale_order_id = o.id), 0)),
            4
           ) AS saldo_total
          FROM 
            orden_venta o
          WHERE 
            o.id = ?
        ''';

    List<Map<String, dynamic>> orderResult = await db.rawQuery(sql, [orderId]);

    final formatter = NumberFormat('#,##0.00', 'es_ES');

    List<Map<String, dynamic>> ordersNew = orderResult.map((row) {
      // Crear una copia modificable de cada fila
      final Map<String, dynamic> newRow = Map<String, dynamic>.from(row);

      // Asegurarse de que saldo_total sea de tipo double
      double saldoTotal = (newRow['saldo_total'] is int)
          ? (newRow['saldo_total'] as int).toDouble()
          : newRow['saldo_total'];

      // Formatear el saldo total
      newRow['saldo_total_formatted'] = formatter.format(saldoTotal);

      return newRow;
    }).toList();

    if (orderResult.isNotEmpty) {
      // Consultar los productos asociados a la orden de venta
      List<Map<String, dynamic>> productsResult = await db.rawQuery('''
          SELECT p.id, p.name, p.price, p.quantity, p.m_product_id, ovl.qty_entered, ovl.price_actual, ovl.m_warehouse_id ,t.rate AS impuesto
          FROM products p
          INNER JOIN orden_venta_lines ovl ON p.id = ovl.producto_id
          INNER JOIN tax t ON p.tax_cat_id  = t.c_tax_category_id
          WHERE ovl.orden_venta_id = ?
        ''', [orderId]);

      int clienteId = orderResult[0]['cliente_id'];

      List<Map<String, dynamic>> clientsResult = await db.rawQuery('''
          SELECT c.bp_name, c.ruc, c.email, c.id, c.phone, c.m_pricelist_id as list_price
          FROM clients c
          WHERE  c.id = ?
        ''', [clienteId]);

      // Crear un mapa que contenga la orden de venta y sus productos
      Map<String, dynamic> orderWithProducts = {
        'client': clientsResult,
        'order': ordersNew
            .first, // La primera (y única) fila de la consulta de la orden de venta
        'products':
            productsResult, // Resultado de la consulta de productos asociados
      };

      return orderWithProducts;
    } else {
      // Manejar el caso en el que no se encuentra la orden de venta
      print('Error: No se encontró la orden de venta con ID $orderId');
      return {};
    }
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return {};
  }
}



Future<Map<String, dynamic>> getOrderPurchaseWithProducts(int orderId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Consultar la orden de venta con el ID especificado
    List<Map<String, dynamic>> orderResult = await db.query(
      'orden_compra',
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (orderResult.isNotEmpty) {
      // Consultar los productos asociados a la orden de venta
      List<Map<String, dynamic>> productsResult = await db.rawQuery('''
          SELECT p.id, p.name, p.price, p.quantity, ocl.qty_entered, ocl.price_actual, t.rate AS impuesto
          FROM products p
          INNER JOIN orden_compra_lines ocl ON p.id = ocl.producto_id
          INNER JOIN tax t ON p.tax_cat_id  = t.c_tax_category_id
          WHERE ocl.orden_compra_id = ?
        ''', [orderId]);

      int provedorId = orderResult[0]['proveedor_id'];

      List<Map<String, dynamic>> clientsResult = await db.rawQuery('''
          SELECT p.bpname, p.tax_id
          FROM providers p
          WHERE  p.id = ?
        ''', [provedorId]);

      // Crear un mapa que contenga la orden de venta y sus productos
      Map<String, dynamic> orderWithProducts = {
        'client': clientsResult,
        'order': orderResult
            .first, // La primera (y única) fila de la consulta de la orden de venta
        'products':
            productsResult, // Resultado de la consulta de productos asociados
      };

      return orderWithProducts;
    } else {
      // Manejar el caso en el que no se encuentra la orden de venta
      print('Error: No se encontró la orden de venta con ID $orderId');
      return {};
    }
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return {};
  }
}

Future<dynamic> getProductAvailableQuantity(int productId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Consultar la cantidad disponible del producto en la tabla 'products'
    List<Map<String, dynamic>> result =
        await db.query('products', where: 'id = ?', whereArgs: [productId]);
    if (result.isNotEmpty) {
      return result.first['quantity'] ?? 0;
    } else {
      // Manejar el caso en el que no se encuentre el producto
      print('Error: No se encontró el producto con ID $productId');
      return 0;
    }
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return 0;
  }
}

Future<List<Map<String, dynamic>>>
    getAllOrdenesCompraWithProveedorNames() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Consultar todas las órdenes de compra con el nombre del proveedor asociado
    List<Map<String, dynamic>> ordenesCompra = await db.rawQuery('''
        
        SELECT oc.*, p.bpname AS nombre_proveedor
        FROM orden_compra oc
        INNER JOIN providers p ON oc.proveedor_id = p.id

      ''');
    return ordenesCompra;
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getRetencionesWithProveedorNames() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Realiza la consulta para recuperar todas las retenciones de la tabla "retenciones"
    // y sus proveedores asociados
    return await db.rawQuery('''
        SELECT r.*, p.bpname AS nombre_proveedor, p.tax_id as ruc
        FROM f_retenciones r
        INNER JOIN providers p ON r.provider_id = p.id
      ''');
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return [];
  }
}

Future<bool> facturaTieneRetencion(int id) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Consultar retenciones asociadas a la factura
    List<Map<String, dynamic>> retenciones = await db.rawQuery('''
        SELECT * FROM retenciones WHERE orden_compra_id = ?
      ''', [id]);

    // Verificar si hay alguna retención asociada
    return retenciones.isNotEmpty;
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return false;
  }
}

Future<List<Map<String, dynamic>>> getProductsWithZeroValues() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    return await db.rawQuery('''
            SELECT * FROM products 
            WHERE cod_product = 0 AND m_product_id = 0
          ''');
  }
  return [];
}

Future<List<Map<String, dynamic>>> getVisitsWithZeroValues() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    return await db.rawQuery('''
            SELECT * FROM visit_customer 
            WHERE record_customer_visit_id = 0 AND end_date != ''
          ''');
  }
  return [];
}

Future<List<Map<String, dynamic>>> getCiiuActivities() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    return await db.rawQuery('''

        SELECT * FROM ciiu

      ''');
  }

  return [];
}

Future<List<Map<String, dynamic>>> getCustomersWithZeroValues() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    return await db.rawQuery('''
            SELECT * FROM clients 
            WHERE c_bpartner_id = 0 AND cod_client = 0
          ''');
  }
  return [];
}

Future<List<Map<String, dynamic>>> getVendorWithZeroValues() async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    return await db.rawQuery('''
            
            SELECT * FROM providers 
            WHERE c_bpartner_id = 0 AND c_code_id = 0

          ''');
  }
  return [];
}

// Método para obtener los datos de un usuario por ID
Future<Map<String, dynamic>?> getUserByLogin(
    String user, String password) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    final List<Map<String, dynamic>> users = await db.query(
      'usuarios',
      where:
          'name = ? AND password = ?', // Combina las condiciones en una sola cadena
      whereArgs: [user, password],
    );

    if (users.isNotEmpty) {
      return users.first;
    } else {
      return null;
    }
  }
  return null;
}

Future<List<Map<String, dynamic>>> getRateConversion() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    final List<Map<String, dynamic>> rateConversion =
        await db.query('rate_conversion');
    if (rateConversion.isNotEmpty) {
      return rateConversion;
    } else {
      return [];
    }
  }

  return [];
}

Future<List<Map<String, dynamic>>> getPlanVisits() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    final List<Map<String, dynamic>> planVisits = await db.query('plan_visits');

    if (planVisits.isNotEmpty) {
      return planVisits;
    } else {
      return [];
    }
  }

  return [];
}

Future<List<Map<String, dynamic>>> obtenerOrdenesDeVentaConLineas() async {
  final db = await DatabaseHelper.instance.database;

  final List<Map<String, dynamic>> resultado = await db!.rawQuery('''
    SELECT 
      orden_venta.id,
      orden_venta.c_doctypetarget_id,
      orden_venta.ad_client_id,
      orden_venta.ad_org_id,
      orden_venta.m_warehouse_id,
      orden_venta.documentno,
      orden_venta.c_order_id,
      orden_venta.paymentrule,
      orden_venta.date_ordered,
      orden_venta.salesrep_id,
      orden_venta.c_bpartner_id,
      orden_venta.c_bpartner_location_id,
      orden_venta.fecha,
      orden_venta.descripcion,
      orden_venta.monto,
      orden_venta.saldo_neto,
      orden_venta.usuario_id,
      orden_venta.cliente_id,
      orden_venta.id_factura,
      orden_venta.desc_prontopago,
      orden_venta.desc_pagoefectivo,
      orden_venta.total_desc,
      orden_venta.cargos,
      orden_venta.status_sincronized,
      orden_venta_lines.id AS line_id,
      orden_venta_lines.producto_id,
      orden_venta_lines.price_entered,
      orden_venta_lines.price_actual,
      orden_venta_lines.m_product_id,
      orden_venta_lines.qty_entered,
      
      ROUND(
          (CAST(REPLACE(orden_venta.monto, ',', '.') AS REAL) - COALESCE((SELECT SUM(pay_amt) FROM cobros WHERE sale_order_id = orden_venta.id), 0)),4) AS saldo_total,
      c.m_pricelist_id as list_price
    FROM orden_venta
    JOIN orden_venta_lines ON orden_venta.id = orden_venta_lines.orden_venta_id
    JOIN clients as c ON orden_venta.cliente_id = c.id
 
    WHERE orden_venta.documentno IS NULL OR orden_venta.documentno = '' 
  ''');

  print('Este es el resultado $resultado');
  Map<int, Map<String, dynamic>> ordenesMap = {};

  for (var row in resultado) {
    if (!ordenesMap.containsKey(row['id'])) {
      ordenesMap[row['id']] = {
        'client': [
          {'list_price': row['list_price']}
        ],
        'order': {
          'id': row['id'],
          'c_doctypetarget_id': row['c_doctypetarget_id'],
          'ad_client_id': row['ad_client_id'],
          'ad_org_id': row['ad_org_id'],
          'm_warehouse_id': row['m_warehouse_id'],
          'documentno': row['documentno'],
          'paymentrule': row['paymentrule'],
          'date_ordered': row['date_ordered'],
          'salesrep_id': row['salesrep_id'],
          'c_bpartner_id': row['c_bpartner_id'],
          'c_bpartner_location_id': row['c_bpartner_location_id'],
          'fecha': row['fecha'],
          'descripcion': row['descripcion'],
          'monto': row['monto'],
          'saldo_neto': row['saldo_neto'],
          'usuario_id': row['usuario_id'],
          'cliente_id': row['cliente_id'],
          'id_factura': row['id_factura'],
          'status_sincronized': row['status_sincronized'],
          'desc_prontopago': row['desc_prontopago'],
          'desc_pagoefectivo': row['desc_pagoefectivo'],
          'total_desc': row['total_desc'],
          'cargos': row['cargos']
        },
        'products': []
      };
    }

    ordenesMap[row['id']]!['products'].add({
      'line_id': row['line_id'],
      'ad_client_id': row['ad_client_id'],
      'ad_org_id': row['ad_org_id'],
      'producto_id': row['producto_id'],
      'price_entered': row['price_entered'],
      'price_actual': row['price_actual'],
      'm_product_id': row['m_product_id'],
      'qty_entered': row['qty_entered'],
      'm_warehouse_id': row['m_warehouse_id'],
      
    });
  }

  return ordenesMap.values.toList();
}

Future<Map<String, dynamic>> obtenerOrdenDeVentaConLineasPorId(
    int orderId) async {
  final db = await DatabaseHelper.instance.database;

  final List<Map<String, dynamic>> resultado = await db!.rawQuery('''
    SELECT 
      orden_venta.id,
      orden_venta.c_doctypetarget_id,
      orden_venta.ad_client_id,
      orden_venta.ad_org_id,
      orden_venta.m_warehouse_id,
      orden_venta.documentno,
      orden_venta.paymentrule,
      orden_venta.date_ordered,
      orden_venta.salesrep_id,
      orden_venta.c_bpartner_id,
      orden_venta.c_bpartner_location_id,
      orden_venta.fecha,
      orden_venta.descripcion,
      orden_venta.monto,
      orden_venta.saldo_neto,
      orden_venta.usuario_id,
      orden_venta.cliente_id,
      orden_venta.status_sincronized,
      orden_venta_lines.id AS line_id,
      orden_venta_lines.producto_id,
      orden_venta_lines.price_entered,
      orden_venta_lines.price_actual,
      orden_venta_lines.m_product_id,
      orden_venta_lines.qty_entered
    FROM orden_venta
    JOIN orden_venta_lines ON orden_venta.id = orden_venta_lines.orden_venta_id
    WHERE orden_venta.id = ?
  ''', [orderId]);

  // Si no se encontraron resultados, retornar un mapa vacío
  if (resultado.isEmpty) return {};

  // Crear un mapa para almacenar la orden de venta y sus líneas de productos
  Map<String, dynamic> ordenDeVenta = {};

  // Iterar sobre el resultado y construir la estructura deseada
  for (var row in resultado) {
    // Si la orden de venta aún no ha sido agregada al mapa, agregarla
    if (ordenDeVenta.isEmpty) {
      ordenDeVenta = {
        'id': row['id'],
        'c_doctypetarget_id': row['c_doctypetarget_id'],
        'ad_client_id': row['ad_client_id'],
        'ad_org_id': row['ad_org_id'],
        'm_warehouse_id': row['m_warehouse_id'],
        'documentno': row['documentno'],
        'paymentrule': row['paymentrule'],
        'date_ordered': row['date_ordered'],
        'salesrep_id': row['salesrep_id'],
        'c_bpartner_id': row['c_bpartner_id'],
        'c_bpartner_location_id': row['c_bpartner_location_id'],
        'fecha': row['fecha'],
        'descripcion': row['descripcion'],
        'monto': row['monto'],
        'saldo_neto': row['saldo_neto'],
        'usuario_id': row['usuario_id'],
        'cliente_id': row['cliente_id'],
        'status_sincronized': row['status_sincronized'],
        'lines': [] // Inicializar la lista de líneas de productos
      };
    }

    // Agregar la línea de producto actual a la lista de líneas de la orden de venta
    ordenDeVenta['lines'].add({
      'line_id': row['line_id'],
      'ad_client_id': row['ad_client_id'],
      'ad_org_id': row['ad_org_id'],
      'producto_id': row['producto_id'],
      'price_entered': row['price_entered'],
      'price_actual': row['price_actual'],
      'm_product_id': row['m_product_id'],
      'qty_entered': row['qty_entered']
    });
  }

  // Retornar la orden de venta con sus líneas de productos
  return ordenDeVenta;
}

Future<Map<String, dynamic>> obtenerOrdenDeCompraConLineasPorId(
    int orderId) async {
  print(
      'Entre aqui a obtenerordedecomprasconlineas y esta es el orderid $orderId');
  final db = await DatabaseHelper.instance.database;

  final List<Map<String, dynamic>> resultado = await db!.rawQuery('''

    SELECT 
      orden_compra.id,
      orden_compra.c_doc_type_target_id,
      orden_compra.ad_client_id,
      orden_compra.ad_org_id,
      orden_compra.m_warehouse_id,
      orden_compra.documentno,
      orden_compra.payment_rule,
      orden_compra.dateordered,
      orden_compra.sales_rep_id,
      orden_compra.c_bpartner_id,
      orden_compra.c_bpartner_location_id,
      orden_compra.fecha,
      orden_compra.description,
      orden_compra.monto,
      orden_compra.saldo_neto,
      orden_compra.usuario_id,
      orden_compra.proveedor_id,
      orden_compra.status_sincronized,
      orden_compra_lines.id AS line_id,
      orden_compra_lines.producto_id,
      orden_compra_lines.price_entered,
      orden_compra_lines.price_actual,
      orden_compra_lines.m_product_id,
      orden_compra_lines.qty_entered
    FROM orden_compra
    JOIN orden_compra_lines ON orden_compra.id = orden_compra_lines.orden_compra_id
    WHERE orden_compra.id = ?

  ''', [orderId]);

  // Si no se encontraron resultados, retornar un mapa vacío
  if (resultado.isEmpty) return {};

  // Crear un mapa para almacenar la orden de venta y sus líneas de productos
  Map<String, dynamic> ordenDeCompra = {};

  // Iterar sobre el resultado y construir la estructura deseada
  for (var row in resultado) {
    // Si la orden de venta aún no ha sido agregada al mapa, agregarla
    if (ordenDeCompra.isEmpty) {
      ordenDeCompra = {
        'id': row['id'],
        'c_doc_type_target_id': row['c_doc_type_target_id'],
        'ad_client_id': row['ad_client_id'],
        'ad_org_id': row['ad_org_id'],
        'm_warehouse_id': row['m_warehouse_id'],
        'documentno': row['documentno'],
        'payment_rule': row['payment_rule'],
        'dateordered': row['dateordered'],
        'sales_rep_id': row['sales_rep_id'],
        'c_bpartner_id': row['c_bpartner_id'],
        'c_bpartner_location_id': row['c_bpartner_location_id'],
        'fecha': row['fecha'],
        'description': row['description'],
        'monto': row['monto'],
        'saldo_neto': row['saldo_neto'],
        'usuario_id': row['usuario_id'],
        'proveedor_id': row['proveedor_id'],
        'status_sincronized': row['status_sincronized'],
        'lines': [] // Inicializar la lista de líneas de productos
      };
    }

    // Agregar la línea de producto actual a la lista de líneas de la orden de venta
    ordenDeCompra['lines'].add({
      'line_id': row['line_id'],
      'ad_client_id': row['ad_client_id'],
      'ad_org_id': row['ad_org_id'],
      'producto_id': row['producto_id'],
      'price_entered': row['price_entered'],
      'price_actual': row['price_actual'],
      'm_product_id': row['m_product_id'],
      'qty_entered': row['qty_entered']
    });
  }

  // Retornar la orden de venta con sus líneas de productos
  return ordenDeCompra;
}

Future<Map<String, dynamic>?> getClientById(int clientId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Realiza la consulta para recuperar el cliente con el ID especificado
    List<Map<String, dynamic>> results = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [clientId],
    );

    // Verifica si se encontró un cliente con el ID especificado
    if (results.isNotEmpty) {
      // Devuelve el primer cliente encontrado (debería ser único ya que se filtra por ID)
      return results.first;
    } else {
      // Si no se encontró ningún cliente con el ID especificado, devuelve null
      return null;
    }
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return null;
  }
}

Future<String?> getAddressName(int locationId) async {
  final db = await DatabaseHelper.instance.database;

  if(db != null){
  List<Map<String, dynamic>> result = await db.query(
    'address_customers',
    columns: ['name'],
    where: 'c_bpartner_location_id = ?',
    whereArgs: [locationId],
  );

  if (result.isNotEmpty) {
    return result.first['name'] as String?;
  } else {
    return null;
  }
  }
}


Future<List<Map<String, dynamic>>> getSalesOrdersHeader() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> orders = await db.query('orden_venta');

    if (orders.isNotEmpty) {
      return orders;
    } else {
      return [];
    }
  } else {
    print('Error db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getSalesOrdersHeaderForId(cOrderId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> orders = await db.query('orden_venta', where: 'c_order_id = ?' , whereArgs: [cOrderId] );

    if (orders.isNotEmpty) {
      return orders;
    } else {
      return [];
    }
  } else {
    print('Error db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getSalesOrdersHeaderForIdInvoice(int idInvoice) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> orders = await db.query('orden_venta', where: 'id_factura = ?' , whereArgs: [idInvoice] );

    if (orders.isNotEmpty) {
      return orders;
    } else {
      return [];
    }
  } else {
    print('Error db is null');
    return [];
  }
}

Future<String?> getWarehouseName(int mWarehouseId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> result = await db.query(
      'm_warehouse',
      columns: ['name'],
      where: 'm_warehouse_id = ?',
      whereArgs: [mWarehouseId],
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String?;
    } else {
      return null;
    }
  } else {
    print('Error: db is null');
    return null;
  }
}


Future<int?> getTaxCategoryId(int mProductId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> result = await db.query(
      'products',
      columns: ['tax_cat_id'],
      where: 'm_product_id = ?',
      whereArgs: [mProductId],
    );

    if (result.isNotEmpty) {
      return result.first['tax_cat_id'] as int?;
    } else {
      return null;
    }
  } else {
    print('Error: db is null');
    return null;
  }
}

Future<double> getTaxRate(int taxCatId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> result = await db.query(
      'tax',
      columns: ['rate'],
      where: 'c_tax_category_id = ?',
      whereArgs: [taxCatId],
    );

    if (result.isNotEmpty) {
      return result.first['rate'] as double;
    } else {
      return 0.0;
    }
  } else {
    print('Error: db is null');
    return 0.0;
  }
}


Future<int?> getProductId(int mProductId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> result = await db.query(
      'products',
      columns: ['id'],
      where: 'm_product_id = ?',
      whereArgs: [mProductId],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return null;
    }
  } else {
    print('Error: db is null');
    return null;
  }
}



Future<int?> getCustomerId(int cBpartnerId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> result = await db.query(
      'clients',
      columns: ['id'], // Asegúrate de que 'id' es el nombre del campo del cliente en tu tabla
      where: 'c_bpartner_id = ?',
      whereArgs: [cBpartnerId],
    );

    if (result.isNotEmpty) {
      return result.first['id'];
    } else {
      return null; // Devuelve null si no se encuentra el cliente
    }
  } else {
    print('Error: db is null');
    return null;
  }
}



Future<List<Map<String, dynamic>>> getAllCobros() async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    List<Map<String, dynamic>> orders = await db.query('cobros');

    if (orders.isNotEmpty) {
      return orders;
    } else {
      return [];
    }
  } else {
    print('Error db is null');
    return [];
  }
}

Future<Map<String, dynamic>?> getVendorsById(int vendorId) async {
  final db = await DatabaseHelper.instance.database;

  if (db != null) {
    // Realiza la consulta para recuperar el cliente con el ID especificado
    List<Map<String, dynamic>> results = await db.query(
      'providers',
      where: 'id = ?',
      whereArgs: [vendorId],
    );

    // Verifica si se encontró un cliente con el ID especificado
    if (results.isNotEmpty) {
      // Devuelve el primer cliente encontrado (debería ser único ya que se filtra por ID)
      return results.first;
    } else {
      // Si no se encontró ningún cliente con el ID especificado, devuelve null
      return null;
    }
  } else {
    // Manejar el caso en el que db sea null, por ejemplo, lanzar una excepción o mostrar un mensaje de error
    print('Error: db is null');
    return null;
  }
}

Future<List<Map<String, dynamic>>> getCobros(
    {required int page, required int pageSize}) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    final int offset = (page - 1) * pageSize;

    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT cobros.*, 
             c.bp_name AS client_name, 
             o.documentno AS orden_venta_nro, 
             o.fecha AS date_order, 
             o.monto AS total, 
             o.m_price_list_id as list_price_order,
             c.m_pricelist_id AS list_price,
             ROUND(
                 (CAST(REPLACE(REPLACE(o.monto, '.', ''), ',', '.') AS REAL) - 
                 COALESCE((SELECT SUM(pay_amt) FROM cobros WHERE sale_order_id = o.id), 0)),
                 4
             ) AS saldo_total
      FROM cobros
      INNER JOIN orden_venta o ON cobros.sale_order_id = o.id
      INNER JOIN clients c ON o.cliente_id = c.id
      
      UNION ALL
      
      SELECT cobros.*, 
             c.bp_name AS client_name, 
             cobros.documentno AS orden_venta_nro, 
             cobros.date_trx AS date_order, 
             cobros.pay_amt AS total,
             NULL as list_price_order,
             NULL AS list_price,
             cobros.pay_amt AS saldo_total
      FROM cobros
      INNER JOIN clients c ON cobros.c_bpartner_id = c.c_bpartner_id
      WHERE cobros.c_order_id IS NULL AND cobros.c_invoice_id IS NULL
      LIMIT ? OFFSET ?;
    ''', [pageSize, offset]);

    return result;
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return [];
  }
}


Future<List<Map<String, dynamic>>> getCobrosByOrderId(int cOrderId) async {
  final db = await DatabaseHelper.instance.database;
  if (db != null) {
    // Consultar todos los registros de la tabla 'cobros' filtrados por c_order_id
    List<Map<String, dynamic>> result = await db
        .query('cobros', where: 'c_order_id = ?', whereArgs: [cOrderId]);
    return result;
  } else {
    // Manejar el caso en el que db sea null
    print('Error: db is null');
    return [];
  }
}

Future<List<Map<String, dynamic>>> getPaymentTerms() async {
  final db = await DatabaseHelper.instance.database;
  return db!
      .query('payment_term_fr', columns: ['id', 'c_paymentterm_id', 'name']);
}


Future<List<Map<String, dynamic>>> getCobrosForSearchBar(String query) async {
  final db = await DatabaseHelper.instance.database;
  
  if (db != null) {
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT *
      FROM (
          SELECT cobros.*, 
                 c.bp_name AS client_name, 
                 o.documentno AS orden_venta_nro, 
                 o.fecha AS date_order, 
                 o.monto AS total, 
                 o.m_price_list_id as list_price_order,
                 c.m_pricelist_id AS list_price,
                 ROUND(
                     (CAST(REPLACE(REPLACE(o.monto, '.', ''), ',', '.') AS REAL) - 
                     COALESCE((SELECT SUM(pay_amt) FROM cobros WHERE sale_order_id = o.id), 0)),
                     4
                 ) AS saldo_total
          FROM cobros
          INNER JOIN orden_venta o ON cobros.sale_order_id = o.id
          INNER JOIN clients c ON o.cliente_id = c.id
          WHERE c.bp_name LIKE ? OR o.documentno LIKE ? OR cobros.documentno LIKE ?
          
          UNION ALL
          
          SELECT cobros.*, 
                 c.bp_name AS client_name, 
                 cobros.documentno AS orden_venta_nro, 
                 cobros.date_trx AS date_order, 
                 cobros.pay_amt AS total,
                 NULL as list_price_order,
                 NULL AS list_price,
                 cobros.pay_amt AS saldo_total
          FROM cobros
          INNER JOIN clients c ON cobros.c_bpartner_id = c.c_bpartner_id
             WHERE cobros.c_order_id IS NULL AND cobros.c_invoice_id IS NULL
            AND (c.bp_name LIKE ? OR cobros.documentno LIKE ?)
      ) AS combined_results
    ''', ['%$query%', '%$query%', '%$query%', '%$query%', '%$query%']);

    return result;
  } else {
    print('Error: db is null');
    return [];
  }
}
