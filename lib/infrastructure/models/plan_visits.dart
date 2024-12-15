class PlanVisits {
  final dynamic id;
  final dynamic adClientId;
  final dynamic adOrgId;
  final dynamic gssCvpId;
  final dynamic gssCvpLineId;
  final dynamic salesRepId;
  final dynamic salesRepName;
  final dynamic cBPartnerId;
  final dynamic bPartnerName;
  final dynamic cSalesRegionId;
  final dynamic salesRegion;
  final dynamic dateCalendar;
  final dynamic dayNumber;
  final dynamic weekNumber;
        dynamic state;
  final dynamic cBPartnerLocationId;
  PlanVisits(
      {this.id,
      required this.adClientId,
      required this.adOrgId,
      required this.gssCvpId,
      required this.gssCvpLineId,
      required this.salesRepId,
      required this.salesRepName,
      required this.cBPartnerId,
      required this.bPartnerName,
      required this.cSalesRegionId,
      required this.salesRegion,
      required this.dateCalendar,
      required this.dayNumber,
      required this.weekNumber,
      required this.state,
      required this.cBPartnerLocationId
      
      });

  Map<String, dynamic> toMap() {
    return {
    
      "ad_client_id": adClientId,
      "ad_org_id": adOrgId,
      "gss_cvp_id": gssCvpId,
      "gss_cvp_line_id": gssCvpLineId,
      "sales_rep_id": salesRepId,
      "sales_rep_name": salesRepName,
      "c_bpartner_id": cBPartnerId,
      "bpartner_name": bPartnerName,
      "c_sales_region_id": cSalesRegionId,
      "salesregion": salesRegion,
      "date_calendar": dateCalendar,
      "day_number": dayNumber,
      "week_number": weekNumber,
      'c_bpartner_location_id':cBPartnerLocationId,
      "state": state,
    };
  }

  factory PlanVisits.fromJson(Map<String, dynamic> json) {
    return PlanVisits(
      id: json['id'],
      adClientId: json['ad_client_id'],
      adOrgId: json['ad_org_id'],
      gssCvpId: json['gss_cvp_id'],
      gssCvpLineId: json['gss_cvp_line_id'],
      salesRepId: json['sales_rep_id'],
      salesRepName: json['sales_rep_name'],
      cBPartnerId: json['c_bpartner_id'],
      bPartnerName: json['bpartner_name'],
      cSalesRegionId: json['c_sales_region_id'],
      salesRegion: json['salesregion'],
      dateCalendar: DateTime.parse(json['date_calendar']),
      dayNumber: json['day_number'],
      weekNumber: json['week_number'],
      cBPartnerLocationId: json['c_bpartner_location_id'],
      state: json['state'],
    );
  }
}
