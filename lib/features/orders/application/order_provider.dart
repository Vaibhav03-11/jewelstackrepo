import 'package:flutter/material.dart';
import 'order_service.dart';
import 'customer_service.dart';
import 'razorpay_service.dart';
import 'invoice_service.dart';
import 'email_service.dart';
import '../domain/order_model.dart';
import '../domain/customer_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  final CustomerService _customerService = CustomerService();
  final RazorpayService _razorpayService = RazorpayService();
  final InvoiceService _invoiceService = InvoiceService();
  final EmailService _emailService = EmailService();

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  List<Customer> _customers = [];
  List<Order> _dueSoonOrders = [];
  List<Order> _inProcessOrders = [];
  bool _isLoading = false;
  String _searchQuery = '';
  double _liveGoldRate = 6350.0; // Default rate

  // Getters
  List<Order> get allOrders => _allOrders;
  List<Order> get filteredOrders => _filteredOrders;
  List<Customer> get customers => _customers;
  List<Order> get dueSoonOrders => _dueSoonOrders;
  List<Order> get inProcessOrders => _inProcessOrders;
  bool get isLoading => _isLoading;
  double get liveGoldRate => _liveGoldRate;
  OrderService get orderService => _orderService; // Expose service for direct access

  // Internal helper to update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Initialize provider
  void initialize() {
    _razorpayService.initialize();
    
    // Load orders
    _orderService.getOrders().listen((orders) {
      _allOrders = orders;
      _applyFilters();
      notifyListeners();
    });

    // Load customers
    _customerService.getCustomers().listen((customers) {
      _customers = customers;
      notifyListeners();
    });

    // Load due soon orders
    _orderService.getOrdersDueSoon().listen((orders) {
      _dueSoonOrders = orders;
      notifyListeners();
    });

    // Load in-process orders
    _orderService.getInProcessOrders().listen((orders) {
      _inProcessOrders = orders;
      notifyListeners();
    });
  }

  // Search orders
  void searchOrders(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Order> result = _allOrders;

    if (_searchQuery.isNotEmpty) {
      result = result.where((order) =>
          order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.id.contains(_searchQuery)).toList();
    }

    _filteredOrders = result;
  }

  // Create new order
  Future<void> createOrder(Order order) async {
    _setLoading(true);
    try {
      await _orderService.createOrder(order);
      await _customerService.updateCustomerAfterOrder(order.customerId, order.totalAmount);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _setLoading(true);
    try {
      // OrderService does not have `updateOrderStatus`; use the available
      // updateOrderStatusWithProgress method to update status.
      await _orderService.updateOrderStatusWithProgress(
        orderId: orderId,
        newStatus: status,
        progressDescription: 'Status updated to ${status.toString()}',
        updatedBy: null,
      );
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update order status with progress tracking
  Future<void> updateOrderStatusWithProgress({
    required String orderId,
    required OrderStatus newStatus,
    required String progressDescription,
    String? updatedBy,
  }) async {
    _setLoading(true);
    try {
      await _orderService.updateOrderStatusWithProgress(
        orderId: orderId,
        newStatus: newStatus,
        progressDescription: progressDescription,
        updatedBy: updatedBy,
      );
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Add daily progress update
  Future<void> addDailyProgressUpdate({
    required String orderId,
    required String description,
    String? updatedBy,
  }) async {
    _setLoading(true);
    try {
      await _orderService.addDailyProgressUpdate(
        orderId: orderId,
        description: description,
        updatedBy: updatedBy,
      );
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Get orders that need daily progress updates
  Stream<List<Order>> getOrdersNeedingProgressUpdates() {
    return _orderService.getOrdersNeedingProgressUpdates();
  }

  // Get order progress timeline
  Stream<List<OrderProgress>> getOrderProgressTimeline(String orderId) {
    return _orderService.getOrderProgressTimeline(orderId);
  }

  // Process payment
  Future<void> processPayment({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerContact,
  }) async {
    _setLoading(true);
    try {
      _razorpayService.openCheckout(
        amount: amount,
        orderId: orderId,
        customerName: customerName,
        customerContact: customerContact,
      );
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update payment
  Future<void> updatePayment(String orderId, double advancePayment, double balanceDue) async {
    _setLoading(true);
    try {
      await _orderService.updatePayment(orderId, advancePayment, balanceDue);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update gold rate
  void updateGoldRate(double newRate) {
    _liveGoldRate = newRate;
    notifyListeners();
  }

  // Add new customer
  Future<void> addCustomer(Customer customer) async {
    _setLoading(true);
    try {
      await _customerService.addCustomer(customer);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update customer details
  Future<void> updateCustomer(Customer customer) async {
    _setLoading(true);
    try {
      await _customerService.updateCustomer(customer);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    _setLoading(true);
    try {
      await _customerService.deleteCustomer(customerId);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // INVOICE GENERATION METHODS

  // Generate PDF Invoice
  Future<void> generatePdfInvoice(Order order, BuildContext context) async {
    _setLoading(true);
    try {
      await _invoiceService.generatePdfInvoice(order, context);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Generate DOC Invoice
  Future<void> generateDocInvoice(Order order, BuildContext context) async {
    _setLoading(true);
    try {
      await _invoiceService.generateDocInvoice(order, context);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Email Invoice
  Future<void> emailInvoice(Order order, BuildContext context) async {
    _setLoading(true);
    try {
      await _invoiceService.emailInvoice(order, context);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Send invoice via email with attachments
  Future<void> sendInvoiceEmail(Order order, List<String> filePaths, BuildContext context) async {
    _setLoading(true);
    try {
      await _emailService.sendInvoiceEmail(order, filePaths);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice email sent successfully to ${order.customerName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: $e'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Generate and email both invoice formats
  Future<void> generateAndEmailAllInvoices(Order order, BuildContext context) async {
    _setLoading(true);
    try {
      // Generate both PDF and DOC invoices
      final output = await getTemporaryDirectory();
      final pdfFile = File("${output.path}/invoice_${order.id}.pdf");
      final docFile = File("${output.path}/invoice_${order.id}.doc");
      
      // Generate PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text('Order ID: ${order.id}'),
                pw.Text('Customer: ${order.customerName}'),
                pw.SizedBox(height: 12),
                pw.Text('Total Amount: ${order.totalAmount.toStringAsFixed(2)}'),
                pw.Text('Advance Payment: ${order.advancePayment.toStringAsFixed(2)}'),
                pw.Text('Balance Due: ${order.balanceDue.toStringAsFixed(2)}'),
              ],
            );
          },
        ),
      );
      await pdfFile.writeAsBytes(await pdf.save());
      
            // Generate DOC
            final docContent = '''
      Invoice
      Order ID: ${order.id}
      Customer: ${order.customerName}
      Total Amount: ${order.totalAmount.toStringAsFixed(2)}
      Advance Payment: ${order.advancePayment.toStringAsFixed(2)}
      Balance Due: ${order.balanceDue.toStringAsFixed(2)}
      ''';
            await docFile.writeAsString(docContent);

      // Send email with both attachments
      await _emailService.sendInvoiceEmail(order, [pdfFile.path, docFile.path]);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All invoices generated and emailed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate and email invoices: $e'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get invoice statistics
  Map<String, dynamic> getInvoiceStats() {
    final deliveredOrders = _allOrders.where((order) => order.status == OrderStatus.delivered).toList();
    final totalInvoicedAmount = deliveredOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final totalAdvanceCollected = deliveredOrders.fold(0.0, (sum, order) => sum + order.advancePayment);
    final totalBalanceDue = deliveredOrders.fold(0.0, (sum, order) => sum + order.balanceDue);

    return {
      'totalInvoices': deliveredOrders.length,
      'totalInvoicedAmount': totalInvoicedAmount,
      'totalAdvanceCollected': totalAdvanceCollected,
      'totalBalanceDue': totalBalanceDue,
      'averageOrderValue': deliveredOrders.isEmpty ? 0 : totalInvoicedAmount / deliveredOrders.length,
    };
  }

  // Get orders ready for invoicing (delivered but not invoiced)
  List<Order> getOrdersReadyForInvoicing() {
    return _allOrders.where((order) => 
      order.status == OrderStatus.delivered && 
      order.advancePayment < order.totalAmount
    ).toList();
  }

  Stream<List<Order>> getOrdersByCustomer(String customerId) {
    return _orderService.getOrdersByCustomer(customerId);
  }
}

