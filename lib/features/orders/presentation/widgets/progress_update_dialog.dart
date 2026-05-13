import 'package:flutter/material.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_textfield.dart';

class ProgressUpdateDialog extends StatefulWidget {
  final Order order;
  final Future<void> Function(OrderStatus, String, String?) onUpdate;

  const ProgressUpdateDialog({
    Key? key,
    required this.order,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ProgressUpdateDialogState createState() => _ProgressUpdateDialogState();
}

class _ProgressUpdateDialogState extends State<ProgressUpdateDialog> {
  OrderStatus _selectedStatus = OrderStatus.pending;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _updatedByController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _descriptionController.text = _getDefaultDescription(_selectedStatus);
  }

  String _getDefaultDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order received and awaiting confirmation';
      case OrderStatus.confirmed:
        return 'Order confirmed and materials being prepared';
      case OrderStatus.inProgress:
        return 'Crafting in progress - daily update';
      case OrderStatus.ready:
        return 'Order completed and ready for delivery';
      case OrderStatus.delivered:
        return 'Order delivered to customer';
      case OrderStatus.cancelled:
        return 'Order cancelled';
    }
  }

  Future<void> _submitUpdate() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter progress description'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedBy = _updatedByController.text.trim();
      await widget.onUpdate(
        _selectedStatus,
        _descriptionController.text.trim(),
        updatedBy.isEmpty ? null : updatedBy,
      );
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Progress updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update progress: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Order Progress'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order #${widget.order.id}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            
            // Status Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Status',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.cardBackground,
                  ),
                  child: DropdownButton<OrderStatus>(
                    value: _selectedStatus,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: OrderStatus.values
                        .where((status) => status != OrderStatus.cancelled) // Exclude cancelled for updates
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(_getStatusText(status)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                          _descriptionController.text = _getDefaultDescription(value);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Progress Description
            CustomTextField(
              label: 'Progress Description',
              hintText: 'Describe the current progress...',
              controller: _descriptionController,
              maxLines: 3,
            ),
            SizedBox(height: 16),
            
            // Updated By (Optional)
            CustomTextField(
              label: 'Updated By (Optional)',
              hintText: 'Your name or initials',
              controller: _updatedByController,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGold,
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textLight,
                  ),
                )
              : Text('Update Progress'),
        ),
      ],
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
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _updatedByController.dispose();
    super.dispose();
  }
}