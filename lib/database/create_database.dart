import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<void> deleteDatabases() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, 'sales_force.db');

    // Elimina la base de datos si existe
    await deleteDatabase(dbPath);
    print('Base de datos eliminada');

    // Llama al método _initDatabase para crear la base de datos con la nueva estructura
    await _initDatabase();
    print('Base de datos creada nuevamente');
  }

  initDatabase() async {
    // Obtener la ruta del directorio donde se almacenará la base de datos
    String databasesPath = await getDatabasesPath();
    String dbpath = path.join(databasesPath, 'sales_force.db');

    // Verificar si la base de datos ya existe
    bool exists = await databaseExists(dbpath);

    if (exists) {
      print("base de datos si existe");
    } else {
      print("base de datos creada");
      await _initDatabase();
    }
  }

  Future<Database> _initDatabase() async {
    print("Entré aquí en init database");
    String databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, 'sales_force.db');
    // Abre la base de datos o crea una nueva si no existe
    Database database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
        
          CREATE TABLE visit_customer(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_bpartner_id INTEGER,
            c_bpname STRING,
            c_bpartner_location_id INTEGER,
            direccion STRING,
            c_sales_region_id INTEGER,
            coordinates TEXT,
            description STRING,
            end_date TEXT,
            sales_rep_id INTEGER,
            visit_date TEXT,
            gss_customer_visit_concept_id INTEGER,
            motivo STRING,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            record_customer_visit_id INTEGER,
            latitude REAL,
            longitud REAL,
            planned STRING,
            state TEXT
          )
        ''');


         await db.execute('''
        
          CREATE TABLE m_warehouse(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            m_warehouse_id INTEGER,
            value INTEGER,
            name TEXT
          )

        ''');   

        await db.execute('''
        
          CREATE TABLE visits_concepts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gss_customer_visit_concept_id INTEGER,
            value INTEGER,
            name TEXT
          )
        ''');

        await db.execute('''
        
          CREATE TABLE center_costs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_element_value_id INTEGER,
            name INTEGER,
            value TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE state(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_region_id INTEGER,
            name STRING,
            c_country_id INTEGER

          )
        ''');

        await db.execute('''
          CREATE TABLE price_sales_list(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            m_pricelist_id INTEGER,
            price_list_name STRING,
            c_currency_id INTEGER,
            m_product_id INTEGER,
            price_list REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE region_sales_visits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_sales_region_id INTEGER,
            name STRING,
            cod INTEGER,
            sales_rep_id INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE plan_visits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            gss_cvp_id INTEGER,
            gss_cvp_line_id INTEGER,
            sales_rep_id INTEGER,
            sales_rep_name STRING,
            c_bpartner_id INTEGER,
            bpartner_name STRING,
            c_sales_region_id INTEGER, 
            salesregion STRING,
            date_calendar STRING,
            day_number INTEGER,
            week_number INTEGER,
            c_bpartner_location_id INTEGER,
            state STRING,
            FOREIGN KEY (c_bpartner_id) REFERENCES clients(c_bpartner_id)

          )
        ''');

        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cod_product INTEGER,
            m_product_id INTEGER,
            name TEXT,
            quantity REAL,
            price REAL,
            product_type STRING,
            product_type_name STRING,
            pro_cat_id INTEGER,
            categoria TEXT,
            tax_cat_id INTEGER,
            tax_cat_name STRING,
            product_group_id INTEGER,
            product_group_name STRING,
            um_id INTEGER,
            um_name STRING,
            quantity_sold INTEGER,
            pricelistsales INTEGER,
            FOREIGN KEY(tax_cat_id) REFERENCES tax(id),
            FOREIGN KEY(m_product_id) REFERENCES price_sales_list(m_product_id)

          )
        ''');

        await db.execute('''
        CREATE TABLE clients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_bpartner_id INTEGER,
            cod_client INTEGER,
            bp_name TEXT,
            c_bp_group_id INTEGER,
            group_bp_name STRING,
            lco_tax_id_typeid INTEGER,
            tax_id_type_name STRING,
            email STRING,
            c_bpartner_location_id INTEGER,
            is_bill_to STRING,
            phone STRING,
            c_location_id INTEGER,
            city STRING,
            region STRING,
            country STRING,
            code_postal INTEGER,
            c_city_id INTEGER,
            c_region_id TEXT,
            c_country_id INTEGER,
            ruc TEXT,
            address STRING,
            lco_tax_payer_typeid INTEGER,
            tax_payer_type_name STRING,
            lve_person_type_id INTEGER,
            person_type_name STRING,
            m_pricelist_id INTEGER,
            c_payment_term_id INTEGER,
            delivery_rule TEXT,
            delivery_via_rule TEXT,
            invoice_rule TEXT,
            payment_rule TEXT,
            FOREIGN KEY (c_bpartner_id) REFERENCES address_customers(c_bpartner_id)

        )

    ''');


        await db.execute('''
          CREATE TABLE tr_discount_documents(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER,
            discount_id INTEGER,
            monto_importe REAL,
            percent_discount REAL,
            FOREIGN KEY (order_id) REFERENCES orden_venta(id),
            FOREIGN KEY (discount_id) REFERENCES discount_documents(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE discount_documents(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            m_discount_schema_id INTEGER,
            name STRING,
            discount REAL,
            limit_discount REAL,
            c_charge_id INTEGER,
            rate REAL
          )
        ''');   

        await db.execute('''
          CREATE TABLE address_customers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name STRING,
            c_bpartner_location_id INTEGER,
            c_sales_region_id INTEGER,
            c_bpartner_id INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE orden_venta (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          c_doctypetarget_id INTEGER,
          ad_client_id INTEGER,
          ad_org_id INTEGER,
          m_warehouse_id INTEGER,
          documentno INTEGER,
          c_order_id INTEGER,
          paymentrule INTEGER,
          date_ordered TEXT,
          salesrep_id INTEGER,
          c_bpartner_id INTEGER,
          c_bpartner_location_id INTEGER,
          fecha TEXT,
          descripcion TEXT,
          id_factura TEXT,
          documentno_factura TEXT,
          saldo_exento REAL,
          saldo_impuesto REAL,
          monto REAL,
          saldo_neto REAL,
          usuario_id INTEGER,
          cliente_id INTEGER,
          status_sincronized STRING,
          doc_status STRING,
          due_date TEXT,
          desc_prontopago REAL,
          desc_pagoefectivo REAL,
          total_desc REAL,
          address STRING,
          m_price_list_id INTEGER,
          m_warehouse_name_dispatch TEXT,
          cargos TEXT,
          is_tax_with_holding_iva TEXT,
          FOREIGN KEY (cliente_id) REFERENCES clients(id),
          FOREIGN KEY (usuario_id) REFERENCES usuarios(ad_user_id)
        )
      ''');

        await db.execute('''

        CREATE TABLE orden_venta_lines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orden_venta_id INTEGER,
            producto_id INTEGER,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            m_warehouse_id INTEGER,
            price_entered INTEGER,
            price_actual INTEGER,
            m_product_id INTEGER,
            qty_entered INTEGER,
            FOREIGN KEY (orden_venta_id) REFERENCES orden_venta(id),
            FOREIGN KEY (producto_id) REFERENCES products(id)
        )

      ''');

        await db.execute('''
          CREATE TABLE cobros(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ad_client_id INTEGER,
            ad_org_id INTEGER,
            c_bankaccount_id INTEGER,
            c_bankaccount_name STRING,
            c_doctype_id INTEGER,
            date_trx TEXT,
            description TEXT,
            c_bpartner_id INTEGER,
            pay_amt REAL,
            pay_amt_bs REAL,
            tasa_conversion REAL,
            date TEXT,
            list_price INTEGER,
            c_currency_id INTEGER,
            c_currency_iso STRING,
            c_order_id INTEGER,
            c_invoice_id INTEGER,
            nro_factura TEXT,
            documentno INTEGER,
            tender_type STRING,
            tender_type_name STRING,
            sale_order_id INTEGER,
            c_payment_id INTEGER,
            doc_status TEXT,
            FOREIGN KEY (sale_order_id) REFERENCES orden_venta(id)
            
          )
        ''');

        await db.execute('''
          CREATE TABLE usuarios(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            name TEXT,
            password INTEGER,
            ad_user_id TEXT,
            email TEXT,
            phone TEXT
            )
        ''');

        await db.execute('''
          CREATE TABLE posproperties(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            country_id INTEGER,
            tax_payer_type_natural INTEGER,
            tax_payer_type_juridic INTEGER,
            person_type_juridic INTEGER,
            person_type_natural INTEGER,
            m_warehouse_id INTEGER,
            c_doc_type_order_id INTEGER,
            c_conversion_type_id INTEGER,
            c_paymentterm_id INTEGER,
            c_bankaccount_id INTEGER,
            c_bpartner_id INTEGER,
            c_doctypepayment_id INTEGER,
            c_doctypereceipt_id INTEGER,
            city STRING,
            address1 STRING, 
            m_pricelist_id INTEGER,
            m_price_saleslist_id INTEGER,
            c_currency_id INTEGER,
            c_doc_type_order_co INTEGER,
            doc_status_receipt STRING,
            doc_status_invoice_so STRING,
            doc_status_order_so STRING,
            doc_status_order_po STRING,
            c_doc_type_target_fr INTEGER,
            c_chargediscount1_id INTEGER,
            c_chargediscount2_id INTEGER,
            discount1 TEXT,
            discount2 TEXT
            
            )
        ''');

        await db.execute('''
          CREATE TABLE tax(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          c_tax_id INTEGER,
          tax_indicator STRING,
          rate REAL,
          name TEXT,
          c_tax_category_id INTEGER,
          iswithholding TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE bank_account_app(
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          c_bank_id INTEGER,
          bank_name STRING,
          routing_no TEXT,
          c_bank_account_id INTEGER,
          account_no TEXT,
          c_currency_id INTEGER,
          iso_code STRING
          )
        ''');

        await db.execute('''
          CREATE TABLE rate_conversion(
            
          id INTEGER PRIMARY KEY AUTOINCREMENT, 
          valid_from  STRING,
          valid_to STRING,
          multiply_rate STRING,
          c_currency_id_to INTEGER

          )
        ''');
      },
    );

    return database;
  }
}
