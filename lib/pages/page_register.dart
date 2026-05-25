import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../helper/color.dart';
import 'page_login.dart';
import 'page_verify.dart';

class PageRegister extends StatefulWidget {
  const PageRegister({super.key});

  @override
  State<PageRegister> createState() => _PageRegisterState();
}

class _PageRegisterState extends State<PageRegister> {
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;

  final nameCtrl     = TextEditingController();
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl  = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty) {
      showMessage('Vui lòng nhập đầy đủ thông tin');
      return;
    }
    if (passwordCtrl.text != confirmCtrl.text) {
      showMessage('Mật khẩu nhập lại không khớp');
      return;
    }
    if (passwordCtrl.text.length < 6) {
      showMessage('Mật khẩu phải ít nhất 6 ký tự');
      return;
    }
    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        data: {'display_name': nameCtrl.text.trim()},
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PageVerify(email: emailCtrl.text.trim()),
          ),
        );
      }
    } on AuthException catch (e) {
      showMessage(e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppColors.textDark)),
        backgroundColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header xanh
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 36,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ChatApp',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Ô tên hiển thị
                    buildTextField(
                      controller: nameCtrl,
                      hint: 'Tên hiển thị',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),

                    // Ô email
                    buildTextField(
                      controller: emailCtrl,
                      hint: 'Email',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Ô mật khẩu
                    buildTextField(
                      controller: passwordCtrl,
                      hint: 'Mật khẩu',
                      icon: Icons.lock_outline_rounded,
                      obscure: obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Ô nhập lại mật khẩu
                    buildTextField(
                      controller: confirmCtrl,
                      hint: 'Nhập lại mật khẩu',
                      icon: Icons.lock_outline_rounded,
                      obscure: obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Nút đăng ký
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryDark,
                          ),
                        )
                            : const Text(
                          'Đăng ký',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Chuyển sang đăng nhập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bạn đã có tài khoản? ',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PageLogin(),
                              ),
                            );
                          },
                          child: const Text(
                            'Đăng nhập ngay',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppColors.primaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF90b4d0), fontSize: 15),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}