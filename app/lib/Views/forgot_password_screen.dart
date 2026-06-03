import 'dart:async';

import 'package:app/Views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../ViewModels/auth_viewmodel.dart';

// ==========================================
// 1. MÀN HÌNH NHẬP EMAIL QUÊN MẬT KHẨU
// ==========================================
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 40),
                const Icon(Icons.lock_reset, size: 80, color: Colors.black54),
                const SizedBox(height: 24),
                const Text(
                  "Quên Mật Khẩu?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Nhập email của bạn để nhận mã khôi phục.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập email" : null,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "GỬI MÃ OTP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendOtp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      final success = await context.read<AuthViewModel>().forgotPassword(email);
      if (!mounted) return;

      if (success) {
        // CHỈ GỌI HIỆN POPUP, TẤT CẢ LOGIC ĐIỀU HƯỚNG GIAO CHO POPUP TỰ XỬ LÝ
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OtpVerificationDialog(email: email),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email không tồn tại trong hệ thống!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ==========================================
// 2. CỬA SỔ POPUP NHẬP OTP
// ==========================================
class OtpVerificationDialog extends StatefulWidget {
  final String email;
  const OtpVerificationDialog({super.key, required this.email});

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;

  int _start = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // TUYỆT ĐỐI BỎ _otpController.dispose() ĐỂ DIỆT GỌN LỖI ĐỎ "USED AFTER DISPOSED"
    super.dispose();
  }

  void _startTimer() {
    setState(() => _start = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // CHỐT CHẶN AN TOÀN: Tránh lỗi gọi setState khi Popup đã đóng
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  void _verify() async {
    if (_otpController.text.length != 6) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    FocusScope.of(context).unfocus(); // Hạ bàn phím

    final valid = await context.read<AuthViewModel>().verifyResetOtp(
      widget.email,
      _otpController.text,
    );

    if (!mounted) return;

    if (valid) {
      // THUẬT TOÁN MỚI: Dùng pushReplacement để "biến hình" Popup thành Trang mới,
      // triệt tiêu hoàn toàn độ trễ và xung đột của lệnh Pop.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            otp: _otpController.text,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _resendOtp() async {
    _startTimer();
    final success = await context.read<AuthViewModel>().forgotPassword(
      widget.email,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã gửi lại mã OTP vào email"),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi gửi email, vui lòng thử lại sau"),
          backgroundColor: Colors.red,
        ),
      );
      _timer?.cancel();
      setState(() => _start = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  "Xác thực OTP",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Mã 6 số đã được gửi đến\n${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            PinCodeTextField(
              appContext: context,
              length: 6,
              keyboardType: TextInputType.number,
              controller: _otpController,
              autoFocus: true,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 45,
                fieldWidth: 35,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.grey.shade100,
                activeColor: _hasError ? Colors.red : Colors.black,
                inactiveColor: _hasError
                    ? Colors.red.shade200
                    : Colors.grey.shade300,
                selectedColor: _hasError ? Colors.red : Colors.black,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              onCompleted: (v) => _verify(),
              onChanged: (v) {
                if (_hasError) setState(() => _hasError = false);
              },
            ),
            if (_hasError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "* Mã OTP không đúng",
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "XÁC NHẬN",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Chưa nhận được mã? ",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (_start == 0)
                  GestureDetector(
                    onTap: _resendOtp,
                    child: const Text(
                      "Gửi lại",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  Text(
                    "Gửi lại sau ${_start}s",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. MÀN HÌNH ĐẶT LẠI MẬT KHẨU
// ==========================================
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Tạo Mật Khẩu Mới",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Vui lòng nhập mật khẩu mới bảo mật hơn.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: (v) =>
                      v!.length < 6 ? "Mật khẩu tối thiểu 6 ký tự" : null,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu mới",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (v) {
                    if (v!.isEmpty) return "Vui lòng xác nhận mật khẩu";
                    if (v != _passwordController.text)
                      return "Mật khẩu không khớp";
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: isLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "LƯU MẬT KHẨU",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleResetPassword() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final errorMessage = await context.read<AuthViewModel>().resetPassword(
        widget.email,
        widget.otp,
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đổi mật khẩu thành công! Bạn có thể đăng nhập."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }
}
