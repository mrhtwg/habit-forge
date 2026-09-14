import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:habit_forge_app/core/i18n/lan_key.dart';
import 'package:habit_forge_app/core/theme/app_colors.dart';
import 'package:habit_forge_app/core/theme/app_theme.dart';
import 'package:habit_forge_app/core/theme/app_typography.dart';
import 'package:habit_forge_app/features/auth/controllers/auth_controller.dart';

/// Email/password form shown as a bottom sheet from Settings (server mode).
/// Does not navigate to [EmailLoginPage] / AuthPage.
class EmailLoginSheet extends StatefulWidget {
  const EmailLoginSheet({super.key});

  static Future<void> show(BuildContext context) {
    return Get.bottomSheet(
      const EmailLoginSheet(),
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  @override
  State<EmailLoginSheet> createState() => _EmailLoginSheetState();
}

class _EmailLoginSheetState extends State<EmailLoginSheet> {
  bool _isRegister = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h + bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                _isRegister ? LanKey.createAccount.tr : LanKey.signIn.tr,
                textAlign: TextAlign.center,
                style: textStyleBold(fontSize: 18.sp, color: AppColors.textPrimary),
              ),
              SizedBox(height: 6.h),
              Text(
                _isRegister ? LanKey.startYourAdventure.tr : LanKey.welcomeBackAdventurer.tr,
                textAlign: TextAlign.center,
                style: textStyleMedium(fontSize: 13.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 20.h),
              _field(
                controller: _emailCtrl,
                label: LanKey.email.tr,
                hint: LanKey.enterYourEmail.tr,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return LanKey.pleaseEnterYourEmail.tr;
                  if (!v.contains('@')) return LanKey.invalidEmailAddress.tr;
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              _field(
                controller: _passCtrl,
                label: LanKey.password.tr,
                hint: LanKey.enterYourPassword.tr,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return LanKey.pleaseEnterYourPassword.tr;
                  if (v.length < 8) return LanKey.passwordMinLength.tr;
                  return null;
                },
              ),
              if (_isRegister) ...[
                SizedBox(height: 12.h),
                _field(
                  controller: _confirmPassCtrl,
                  label: LanKey.confirmPassword.tr,
                  hint: LanKey.reEnterYourPassword.tr,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return LanKey.pleaseConfirmYourPassword.tr;
                    if (v != _passCtrl.text) return LanKey.passwordsDoNotMatch.tr;
                    return null;
                  },
                ),
              ],
              SizedBox(height: 20.h),
              Obx(() {
                final loading = AuthController.to.isLoading.value;
                return ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: loading
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          _isRegister ? LanKey.createAccount.tr : LanKey.signIn.tr,
                          style: AppTypography.title.copyWith(fontSize: 16.sp, color: Colors.white),
                        ),
                );
              }),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegister ? LanKey.alreadyHaveAccount.tr : LanKey.noAccountYet.tr,
                    style: textStyleRegular(color: AppColors.textMuted, fontSize: 13.sp),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isRegister = !_isRegister;
                      _formKey.currentState?.reset();
                    }),
                    child: Text(
                      _isRegister ? LanKey.signIn.tr : LanKey.signUp.tr,
                      style: textStyleBold(fontSize: 13.sp, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
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
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
      validator: validator,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = _isRegister
        ? await AuthController.to.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text)
        : await AuthController.to.loginWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) Get.back();
  }
}
