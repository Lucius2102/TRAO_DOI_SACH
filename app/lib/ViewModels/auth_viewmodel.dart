import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  //String _http = 'http://10.0.2.2:3000';// Máy ảo
  String _http = 'http://192.168.1.192:3000'; // Máy thật

  // 1. ĐĂNG NHẬP (Trả về int: 1 = Thành công, 2 = Chưa xác thực, 0 = Lỗi/Sai pass)
  Future<int> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_http/api/users/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return 1; // Thành công
      } else if (response.statusCode == 403) {
        return 2; // Đúng tài khoản nhưng chưa xác thực email
      } else {
        return 0; // Sai email hoặc mật khẩu
      }
    } catch (e) {
      print('Lỗi kết nối Login: $e');
      _isLoading = false;
      notifyListeners();
      return 0;
    }
  }

  // 2. XIN CẤP MÃ OTP (Chỉ gửi email, chưa tạo user. Gọi ở màn RegisterScreen)
  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_http/api/users/request-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('--- PHẢN HỒI TỪ SERVER (REQUEST OTP) ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('---------------------------------------');

      _isLoading = false;
      notifyListeners();

      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi kết nối Request OTP: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 3. XÁC NHẬN OTP & TẠO TÀI KHOẢN (Gọi ở màn OtpScreen)
  Future<bool> register(
    String fullName,
    String email,
    String password,
    String otp,
  ) async {
    // Không dùng _isLoading ở đây vì bên giao diện OtpScreen đã có nút quay vòng riêng
    try {
      final url = Uri.parse('$_http/api/users/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password_hash': password,
          'otp': otp,
        }),
      );

      print('--- PHẢN HỒI TỪ SERVER (REGISTER) ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('------------------------------------------');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Lỗi kết nối Register: $e');
      return false;
    }
  }

  // 4. QUÊN MẬT KHẨU (Xin mã OTP)
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$_http/api/users/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // KIỂM TRA MÃ OTP TRƯỚC KHI CHO ĐỔI MẬT KHẨU
  Future<bool> verifyResetOtp(String email, String otp) async {
    // Không dùng _isLoading ở đây vì Dialog sẽ có biến loading riêng
    try {
      final response = await http.post(
        Uri.parse('$_http/api/users/verify-reset-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. ĐẶT LẠI MẬT KHẨU MỚI (Trả về String? chứa thông báo lỗi nếu có)
  Future<String?> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$_http/api/users/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );
      _isLoading = false;
      notifyListeners();

      // Đọc toàn bộ gói dữ liệu JSON từ Server trả về
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return null; // Không có lỗi -> Thành công
      } else {
        // Trả về câu báo lỗi cụ thể từ Server (Ví dụ: "Mật khẩu mới không được trùng...")
        return data['message'] ?? 'Có lỗi xảy ra, vui lòng thử lại!';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Lỗi kết nối đến máy chủ.';
    }
  }
}
