import 'package:app/Views/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // TÁCH 2 BIẾN ĐỘC LẬP CHO 2 Ô MẬT KHẨU
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Danh sách các danh mục
  final List<String> _categories = [
    'Kinh tế',
    'Văn học',
    'Kỹ năng',
    'Lịch sử',
    'Khoa học',
    'Nghệ thuật',
  ];

  // Lưu trữ các danh mục người dùng đã chọn
  final List<String> _selectedCategories = [];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                // Thanh Header chứa nút Back và Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
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

                // Tiêu đề
                const Text(
                  "Tạo tài khoản mới",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Gia nhập cộng đồng chia sẻ tri thức.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // Họ và tên
                _buildOutlinedInput(
                  controller: _nameController,
                  label: "Họ và tên",
                  validator: (v) =>
                      v!.isEmpty ? "Vui lòng nhập họ và tên" : null,
                ),
                const SizedBox(height: 24),

                // Email
                _buildOutlinedInput(
                  controller: _emailController,
                  label: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập email" : null,
                ),
                const SizedBox(height: 24),

                // Mật khẩu
                _buildOutlinedInput(
                  controller: _passwordController,
                  label: "Mật khẩu",
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (v) =>
                      v!.length < 6 ? "Mật khẩu tối thiểu 6 ký tự" : null,
                ),
                const SizedBox(height: 24),

                // Xác nhận mật khẩu
                _buildOutlinedInput(
                  controller: _confirmPasswordController,
                  label: "Xác nhận mật khẩu",
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (v) {
                    if (v!.isEmpty) return "Vui lòng xác nhận mật khẩu";
                    if (v != _passwordController.text) {
                      return "Mật khẩu không khớp";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Danh mục yêu thích
                const Text(
                  "DANH MỤC YÊU THÍCH",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 16),

                // Hiển thị các Chip
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      backgroundColor: Colors.transparent,
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: isSelected
                              ? Colors.black
                              : Colors.grey.shade400,
                        ),
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 56),

                // Nút Đăng ký
                ElevatedButton(
                  onPressed: _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "ĐĂNG KÝ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Đã có tài khoản? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Đăng nhập ngay",
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

  Widget _buildOutlinedInput({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !isVisible : false,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  void _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vui lòng chọn ít nhất 1 danh mục yêu thích"),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // GỌI HÀM XIN MÃ OTP TRƯỚC (chưa tạo tài khoản)
      final otpSent = await context.read<AuthViewModel>().requestOtp(
        _emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();

      if (otpSent) {
        // CHUYỂN SANG MÀN HÌNH OTP VÀ MANG THEO TOÀN BỘ DATA
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email đã tồn tại hoặc lỗi gửi mã OTP!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}