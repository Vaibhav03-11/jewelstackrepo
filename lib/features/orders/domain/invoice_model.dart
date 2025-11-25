class Invoice {
  final String id;
  final String orderId;
  final String customerName;
  final String customerContact;
  final DateTime invoiceDate;
  final List<InvoiceItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final double advancePaid;
  final double balanceDue;
  final DateTime estimatedDelivery;

  Invoice({
    required this.id,
    required this.orderId,
    required this.customerName,
    required this.customerContact,
    required this.invoiceDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.advancePaid,
    required this.balanceDue,
    required this.estimatedDelivery,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'customerName': customerName,
      'customerContact': customerContact,
      'invoiceDate': invoiceDate.millisecondsSinceEpoch,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'advancePaid': advancePaid,
      'balanceDue': balanceDue,
      'estimatedDelivery': estimatedDelivery.millisecondsSinceEpoch,
    };
  }
}

class InvoiceItem {
  final String description;
  final double weight;
  final double rate;
  final double amount;

  InvoiceItem({
    required this.description,
    required this.weight,
    required this.rate,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'weight': weight,
      'rate': rate,
      'amount': amount,
    };
  }
}