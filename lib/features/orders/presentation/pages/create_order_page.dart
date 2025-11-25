import 'package:flutter/material.dart';
import 'package:jewelstack/core/constants/colors.dart';
import 'package:jewelstack/core/widgets/custom_textfield.dart';
import 'package:jewelstack/features/orders/presentation/pages/customer_list_page.dart';
import 'package:provider/provider.dart';
import '../../application/order_provider.dart';
import '../../domain/order_model.dart';
import '../../domain/customer_model.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/custom_textfield.dart';

class CreateOrderPage extends StatefulWidget {
  final Customer? selectedCustomer;

  const CreateOrderPage({Key? key, this.selectedCustomer}) : super(key: key);

  @override
  _CreateOrderPageState createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerSearchController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _advancePaymentController = TextEditingController();
  
  Customer? _selectedCustomer;

  String _selectedMaterial = '22K Gold';
  String _selectedItemType = 'Necklace';
  DateTime _selectedDeliveryDate = DateTime.now().add(Duration(days: 7));
  bool _isLoading = false;

  List<String> materialTypes = ['22K Gold', '18K Gold', '24K Gold', 'Platinum', 'Silver'];
  List<String> itemTypes = ['Necklace', 'Rings', 'Bracelet', 'Earrings', 'Custom'];

  @override
  void initState() {
    super.initState();
    if (widget.selectedCustomer != null) {
      _selectedCustomer = widget.selectedCustomer;
      _customerSearchController.text = widget.selectedCustomer!.name;
    }
  }

  double _calculateTotal() {
    if (_weightController.text.isEmpty) return 0.0;
    
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final provider = Provider.of<OrderProvider>(context, listen: false);
    final goldRate = provider.liveGoldRate;
    
    double rateMultiplier = 1.0;
    switch (_selectedMaterial) {
      case '22K Gold':
        rateMultiplier = 0.916; // 91.6% gold
        break;
      case '18K Gold':
        rateMultiplier = 0.750; // 75% gold
        break;
      case '24K Gold':
        rateMultiplier = 1.000; // 100% gold
        break;
      case 'Platinum':
        rateMultiplier = 1.2; // Platinum is typically more expensive
        break;
      case 'Silver':
        rateMultiplier = 0.05; // Silver is much less expensive
        break;
    }
    
    double makingCharges = weight * 500; // ₹500 per gram making charges
    double goldValue = weight * goldRate * rateMultiplier;
    
    return goldValue + makingCharges;
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a customer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final totalAmount = _calculateTotal();
      final advancePayment = double.tryParse(_advancePaymentController.text) ?? 0.0;
      final balanceDue = totalAmount - advancePayment;

       // Create initial progress update
    final initialProgress = OrderProgress(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      status: OrderStatus.pending,
      description: 'Order created and awaiting confirmation',
      timestamp: DateTime.now(),
      updatedBy: 'System',
    );

      final itemWeight = double.tryParse(_weightController.text) ?? 0.0;
      final itemTotal = totalAmount;
      final itemUnitPrice = itemWeight > 0 ? itemTotal / itemWeight : itemTotal;

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        customerContact: _selectedCustomer!.contactNumber,
        items: [
          OrderItem(
            name: '$_selectedItemType - $_selectedMaterial',
            type: _selectedItemType,
            weight: itemWeight,
            description: _descriptionController.text,
            id: '',
            quantity: 1,
            unitPrice: itemUnitPrice,
            totalPrice: itemTotal,
          ),
        ],
        materialType: _selectedMaterial,
        goldRate: Provider.of<OrderProvider>(context, listen: false).liveGoldRate,
        totalWeight: itemWeight,
        totalAmount: totalAmount,
        advancePayment: advancePayment,
        balanceDue: balanceDue,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        estimatedDelivery: _selectedDeliveryDate,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        progressUpdates: [initialProgress],
      );

