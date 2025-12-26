import 'package:flutter/material.dart';
import 'models/book.dart';
import 'pdf_viewer_screen.dart';

class DetailScreen extends StatelessWidget {
  final Book book;

  // Nhận dữ liệu cuốn sách từ màn hình Home truyền sang
  const DetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Cho phép cuộn nếu nội dung dài
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Ảnh bìa lớn
            SizedBox(
              width: double.infinity,
              height: 250,
              child: Image.network(
                book.coverImage,
                fit: BoxFit.contain, // Hiển thị trọn vẹn ảnh
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey, child: const Icon(Icons.error)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Giá tiền và Loại sách
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${book.price == 0 ? "Miễn phí" : "${book.price} đ"}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('E-book'), // Sau này sẽ check logic để hiện Sách giấy/Ebook
                        backgroundColor: Colors.blue.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 3. Tên sách và Tác giả
                  Text(
                    book.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tác giả: ${book.author}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // 4. Mô tả nội dung
                  const Text(
                    "Giới thiệu nội dung:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Nếu không có mô tả thì hiện văn bản mẫu
                    "Đây là cuốn sách rất hay nói về những triết lý nhân sinh quan...",
                    style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),

                  // 5. Nút Hành động (Mua hoặc Đọc)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Kiểm tra giả lập: Nếu có link file thì mở đọc
                        // (Lưu ý: Trong DB bạn phải có trường file_url, và model Book phải parse được nó)
                        // Tạm thời tôi giả định bạn test với link mẫu nếu DB chưa có
                        String pdfUrl = "https://pdfobject.com/pdf/sample.pdf";

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(
                              bookTitle: book.title,
                              url: pdfUrl, // Sau này thay bằng book.fileUrl
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'ĐỌC NGAY', // Hoặc "THÊM VÀO GIỎ"
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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