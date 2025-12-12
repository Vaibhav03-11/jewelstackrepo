import "package:flutter/material.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;
import "../domain/order_model.dart";
import "save_invoice_stub.dart"
    if (dart.library.html) "save_invoice_web.dart"
    if (dart.library.io) "save_invoice_io.dart";
import "save_doc_stub.dart"
    if (dart.library.html) "save_doc_web.dart"
    if (dart.library.io) "save_doc_io.dart";
import "../../../core/constants/colors.dart";

class InvoiceService {
  // Generate PDF Invoice
  Future<void> generatePdfInvoice(Order order, BuildContext context) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(_buildInvoicePage(order));

      // Save locally on mobile/desktop, download on web
      await savePdf(await pdf.save(), 'invoice_${order.id}.pdf', context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF invoice: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Generate DOC Invoice (text-based)
  Future<void> generateDocInvoice(Order order, BuildContext context) async {
    try {
      final content = _generateDocContent(order);
      await saveDoc(content, 'invoice_${order.id}.doc', context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate DOC invoice: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Prepare both invoice formats; hook email sending after save
  Future<void> emailInvoice(Order order, BuildContext context) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(_buildInvoicePage(order));
      await savePdf(await pdf.save(), 'invoice_${order.id}.pdf', context);

      final docContent = _generateDocContent(order);
      await saveDoc(docContent, 'invoice_${order.id}.doc', context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ready for emailing to ${order.customerName}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to prepare email: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // PDF Widgets
  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'JEWELSTACK',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              'Professional Jewelry Management',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text('123 Jewelry Street, Gold City', style: pw.TextStyle(fontSize: 10)),
            pw.Text('Phone: +91-9876543210 | Email: info@jewelstack.com', style: pw.TextStyle(fontSize: 10)),
            pw.Text('GSTIN: 27ABCDE1234F1Z5', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.Container(
          width: 80,
          height: 80,
          decoration: pw.BoxDecoration(
            color: PdfColors.amber,
            shape: pw.BoxShape.circle,
          ),
          child: pw.Center(
            child: pw.Text(
              'JS',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceTitle(Order order) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'TAX INVOICE',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Invoice No: JS${order.id}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Date: ${_formatDate(order.orderDate)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCustomerAndOrderDetails(Order order) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BILL TO:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(order.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Contact: ${order.customerContact}'),
              if (order.description != null) pw.Text('Order Notes: ${order.description!}'),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ORDER DETAILS:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Order ID: ${order.id}'),
              pw.Text('Order Date: ${_formatDate(order.orderDate)}'),
              pw.Text('Delivery Date: ${_formatDate(order.estimatedDelivery)}'),
              pw.Text('Status: ${_getStatusText(order.status)}'),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(Order order) {
    final makingCharges = order.totalWeight * 500;
    final goldValue = order.totalAmount - makingCharges;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Weight (g)', isHeader: true, textAlign: pw.TextAlign.center),
            _buildTableCell('Purity', isHeader: true, textAlign: pw.TextAlign.center),
            _buildTableCell('Amount (₹)', isHeader: true, textAlign: pw.TextAlign.right),
          ],
        ),
        ...order.items.map(
          (item) => pw.TableRow(
            children: [
              _buildTableCell('${item.type} - ${item.name}'),
              _buildTableCell(item.weight.toStringAsFixed(2), textAlign: pw.TextAlign.center),
              _buildTableCell(order.materialType, textAlign: pw.TextAlign.center),
              _buildTableCell('₹${_calculateItemAmount(item, order).toStringAsFixed(0)}', textAlign: pw.TextAlign.right),
            ],
          ),
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Gold Value', isBold: true),
            _buildTableCell(order.totalWeight.toStringAsFixed(2), isBold: true, textAlign: pw.TextAlign.center),
            _buildTableCell('${_getPurityPercentage(order.materialType)}%', isBold: true, textAlign: pw.TextAlign.center),
            _buildTableCell('₹${goldValue.toStringAsFixed(0)}', isBold: true, textAlign: pw.TextAlign.right),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Making Charges (@₹500/g)', isBold: true),
            _buildTableCell(order.totalWeight.toStringAsFixed(2), isBold: true, textAlign: pw.TextAlign.center),
            _buildTableCell('-', isBold: true, textAlign: pw.TextAlign.center),
            _buildTableCell('₹${makingCharges.toStringAsFixed(0)}', isBold: true, textAlign: pw.TextAlign.right),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(String text,
      {bool isHeader = false, bool isBold = false, pw.TextAlign textAlign = pw.TextAlign.left}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: textAlign,
        style: pw.TextStyle(
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : null,
          fontSize: isHeader ? 10 : 9,
        ),
      ),
    );
  }

  pw.Widget _buildPaymentSummary(Order order) {
    return pw.Container(
      width: 300,
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT SUMMARY',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildPaymentRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}'),
          _buildPaymentRow('Advance Paid', '₹${order.advancePayment.toStringAsFixed(0)}'),
          _buildPaymentRow(
            'Balance Due',
            '₹${order.balanceDue.toStringAsFixed(0)}',
            isBold: true,
            color: order.balanceDue > 0 ? PdfColors.red : PdfColors.green,
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'NET AMOUNT:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentRow(String label, String value, {bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTermsAndConditions() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Terms & Conditions:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(' Gold rate is subject to market changes'),
        pw.Text(' Making charges are non-refundable'),
        pw.Text(' Delivery date is estimated and may vary'),
        pw.Text(' Goods once sold cannot be returned or exchanged'),
        pw.Text(' Certificate of authenticity provided with each piece'),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.Column(
              children: [
                pw.Text('For JewelStack'),
                pw.SizedBox(height: 20),
                pw.Text('_________________________'),
                pw.Text('Authorized Signature'),
              ],
            ),
            pw.Column(
              children: [
                pw.Text('Customer Acceptance'),
                pw.SizedBox(height: 20),
                pw.Text('_________________________'),
                pw.Text('Customer Signature'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Center(
          child: pw.Text(
            'Thank you for your business! Visit us again.',
            style: pw.TextStyle(
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  pw.Page _buildInvoicePage(Order order) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildInvoiceTitle(order),
            pw.SizedBox(height: 15),
            _buildCustomerAndOrderDetails(order),
            pw.SizedBox(height: 20),
            _buildItemsTable(order),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.topRight,
              child: _buildPaymentSummary(order),
            ),
            pw.SizedBox(height: 25),
            _buildTermsAndConditions(),
            pw.Spacer(),
            _buildFooter(),
          ],
        );
      },
    );
  }

  // DOC Content Generation
  String _generateDocContent(Order order) {
    final makingCharges = order.totalWeight * 500;
    final goldValue = order.totalAmount - makingCharges;

    return '''
JEWELSTACK - TAX INVOICE
========================

Invoice No: JS${order.id}
Date: ${_formatDate(order.orderDate)}

COMPANY DETAILS:
JewelStack - Professional Jewelry Management
123 Jewelry Street, Gold City
Phone: +91-9876543210 | Email: info@jewelstack.com
GSTIN: 27ABCDE1234F1Z5

BILL TO:
${order.customerName}
Contact: ${order.customerContact}

ORDER DETAILS:
Order ID: ${order.id}
Order Date: ${_formatDate(order.orderDate)}
Delivery Date: ${_formatDate(order.estimatedDelivery)}
Status: ${_getStatusText(order.status)}

ORDER ITEMS:
${_generateItemsTable(order)}

PAYMENT SUMMARY:
${_generatePaymentSummary(order)}

BREAKDOWN:
Gold Value (${order.totalWeight}g @ ${_getPurityPercentage(order.materialType)}%): ₹${goldValue.toStringAsFixed(0)}
Making Charges (${order.totalWeight}g @ ₹500/g): ₹${makingCharges.toStringAsFixed(0)}
Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}
Advance Paid: ₹${order.advancePayment.toStringAsFixed(0)}
Balance Due: ₹${order.balanceDue.toStringAsFixed(0)}

TERMS & CONDITIONS:
 Gold rate is subject to market changes
 Making charges are non-refundable
 Delivery date is estimated and may vary
 Goods once sold cannot be returned or exchanged
 Certificate of authenticity provided with each piece

AUTHORIZED SIGNATURES:

For JewelStack: _________________________

Customer Acceptance: _________________________

Thank you for your business! Visit us again.
    ''';
  }

  String _generateItemsTable(Order order) {
    final buffer = StringBuffer();
    buffer.writeln('Description\t\tWeight(g)\tPurity\tAmount(₹)');
    buffer.writeln('-----------\t\t---------\t------\t--------');

    for (var item in order.items) {
      buffer.writeln('${item.type} - ${item.name}\t\t${item.weight.toStringAsFixed(2)}\t\t${order.materialType}\t₹${_calculateItemAmount(item, order).toStringAsFixed(0)}');
    }

    return buffer.toString();
  }

  String _generatePaymentSummary(Order order) {
    return '''
Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}
Advance Paid: ₹${order.advancePayment.toStringAsFixed(0)}
Balance Due: ₹${order.balanceDue.toStringAsFixed(0)}
Net Amount: ₹${order.totalAmount.toStringAsFixed(0)}
    ''';
  }

  // Helper methods
  double _calculateItemAmount(OrderItem item, Order order) {
    final totalWeight = order.items.fold(0.0, (sum, i) => sum + i.weight);
    if (totalWeight == 0) return 0;
    return (item.weight / totalWeight) * order.totalAmount;
  }

  String _getPurityPercentage(String materialType) {
    switch (materialType) {
      case '22K Gold':
        return '91.6';
      case '18K Gold':
        return '75.0';
      case '24K Gold':
        return '99.9';
      case 'Platinum':
        return '95.0';
      case 'Silver':
        return '92.5';
      default:
        return '100.0';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
