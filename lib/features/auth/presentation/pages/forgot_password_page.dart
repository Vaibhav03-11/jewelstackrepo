import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../widgets/auth_button.dart';
import '../../application/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ForgotPasswordPage({Key? key, this.onBackPressed}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resetPassword(_emailController.text.trim());
      setState(() => _emailSent = true);
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
                // Back Button
                SizedBox(height: 20),
                GestureDetector(
                  onTap: widget.onBackPressed,
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                SizedBox(height: 40),

                // Header
                Center(
                  child: Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    _emailSent
                        ? 'Check your email for reset instructions'
                        : 'Enter your email to reset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 40),

                if (!_emailSent) ...[
                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    }, onChanged: (value) {  }, readOnly: false, onTap: () {  },
                  ),
                  SizedBox(height: 30),

                  // Reset Password Button
                  AuthButton(
                    text: 'Send Reset Link',
                    onPressed: _resetPassword,
                    isLoading: _isLoading,
                  ),
                ] else ...[
                  // Success State
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Reset Link Sent!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We\'ve sent a password reset link to ${_emailController.text}. '
                          'Please check your email and follow the instructions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Back to Login Button
                  AuthButton(
                    text: 'Back to Login',
                    onPressed: widget.onBackPressed!,
                  ),
                ],
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
    super.dispose();
  }
}