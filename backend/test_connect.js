const mongoose = require('mongoose');

// Thay đổi dòng bên dưới bằng chuỗi kết nối bạn vừa copy
// Nhớ thay <db_password> bằng mật khẩu thật (ví dụ 123456)
const uri = "mongodb+srv://theanht_db_user:tta992004@cluster0.tyafjxu.mongodb.net/?appName=Cluster0"; 

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