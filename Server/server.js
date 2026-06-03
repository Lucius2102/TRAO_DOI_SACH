const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware để đọc được dữ liệu JSON từ Flutter gửi lên
app.use(express.json());
app.use(cors());

// Import và sử dụng Router
const userRoutes = require('./routes/user.route');
app.use('/api/users', userRoutes); // Tất cả API trong file kia sẽ có tiền tố là /api/users

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server đang chạy trên cổng http://localhost:${PORT}`);
});
