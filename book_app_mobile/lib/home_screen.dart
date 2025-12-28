import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/book.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import 'constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> books = []; // Danh sách sách sẽ hiển thị
  bool isLoading = true; // Biến để hiện vòng tròn xoay xoay khi đang tải

  @override
  void initState() {
    super.initState();
    fetchBooks(); // Gọi hàm lấy sách ngay khi mở màn hình
  }

  // Hàm gọi API
  Future<void> fetchBooks() async {
    print("--- BẮT ĐẦU GỌI API LẤY SÁCH ---");
    // final url = Uri.parse('http://10.0.2.2:3000/api/books'); Dùng 10.0.2.2 cho máy ảo Android
    final url = Uri.parse('${Constants.baseUrl}/books');

    try {
      final response = await http.get(url);

      print("Trạng thái Server: ${response.statusCode}");
      print("Dữ liệu trả về: ${response.body}");

      if (response.statusCode == 200) {
        // Nếu thành công, giải mã JSON
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          books = data.map((json) => Book.fromJson(json)).toList();
          isLoading = false; // Tắt loading
        });
        print("=> Đã tải được ${books.length} cuốn sách");
      } else {
        print('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư Viện Sách'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiện vòng xoay nếu đang tải
          : ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(book: book),
                  ),
                );
              },
              leading: Image.network(
                book.coverImage,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.book), // Hiện icon nếu ảnh lỗi
              ),
              title: Text(
                book.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(book.author),
              trailing: Text(
                '${book.price} đ',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}