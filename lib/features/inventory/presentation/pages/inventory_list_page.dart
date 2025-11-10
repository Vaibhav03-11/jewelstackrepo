import 'package:flutter/material.dart';
import 'package:jewelstack/features/inventory/presentation/pages/add_inventory_page.dart';
import 'package:provider/provider.dart';
import '../../application/inventory_provider.dart';
import '../../domain/inventory_item_model.dart';
import '../widgets/inventory_card.dart';
import '../widgets/inventory_stats_card.dart';
import '../../../../core/constants/colors.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({Key? key}) : super(key: key);

  @override
  _InventoryListPageState createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Search and Filter
            _buildSearchFilter(),
            // Statistics
            _buildStatistics(),
            // Inventory List
            _buildInventoryList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              InventoryStatsCard(
                title: 'Total Items',
                value: stats['totalItems'].toString(),
                color: AppColors.primaryGold,
                icon: Icons.inventory_2,
              ),
              InventoryStatsCard(
                title: 'Low Stock',
                value: stats['lowStock'].toString(),
                color: AppColors.warning,
                icon: Icons.warning,
              ),
              InventoryStatsCard(
                title: 'Out of Stock',
                value: stats['outOfStock'].toString(),
                color: AppColors.error,
                icon: Icons.error,
              ),
              InventoryStatsCard(
                title: 'Total Value',
                value: '₹${stats['totalValue']}',
                color: AppColors.success,
                icon: Icons.attach_money,
              ),
            ],
          ),
        );
      },
    );
  }

  // Replace the Consumer in _buildInventoryList with this improved version:
Widget _buildInventoryList() {
  return Expanded(
    child: Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        // Show loading only on initial load
        if (provider.isLoading && provider.allItems.isEmpty) {
          return Center(
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
          );
        }

        if (provider.filteredItems.isEmpty) {
          return Center(
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
                  _searchQuery.isNotEmpty 
                      ? 'No items found for "$_searchQuery"'
                      : 'No inventory items yet',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                if (_searchQuery.isNotEmpty)
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
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Force refresh data
            provider.initialize();
          },
          child: ListView.builder(
            itemCount: provider.filteredItems.length,
            itemBuilder: (context, index) {
              final item = provider.filteredItems[index];
              return InventoryCard(
                item: item,
                onTap: () {
                  _showItemDetails(context, item);
                },
                onEdit: () {
                  _editItem(context, item);
                },
                onDelete: () {
                  _deleteItem(context, item);
                },
              );
            },
          ),
        );
      },
    ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _searchQuery {
  static var isNotEmpty;
}