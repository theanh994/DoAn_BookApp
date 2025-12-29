import 'package:flutter/material.dart';
import 'user_data.dart'; // File quản lý lưu trữ user
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Gọi hàm kiểm tra ngay khi màn hình hiện lên
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 1. Giả vờ đợi 2 giây cho người dùng kịp nhìn thấy Logo (tạo hiệu ứng mượt)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Kiểm tra dữ liệu trong máy
    final user = await UserData.getUser();

    // 3. Điều hướng (Dùng pushReplacement để không cho back lại Splash)
    if (!mounted) return;

    if (user != null) {
      // Đã đăng nhập -> Vào thẳng trang chủ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Chưa đăng nhập -> Vào trang đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Màu nền thương hiệu
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ứng dụng (Icon sách)
            const Icon(
                Icons.book,
                size: 100,
                color: Colors.white
            ),
            const SizedBox(height: 20),

            // Tên ứng dụng
            const Text(
              "Sincerely - The Garden",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),

            // Vòng tròn xoay xoay loading (nhỏ nhỏ bên dưới)
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}