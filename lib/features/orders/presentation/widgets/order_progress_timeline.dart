import 'package:flutter/material.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';

class OrderProgressTimeline extends StatelessWidget {
  final List<OrderProgress> progressUpdates;
  final OrderStatus currentStatus;

  const OrderProgressTimeline({
    Key? key,
    required this.progressUpdates,
    required this.currentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort progress updates by timestamp (newest first)
    final sortedProgress = List<OrderProgress>.from(progressUpdates)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primaryGold),
                SizedBox(width: 8),
                Text(
                  'Order Progress Timeline',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (sortedProgress.isEmpty)
              Text(
                'No progress updates yet',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.textSecondary,
                ),
              )
            else
              Column(
                children: sortedProgress
                    .asMap()
                    .entries
                    .map((entry) => _buildProgressItem(entry.value, entry.key == 0))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(OrderProgress progress, bool isLatest) {
    Color statusColor = _getStatusColor(progress.status);
    IconData statusIcon = _getStatusIcon(progress.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Icon(
                  statusIcon,
                  size: 12,
                  color: statusColor,
                ),
              ),
              if (!isLatest)
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.borderColor,
                ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getStatusText(progress.status),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(progress.timestamp),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  progress.description,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.textPrimary,
                  ),
                ),
                if (progress.updatedBy != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'Updated by: ${progress.updatedBy}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule;
      case OrderStatus.confirmed:
        return Icons.check_circle;
      case OrderStatus.inProgress:
        return Icons.build;
      case OrderStatus.ready:
        return Icons.inventory_2;
      case OrderStatus.delivered:
        return Icons.local_shipping;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Pending';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.ready:
        return 'Ready for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}