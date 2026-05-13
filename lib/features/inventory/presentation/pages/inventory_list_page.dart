import 'package:flutter/material.dart';
import 'package:jewelstack/features/inventory/presentation/pages/add_inventory_page.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/shop_app_drawer.dart';
import '../../../auth/application/auth_service.dart';
import '../../application/inventory_provider.dart';
import '../../domain/inventory_item_model.dart';
import '../widgets/inventory_card.dart';
import '../widgets/inventory_stats_card.dart';
import '../../../../core/constants/colors.dart';

class InventoryListPage extends StatefulWidget {
  final bool readOnly;

  const InventoryListPage({Key? key, this.readOnly = false}) : super(key: key);

  @override
  _InventoryListPageState createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  _StockFilter _stockFilter = _StockFilter.all;
  bool _roleReadOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).initialize();
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            Provider.of<InventoryProvider>(context, listen: false).initialize();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildSearchFilter()),
              SliverToBoxAdapter(child: _buildStatistics()),
              _buildInventoryList(),
            ],
          ),
        ),
      ),
        floatingActionButton: _effectiveReadOnly
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddInventoryPage()),
                );
              },
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.textLight,
              child: Icon(Icons.add),
            ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: AppColors.primaryGold),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Text(
            'Inventory',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.dashboard, color: AppColors.primaryGold),
            onPressed: () {
              // Navigate to dashboard
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: Icon(Icons.search, color: AppColors.hintColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              filled: true,
              fillColor: AppColors.cardBackground,
            ),
            onChanged: (value) {
              Provider.of<InventoryProvider>(context, listen: false)
                  .searchItems(value);
            },
          ),
          SizedBox(height: 12),
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('All'),
                ...InventoryCategories.categories.map(_buildCategoryChip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
          Provider.of<InventoryProvider>(context, listen: false)
              .filterByCategory(category);
        },
        selectedColor: AppColors.primaryGold,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.textLight : AppColors.textPrimary,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final stats = provider.getDashboardStats();
        return Padding(
          padding: EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            physics: ScrollPhysics(),
            children: [
              InventoryStatsCard(
                title: 'Total Items',
                value: stats['totalItems'].toString(),
                color: AppColors.primaryGold,
                icon: Icons.inventory_2,
                onTap: () {
                  setState(() {
                    _stockFilter = _StockFilter.all;
                  });
                },
              ),
              InventoryStatsCard(
                title: 'Low Stock',
                value: stats['lowStock'].toString(),
                color: AppColors.primaryGold,
                icon: Icons.warning,
                onTap: () {
                  setState(() {
                    _stockFilter = _StockFilter.low;
                  });
                },
              ),
              InventoryStatsCard(
                title: 'Out of Stock',
                value: stats['outOfStock'].toString(),
                color: AppColors.error,
                icon: Icons.error,
                onTap: () {
                  setState(() {
                    _stockFilter = _StockFilter.out;
                  });
                },
              ),
              InventoryStatsCard(
                title: 'Total Value',
                value: '₹${stats['totalValue']}',
                color: AppColors.success,
                icon: Icons.attach_money,
                onTap: () {
                  setState(() {
                    _stockFilter = _StockFilter.all;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

    // Replace the Consumer in _buildInventoryList with this improved version:
    Widget _buildInventoryList() {
      return Consumer<InventoryProvider>(
        builder: (context, provider, child) {
        final searchQuery = _searchController.text.trim();
        final visibleItems = _applyStockFilter(provider.filteredItems);
        // Show loading only on initial load
        if (provider.isLoading && provider.allItems.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading inventory...',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
        }

        if (visibleItems.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 64,
                      color: AppColors.hintColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _buildEmptyStateMessage(searchQuery),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<InventoryProvider>(context, listen: false)
                              .searchItems('');
                        },
                        child: Text('Clear search'),
                      ),
                  ],
                ),
              ),
            );
        }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = visibleItems[index];
                return InventoryCard(
                  item: item,
                  onTap: () {
                    _showItemDetails(context, item);
                  },
                  onSell: _effectiveReadOnly
                      ? null
                      : () {
                          _sellItem(context, item);
                        },
                  onEdit: _effectiveReadOnly
                      ? null
                      : () {
                          _editItem(context, item);
                        },
                  onDelete: _effectiveReadOnly
                      ? null
                      : () {
                          _deleteItem(context, item);
                        },
                );
              },
              childCount: visibleItems.length,
            ),
          );
        },
      );
    }

  void _showItemDetails(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.imageUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 16),
            Text('Purity: ${item.purity}'),
            Text('Weight: ${item.weight}g'),
            Text('Stock: ${item.stock}'),
            Text('Price: ₹${item.price}'),
            if (item.description != null) Text('Description: ${item.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editItem(BuildContext context, InventoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddInventoryPage(item: item),
      ),
    );
  }

  void _deleteItem(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await Provider.of<InventoryProvider>(context, listen: false)
                    .deleteItem(item.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete item: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _sellItem(BuildContext context, InventoryItem item) {
    if (item.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item is out of stock'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sell Item'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity to sell',
            hintText: 'Enter quantity',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text.trim());
              if (quantity == null || quantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Enter a valid quantity'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              if (quantity > item.stock) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quantity exceeds available stock'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              try {
                await Provider.of<InventoryProvider>(context, listen: false)
                    .updateStock(item.id, item.stock - quantity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update stock: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.textLight,
            ),
            child: Text('Sell'),
          ),
        ],
      ),
    );
  }

  List<InventoryItem> _applyStockFilter(List<InventoryItem> items) {
    switch (_stockFilter) {
      case _StockFilter.low:
        return items.where((item) => item.stock > 0 && item.stock < 5).toList();
      case _StockFilter.out:
        return items.where((item) => item.stock == 0).toList();
      case _StockFilter.all:
      default:
        return items;
    }
  }

  String _buildEmptyStateMessage(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      return 'No items found for "$searchQuery"';
    }
    switch (_stockFilter) {
      case _StockFilter.low:
        return 'No low stock items';
      case _StockFilter.out:
        return 'No out of stock items';
      case _StockFilter.all:
      default:
        return 'No inventory items yet';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

enum _StockFilter { all, low, out }

