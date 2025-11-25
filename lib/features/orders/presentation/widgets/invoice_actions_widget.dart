import 'package:flutter/material.dart';
import '../../application/invoice_service.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';

class InvoiceActionsWidget extends StatelessWidget {
  final Order order;
  final InvoiceService invoiceService = InvoiceService();

  InvoiceActionsWidget({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primaryGold),
                SizedBox(width: 8),
                Text(
                  'Invoice Generation',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Generate and manage invoices for this order:',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildInvoiceButton(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF Invoice',
                  color: AppColors.error,
                  onPressed: () => invoiceService.generatePdfInvoice(order, context),
                ),
                _buildInvoiceButton(
                  icon: Icons.description,
                  label: 'DOC Invoice',
                  color: Colors.blue,
                  onPressed: () => invoiceService.generateDocInvoice(order, context),
                ),
                _buildInvoiceButton(
                  icon: Icons.email,
                  label: 'Email Invoice',
                  color: AppColors.primaryGold,
                  onPressed: () => invoiceService.emailInvoice(order, context),
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 8),
            Text(
              'Invoice Details:',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            _buildInvoiceDetail('Invoice Number', 'JS${order.id}'),
            _buildInvoiceDetail('Order Date', _formatDate(order.orderDate)),
            _buildInvoiceDetail('Customer', order.customerName),
            _buildInvoiceDetail('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildInvoiceDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}