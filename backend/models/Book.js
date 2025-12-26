// backend/models/Book.js
const mongoose = require('mongoose');

const BookSchema = new mongoose.Schema({
  title: { type: String, required: true },
  author: { type: String, required: true },
  description: { type: String },
  cover_image: { type: String }, // Link ảnh bìa
  price: { type: Number, required: true }, // Giá tiền
  type: { 
    type: String, 
    enum: ['ebook', 'physical', 'comic'], 
    required: true 
  },
  // Nếu là ebook thì cần link tải
  file_url: { type: String, default: '' },
  allow_download: { type: Boolean, default: false },
  
  // Thống kê
  total_reads: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.model('Book', BookSchema);