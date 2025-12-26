// backend/models/User.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  email: { 
    type: String, 
    required: true, 
    unique: true // Không cho phép trùng email
  },
  password: { 
    type: String, 
    required: true 
  },
  full_name: { type: String, default: 'Người dùng mới' },
  role: { 
    type: String, 
    enum: ['user', 'admin'], // Chỉ chấp nhận 2 giá trị này
    default: 'user' 
  },
  wallet_balance: { type: Number, default: 0 }, // Ví tiền mặc định 0đ
  avatar: { type: String, default: '' },
}, { timestamps: true }); // Tự động tạo ngày created_at

module.exports = mongoose.model('User', UserSchema);