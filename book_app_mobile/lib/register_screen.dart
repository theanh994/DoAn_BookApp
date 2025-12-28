import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Các biến để lấy dữ liệu từ ô nhập
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Hàm gọi API Đăng ký
  Future<void> register() async {
    setState(() => isLoading = true);

    // Kiểm tra rỗng
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin bắt buộc!")),
      );
      return; // Dừng lại, không gửi lên server
    }

    // Kiểm tra Số điện thoại (Phải đủ 10 số)
    if (_phoneController.text.length != 10) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại không hợp lệ (phải có 10 số)")),
      );
      return;
    }

    // Kiểm tra Email (Phải có chữ @)
    if (!_emailController.text.contains('@')) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email không đúng định dạng")),
      );
      return;
    }

    // Kiểm tra mật khẩu khớp
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp")),
      );
      return;
    }

    // 1. Chuẩn bị dữ liệu
    // final url = Uri.parse('http://10.0.2.2:3000/api/register');
    final url = Uri.parse('${Constants.baseUrl}/register');
    final body = jsonEncode({
      "full_name": _nameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
    });

    try {
      // 2. Gửi lên Server
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // Thêm charset=UTF-8 cho phép hiển thị tên Tiếng Việt
        },
        body: body,
      );

      // 3. Xử lý kết quả
      if (response.statusCode == 201) {
        // Thành công -> Quay lại màn hình đăng nhập
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")),
        );
        Navigator.pop(context); // Đóng màn hình đăng ký
      } else {
        // Lỗi (ví dụ trùng email)
        final error = jsonDecode(response.body)['message'];
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }

  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng Ký Tài Khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words, // Tự động viết hoa tên riêng
              decoration: const InputDecoration(
                  labelText: "Họ và Tên",
                  prefixIcon: Icon(Icons.person)
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email)
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,// Ẩn mật khẩu
              decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  )
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  )
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone, // Bàn phím số
              maxLength: 10,
              decoration: const InputDecoration(
                  labelText: "Số điện thoại",
                  prefixIcon: Icon(Icons.phone),
                  counterText: ""),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                  labelText: "Địa chỉ nhận sách",
                  prefixIcon: Icon(Icons.home)),
            ),
            const SizedBox(height: 10),

            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text("ĐĂNG KÝ NGAY"),
            ),
          ],
        ),
      ),
    );
  }
}