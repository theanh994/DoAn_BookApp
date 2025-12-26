const mongoose = require('mongoose');

require('dotenv').config(); // Dòng này giúp đọc file .env
const uri = process.env.MONGO_URI; // Lấy mật khẩu từ .env ra

async function connectDB() {
  try {
    await mongoose.connect(uri);
    console.log("-----------------------------------------");
    console.log("✅ KẾT NỐI THÀNH CÔNG! CHÚC MỪNG BẠN.");
    console.log("-----------------------------------------");
  } catch (error) {
    console.error("❌ Kết nối thất bại:", error.message);
  } finally {
    // Đóng kết nối sau khi test xong
    await mongoose.disconnect();
  }
}

connectDB();