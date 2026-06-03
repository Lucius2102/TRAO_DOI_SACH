import 'package:app/Views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../ViewModels/auth_viewmodel.dart';

class OtpScreen extends StatefulWidget {
  // ĐÓN NHẬN TOÀN BỘ DỮ LIỆU TỪ MÀN HÌNH ĐĂNG KÝ
  final String fullName;
  final String email;
  final String password;

  const OtpScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _hasError = false;

  // Xử lý đếm ngược gửi lại mã
  int _start = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    // Sửa lại hàm dispose chuẩn xác để tránh lỗi memory leak khi bấm Back
    _timer?.cancel();
    final controller = _otpController;
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.dispose();
    });
    super.dispose();
  }

  void _startTimer() {
    setState(() => _start = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _start--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nút Back
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    // ÉP ẨN BÀN PHÍM VÀ NGẮT KẾT NỐI TRƯỚC KHI THOÁT
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 48),

              // Biểu tượng Email
              const Center(
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // Tiêu đề
              const Text(
                "Xác thực OTP",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Chú thích
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: "Vui lòng nhập mã 6 số vừa được gửi đến\n",
                    ),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Ô nhập mã PIN (Sử dụng thư viện pin_code_fields)
              PinCodeTextField(
                appContext: context,
                length: 6,
                obscureText: false,
                animationType: AnimationType.fade,
                keyboardType: TextInputType.number,
                controller: _otpController,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.grey.shade100,

                  // ĐỔI MÀU VIỀN THÀNH ĐỎ KHI NHẬP SAI
                  activeColor: _hasError
                      ? Colors.red
                      : Colors.black, // Viền ô đã nhập
                  inactiveColor: _hasError
                      ? Colors.red.shade200
                      : Colors.grey.shade300, // Viền ô trống
                  selectedColor: _hasError
                      ? Colors.red
                      : Colors.black, // Viền ô đang focus
                  errorBorderColor: Colors.red,
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onCompleted: (v) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _verifyOtp(); // Hoặc tên hàm gọi API đăng ký của bạn
                  });
                },
                onChanged: (value) {
                  // Khi người dùng bắt đầu gõ phím mới, tự động tắt trạng thái báo đỏ
                  if (_hasError) setState(() => _hasError = false);
                },
              ),

              // Thông báo lỗi nếu nhập sai
              if (_hasError)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "* Mã OTP không hợp lệ hoặc đã hết hạn, vui lòng thử lại.",
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 48),

              // Nút Xác nhận
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 32),

              // Gửi lại mã
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Chưa nhận được mã? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  if (_start == 0)
                    GestureDetector(
                      onTap: _resendOtp,
                      child: const Text(
                        "Gửi lại",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    )
                  else
                    Text(
                      "Gửi lại sau ${_start}s",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
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

  void _verifyOtp() async {
    if (_otpController.text.length != 6) return;

    setState(() => _isLoading = true);

    // Gọi API Đăng ký
    final success = await context.read<AuthViewModel>().register(
      widget.fullName,
      widget.email,
      widget.password,
      _otpController.text,
    );

    if (!mounted) return;

    if (success) {
      // Hiện thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công! Đăng nhập để tiếp tục."),
          backgroundColor: Colors.green,
        ),
      );

      // Hạ bàn phím xuống cho thoáng màn hình trước khi đổi trang
      FocusManager.instance.primaryFocus?.unfocus();

      // Cho hệ thống nghỉ 300ms để luồng xử lý tĩnh lặng hoàn toàn
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Xóa các trang trung gian, đưa về trang Login nằm trên Welcome
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => route.isFirst,
      );
    } else {
      // Nhánh này bây giờ chỉ chạy khi gõ SAI mã OTP thực sự
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _resendOtp() async {
    _startTimer();

    // GỌI HÀM XIN LẠI MÃ MỚI TỪ VIEWMODEL
    final success = await context.read<AuthViewModel>().requestOtp(
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
}
