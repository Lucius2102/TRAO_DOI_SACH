import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  List<UserModel> _users = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getter để tầng View lấy dữ liệu an toàn
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Hàm gọi API
  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners(); // Báo cho View biết đang tải dữ liệu để hiện vòng xoay

    try {
      // Dùng 10.0.2.2 cho máy ảo Android, port 3100 như bạn đã test
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3100/api/users'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Kiểm tra biến success từ cấu trúc API của bạn
        if (responseData['success'] == true) {
          final List<dynamic> userJsonList = responseData['data'];
          _users = userJsonList
              .map((json) => UserModel.fromJson(json))
              .toList();
        }
      } else {
        _errorMessage = 'Lỗi server: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Không thể kết nối đến máy chủ: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Báo cho View biết đã lấy xong dữ liệu
    }
  }
}