      await Provider.of<OrderProvider>(context, listen: false).createOrder(order);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeliveryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDeliveryDate) {
      setState(() {
        _selectedDeliveryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _calculateTotal();
    final advancePayment = double.tryParse(_advancePaymentController.text) ?? 0.0;
    final balanceDue = totalAmount - advancePayment;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'New Order',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information Section
                Text(
                  'Customer Information',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                _buildCustomerSection(),
                SizedBox(height: 24),

                // Item Details Section
                Text(
                  'Item Details',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                _buildItemDetailsSection(),
                SizedBox(height: 24),

                // Pricing Section
                Text(
                  'Pricing & Payment',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),
                _buildPricingSection(totalAmount, advancePayment, balanceDue),
                SizedBox(height: 32),

                // Create Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: AppColors.textLight,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: AppColors.textLight)
                        : Text(
                            'Create Order',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // In the _buildCustomerSection method, ensure the selected customer display is correct:
Widget _buildCustomerSection() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Customer Search Field
          InkWell(
            onTap: _showCustomerSearchDialog,
            child: IgnorePointer(
              child: TextFormField(
                controller: _customerSearchController,
                decoration: InputDecoration(
                  labelText: 'Customer Name *',
                  hintText: 'Tap to search or add customer',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                validator: (value) {
                  if (_selectedCustomer == null) {
                    return 'Please select a customer';
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // Selected Customer Display
          if (_selectedCustomer != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: AppColors.primaryGold),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCustomer!.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _selectedCustomer!.contactNumber,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedCustomer = null;
                        _customerSearchController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildItemDetailsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Material Type
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Material Type',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
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
                        child: DropdownButton<String>(
                          value: _selectedMaterial,
                          isExpanded: true,
                          underline: SizedBox(),
                          items: materialTypes
                              .map((material) => DropdownMenuItem(
                                    value: material,
                                    child: Text(material),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMaterial = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Type',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
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
                        child: DropdownButton<String>(
                          value: _selectedItemType,
                          isExpanded: true,
                          underline: SizedBox(),
                          items: itemTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedItemType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Weight
            CustomTextField(
              label: 'Weight (grams)',
              hintText: 'Enter weight in grams',
              controller: _weightController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter weight';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid weight';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {});
              }, readOnly: false, onTap: () {  },
            ),
            SizedBox(height: 16),
            // Description
            CustomTextField(
              label: 'Description (Optional)',
              hintText: 'Enter custom description',
              controller: _descriptionController,
              keyboardType: TextInputType.multiline, onChanged: (value) {  }, readOnly: false, onTap: () {  },
            ),
            SizedBox(height: 16),
            // Delivery Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Delivery Date',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: _selectDeliveryDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.cardBackground,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primaryGold),
                        SizedBox(width: 12),
                        Text(
                          '${_selectedDeliveryDate.day}/${_selectedDeliveryDate.month}/${_selectedDeliveryDate.year}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection(double totalAmount, double advancePayment, double balanceDue) {
    final provider = Provider.of<OrderProvider>(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Live Gold Rate
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_rupee, color: AppColors.primaryGold),
                  SizedBox(width: 8),
                  Text(
                    'Live Gold Rate: ',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${provider.liveGoldRate.toStringAsFixed(0)}/gram',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Total Amount
            _buildPricingRow('Total Amount', '₹${totalAmount.toStringAsFixed(0)}'),
            SizedBox(height: 12),
            // Advance Payment
            CustomTextField(
              label: 'Advance Payment (₹)',
              hintText: 'Enter advance amount',
              controller: _advancePaymentController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              }, readOnly: false, onTap: () {  },
            ),
            SizedBox(height: 12),
            // Balance Due
            _buildPricingRow(
              'Balance Due',
              '₹${balanceDue.toStringAsFixed(0)}',
              color: balanceDue > 0 ? AppColors.warning : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, {Color? color}) {
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
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

    // Replace the _showCustomerSearchDialog method with this fixed version:
void _showCustomerSearchDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Select Customer'),
      content: Container(
        width: double.maxFinite,
        child: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search customers by name or phone...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // This will trigger customer search
                    provider.searchOrders(value); // Using searchOrders for customer search
                  },
                ),
                SizedBox(height: 16),
                Container(
                  height: 300,
                  child: provider.customers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: AppColors.hintColor),
                              SizedBox(height: 8),
                              Text(
                                'No customers found',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.customers.length,
                          itemBuilder: (context, index) {
                            final customer = provider.customers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryGold.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primaryGold,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                customer.name,
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(customer.contactNumber),
                              trailing: Text(
                                '${customer.totalOrders} orders',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCustomer = customer;
                                  _customerSearchController.text = customer.name;
                                });
                                Navigator.pop(context); // Close the dialog
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close this dialog first
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerListPage()),
            ).then((newCustomer) {
              // Handle if a new customer was created and selected
              if (newCustomer != null && newCustomer is Customer) {
                setState(() {
                  _selectedCustomer = newCustomer;
                  _customerSearchController.text = newCustomer.name;
                });
              }
            });
          },
          child: Text('Add New Customer'),
        ),
      ],
    ),
  );
}
  @override
  void dispose() {
    _customerSearchController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _advancePaymentController.dispose();
    super.dispose();
  }
}