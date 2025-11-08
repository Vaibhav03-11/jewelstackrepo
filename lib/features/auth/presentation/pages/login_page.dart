import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../widgets/auth_button.dart';
import '../../application/auth_service.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onForgotPasswordPressed;

  const LoginPage({
    Key? key,
    this.onRegisterPressed,
    this.onForgotPasswordPressed,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Navigation will be handled by auth state listener in main.dart
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                SizedBox(height: 40),
                Center(
                  child: Text(
                    'JewelStack',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  label: 'Email or Phone Number',
                  hintText: 'Enter your email or phone number',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email or phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.hintColor,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                SizedBox(height: 16),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: widget.onForgotPasswordPressed,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: AppColors.primaryGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Login Button
                AuthButton(
                  text: 'Log In',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.borderColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.borderColor)),
                  ],
                ),
                SizedBox(height: 24),

                // Create Account Button
                AuthButton(
                  text: 'Create Account',
                  onPressed: widget.onRegisterPressed!,
                  isPrimary: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}