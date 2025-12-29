import 'package:flutter/material.dart';
import 'user_data.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    // Lấy thông tin user từ bộ nhớ máy (đã lưu lúc đăng nhập)
    final data = await UserData.getUser();
    setState(() {
      user = data; // Nếu là khách thì user sẽ là null
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? _buildGuestUI() // <--- Giao diện cho Khách
          : _buildUserUI(), // <--- Giao diện cho Thành viên (Code cũ)
    );
  }

  // GIAO DIỆN CHO KHÁCH
  Widget _buildGuestUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            "Bạn đang dùng chế độ Khách",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Chuyển sang màn hình đăng nhập
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Đăng nhập ngay"),
          ),
        ],
      ),
    );
  }

  // GIAO DIỆN CHO THÀNH VIÊN (Copy nội dung cũ của bạn vào đây)
  Widget _buildUserUI() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. AVATAR VÀ TÊN
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              user!['full_name'] ?? "Tên người dùng",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user!['email'] ?? "",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 30),
            const Divider(), // Đường kẻ ngang
            // 2. THÔNG TIN CÁ NHÂN (MỚI THÊM)
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text("Số điện thoại"),
              subtitle: Text(
                (user!['phone'] != null && user!['phone'] != "")
                    ? user!['phone']
                    : "Chưa cập nhật",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text("Địa chỉ"),
              subtitle: Text(
                (user!['address'] != null && user!['address'] != "")
                    ? user!['address']
                    : "Chưa cập nhật",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const Divider(), // Đường kẻ ngang
            // 3. VÍ TIỀN
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Card(
                elevation: 4,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.blue,
                    size: 30,
                  ),
                  title: const Text(
                    "Số dư ví",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    "${user!['wallet_balance'] ?? 0} đ",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4. NÚT ĐĂNG XUẤT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  // Xóa dữ liệu user trong máy
                  await UserData.logout();

                  if (!mounted) return;
                  // Quay về màn hình đăng nhập, xóa hết các màn hình cũ
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("Đăng xuất", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
