import 'package:flutter/material.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';

class OrderReminderWidget extends StatelessWidget {
  final List<Order> dueSoonOrders;
  final VoidCallback onViewAll;

  const OrderReminderWidget({
    Key? key,
    required this.dueSoonOrders,
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
                Icon(Icons.notifications_active, color: AppColors.warning),
                SizedBox(width: 8),
                Text(
                  'Order Reminders',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                Text(
                  'Due in 3 days',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (dueSoonOrders.isEmpty)
              Text(
                'No orders due soon',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.textSecondary,
                ),
              )
            else
              Column(
                children: dueSoonOrders.take(3).map((order) => _buildOrderItem(order)).toList(),
              ),
            if (dueSoonOrders.length > 3)
              TextButton(
                onPressed: onViewAll,
                child: Text('View All (${dueSoonOrders.length})'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Order order) {
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
            backgroundColor: AppColors.warning.withOpacity(0.1),
            child: Icon(Icons.schedule, size: 16, color: AppColors.warning),
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
}