import 'package:flutter/material.dart';
import 'package:jewelstack/core/constants/colors.dart';
import 'package:provider/provider.dart';
import '../../application/order_provider.dart';
import '../../domain/customer_model.dart';
import '../../domain/order_model.dart';
import '../../core/constants/colors.dart';


class CustomerDetailPage extends StatefulWidget {
  final Customer customer;

  const CustomerDetailPage({Key? key, required this.customer}) : super(key: key);

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  List<Order> _customerOrders = [];

  @override
  void initState() {
    super.initState();
    _loadCustomerOrders();
  }

  void _loadCustomerOrders() {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    provider.orderService.getOrdersByCustomer(widget.customer.id).listen((orders) {
      setState(() {
        _customerOrders = orders;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Customer Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Profile Card
              _buildCustomerProfile(),
              SizedBox(height: 24),
              
              // Purchase History Section
              _buildPurchaseHistory(),
              SizedBox(height: 24),
              
              // Payment History Section
              _buildPaymentHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerProfile() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: AppColors.primaryGold,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.customer.contactNumber,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Last Purchase', _formatTimeAgo(widget.customer.lastPurchase)),
                _buildStatItem('Total Orders', '${widget.customer.totalOrders}'),
                _buildStatItem('Total Spent', '₹${widget.customer.totalSpent.toStringAsFixed(0)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase History',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        if (_customerOrders.isEmpty)
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No purchase history',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Column(
            children: _customerOrders.map((order) => _buildOrderItem(order)).toList(),
          ),
      ],
    );
  }

  Widget _buildOrderItem(Order order) {
    Color statusColor;
    String statusText;
    
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case OrderStatus.confirmed:
        statusColor = AppColors.primaryGold;
        statusText = 'Confirmed';
        break;
      case OrderStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case OrderStatus.ready:
        statusColor = Colors.orange;
        statusText = 'Ready';
        break;
      case OrderStatus.delivered:
        statusColor = AppColors.success;
        statusText = 'Delivered';
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order ID: ${order.id}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Date: ${_formatDate(order.orderDate)}',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Items: ${order.items.length}',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    final totalAdvance = _customerOrders.fold(0.0, (sum, order) => sum + order.advancePayment);
    final totalBalance = _customerOrders.fold(0.0, (sum, order) => sum + order.balanceDue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildPaymentItem('Total Advance Paid', '₹${totalAdvance.toStringAsFixed(0)}', AppColors.success),
              SizedBox(height: 8),
              _buildPaymentItem('Total Balance Due', '₹${totalBalance.toStringAsFixed(0)}', 
                  totalBalance > 0 ? AppColors.warning : AppColors.success),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              _buildPaymentItem('Net Amount', '₹${widget.customer.totalSpent.toStringAsFixed(0)}', AppColors.primaryGold),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}