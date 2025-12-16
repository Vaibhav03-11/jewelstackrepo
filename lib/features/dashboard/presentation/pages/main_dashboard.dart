import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/application/auth_service.dart';
import '../../../inventory/presentation/pages/inventory_list_page.dart';
import '../../../orders/presentation/pages/order_list_page.dart';
import '../../../orders/presentation/pages/customer_list_page.dart';
import 'details_page.dart';

class MainDashboard extends StatefulWidget {
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DetailsPage(),
    InventoryListPage(),
    CustomerListPage(),
    OrderListPage(),
    _MLInsightsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFAF9F6),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: const Color(0xFF9CA3AF),
        elevation: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Details',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'ML Insights',
          ),
        ],
      ),
    );
  }
}

class _MLInsightsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '✨ ML Insights',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 2.0,
            color: Color(0xFFFAF9F6),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1F1F1F),
                Color(0xFF2D2416),
                Color(0xFF3E2723),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFAF9F6),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeInOutCubic,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value * 0.8 + 0.2,
              child: Opacity(
                opacity: value,
                child: child,
              )
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D5016), Color(0xFF1E3A5F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A5F).withOpacity(0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.analytics,
                  size: 100,
                  color: Color(0xFFFAF9F6),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'ML Insights Module',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.15),
                      const Color(0xFFD4AF37).withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4AF37),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Advanced jewelry analytics and insights powered by machine learning',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text(
          '✨ JewelStack Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 2.0,
            color: Color(0xFFFAF9F6),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1F1F1F),
                Color(0xFF2D2416),
                Color(0xFF3E2723),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFAF9F6),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.easeInOutCubic,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * 30),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to JewelStack',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F1F1F),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4AF37).withOpacity(0.15),
                            const Color(0xFFD4AF37).withOpacity(0.08),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withOpacity(0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Logged in as: ${user?.email ?? 'Unknown'}',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: const Color(0xFFD4AF37).withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Navigation Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildAnimatedDashboardCard(
                    title: 'Inventory',
                    icon: Icons.inventory_2,
                    primaryColor: const Color(0xFFD4AF37),
                    secondaryColor: const Color(0xFFC19A00),
                    delay: 0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InventoryListPage()),
                      );
                    },
                  ),
                  _buildAnimatedDashboardCard(
                    title: 'Customers',
                    icon: Icons.people,
                    primaryColor: const Color(0xFF8B7355),
                    secondaryColor: const Color(0xFFA1887F),
                    delay: 1,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder:(context)=>CustomerListPage()),
                      );
                    },
                  ),
                  _buildAnimatedDashboardCard(
                    title: 'Orders',
                    icon: Icons.shopping_cart,
                    primaryColor: const Color(0xFF1E3A5F),
                    secondaryColor: const Color(0xFF2D5016),
                    delay: 2,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder:(context)=>OrderListPage()),
                      );
                    },
                  ),
                  _buildAnimatedDashboardCard(
                    title: 'ML Insights',
                    icon: Icons.analytics,
                    primaryColor: const Color(0xFF4A3F35),
                    secondaryColor: const Color(0xFF3E2723),
                    delay: 3,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('ML Insights module coming soon!'),
                          backgroundColor: const Color(0xFFD4AF37),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDashboardCard({
    required String title,
    required IconData icon,
    required Color primaryColor,
    required Color secondaryColor,
    required int delay,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (delay * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeInOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: const Color(0xFFFAF9F6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}