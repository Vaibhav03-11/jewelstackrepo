import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../../features/auth/application/auth_service.dart';

class ShopAppDrawer extends StatefulWidget {
  const ShopAppDrawer({Key? key}) : super(key: key);

  @override
  State<ShopAppDrawer> createState() => _ShopAppDrawerState();
}

class _ShopAppDrawerState extends State<ShopAppDrawer> {
  late Future<_DrawerData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadDrawerData();
  }

  Future<_DrawerData> _loadDrawerData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firebaseUser = authService.currentUser;

    if (firebaseUser == null) {
      return const _DrawerData(
        userEmail: 'Unknown user',
        shopId: 'N/A',
        shopName: 'N/A',
      );
    }

    final firestore = FirebaseFirestore.instance;
  final userModel = await authService.getUserData(firebaseUser.uid);

  // Keep raw map for optional fallback fields that are not in UserModel.
  final userSnap = await firestore.collection('users').doc(firebaseUser.uid).get();
  final userData = userSnap.data() ?? <String, dynamic>{};

  final String shopId = (userModel?.shopId ?? '').trim().isNotEmpty
    ? userModel!.shopId.trim()
    : ((userData['shopId'] as String?)?.trim().isNotEmpty == true
      ? (userData['shopId'] as String).trim()
      : 'N/A');

    String shopName = 'N/A';
    if (shopId != 'N/A') {
      try {
        final shopSnap = await firestore.collection('shops').doc(shopId).get();
        final shopData = shopSnap.data() ?? <String, dynamic>{};
        final String? docName = (shopData['name'] as String?)?.trim();
        if (docName != null && docName.isNotEmpty) {
          shopName = docName;
        }
      } catch (check) {
        // Keep drawer usable even if shop doc read fails for transient reasons.
      }

      if (shopName == 'N/A') {
        final String? userShopName = (userData['shopName'] as String?)?.trim();
        if (userShopName != null && userShopName.isNotEmpty) {
          shopName = userShopName;
        }
      }
    }

    return _DrawerData(
      userEmail: firebaseUser.email ?? 'Unknown user',
      shopId: shopId,
      shopName: shopName,
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About JewelStack'),
        content: const Text(
          'JewelStack helps jewellery businesses manage inventory, customers, and orders with secure role-based access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<_DrawerData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.store, color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      data?.shopName ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data?.userEmail ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Shop ID'),
                subtitle: Text(data?.shopId ?? 'Loading...'),
              ),
              ListTile(
                leading: const Icon(Icons.storefront),
                title: const Text('Shop Name'),
                subtitle: Text(data?.shopName ?? 'Loading...'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Us'),
                onTap: _showAboutDialog,
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DrawerData {
  final String userEmail;
  final String shopId;
  final String shopName;

  const _DrawerData({
    required this.userEmail,
    required this.shopId,
    required this.shopName,
  });
}
