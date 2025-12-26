class Book {
  final String id;
  final String title;
  final String author;
  final int price;
  final String coverImage;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.coverImage,
  });

  // Hàm này giúp chuyển đổi cục JSON loằng ngoằng thành Object gọn gàng
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'], // MongoDB dùng _id
      title: json['title'] ?? 'Không tên',
      author: json['author'] ?? 'Ẩn danh',
      price: json['price'] ?? 0,
      coverImage: json['cover_image'] ?? '',
    );
  }
}