import 'package:flutter/material.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';

class OrderInProcessWidget extends StatelessWidget {
  final List<Order> inProcessOrders;
  final VoidCallback onViewAll;

  const OrderInProcessWidget({
    Key? key,
    required this.inProcessOrders,
    required this.onViewAll,
  }) : super(key: key);

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
                Icon(Icons.inventory_2, color: AppColors.primaryGold),
                SizedBox(width: 8),
                Text(
                  'Orders In Process',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${inProcessOrders.length}',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (inProcessOrders.isEmpty)
              Text(
                'No orders in process',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.textSecondary,
                ),
              )
            else
              Column(
                children: inProcessOrders.take(3).map((order) => _buildOrderItem(order)).toList(),
              ),
            if (inProcessOrders.length > 3)
              TextButton(
                onPressed: onViewAll,
                child: Text('View All (${inProcessOrders.length})'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        break;
      case OrderStatus.confirmed:
        statusColor = AppColors.primaryGold;
        break;
      case OrderStatus.inProgress:
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(Icons.work, size: 16, color: statusColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusText(order.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
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
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      default:
        return 'Unknown';
    }
  }
}