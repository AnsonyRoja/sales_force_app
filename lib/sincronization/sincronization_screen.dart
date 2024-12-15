import 'package:sales_force/config/app_bar_sales_force.dart';
import 'package:sales_force/config/getPosProperties.dart';
import 'package:sales_force/database/create_database.dart';
import 'package:sales_force/presentation/cobranzas/idempiere/getRateConversion.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:sales_force/sincronization/helpers/container_indicators.dart';
import 'package:sales_force/sincronization/helpers/container_indicators_update_flag.dart';
import 'package:sales_force/sincronization/https/address_customer.dart';
import 'package:sales_force/sincronization/https/bank_account.dart';
import 'package:sales_force/sincronization/https/discount_document_http.dart';
import 'package:sales_force/sincronization/https/get_cobros.dart';
import 'package:sales_force/sincronization/https/get_order_sales.dart';
import 'package:sales_force/sincronization/https/get_plan_visits_http.dart';
import 'package:sales_force/sincronization/https/get_status_documents.dart';
import 'package:sales_force/sincronization/https/get_status_payments.dart';
import 'package:sales_force/sincronization/https/get_ware_house_http%20.dart';
import 'package:sales_force/sincronization/https/impuesto_http.dart';
import 'package:sales_force/sincronization/https/price_sales_list_products.dart';
import 'package:sales_force/sincronization/https/region_sales_visits_http.dart';
import 'package:sales_force/sincronization/https/search_id_invoice.dart';
import 'package:sales_force/sincronization/https/states_http.dart';
import 'package:sales_force/sincronization/https/visits_concepts_http.dart';
import 'package:sales_force/sincronization/sincronizar_create.dart';
import 'package:flutter/material.dart';
import 'package:sales_force/sincronization/widgets/empty_database.dart';
import 'package:sizer/sizer.dart';

double syncPercentage = 0.0; // Estado para mantener el porcentaje sincronizado
double syncPercentageClient = 0.0;
double syncPercentageProviders = 0.0;
double syncPercentageSelling = 0.0;
double syncPercentageVisits = 0.0;
double syncPercentageImpuestos = 0.0;
double syncPercentageBankAccount = 0.0;
double syncPercentageAddressCustomers = 0.0;
double syncPercentageOrderSales = 0.0;
double syncPercentageCobros = 0.0;

bool setearValoresEnCero = true;

class SynchronizationScreen extends StatefulWidget {
  const SynchronizationScreen({super.key});

  @override
  _SynchronizationScreenState createState() => _SynchronizationScreenState();
}

class _SynchronizationScreenState extends State<SynchronizationScreen> {
  GlobalKey<_SynchronizationScreenState> synchronizationScreenKey =
      GlobalKey<_SynchronizationScreenState>();
  bool _enableButtons = true;
  bool _enableContainerAddressCustomer = true;

  _updateEnableOption(bool enableButton) {
    setState(() {
      _enableContainerAddressCustomer = enableButton;
    });
  }

  void deleteDB() async {
    await DatabaseHelper.instance.deleteDatabases();
  }

