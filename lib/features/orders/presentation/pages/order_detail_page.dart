import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../auth/application/auth_service.dart';
import '../../application/order_provider.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';
import '../widgets/order_progress_timeline.dart';
import '../widgets/progress_update_dialog.dart';
import '../widgets/invoice_actions_widget.dart'; // ADD THIS IMPORT

class OrderDetailPage extends StatefulWidget {
  final Order order;
  final bool readOnly;

  const OrderDetailPage({Key? key, required this.order, this.readOnly = false}) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List<OrderProgress> _progressUpdates = [];
  late DateTime _estimatedDelivery;
  late double _pendingAmount;
  late OrderStatus _displayStatus;
  late double _displayProgress;
  Timer? _dailyReminderTimer;
  DateTime? _lastReminderShownAt;
  bool _roleReadOnly = true;
  double? _tempProgressValue; // NEW: For slider

  @override
  void initState() {
    super.initState();
    _estimatedDelivery = widget.order.estimatedDelivery;
    _pendingAmount = widget.order.balanceDue;
    _displayStatus = widget.order.status;
    _displayProgress = widget.order.progressPercentage;
    _progressUpdates = List<OrderProgress>.from(widget.order.progressUpdates)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _loadProgressUpdates();
    _startDailyUpdateReminder();
    _resolveRoleReadOnly();
  }

  Future<void> _resolveRoleReadOnly() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseUser = authService.currentUser;
      if (firebaseUser == null) {
        if (mounted) {
          setState(() => _roleReadOnly = true);
        }
        return;
      }

