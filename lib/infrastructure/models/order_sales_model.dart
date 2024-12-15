






 class OrderSalesModel {

    final dynamic id;
    final dynamic clienteId;
    final dynamic documentNo;
    final dynamic fecha;
    final dynamic descripcion;
    final dynamic monto;
    final dynamic saldoNeto;
    final dynamic productos;
    final dynamic cBPartnerId;
    final dynamic cBPartnerLocationId;
    final dynamic cDocTypeTargetId;
    final dynamic adClientId;
    final dynamic adOrgId;
    final dynamic mWareHouseId;
    final dynamic paymentRule;
    final dynamic dateOrdered;
    final dynamic salesRepId;
    final dynamic usuarioId;
    final dynamic saldoExento;
    final dynamic mWareHouseNameDispatch;
    final dynamic saldoImpuesto;
    final dynamic statusSincronized;
    final dynamic descProntoPago;
    final dynamic descPagoEfectivo;
    final dynamic totalDesc;
    final dynamic cargos; 
    final dynamic address;
    final dynamic cInvoiceId;
    final dynamic documentNoInvoice;
    final dynamic docStatus;
    final dynamic cOrderId;
    final dynamic dueDate;
    final dynamic mPriceListId;


  OrderSalesModel({
   this.id,
   required this.cBPartnerId, 
   required this.adClientId , 
   required this.adOrgId, 
   required this.cDocTypeTargetId,
   required this.cargos, 
   required this.clienteId,
   required this.dateOrdered,
   required this.descPagoEfectivo,
   required this.descProntoPago,
   required this.descripcion,
   required this.cBPartnerLocationId,
   required this.documentNo,
   required this.fecha,
   required this.mWareHouseId,
   required this.address,
   required this.mWareHouseNameDispatch, 
   required this.monto,
   required this.paymentRule,
   required this.productos,
   required this.saldoExento,
   required this.saldoImpuesto,
   required this.saldoNeto,
   required this.salesRepId,
   required this.statusSincronized,
   required this.totalDesc,
   required this.usuarioId,
   required this.documentNoInvoice,
   required this.cInvoiceId,
   required this.docStatus,
   required this.cOrderId,
   required this.dueDate,
   required this.mPriceListId
   });


  Map<String, dynamic> toMap() {

      print('Esto es el cInvoicedId $cInvoiceId y este es el documentNoInvoice $documentNoInvoice');

  
      return {

        
          'cliente_id': clienteId,
          'documentno': documentNo,
          'fecha': fecha,
          'saldo_neto': saldoNeto,
          'productos': productos,
          'c_bpartner_id': cBPartnerId,
          'c_bpartner_location_id': cBPartnerLocationId,
          'c_doctypetarget_id' : cDocTypeTargetId,
          'ad_client_id': adClientId,
          'ad_org_id': adOrgId,
          'm_warehouse_id': mWareHouseId,
          'payment_rule' : paymentRule,
          'date_ordered' : dateOrdered,
          'salesrep_id': salesRepId,
          'usuario_id': usuarioId,
          'saldo_exento': saldoExento,
          'm_warehouse_name_dispatch': mWareHouseNameDispatch,
          'saldo_impuesto': saldoImpuesto,
          'status_sincronized': statusSincronized,
          'desc_prontopago': descProntoPago,
          'desc_pagoefectivo': descPagoEfectivo,
          'total_desc': totalDesc,
          'cargos': cargos,
          'address': address,
          'monto': monto,
          'descripcion': descripcion,
          'c_invoice_id': cInvoiceId != '{@nil: true}' ? cInvoiceId : null,
          'documentno_invoice': documentNoInvoice != '{@nil: true}' ? documentNoInvoice : null ,
          'doc_status': docStatus,
          'c_order_id': cOrderId,
          'due_date': dueDate,
          'm_price_list_id': mPriceListId,

      };

  }



 }








