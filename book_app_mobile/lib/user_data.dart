import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserData {
  // Lưu thông tin user vào máy
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user));
  }

  // Lấy thông tin user ra dùng
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('user_data');
    if (userData == null) return null;
    return jsonDecode(userData);
  }

  // Đăng xuất (Xóa dữ liệu)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Hàm lưu đè thông tin mới (ví dụ sau khi mua sách)
  static Future<void> updateUser(Map<String, dynamic> newUser) async {
    final prefs = await SharedPreferences.getInstance();
    // Giữ lại token cũ hoặc các thông tin hệ thống nếu cần, ở đây thì bắt lưu đè luôn
    await prefs.setString('user_data', jsonEncode(newUser));
  }
}