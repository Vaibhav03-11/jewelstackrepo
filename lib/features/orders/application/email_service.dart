import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../domain/order_model.dart';

class EmailService {
  
  Future<void> sendInvoiceEmail(Order order, List<String> filePaths) async {
    try {
      final Email email = Email(
        body: '''
Dear ${order.customerName},

Thank you for your order with JewelStack. Please find your invoice attached.

Order Details:
- Order ID: ${order.id}
- Order Date: ${_formatDate(order.orderDate)}
- Total Amount: ₹${order.totalAmount.toStringAsFixed(0)}
- Delivery Date: ${_formatDate(order.estimatedDelivery)}

We appreciate your business and look forward to serving you again.

Best regards,
JewelStack Team
        ''',
        subject: 'JewelStack Invoice - Order #${order.id}',
        recipients: [order.customerContact], // Using contact as email, you might want to store email separately
        cc: [],
        bcc: [],
        attachmentPaths: filePaths,
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
    } catch (e) {
      throw 'Failed to send email: $e';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}