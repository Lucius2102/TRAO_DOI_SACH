import 'package:app/Views/forgot_password_screen.dart';
import 'package:app/Views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModels/auth_viewmodel.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final Color _darkPrimary = const Color(0xFF0D1B1B);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thanh Header chứa nút Back và Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy 2 thành phần ra 2 góc
                  children: [
                    // 1. Nút Back (Sát lề trái)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(), // Giúp loại bỏ khoảng trắng thừa của IconButton
                    ),
                    
                    // 2. Cụm Logo & Tiêu đề (Sát lề phải)
                    const Row(
                      mainAxisSize: MainAxisSize.min, // Quan trọng: Ép cụm này nhỏ nhất có thể để không bị đẩy tràn màn hình
                      children: [
                        Image(
                          image: AssetImage("assets/images/black_app_logo.png"),
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "OmniBook",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                const Text(
                  "Chào mừng trở lại",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Đăng nhập để tiếp tục mượn sách và kết nối.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Email Field (Đã thêm Validator)
                _buildInput(
                  controller: _emailController,
                  label: "Địa chỉ Email",
                  isPassword: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập địa chỉ email';
                    }
                    // Kiểm tra định dạng email cơ bản
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) { //Biểu thức chính quy
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field (Đã thêm Validator)
                _buildInput(
                  controller: _passwordController,
                  label: "Mật khẩu",
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    // if (value.length < 6) {
                    //   return 'Mật khẩu phải có ít nhất 6 ký tự';
                    // }
                    return null;
                  },
                ),

                // Quên mật khẩu
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );},
                    child: const Text(
                      "Quên mật khẩu?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nút Đăng nhập
                ElevatedButton(
                  onPressed: isLoading ? null : () => _performLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                // Divider
                const SizedBox(height: 32),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "HOẶC ĐĂNG NHẬP VỚI",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),

                // Nút Google
                OutlinedButton(
                  onPressed: () {
                    print("Đăng nhập Google");
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage("assets/images/google_logo.png"),
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 8),
                      Text("Google", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Nút Facebook
                OutlinedButton(
                  onPressed: () {
                    print("Đăng nhập Facebook");
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage("assets/images/facebook_logo.png"),
                        width: 20,
                        height: 20,
                      ),
                      SizedBox(width: 8),
                      Text("Facebook", style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),

                // Đăng ký
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Chưa có tài khoản? "),
                    GestureDetector(
                      onTap: () {Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );},
                      child: const Text(
                        "Đăng ký ngay",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cập nhật _buildInput để nhận thêm biến validator
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required bool isPassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      validator: validator, // Kích hoạt kiểm tra lỗi
      autovalidateMode: AutovalidateMode.onUserInteraction, // Hiện lỗi ngay khi người dùng gõ sai
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
      ),
    );
  }

// Hoàn thiện logic đăng nhập
  void _performLogin(BuildContext context) async {
    // 1. Ẩn bàn phím khi bấm đăng nhập
    FocusScope.of(context).unfocus();

    // 2. Kiểm tra xem các ô nhập liệu đã hợp lệ chưa
    if (_formKey.currentState!.validate()) {
      // Gọi API login và hứng kết quả trả về là kiểu int
      final status = await context.read<AuthViewModel>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (!mounted) return;

      // Xóa các thông báo lỗi cũ đang hiển thị (nếu có)
      ScaffoldMessenger.of(context).clearSnackBars();

      // 3. Xử lý logic dựa trên mã trả về từ ViewModel
      if (status == 1) { 
        // 1: Đăng nhập thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng nhập thành công! 🎉"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // TODO: Chuyển hướng sang màn hình HomeScreen tại đây
        
      } else if (status == 2) { 
        // 2: Đúng tài khoản nhưng chưa xác thực email (Luồng bảo mật)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Vui lòng xác thực email trước khi đăng nhập!"),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5), // Hiện lâu hơn một chút
            action: SnackBarAction(
              label: 'XÁC THỰC NGAY',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Gọi API gửi lại mã OTP, rồi đẩy qua màn hình OtpScreen
                // Lưu ý: Tính năng này bạn sẽ cần truyền thêm password hoặc fullName 
                // tùy theo cách bạn cấu trúc trang OtpScreen ở các bước trước.
              },
            ),
          ),
        );
      } else { 
        // 0: Sai tài khoản / mật khẩu / Lỗi hệ thống
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sai email hoặc mật khẩu. Vui lòng thử lại!"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}