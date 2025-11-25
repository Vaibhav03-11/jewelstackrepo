import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/order_provider.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';
import '../widgets/order_progress_timeline.dart';
import '../widgets/progress_update_dialog.dart';
import '../widgets/invoice_actions_widget.dart'; // ADD THIS IMPORT

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<OrderProgress> _progressUpdates = [];

  @override
  void initState() {
    super.initState();
    _loadProgressUpdates();
  }

  void _loadProgressUpdates() {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    provider.getOrderProgressTimeline(widget.order.id).listen((updates) {
      setState(() {
        _progressUpdates = updates;
      });
    });
  }

  void _showProgressUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateDialog(
        order: widget.order,
        onUpdate: (status, description) async {
          final provider = Provider.of<OrderProvider>(context, listen: false);
          await provider.updateOrderStatusWithProgress(
            orderId: widget.order.id,
            newStatus: status,
            progressDescription: description,
            updatedBy: 'Staff',
          );
        },
      ),
    );
  }

  void _addDailyUpdate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Daily Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add a daily progress update without changing the status.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Today\'s Progress',
                hintText: 'Describe what was done today...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Implement daily update
              final provider = Provider.of<OrderProvider>(context, listen: false);
              try {
                await provider.addDailyProgressUpdate(
                  orderId: widget.order.id,
                  description: 'Daily progress update', // You can get this from the text field
                  updatedBy: 'Staff',
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Daily update added successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add daily update: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
            ),
            child: Text('Add Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.update),
            onPressed: _showProgressUpdateDialog,
            tooltip: 'Update Progress',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Order Summary Card
              _buildOrderSummary(),
              SizedBox(height: 20),
              
              // Progress Timeline
              OrderProgressTimeline(
                progressUpdates: _progressUpdates,
                currentStatus: widget.order.status,
              ),
              SizedBox(height: 20),
              
              // ✅ INVOICE ACTIONS WIDGET ADDED HERE
              InvoiceActionsWidget(order: widget.order),
              SizedBox(height: 20),
              
              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${widget.order.id}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(widget.order.status),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(widget.order.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Customer: ${widget.order.customerName}',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Contact: ${widget.order.customerContact}',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: widget.order.progressPercentage,
                        backgroundColor: AppColors.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(widget.order.status),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${(widget.order.progressPercentage * 100).toInt()}% Complete',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Delivery Date',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatDate(widget.order.estimatedDelivery),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: _isDueSoon(widget.order.estimatedDelivery) ? AppColors.warning : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  icon: Icons.update,
                  label: 'Daily Update',
                  onTap: _addDailyUpdate,
                  color: Colors.blue,
                ),
                _buildActionButton(
                  icon: Icons.local_shipping,
                  label: 'Mark Ready',
                  onTap: () => _updateStatus(OrderStatus.ready, 'Order ready for delivery'),
                  color: Colors.orange,
                ),
                _buildActionButton(
                  icon: Icons.check_circle,
                  label: 'Mark Delivered',
                  onTap: () => _updateStatus(OrderStatus.delivered, 'Order delivered to customer'),
                  color: AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(OrderStatus status, String description) async {
    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      await provider.updateOrderStatusWithProgress(
        orderId: widget.order.id,
        newStatus: status,
        progressDescription: description,
        updatedBy: 'Staff',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.primaryGold;
      case OrderStatus.inProgress:
        return Colors.blue;
      case OrderStatus.ready:
        return Colors.orange;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
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

  bool _isDueSoon(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    // Consider due soon if within the next 3 days (including today)
    return difference >= 0 && difference <= 3;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}