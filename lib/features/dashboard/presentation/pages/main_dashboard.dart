import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/application/auth_service.dart';
import '../../../inventory/presentation/pages/inventory_list_page.dart';
import '../../../../core/constants/colors.dart';
import '../../../orders/presentation/pages/order_list_page.dart';
import '../../../orders/presentation/pages/customer_list_page.dart';

class MainDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'JewelStack',
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
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to JewelStack!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Logged in as: ${user?.email ?? 'Unknown'}',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 32),
            
            // Navigation Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  title: 'Inventory',
                  icon: Icons.inventory_2,
                  color: AppColors.primaryGold,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InventoryListPage()),
                    );
                  },
                ),
                _buildDashboardCard(
                  title: 'Customers',
                  icon: Icons.people,
                  color: AppColors.secondaryGold,
                  onTap: () {
                    // TODO: Navigate to customers
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context)=>CustomerListPage()),
                    );
                  },
                ),
                _buildDashboardCard(
                  title: 'Orders',
                  icon: Icons.shopping_cart,
                  color: AppColors.accentGold,
                  onTap: () {
                    // TODO: Navigate to orders
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context)=>OrderListPage()),
                    );
                  },
                ),
                _buildDashboardCard(
                  title: 'ML Insights',
                  icon: Icons.analytics,
                  color: AppColors.success,
                  onTap: () {
                    // TODO: Navigate to ML insights
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ML Insights module coming soon!'),
                        backgroundColor: AppColors.primaryGold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}