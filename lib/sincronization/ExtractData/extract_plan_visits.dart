import 'dart:convert';

List<Map<String, dynamic>> extractPlanVisits(String responseData) {
  Map<String, dynamic> parsedResponse = jsonDecode(responseData);

  print('esta es la respuesta parsedResponse  $parsedResponse');
  List<dynamic> dataRows =
      parsedResponse['WindowTabData']['DataSet']['DataRow'] is Map ? [parsedResponse['WindowTabData']['DataSet']['DataRow']]: parsedResponse['WindowTabData']['DataSet']['DataRow'];

  List<Map<String, dynamic>> planVisits = [];

  print('Esto es la respuesta del endpount price sales list $dataRows');

  try {
    for (var row in dataRows) {
      print('Estos son los rows $row');

      Map<String, dynamic> planVisit = {
        'ad_client_id': row['field']
            .firstWhere((field) => field['@column'] == 'AD_Client_ID')['val'],
        'ad_org_id': row['field']
            .firstWhere((field) => field['@column'] == 'AD_Org_ID')['val'],
        'gss_cvp_id': row['field']
            .firstWhere((field) => field['@column'] == 'GSS_CVP_ID')['val'],
        'gss_cvp_line_id': row['field']
            .firstWhere((field) => field['@column'] == 'GSS_CVPLine_ID')['val'],
        'sales_rep_id': row['field']
            .firstWhere((field) => field['@column'] == 'SalesRep_ID')['val'],
        'sales_rep_name': row['field']
            .firstWhere((field) => field['@column'] == 'SalesRep_Name')['val'],
        'c_bpartner_id': row['field']
            .firstWhere((field) => field['@column'] == 'C_BPartner_ID')['val'],
        'bpartner_name': row['field']
            .firstWhere((field) => field['@column'] == 'bpartner_name')['val'],
        'c_sales_region_id': row['field'].firstWhere(
            (field) => field['@column'] == 'C_SalesRegion_ID')['val'],
        'salesregion': row['field']
            .firstWhere((field) => field['@column'] == 'salesregion')['val'],
        'date_calendar': row['field']
            .firstWhere((field) => field['@column'] == 'date_calendar')['val'],
        'day_number': row['field']
            .firstWhere((field) => field['@column'] == 'daynumber')['val'],
        'week_number': row['field']
            .firstWhere((field) => field['@column'] == 'WeekNumber')['val'],
        'c_bpartner_location_id': row['field']
            .firstWhere((field) => field['@column'] == 'C_BPartner_Location_ID')['val'],
        'state': 'No Visits'
      };

      planVisits.add(planVisit);
    }
  } catch (e) {
    print("ESTE ES EL ERROR $e");
  }

  print("Estos son los estados disponibles desde idempiere $planVisits");

  return planVisits;
}
