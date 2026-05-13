import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/application/auth_service.dart';
import '../../application/order_provider.dart';
import '../../domain/order_model.dart' as order_model;
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/shop_app_drawer.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../widgets/order_reminder_widget.dart';
import '../widgets/order_in_process_widget.dart';
import 'order_detail_page.dart';
import 'create_order_page.dart';

class OrderListPage extends StatefulWidget {
  final bool readOnly;

  const OrderListPage({Key? key, this.readOnly = false}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _showDashboardWidgets = true;
  bool _roleReadOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).initialize();
      _resolveRoleReadOnly();
    });
  }

  Future<void> _resolveRoleReadOnly() async {
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
  }

  bool get _effectiveReadOnly => widget.readOnly || _roleReadOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      drawer: const ShopAppDrawer(),
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
            // Order List using StreamBuilder
            _buildOrderListStream(),
          ],
        ),
      ),
        floatingActionButton: _effectiveReadOnly
          ? null
          : FloatingActionButton(
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
              setState(() {
                // Trigger rebuild for search
              });
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
    final provider = Provider.of<OrderProvider>(context, listen: false);
    return StreamBuilder(
      stream: provider.orderService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildShimmerCard(),
                SizedBox(height: 16),
                _buildShimmerCard(),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Error loading orders: ${snapshot.error}'),
          );
        }

        final orders = snapshot.data as List<order_model.Order>? ?? [];
        final dueSoonOrders =
          orders.where((order) => order.isDueSoon).toList();
        final inProcessOrders = orders
          .where((order) =>
            order.status == order_model.OrderStatus.pending ||
            order.status == order_model.OrderStatus.confirmed ||
            order.status == order_model.OrderStatus.inProgress)
          .toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              OrderReminderWidget(
                dueSoonOrders: dueSoonOrders,
                onViewAll: () {
                  setState(() {
                    _selectedFilter = 'Due Soon';
                  });
                },
              ),
              SizedBox(height: 16),
              OrderInProcessWidget(
                inProcessOrders: inProcessOrders,
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

  Widget _buildOrderListStream() {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    return Expanded(
      child: StreamBuilder<List<order_model.Order>>(
        stream: provider.orderService.getOrders(),
        builder: (context, snapshot) {
 
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator()
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading orders',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<OrderProvider>(context, listen: false).initialize();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final List<order_model.Order> allOrders = snapshot.data ?? [];
          
          // Apply search filter
          List<order_model.Order> filteredOrders = allOrders;
          if (_searchController.text.isNotEmpty) {
            filteredOrders = allOrders.where((order) =>
                order.customerName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                order.id.contains(_searchController.text)).toList();
          }

          // Apply status filter
          filteredOrders = _filterOrders(filteredOrders);

          // Handle empty state
          if (filteredOrders.isEmpty) {
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
                  if (_selectedFilter != 'All' || _searchController.text.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'All';
                          _searchController.clear();
                        });
                      },
                      child: Text('Show All Orders'),
                    ),
                ],
              ),
            );
          }

          // Display orders list
          return RefreshIndicator(
            onRefresh: () async {
              // Force refresh by re-initializing
              Provider.of<OrderProvider>(context, listen: false).initialize();
            },
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
      ),
    );
  }

  List<order_model.Order> _filterOrders(List<order_model.Order> orders) {
    switch (_selectedFilter) {
      case 'Pending':
        return orders.where((order) => order.status == order_model.OrderStatus.pending).toList();
      case 'Confirmed':
        return orders.where((order) => order.status == order_model.OrderStatus.confirmed).toList();
      case 'In Progress':
        return orders.where((order) => order.status == order_model.OrderStatus.inProgress).toList();
      case 'Ready':
        return orders.where((order) => order.status == order_model.OrderStatus.ready).toList();
      case 'Delivered':
        return orders.where((order) => order.status == order_model.OrderStatus.delivered).toList();
      case 'Due Soon':
        return orders.where((order) => order.isDueSoon).toList();
      case 'All':
      default:
        return orders;
    }
  }

  String _getEmptyStateMessage() {
    if (_searchController.text.isNotEmpty) {
      return 'No orders found for "${_searchController.text}"';
    }
    
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
        return 'No orders found\nCreate your first order using the + button';
    }
  }

  Widget _buildOrderCard(order_model.Order order) {
    Color statusColor;
    String statusText;
    
    switch (order.status) {
      case order_model.OrderStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case order_model.OrderStatus.confirmed:
        statusColor = AppColors.primaryGold;
        statusText = 'Confirmed';
        break;
      case order_model.OrderStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case order_model.OrderStatus.ready:
        statusColor = Colors.orange;
        statusText = 'Ready';
        break;
      case order_model.OrderStatus.delivered:
        statusColor = AppColors.success;
        statusText = 'Delivered';
        break;
      case order_model.OrderStatus.cancelled:
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
              builder: (context) => OrderDetailPage(order: order, readOnly: _effectiveReadOnly),
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
                      'Order #${order.id.length > 6 ? order.id.substring(order.id.length - 6) : order.id}',
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
              
              // Order Details
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
                            Icon(Icons.scale, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text(
                              '${order.totalWeight}g ${order.materialType}',
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
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      SizedBox(height: 4),
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
              SizedBox(height: 12),
              
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
                  if (order.status == order_model.OrderStatus.delivered)
                    OutlinedButton(
                      onPressed: () {
                        // Generate invoice
                      },
                      child: Text('Invoice'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGold,
                        side: BorderSide(color: AppColors.primaryGold),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
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
                  child: Container(
                    height: 20,
                    width: 100,
                    color: AppColors.borderColor,
                  ),
                ),
                Container(
                  height: 24,
                  width: 80,
                  color: AppColors.borderColor,
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(height: 16, width: 150, color: AppColors.borderColor),
            SizedBox(height: 8),
            Container(height: 14, width: 120, color: AppColors.borderColor),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}