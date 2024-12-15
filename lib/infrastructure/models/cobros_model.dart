






 class CobrosSync {

    final dynamic adClientId;
    final dynamic adOrgId;
    final dynamic cPaymentId;
    final dynamic cBankAccountId;
    final dynamic bankAccountName;
    final dynamic cDocTypeId;
    final dynamic dateTrx;
    final dynamic description;
    final dynamic cBPartnerId;
    final dynamic payAmtBs;
    final dynamic payAmtUsd;
    final dynamic tasaConversion;
    final dynamic date;
    final dynamic mPriceListid;
    final dynamic cCurrencyId;
    final dynamic cOrderId;
    final dynamic cInvoiceId;
    final dynamic documentNoInvoice;
    final dynamic documentNoCobros;
    final dynamic tenderType;
    final dynamic tenderTypeName;
    final dynamic docStatus;
    final dynamic salesRepId;
    final dynamic cCurrencyIso;
    final dynamic orderIdLocal;

  CobrosSync({
   required this.adClientId, 
   required this.adOrgId , 
   required this.cPaymentId, 
   required this.cBankAccountId,
   required this.bankAccountName, 
   required this.cDocTypeId,
   required this.dateTrx,
   required this.description,
   required this.cBPartnerId,
   required this.payAmtBs,
   required this.payAmtUsd,
   required this.tasaConversion,
   required this.date,
   required this.mPriceListid,
   required this.cCurrencyId,
   required this.cOrderId, 
   required this.cInvoiceId,
   required this.documentNoInvoice,
   required this.documentNoCobros,
   required this.tenderType,
   required this.tenderTypeName,
   required this.docStatus,
   required this.salesRepId,
   required this.cCurrencyIso,
   required this.orderIdLocal

   });


  Map<String, dynamic> toMap() {


      return {

        
          'ad_client_id': adClientId,
          'ad_org_id': adOrgId,
          'c_bankaccount_id': cBankAccountId,
          'c_bankaccount_name': bankAccountName,
          'c_doctype_id': cDocTypeId,
          'date_trx': dateTrx,
          'description': description,
          'c_bpartner_id' : cBPartnerId,
          'pay_amt': payAmtUsd,
          'pay_amt_bs': payAmtBs,
          'tasa_conversion': tasaConversion,
          'date': date,
          'list_price' : mPriceListid,
          'c_currency_id' : cCurrencyId,
          'c_currency_iso': cCurrencyIso,
          'c_order_id': cOrderId,
          'c_invoice_id': cInvoiceId,
          'nro_factura': documentNoInvoice,
          'documentno': documentNoCobros,
          'tender_type': tenderType,
          'tender_type_name': tenderTypeName,
          'sale_order_id': orderIdLocal,
          'c_payment_id': cPaymentId,
          'doc_status': docStatus,
      };

  }



 }








