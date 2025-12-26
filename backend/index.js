// backend/index.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Import các Models (Khuôn mẫu dữ liệu)
const Book = require('./models/Book');
const User = require('./models/User');

const app = express();
const PORT = 3000; // Cổng chạy server

// Cấu hình Middleware (Để server hiểu được dữ liệu JSON)
app.use(express.json());
app.use(cors()); // Cho phép App Mobile gọi vào Server này

// 1. KẾT NỐI MONGODB
require('dotenv').config(); // Dòng này giúp đọc file .env
const uri = process.env.MONGO_URI; // Lấy mật khẩu từ .env ra

mongoose.connect(uri)
  .then(() => console.log("✅ Đã kết nối MongoDB thành công!"))
  .catch((err) => console.error("❌ Lỗi kết nối:", err));

// 2. VIẾT API (CÁC ĐƯỜNG DẪN)

// API 1: Trang chủ (Test xem server sống hay chết)
app.get('/', (req, res) => {
  res.send('Xin chào! Server BookApp đang chạy ngon lành.');
});

// API 2: Lấy danh sách toàn bộ sách
// App Mobile sẽ gọi vào đường dẫn: http://localhost:3000/api/books
app.get('/api/books', async (req, res) => {
  try {
    const books = await Book.find(); // Lệnh lấy tất cả sách từ DB
    res.status(200).json(books); // Trả về dạng JSON cho App
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// API 3: Đăng nhập (Đơn giản - chưa mã hóa mật khẩu để test trước)
// App Mobile sẽ gọi: POST http://localhost:3000/api/login
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Tìm xem có user nào trùng email không
    const user = await User.findOne({ email: email });
    
    if (!user) {
      return res.status(404).json({ message: "Email không tồn tại!" });
    }

    // Kiểm tra mật khẩu (So sánh thô - sau này sẽ nâng cấp)
    if (user.password !== password) {
      return res.status(400).json({ message: "Sai mật khẩu!" });
    }

    // Nếu đúng hết -> Trả về thông tin user
    res.status(200).json({ 
      message: "Đăng nhập thành công",
      user: user 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 3. KHỞI CHẠY SERVER
app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại địa chỉ: http://localhost:${PORT}`);
});