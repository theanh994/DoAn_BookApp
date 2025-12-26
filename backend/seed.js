const mongoose = require('mongoose');
const User = require('./models/User');
const Book = require('./models/Book');

require('dotenv').config(); // Dòng này giúp đọc file .env
const uri = process.env.MONGO_URI; // Lấy mật khẩu từ .env ra

const sampleBooks = [
  {
    title: "Nhà Giả Kim",
    author: "Paulo Coelho",
    description: "Cuốn sách bán chạy nhất chỉ sau Kinh Thánh...",
    price: 50000,
    type: "physical",
    cover_image: "https://via.placeholder.com/150", // Ảnh giả lập
    stock_quantity: 10
  },
  {
    title: "Dế Mèn Phiêu Lưu Ký",
    author: "Tô Hoài",
    description: "Truyện thiếu nhi kinh điển của Việt Nam.",
    price: 0, // Miễn phí
    type: "ebook",
    cover_image: "https://via.placeholder.com/150",
    file_url: "https://example.com/demen.pdf",
    allow_download: true
  }
];

const seedData = async () => {
  try {
    await mongoose.connect(uri);
    console.log("🔌 Đã kết nối DB...");

    // 1. Xóa sạch dữ liệu cũ (để tránh bị trùng khi chạy nhiều lần)
    await User.deleteMany({});
    await Book.deleteMany({});
    console.log("🗑️  Đã xóa dữ liệu cũ.");

    // 2. Tạo User mẫu
    await User.create({
      email: "sinhvien@gmail.com",
      password: "123", // Sau này sẽ mã hóa, giờ để trần test cho dễ
      full_name: "Nguyễn Văn A",
      role: "admin",
      wallet_balance: 1000000
    });
    console.log("👤 Đã tạo User mẫu: sinhvien@gmail.com");

    // 3. Tạo Sách mẫu
    await Book.insertMany(sampleBooks);
    console.log("📚 Đã tạo 2 cuốn sách mẫu.");

    console.log("✅ HOÀN TẤT! HÃY KIỂM TRA COMPASS.");
  } catch (error) {
    console.error("Lỗi:", error);
  } finally {
    mongoose.disconnect();
  }
};

seedData();