      final userModel = await authService.getUserData(firebaseUser.uid);
      if (!mounted) return;
      setState(() {
        _roleReadOnly = userModel?.role == 'staff';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _roleReadOnly = true;
      });
    }
  }

  bool get _effectiveReadOnly => widget.readOnly || _roleReadOnly;

  void _loadProgressUpdates() {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    provider.getOrderProgressTimeline(widget.order.id).listen(
      (updates) {
        if (!mounted) return;
        setState(() {
          _progressUpdates = updates;
        });
        _checkDailyUpdateReminder();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _progressUpdates = List<OrderProgress>.from(widget.order.progressUpdates)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
        _showSnackBarSafe(
          SnackBar(
            content: Text('Could not live-load progress updates. Showing saved order timeline.'),
            backgroundColor: AppColors.warning,
          ),
        );
      },
    );
  }

  void _startDailyUpdateReminder() {
    _dailyReminderTimer?.cancel();
    _dailyReminderTimer = Timer.periodic(Duration(hours: 1), (_) {
      _checkDailyUpdateReminder();
    });
    _checkDailyUpdateReminder();
  }

  void _checkDailyUpdateReminder() {
    if (!mounted) return;
    if (!_shouldTrackDailyUpdates()) return;

    final now = DateTime.now();
    final latestUpdateTime = _getLatestProgressTimestamp();
    final needsReminder = now.difference(latestUpdateTime) >= Duration(hours: 24);

    if (!needsReminder) return;

    if (_lastReminderShownAt != null &&
        now.difference(_lastReminderShownAt!) < Duration(hours: 24)) {
      return;
    }

    _lastReminderShownAt = now;

    _showSnackBarSafe(
      SnackBar(
        content: Text('Daily update reminder: Add today\'s progress for this order.'),
        backgroundColor: AppColors.warning,
        duration: Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Update Now',
          textColor: AppColors.textLight,
          onPressed: _addDailyUpdate,
        ),
      ),
    );
  }

  void _showSnackBarSafe(SnackBar snackBar) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.showSnackBar(snackBar);
    });
  }

  bool _shouldTrackDailyUpdates() {
    return widget.order.status == OrderStatus.pending ||
        widget.order.status == OrderStatus.confirmed ||
        widget.order.status == OrderStatus.inProgress ||
        widget.order.status == OrderStatus.ready;
  }

  DateTime _getLatestProgressTimestamp() {
    if (_progressUpdates.isEmpty) {
      return widget.order.orderDate;
    }

    DateTime latest = _progressUpdates.first.timestamp;
    for (final update in _progressUpdates) {
      if (update.timestamp.isAfter(latest)) {
        latest = update.timestamp;
      }
    }
    return latest;
  }

  void _showProgressUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => ProgressUpdateDialog(
        order: widget.order,
        onUpdate: (status, description, updatedBy) async {
          final previousStatus = _displayStatus;
          final previousProgress = _displayProgress;
          final previousUpdates = List<OrderProgress>.from(_progressUpdates);
          final optimisticUpdate = OrderProgress(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            status: status,
            description: description,
            timestamp: DateTime.now(),
            updatedBy: updatedBy,
          );

          setState(() {
            _displayStatus = status;
            _displayProgress = _maxProgress(_displayProgress, _statusToProgress(status));
            _progressUpdates = [optimisticUpdate, ..._progressUpdates];
          });

          final provider = Provider.of<OrderProvider>(context, listen: false);
          try {
            await provider.updateOrderStatusWithProgress(
              orderId: widget.order.id,
              newStatus: status,
              progressDescription: description,
              updatedBy: updatedBy,
            );
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _displayStatus = previousStatus;
              _displayProgress = previousProgress;
              _progressUpdates = previousUpdates;
            });
            _showSnackBarSafe(
              SnackBar(
                content: Text('Failed to update status: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _addDailyUpdate() {
    final currentProgressPercentage = widget.order.progressPercentage;
    _tempProgressValue = currentProgressPercentage;
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Add Daily Update'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add a daily progress update without changing the status.'),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Today\'s Progress',
                    hintText: 'Describe what was done today...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Progress: ${(_tempProgressValue! * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Slider(
                  value: _tempProgressValue!,
                  min: currentProgressPercentage,
                  max: 1.0,
                  divisions: 20,
                  label: '${(_tempProgressValue! * 100).toInt()}%',
                  activeColor: AppColors.primaryGold,
                  inactiveColor: AppColors.borderColor,
                  onChanged: (value) {
                    setDialogState(() {
                      _tempProgressValue = value;
                    });
                  },
                ),
                SizedBox(height: 8),
                Text(
                  'Note: Progress can only be increased, not decreased',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<OrderProvider>(context, listen: false);
                final previousProgress = _displayProgress;
                final previousUpdates = List<OrderProgress>.from(_progressUpdates);
                final optimisticProgress = _tempProgressValue!;
                final optimisticUpdate = OrderProgress(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  status: _displayStatus,
                  description: descriptionController.text.isEmpty
                      ? 'Daily progress update'
                      : descriptionController.text,
                  timestamp: DateTime.now(),
                  updatedBy: null,
                );

                setState(() {
                  _displayProgress = _maxProgress(_displayProgress, optimisticProgress);
                  _progressUpdates = [optimisticUpdate, ..._progressUpdates];
                });

                try {
                  // Update progress if changed
                  if (_tempProgressValue! > currentProgressPercentage) {
                    await provider.updateProgressPercentage(
                      orderId: widget.order.id,
                      newProgressPercentage: _tempProgressValue!,
                    );
                  }

                  // Add daily update
                  await provider.addDailyProgressUpdate(
                    orderId: widget.order.id,
                    description: optimisticUpdate.description,
                    updatedBy: null,
                  );
                  
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Daily update added successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _displayProgress = previousProgress;
                      _progressUpdates = previousUpdates;
                    });
                  }
                  Navigator.pop(dialogContext);
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
      ),
    );
  }

  Future<void> _editDeliveryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _estimatedDelivery,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 3650)),
    );

    if (selectedDate == null) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    try {
      await provider.updateEstimatedDeliveryDate(widget.order.id, selectedDate);
      if (!mounted) return;
      setState(() {
        _estimatedDelivery = selectedDate;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery date updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update delivery date: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _updatePendingAmount() {
    final controller = TextEditingController(
      text: _pendingAmount.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Update Pending Amount'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Pending Amount',
            hintText: 'Enter amount',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final parsedAmount = double.tryParse(controller.text.trim());
              if (parsedAmount == null || parsedAmount < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final provider = Provider.of<OrderProvider>(context, listen: false);
              try {
                await provider.updatePendingAmount(widget.order.id, parsedAmount);
                if (!mounted) return;
                setState(() {
                  _pendingAmount = parsedAmount;
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pending amount updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update pending amount: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
            ),
            child: Text('Update'),
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
        actions: _effectiveReadOnly
            ? null
            : [
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
                currentStatus: _displayStatus,
              ),
              SizedBox(height: 20),
              
              if (!_effectiveReadOnly) ...[
                InvoiceActionsWidget(order: widget.order),
                SizedBox(height: 20),
                _buildQuickActions(),
              ],
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
                    color: _getStatusColor(_displayStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(_displayStatus),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(_displayStatus),
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
                        value: _displayProgress,
                        backgroundColor: AppColors.borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(_displayStatus),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${(_displayProgress * 100).toInt()}% Complete',
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
                      _formatDate(_estimatedDelivery),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: _isDueSoon(_estimatedDelivery) ? AppColors.warning : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pending Amount',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rs. ${_pendingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: _pendingAmount > 0 ? AppColors.warning : AppColors.success,
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
                  icon: Icons.event,
                  label: 'Edit Delivery Date',
                  onTap: _editDeliveryDate,
                  color: AppColors.primaryGold,
                ),
                _buildActionButton(
                  icon: Icons.account_balance_wallet,
                  label: 'Update Pending',
                  onTap: _updatePendingAmount,
                  color: Colors.purple,
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
    final previousStatus = _displayStatus;
    final previousProgress = _displayProgress;
    final previousUpdates = List<OrderProgress>.from(_progressUpdates);
    final optimisticUpdate = OrderProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      status: status,
      description: description,
      timestamp: DateTime.now(),
      updatedBy: null,
    );

    setState(() {
      _displayStatus = status;
      _displayProgress = _maxProgress(_displayProgress, _statusToProgress(status));
      _progressUpdates = [optimisticUpdate, ..._progressUpdates];
    });

    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      await provider.updateOrderStatusWithProgress(
        orderId: widget.order.id,
        newStatus: status,
        progressDescription: description,
        updatedBy: null,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayStatus = previousStatus;
          _displayProgress = previousProgress;
          _progressUpdates = previousUpdates;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  double _statusToProgress(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.2;
      case OrderStatus.confirmed:
        return 0.4;
      case OrderStatus.inProgress:
        return 0.6;
      case OrderStatus.ready:
        return 0.8;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  double _maxProgress(double a, double b) => a > b ? a : b;

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

  @override
  void dispose() {
    _dailyReminderTimer?.cancel();
    super.dispose();
  }
}