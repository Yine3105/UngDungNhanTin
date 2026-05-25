import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:ung_dung_nhan_tin_nhom3/helper/color.dart';
import 'package:ung_dung_nhan_tin_nhom3/pages/page_home.dart';
import 'package:ung_dung_nhan_tin_nhom3/pages/page_register.dart';

class PageVerify extends StatelessWidget {
  const PageVerify({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final otpCode = ValueNotifier<String>('');
    final isLoading = ValueNotifier<bool>(false);

    Future<void> handleVerify() async {
      if (otpCode.value.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng nhập đủ 6 số')),
        );
        return;
      }
      isLoading.value = true;
      try {
        var response = await Supabase.instance.client.auth.verifyOTP(
          type: OtpType.email,
          token: otpCode.value,
          email: email,
        );
        if (response.session != null && response.user != null) {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const PageHome()),
                  (route) => false,
            );
          }
        }
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'OTP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 38, color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            OtpTextField(
              numberOfFields: 6,
              borderColor: const Color(0xFFa2d2ff),
              focusedBorderColor: const Color(0xFFa2d2ff),
              showFieldAsBox: true,
              borderWidth: 4.0,
              fieldWidth: 45,
              textStyle: const TextStyle(fontSize: 15),
              clearText: true,
              onCodeChanged: (code) => otpCode.value = code,
              onSubmit: (code) => otpCode.value = code,
            ),

            const SizedBox(height: 28),

            ValueListenableBuilder<bool>(
              valueListenable: isLoading,
              builder: (context, loading, _) => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : const Text(
                    'Xác nhận',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PageRegister()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  side: const BorderSide(color: AppColors.primaryLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Quay lại đăng ký',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}