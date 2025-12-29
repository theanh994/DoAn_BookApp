// backend/index.js
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const cors = require('cors');

// Import các Models (Khuôn mẫu dữ liệu)
const Book = require('./models/Book');
const User = require('./models/User');

const app = express();
const PORT = process.env.PORT || 3000; // Cổng chạy server
// Cấu hình để phục vụ file tĩnh 
app.use(express.static(path.join(__dirname, 'public')));

// Cấu hình Middleware (Để server hiểu được dữ liệu JSON)
app.use(express.json());
app.use(cors()); // Cho phép App Mobile gọi vào Server này

// 1. KẾT NỐI MONGODB
require('dotenv').config(); // Dòng này giúp đọc file .env
const uri = process.env.MONGO_URI; // Lấy mật khẩu từ .env ra

mongoose.connect(uri)
  .then(() => {
    console.log("✅ Đã kết nối MongoDB thành công!");
    console.log("📂 Đang sử dụng Database tên là:", mongoose.connection.name);
  })
  .catch((err) => console.error("❌ Lỗi kết nối:", err));

// 2. VIẾT API (CÁC ĐƯỜNG DẪN)

// API 1: Trang chủ (Trả về HTML để hiện Icon)
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>Sincerely - The Garden</title>
        <!-- Dòng này ép trình duyệt phải lấy icon -->
        <link rel="icon" type="image/x-icon" href="/favicon.ico">
      </head>
      <body style="font-family: sans-serif; text-align: center; padding-top: 50px;">
        <h1>🚀 Server Sincerely - The Garden đang chạy ngon lành!</h1>
        <p>Được deploy trên Render.</p>
      </body>
    </html>
  `);
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

// API 4: Đăng ký tài khoản mới
app.post('/api/register', async (req, res) => {
  try {
    const { email, password, full_name, phone, address } = req.body;

    // 1. Kiểm tra xem email đã tồn tại chưa
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email này đã được sử dụng!" });
    }

    // 2. Tạo user mới
    const newUser = new User({
      email,
      password, //  Đồ án chưa mã hóa password (nâng cấp sau)
      phone,
      address,
      full_name,
      role: 'user', // Mặc định là user thường
      wallet_balance: 0 // Ví 0 đồng
    });

    await newUser.save();

    res.status(201).json({ 
      message: "Đăng ký thành công!", 
      user: newUser 
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// API 5: Mua sách
app.post('/api/buy', async (req, res) => {
  try {
    const { userId, bookId } = req.body;

    // 1. Lấy thông tin User và Book
    const user = await User.findById(userId);
    const book = await Book.findById(bookId);

    if (!user || !book) {
      return res.status(404).json({ message: "Không tìm thấy người dùng hoặc sách" });
    }

    // 2. Kiểm tra xem đã mua chưa
    if (user.purchased_books && user.purchased_books.includes(bookId)) {
      return res.status(400).json({ message: "Bạn đã sở hữu sách này rồi!" });
    }

    // 3. Kiểm tra tiền
    if (user.wallet_balance < book.price) {
      return res.status(400).json({ message: "Số dư không đủ. Vui lòng nạp thêm!" });
    }

    // 4. TRỪ TIỀN & THÊM SÁCH
    user.wallet_balance -= book.price; // Trừ tiền
    user.purchased_books.push(bookId); // Thêm ID sách vào danh sách đã mua
    
    await user.save(); // Lưu lại vào Database

    res.status(200).json({ 
      message: "Mua sách thành công!", 
      newBalance: user.wallet_balance,
      purchasedBooks: user.purchased_books
    });

  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// 3. KHỞI CHẠY SERVER
app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy tại địa chỉ: http://localhost:${PORT}`);
});