import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/core/theme/app_typography.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  bool _isRegister = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // Icon
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: const Icon(Icons.email_outlined, color: AppColors.primary, size: 40),
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Center(
                child: Text(
                  _isRegister ? 'Create Account' : 'Sign In',
                  style: AppTypography.headline,
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  _isRegister ? 'Start your adventure' : 'Welcome back, adventurer',
                  style: AppTypography.caption,
                ),
              ),

              SizedBox(height: 40.h),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Invalid email address';
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your password';
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    if (_isRegister) ...[
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _confirmPassCtrl,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your password';
                          if (v != _passCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 32.h),

                    // Submit button
                    Obx(() {
                      final loading = AuthController.to.isLoading.value;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textPrimary,
                            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: loading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5.w,
                                    color: AppColors.textPrimary,
                                  ),
                                )
                              : Text(
                                  _isRegister ? 'Create Account' : 'Sign In',
                                  style: AppTypography.title.copyWith(fontSize: 16.sp),
                                ),
                        ),
                      );
                    }),

                    SizedBox(height: 16.h),

                    // Toggle sign in / sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRegister ? 'Already have an account?' : "Don't have an account?",
                          style: textStyleRegular(color: AppColors.textMuted, fontSize: 14.sp),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () => setState(() {
                            _isRegister = !_isRegister;
                            _formKey.currentState?.reset();
                          }),
                          child: Text(
                            _isRegister ? 'Sign In' : 'Sign Up',
                            style: textStyleSemiBold(
                              color: AppColors.primaryLight,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: textStyleRegular(color: AppColors.textPrimary, fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: textStyleRegular(color: AppColors.textMuted, fontSize: 13.sp),
        labelStyle: textStyleRegular(color: AppColors.textMuted, fontSize: 14.sp),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.red),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
      validator: validator,
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isRegister) {
      AuthController.to.registerWithEmail(_emailCtrl.text, _passCtrl.text);
    } else {
      AuthController.to.loginWithEmail(_emailCtrl.text, _passCtrl.text);
    }
  }
}
