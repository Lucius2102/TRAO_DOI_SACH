import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Hình nền và hiệu ứng tối màu (Dark Overlay)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/welcome_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 2. Lớp phủ Gradient đen (Bạn đã làm đúng phần này)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // 2. Nội dung chính
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge "Thư Viện Cộng Đồng"
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Colors.orangeAccent,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Thư Viện Cộng Đồng",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logo và Tên App
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage(
                          'assets/images/white_app_logo.png',
                        ), // Đảm bảo bạn đã thêm hình này vào assets
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "OmniBook",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tiêu đề chính
                  const Text(
                    "Kết nối tri thức,\nLan tỏa yêu thương",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mô tả
                  Text(
                    "Tham gia cộng đồng trao đổi sách lớn nhất để khám phá những chân trời mới qua từng trang giấy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nút "Bắt đầu ngay"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF58E3A), // Màu cam
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Bắt đầu ngay",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nút "Đăng nhập" (Glassmorphism)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 48,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                    child: const Text(
                      "Đăng nhập",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Danh sách các thẻ tính năng (Feature Cards)
                  _buildGlassCard(
                    icon: Icons.sync,
                    title: "Trao đổi dễ dàng",
                    description:
                        "Mượn và cho mượn sách chỉ với vài lần chạm đơn giản.",
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    icon: Icons.people_alt_outlined,
                    title: "Cộng đồng tin cậy",
                    description:
                        "Gặp gỡ những người yêu sách trong khu vực của bạn.",
                  ),
                  const SizedBox(height: 16),
                  _buildGlassCard(
                    icon: Icons.menu_book_outlined,
                    title: "Kho sách khổng lồ",
                    description:
                        "Khám phá hàng ngàn đầu sách từ cổ điển đến hiện đại.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hỗ trợ tạo hiệu ứng Kính mờ (Glassmorphism) cho các ô tính năng
  Widget _buildGlassCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Làm mờ nền phía sau
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), // Nền hơi sáng nhẹ
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)), // Viền mờ
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFFF58E3A), size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
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
}
