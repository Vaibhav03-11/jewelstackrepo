import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jewelstack/core/constants/colors.dart';
import 'package:jewelstack/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:jewelstack/features/auth/presentation/pages/login_page.dart';
import 'package:jewelstack/features/auth/presentation/pages/main_dashboard.dart' as auth_dashboard;
import 'package:jewelstack/features/auth/presentation/pages/register_page.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/application/auth_service.dart';
import 'features/inventory/application/inventory_provider.dart';
import 'features/dashboard/presentation/pages/main_dashboard.dart' as dashboard;
import 'features/orders/application/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //Provider<AuthService>(create: (_) => AuthService()),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<InventoryProvider>(
          create: (_) => InventoryProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'JewelStack',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AuthenticationFlow(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - navigate to main dashboard
          return dashboard.MainDashboard();
        }

        // User is not logged in - show authentication flow
        return LoginPage();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'JewelStack',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthenticationFlow extends StatefulWidget {
  @override
  _AuthenticationFlowState createState() => _AuthenticationFlowState();
}

class _AuthenticationFlowState extends State<AuthenticationFlow> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  
  void _navigateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body:
      StreamBuilder(stream: authService.authStateChanges, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - navigate to main dashboard
          return dashboard.MainDashboard();
        }

        return PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          LoginPage(
            onRegisterPressed: () => _navigateToPage(1),
            onForgotPasswordPressed: () => _navigateToPage(2),
          ),
          RegisterPage(
            onLoginPressed: () => _navigateToPage(0),
          ),
          ForgotPasswordPage(
            onBackPressed: () => _navigateToPage(0),
          ),
        ],
      );
      },)
       ,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}