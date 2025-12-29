import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/book.dart';
import 'pdf_viewer_screen.dart';
import 'user_data.dart';
import 'constants.dart';
import 'login_screen.dart';

class DetailScreen extends StatefulWidget {
  final Book book;
  const DetailScreen({super.key, required this.book});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isOwned = false; // Trạng thái: Đã mua hay chưa
  bool isLoading = true;
  Map<String, dynamic>? user; // Thông tin user hiện tại

  @override
  void initState() {
    super.initState();
    checkOwnership();
  }

  // 1. Kiểm tra xem đã mua sách này chưa
  Future<void> checkOwnership() async {
    final userData = await UserData.getUser();
    setState(() {
      user = userData;
      if (user != null && user!['purchased_books'] != null) {
        // Kiểm tra ID sách có trong mảng đã mua không
        List<dynamic> purchased = user!['purchased_books'];
        isOwned = purchased.contains(widget.book.id);
      }
      // Nếu sách miễn phí (giá = 0) thì coi như đã sở hữu
      if (widget.book.price == 0) {
        isOwned = true;
      }
      isLoading = false;
    });
  }

  // 2. Hàm xử lý Mua sách
  Future<void> buyBook() async {
    // --- THÊM ĐOẠN CHECK KHÁCH VÃNG LAI Ở ĐÂY ---
    if (user == null) {
      // Hiển thị hộp thoại hỏi người dùng
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Yêu cầu đăng nhập"),
          content: const Text("Bạn cần đăng nhập để mua sách này. Bạn có muốn đăng nhập ngay không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Đóng hộp thoại
              child: const Text("Để sau"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại trước
                // Chuyển sang màn hình Đăng nhập
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text("Đăng nhập"),
            ),
          ],
        ),
      );
      return; // Dừng lại, không chạy code mua bên dưới
    }

    // Hiển thị hộp thoại xác nhận
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận mua"),
        content: Text("Bạn có muốn mua sách này với giá ${widget.book.price} đ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Đồng ý")),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('${Constants.baseUrl}/buy');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "userId": user!['_id'], // ID của user trong MongoDB
          "bookId": widget.book.id,
        }),
      );

      final resData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Mua thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mua sách thành công!"), backgroundColor: Colors.green),
        );

        // Cập nhật lại thông tin User trong bộ nhớ (để trừ tiền và thêm sách)
        // Server trả về newBalance và purchasedBooks mới, ta cập nhật vào user local
        user!['wallet_balance'] = resData['newBalance'];
        user!['purchased_books'] = resData['purchasedBooks'];
        await UserData.updateUser(user!);

        setState(() {
          isOwned = true; // Đổi trạng thái thành Đã sở hữu
        });
      } else {
        // Lỗi (ví dụ thiếu tiền)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resData['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title), backgroundColor: Colors.blue),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                widget.book.coverImage,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey, child: const Icon(Icons.error)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.book.price == 0 ? "Miễn phí" : "${widget.book.price} đ",
                        style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      // Nếu đã mua thì hiện chữ Đã sở hữu
                      if (isOwned)
                        const Chip(
                          label: Text('Đã sở hữu'),
                          backgroundColor: Colors.greenAccent,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Tác giả: ${widget.book.author}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 20),
                  const Text("Giới thiệu nội dung:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(widget.book.description ?? "Đang cập nhật...", style: const TextStyle(fontSize: 15, height: 1.5)),

                  const SizedBox(height: 30),

                  // --- NÚT BẤM THÔNG MINH ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOwned ? Colors.blue : Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (isOwned) {
                          // ĐÃ MUA -> ĐỌC
                          String pdfUrl = "https://pdfobject.com/pdf/sample.pdf"; // Link test
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewerScreen(
                                bookTitle: widget.book.title,
                                url: pdfUrl,
                              ),
                            ),
                          );
                        } else {
                          // CHƯA MUA -> GỌI HÀM MUA
                          buyBook();
                        }
                      },
                      child: Text(
                        isOwned ? 'ĐỌC NGAY' : 'MUA NGAY (${widget.book.price} đ)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}