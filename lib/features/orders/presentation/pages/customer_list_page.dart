import 'package:flutter/material.dart';
import 'package:jewelstack/core/constants/colors.dart';
import 'package:jewelstack/core/widgets/custom_textfield.dart';
import 'package:jewelstack/core/widgets/shop_app_drawer.dart';
import 'package:provider/provider.dart';
import '../../application/order_provider.dart';
import '../../domain/customer_model.dart';
import 'customer_detail_page.dart';

enum _CustomerAction { edit, delete }

class CustomerListPage extends StatefulWidget {
  final bool readOnly;
  final bool returnCustomerOnSelect;

  const CustomerListPage({
    Key? key,
    this.readOnly = false,
    this.returnCustomerOnSelect = false,
  }) : super(key: key);

  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      provider.initialize();
      provider.searchCustomers('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      drawer: const ShopAppDrawer(),
      appBar: AppBar(
        title: Text(
          'Customers',
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16),
              child: CustomTextField(
                label: 'Search Customers',
                hintText: 'Search by name or contact number',
                controller: _searchController,
                onChanged: (value) {
                  Provider.of<OrderProvider>(context, listen: false)
                      .searchCustomers(value);
                },
                readOnly: false,
                onTap: () {},
              ),
            ),
            // Customer List
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.customers.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.customers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.hintColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No customers found',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: provider.customers.length,
                    itemBuilder: (context, index) {
                      final customer = provider.customers[index];
                      return _buildCustomerCard(customer);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton(
              onPressed: () {
                _showAddCustomerDialog(context);
              },
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.textLight,
              child: Icon(Icons.person_add),
            ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGold.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: AppColors.primaryGold,
          ),
        ),
        title: Text(
          customer.name,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.contactNumber),
            SizedBox(height: 4),
            Text(
              'Last Purchase: ${_formatTimeAgo(customer.lastPurchase)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${customer.totalOrders} orders',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '₹${customer.totalSpent.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
            if (!widget.readOnly)
              PopupMenuButton<_CustomerAction>(
                onSelected: (action) {
                  switch (action) {
                    case _CustomerAction.edit:
                      _showEditCustomerDialog(context, customer);
                      break;
                    case _CustomerAction.delete:
                      _confirmDeleteCustomer(context, customer);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _CustomerAction.edit,
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: _CustomerAction.delete,
                    child: Text('Delete'),
                  ),
                ],
              ),
          ],
        ),
        onTap: () {
          if (widget.returnCustomerOnSelect) {
            Navigator.pop(context, customer);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerDetailPage(customer: customer),
            ),
          );
        },
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final contactController =
        TextEditingController(text: customer.contactNumber);
    final addressController =
        TextEditingController(text: customer.address ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  contactController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill required fields'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final updatedCustomer = customer.copyWith(
                name: nameController.text.trim(),
                contactNumber: contactController.text.trim(),
                address: addressController.text.trim().isEmpty
                    ? null
                    : addressController.text.trim(),
              );

              try {
                await Provider.of<OrderProvider>(context, listen: false)
                    .updateCustomer(updatedCustomer);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Customer updated'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update customer: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await Provider.of<OrderProvider>(context, listen: false)
                    .deleteCustomer(customer.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Customer deleted'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete customer: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
            onPressed: () async {
              if (nameController.text.isEmpty || contactController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill required fields'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                final customer = Customer(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  contactNumber: contactController.text.trim(),
                  email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                  createdAt: DateTime.now(),
                  lastPurchase: DateTime.now(),
                  totalOrders: 0,
                  totalSpent: 0.0,
                );

                await Provider.of<OrderProvider>(context, listen: false).addCustomer(customer);
                // Close the add-customer dialog
                Navigator.pop(context);
                // Only return the new customer when this page is used as a picker.
                if (widget.returnCustomerOnSelect) {
                  Navigator.pop(this.context, customer);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add customer: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
            ),
            child: Text('Add Customer'),
          ),
        ],
      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

