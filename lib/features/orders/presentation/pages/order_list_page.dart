import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/order_provider.dart';
import '../../application/invoice_service.dart';
import '../../domain/order_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../widgets/order_reminder_widget.dart';
import '../widgets/order_in_process_widget.dart';
import 'order_detail_page.dart';
import 'create_order_page.dart';

extension OrderExtensions on Order {
  // Returns true if the estimated delivery is within the next 2 days and the order is not completed or cancelled.
  bool get isDueSoon {
    final now = DateTime.now();
    try {
      final daysUntil = estimatedDelivery.difference(now).inDays;
      return daysUntil >= 0 && daysUntil <= 2 && status != OrderStatus.delivered && status != OrderStatus.cancelled;
    } catch (_) {
      return false;
    }
  }

  // Convenience helper used by the UI to display quick action buttons.
  bool get isInProcess {
    return status == OrderStatus.inProgress || status == OrderStatus.confirmed;
  }
}

class OrderListPage extends StatefulWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  final InvoiceService _invoiceService = InvoiceService();
  String _selectedFilter = 'All';
  bool _showDashboardWidgets = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Orders',
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
            icon: Icon(_showDashboardWidgets ? Icons.dashboard : Icons.list),
            onPressed: () {
              setState(() {
                _showDashboardWidgets = !_showDashboardWidgets;
              });
            },
            tooltip: _showDashboardWidgets ? 'Hide Dashboard' : 'Show Dashboard',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter
            _buildSearchFilter(),
            // Dashboard Widgets (Conditional)
            if (_showDashboardWidgets) _buildDashboardWidgets(),
            // Order List
            _buildOrderList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateOrderPage()),
          );
        },
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textLight,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CustomTextField(
            label: 'Search Orders',
            hintText: 'Search by customer name or order ID',
            controller: _searchController,
            onChanged: (value) {
              Provider.of<OrderProvider>(context, listen: false).searchOrders(value);
            },
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Pending'),
                _buildFilterChip('Confirmed'),
                _buildFilterChip('In Progress'),
                _buildFilterChip('Ready'),
                _buildFilterChip('Delivered'),
                _buildFilterChip('Due Soon'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        selectedColor: AppColors.primaryGold,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.textLight : AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildDashboardWidgets() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              OrderReminderWidget(
                dueSoonOrders: provider.dueSoonOrders,
                onViewAll: () {
                  setState(() {
                    _selectedFilter = 'Due Soon';
                  });
                },
              ),
              SizedBox(height: 16),
              OrderInProcessWidget(
                inProcessOrders: provider.inProcessOrders,
                onViewAll: () {
                  setState(() {
                    _selectedFilter = 'In Progress';
                  });
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderList() {
    return Expanded(
      child: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          List<Order> displayedOrders = _filterOrders(provider.filteredOrders);

          if (provider.isLoading && displayedOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading orders...',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (displayedOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.hintColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _getEmptyStateMessage(),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  if (_selectedFilter != 'All')
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'All';
                        });
                      },
                      child: Text('Show All Orders'),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: displayedOrders.length,
            itemBuilder: (context, index) {
              final order = displayedOrders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders) {
    switch (_selectedFilter) {
      case 'Pending':
        return orders.where((order) => order.status == OrderStatus.pending).toList();
      case 'Confirmed':
        return orders.where((order) => order.status == OrderStatus.confirmed).toList();
      case 'In Progress':
        return orders.where((order) => order.status == OrderStatus.inProgress).toList();
      case 'Ready':
        return orders.where((order) => order.status == OrderStatus.ready).toList();
      case 'Delivered':
        return orders.where((order) => order.status == OrderStatus.delivered).toList();
      case 'Due Soon':
        return orders.where((order) => order.isDueSoon).toList();
      case 'All':
      default:
        return orders;
    }
  }

  String _getEmptyStateMessage() {
    switch (_selectedFilter) {
      case 'Pending':
        return 'No pending orders';
      case 'Confirmed':
        return 'No confirmed orders';
      case 'In Progress':
        return 'No orders in progress';
      case 'Ready':
        return 'No orders ready for delivery';
      case 'Delivered':
        return 'No delivered orders';
      case 'Due Soon':
        return 'No orders due soon';
      case 'All':
      default:
        return 'No orders found';
    }
  }

  Widget _buildOrderCard(Order order) {
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

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Customer Info
              Text(
                order.customerName,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                order.customerContact,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: order.progressPercentage,
                          backgroundColor: AppColors.borderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${(order.progressPercentage * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getProgressText(order.status),
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Order Details Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              'Delivery: ${_formatDate(order.estimatedDelivery)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.inventory_2, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (order.latestProgress != null) ...[
                        Text(
                          'Last update: ${_formatTimeAgo(order.latestProgress!.timestamp)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.isDueSoon ? AppColors.warning.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: order.isDueSoon ? Border.all(color: AppColors.warning) : null,
                        ),
                        child: Text(
                          order.isDueSoon ? 'Due Soon' : 'On Track',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: order.isDueSoon ? AppColors.warning : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Payment Summary
              Divider(),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Advance: ₹${order.advancePayment.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Balance: ₹${order.balanceDue.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: order.balanceDue > 0 ? AppColors.warning : AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Quick Action Buttons (for in-process orders)
              if (order.isInProcess) ...[
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _quickUpdateStatus(order, OrderStatus.ready, 'Marked as ready for delivery');
                        },
                        icon: Icon(Icons.inventory_2, size: 16),
                        label: Text('Mark Ready'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: BorderSide(color: Colors.orange),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _quickUpdateStatus(order, OrderStatus.delivered, 'Order delivered to customer');
                        },
                        icon: Icon(Icons.local_shipping, size: 16),
                        label: Text('Deliver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Invoice Quick Actions (for delivered orders)
              if (order.status == OrderStatus.delivered) ...[
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _generateInvoice(order, 'pdf');
                        },
                        icon: Icon(Icons.picture_as_pdf, size: 16),
                        label: Text('PDF Invoice'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _generateInvoice(order, 'doc');
                        },
                        icon: Icon(Icons.description, size: 16),
                        label: Text('DOC Invoice'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: BorderSide(color: Colors.blue),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _emailInvoice(order);
                        },
                        icon: Icon(Icons.email, size: 16),
                        label: Text('Email Invoice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getProgressText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Awaiting confirmation';
      case OrderStatus.confirmed:
        return 'Materials preparation';
      case OrderStatus.inProgress:
        return 'Crafting in progress';
      case OrderStatus.ready:
        return 'Ready for delivery';
      case OrderStatus.delivered:
        return 'Order completed';
      case OrderStatus.cancelled:
        return 'Order cancelled';
    }
  }

  void _quickUpdateStatus(Order order, OrderStatus newStatus, String description) async {
    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      await provider.updateOrderStatusWithProgress(
        orderId: order.id,
        newStatus: newStatus,
        progressDescription: description,
        updatedBy: 'Staff',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${_getStatusText(newStatus)}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _generateInvoice(Order order, String format) async {
    try {
      if (format == 'pdf') {
        await _invoiceService.generatePdfInvoice(order, context);
      } else {
        await _invoiceService.generateDocInvoice(order, context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate $format invoice: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _emailInvoice(Order order) async {
    try {
      await _invoiceService.emailInvoice(order, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to email invoice: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}