  @override
  void initState() {
    // deleteDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaScreen = MediaQuery.of(context).size.width * 0.9;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 245, 235),
      key: synchronizationScreenKey,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(170),
          child: AppBars(labelText: 'Sincronización')),
      body: Column(
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ContainerIndicators(
                    text: 'Productos',
                    syncPercentagesIndicators: syncPercentage),
                ContainerIndicators(
                    text: 'Clientes',
                    syncPercentagesIndicators: syncPercentageClient),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

              
                ContainerIndicators(
                    text: 'Impuestos',
                    syncPercentagesIndicators: syncPercentageImpuestos),
                 ContainerIndicators(
                    text: 'Cuentas Bancarias',
                    syncPercentagesIndicators: syncPercentageBankAccount),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
       
                ContainerIndicators(
                    text: 'Plan de Visitas',
                    syncPercentagesIndicators: syncPercentageVisits),
                      ContainerIndicatorsUpdateFlag(
                  text: 'Direcciones, Cliente',
                  syncPercentagesIndicators: syncPercentageAddressCustomers,
                  updateEnableOption: _updateEnableOption,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                    ContainerIndicators(
                        text: 'Ordernes de Ventas',
                        syncPercentagesIndicators: syncPercentageOrderSales),
                    ContainerIndicators(
                        text: 'Cobros',
                        syncPercentagesIndicators: syncPercentageCobros),
            

                  
              ],
            ),
          ),
          SizedBox(height: 5.sp,),
          SizedBox(
            width: mediaScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Divider(),
                Text('Creacion', style: TextStyle(fontFamily: 'Poppins Bold', fontSize: 19.sp) , textAlign: TextAlign.start,),
                Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ContainerIndicators(
                        text: 'Ventas',
                        syncPercentagesIndicators: syncPercentageSelling),
                       

                  ],
                ),
              ),

              
              ],
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 7,
                  spreadRadius: 1,
                )
              ]),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0XFF00722D)),
                  elevation: WidgetStateProperty.all<double>(0),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide.none)),
                ),
                onPressed: _enableButtons
                    ? () async {
                        // Llamada a la función de sincronización
                        setState(() {
                          _enableButtons = false;
                        });

                        if (setearValoresEnCero == false) {
                          setState(() {
                            syncPercentage = 0;
                            syncPercentageClient = 0;
                            syncPercentageImpuestos = 0;
                            syncPercentageProviders = 0;
                            syncPercentageSelling = 0;
                            syncPercentageBankAccount = 0;
                            syncPercentageVisits = 0;
                            syncPercentageAddressCustomers = 0;
                            syncPercentageOrderSales = 0;
                            syncPercentageCobros = 0;
                            setearValoresEnCero = true;
                          });
                        }
                        
                        // sincronizationCenterCosts();

                        getRateConversion().then((value) {
                          if (value == false) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35)),
                                  title: Text('No hay conexión a Internet'),
                                  content: Text(
                                      'Por favor, verifica tu conexión y vuelve a intentarlo.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Aceptar'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Cierra el diálogo
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            setState(() {
                              _enableButtons = true;
                            });
                            return;
                          }
                        });
                        sincronizationDiscountDocument();
                        getPosPropertiesInit();
                        await sincronizationPriceSalesListProducts();
                        sincronizationStates();
                        sincronizationPlanVisits();
                        sincronizationRegionSalesVisits();
                        sincronizationVisitsConcepts();
                        sincronizationWareHouse();

                        List<Map<String, dynamic>> response =
                            await getPosPropertiesV();

                        setState(() {
                          variablesG = response;
                        });
                        sincronizationStatusPayments();
                        sincronizationBankAccount(setState);
                        sincronizationImpuestos(setState);
                        sincronizationStatusDocumentsOrder();
                        await synchronizeCustomersWithIdempiere(setState);
                        if (_enableContainerAddressCustomer) {
                          await sincronizationAddressCustomer(setState, mounted);
                        }
                        await synchronizeProductsWithIdempiere(setState);
                        await synchronizeVisitsWithIdempiere(setState);
                        await sincronizationOrderSalesInProcess(setState);
                        await sincronizationSearchIdInvoice(setState);
                        await sincronizationCobros(setState);
                        await synchronizeOrderSalesWithIdempiere(setState);

                        setState(() {
                          _enableButtons = true;
                          setearValoresEnCero = false;
                        });
                      }
                    : null,
                child: Text(
                  'Sincronizar',
                  style: TextStyle(
                      fontFamily: 'Poppins Bold',
                      fontSize: 17,
                      color: _enableButtons
                          ? Color(0XFFFFFFFF)
                          : Color.fromARGB(255, 82, 78, 78)),
                ),
              ),
            ),
          ),
          EmptyDatabase(),
        ],
      ),
    );
  }
}
