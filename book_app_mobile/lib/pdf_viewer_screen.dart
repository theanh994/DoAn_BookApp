import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  final String bookTitle;
  final String url;

  const PDFViewerScreen({super.key, required this.bookTitle, required this.url});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String localPath = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  // Hàm tải file PDF từ internet về máy (Cache tạm)
  Future<void> loadPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/temp_book.pdf');

        await file.writeAsBytes(bytes, flush: true);

        setState(() {
          localPath = file.path;
          isLoading = false; // Tắt xoay khi thành công
        });
      } else {
        throw Exception('Server trả về lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print("Lỗi tải PDF: $e");
      // QUAN TRỌNG: Gặp lỗi cũng phải tắt xoay để người dùng biết
      setState(() {
        isLoading = false;
      });

      // Hiện thông báo lỗi lên màn hình
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không tải được sách: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.bookTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: localPath, // Mở file từ đường dẫn đã tải
        enableSwipe: true,
        swipeHorizontal: true, // Lật trang ngang
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}