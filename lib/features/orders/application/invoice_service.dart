import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import '../domain/order_model.dart';
import '../../../core/constants/colors.dart';

class InvoiceService {
  
  // Generate PDF Invoice
  Future<void> generatePdfInvoice(Order order, BuildContext context) async {
    try {
      final pdf = pw.Document();

      // Add invoice page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with logo and company info
                _buildHeader(),
                pw.SizedBox(height: 20),
                
                // Invoice title and details
                _buildInvoiceTitle(order),
                pw.SizedBox(height: 15),
                
                // Customer and order details
                _buildCustomerAndOrderDetails(order),
                pw.SizedBox(height: 20),
                
                // Items table
                _buildItemsTable(order),
                pw.SizedBox(height: 20),
                
                // Payment summary
                _buildPaymentSummary(order),
                pw.SizedBox(height: 25),
                
                // Terms and conditions
                _buildTermsAndConditions(),
                pw.SizedBox(height: 20),
                
                // Footer
                _buildFooter(),
              ],
            );
          },
        ),
      );

      // Save and open PDF
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/invoice_${order.id}.pdf");
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF invoice generated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF invoice: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Generate DOC Invoice (using .docx format with a template)
  Future<void> generateDocInvoice(Order order, BuildContext context) async {
    try {
      // Create a comprehensive text document that can be saved as .doc
      final String content = _generateDocContent(order);

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/invoice_${order.id}.doc");
      await file.writeAsString(content);

      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DOC invoice generated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate DOC invoice: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Email Invoice
  Future<void> emailInvoice(Order order, BuildContext context) async {
    try {
      // Generate both PDF and DOC
      final output = await getTemporaryDirectory();
      final pdfFile = File("${output.path}/invoice_${order.id}.pdf");
      final docFile = File("${output.path}/invoice_${order.id}.doc");
      
      // Generate PDF
      final pdf = pw.Document();
      pdf.addPage(_buildInvoicePage(order));
      await pdfFile.writeAsBytes(await pdf.save());
      
      // Generate DOC
      final docContent = _generateDocContent(order);
      await docFile.writeAsString(docContent);

      // Here you would integrate with email service
      // For now, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ready for emailing to ${order.customerName}'),
          backgroundColor: AppColors.success,
        ),
      );

      // You can integrate with flutter_email_sender package here
      // await FlutterEmailSender.send(email);

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
            pw.Text(
              '123 Jewelry Street, Gold City',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Phone: +91-9876543210 | Email: info@jewelstack.com',
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'GSTIN: 27ABCDE1234F1Z5',
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        // You can add logo here
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
        // Customer Details
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
        
        // Order Details
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

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ORDER ITEMS',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 14,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                pw.Padding(
                  child: pw.Text(
                    'Description',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    'Weight (g)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    'Purity',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    'Amount (₹)',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.right,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
              ],
            ),
            
            // Item rows
            ...order.items.map((item) => pw.TableRow(
              children: [
                pw.Padding(
                  child: pw.Text('${item.type} - ${item.name}'),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    item.weight.toStringAsFixed(2),
                    textAlign: pw.TextAlign.center,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    order.materialType,
                    textAlign: pw.TextAlign.center,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    '₹${_calculateItemAmount(item, order).toStringAsFixed(0)}',
                    textAlign: pw.TextAlign.right,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
              ],
            )),
            
            // Gold value row
            pw.TableRow(
              children: [
                pw.Padding(
                  child: pw.Text('Gold Value'),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    order.totalWeight.toStringAsFixed(2),
                    textAlign: pw.TextAlign.center,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    '${_getPurityPercentage(order.materialType)}%',
                    textAlign: pw.TextAlign.center,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    '₹${goldValue.toStringAsFixed(0)}',
                    textAlign: pw.TextAlign.right,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
              ],
            ),
            
            // Making charges row
            pw.TableRow(
              children: [
                pw.Padding(
                  child: pw.Text('Making Charges (@₹500/g)'),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    order.totalWeight.toStringAsFixed(2),
                    textAlign: pw.TextAlign.center,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text('-'),
                  padding: pw.EdgeInsets.all(8),
                ),
                pw.Padding(
                  child: pw.Text(
                    '₹${makingCharges.toStringAsFixed(0)}',
                    textAlign: pw.TextAlign.right,
                  ),
                  padding: pw.EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ],
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
          _buildPaymentRow('Balance Due', '₹${order.balanceDue.toStringAsFixed(0)}',
              isBold: true, color: order.balanceDue > 0 ? PdfColors.red : PdfColors.green),
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
        pw.Text('• Gold rate is subject to market changes'),
        pw.Text('• Making charges are non-refundable'),
        pw.Text('• Delivery date is estimated and may vary'),
        pw.Text('• Goods once sold cannot be returned or exchanged'),
        pw.Text('• Certificate of authenticity provided with each piece'),
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
• Gold rate is subject to market changes
• Making charges are non-refundable
• Delivery date is estimated and may vary
• Goods once sold cannot be returned or exchanged
• Certificate of authenticity provided with each piece

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
    // Distribute total amount proportionally by weight
    final totalWeight = order.items.fold(0.0, (sum, i) => sum + i.weight);
    if (totalWeight == 0) return 0;
    return (item.weight / totalWeight) * order.totalAmount;
  }

  String _getPurityPercentage(String materialType) {
    switch (materialType) {
      case '22K Gold': return '91.6';
      case '18K Gold': return '75.0';
      case '24K Gold': return '99.9';
      case 'Platinum': return '95.0';
      case 'Silver': return '92.5';
      default: return '100.0';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.inProgress: return 'In Progress';
      case OrderStatus.ready: return 'Ready';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
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
            _buildPaymentSummary(order),
            pw.SizedBox(height: 25),
            _buildTermsAndConditions(),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ],
        );
      },
    );
  }
}