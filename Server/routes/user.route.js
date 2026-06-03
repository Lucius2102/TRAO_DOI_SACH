const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'omnibook001@gmail.com', // Email dự án
        pass: 'ffwk vwsb frcn ovyo'    // App Password
    }
});

router.get('/', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .query('SELECT user_id, email, full_name, avatar_url, created_at FROM dbo.users');
        
        res.status(200).json({ success: true, data: result.recordset });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// [POST] 1. YÊU CẦU GỬI OTP (Lưu vào bảng tạm otp_requests)
router.post('/request-otp', async (req, res) => {
    const { email } = req.body;
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    const expiryDate = new Date();
    expiryDate.setMinutes(expiryDate.getMinutes() + 5); // OTP có hiệu lực 5 phút

    try {
        const pool = await poolPromise;

        // BƯỚC CHẶN: Kiểm tra xem email này đã có trong bảng users chính chưa
        const checkUser = await pool.request()
            .input('email', sql.VarChar, email)
            .query('SELECT user_id FROM dbo.users WHERE email = @email');
        
        if (checkUser.recordset.length > 0) {
            return res.status(400).json({ success: false, message: 'Email này đã được đăng ký tài khoản!' });
        }

        // Lưu vào bảng tạm otp_requests
        await pool.request()
            .input('email', sql.VarChar, email)
            .input('otp', sql.VarChar, otp)
            .input('expiry', sql.DateTime, expiryDate)
            .query(`
                MERGE dbo.otp_requests AS target
                USING (SELECT @email AS email) AS source
                ON (target.email = source.email)
                WHEN MATCHED THEN
                    UPDATE SET otp_code = @otp, otp_expiry = @expiry
                WHEN NOT MATCHED THEN
                    INSERT (email, otp_code, otp_expiry) VALUES (@email, @otp, @expiry);
            `);

        // Gửi email
        const mailOptions = {
            from: '"OmniBook" <omnibook001@gmail.com>',
            to: email,
            subject: 'Mã xác thực đăng ký tài khoản OmniBook',
            text: `Chào bạn,\n\nMã xác thực (OTP) của bạn là: ${otp}\n\nMã này sẽ hết hạn trong 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai.`
        };

        transporter.sendMail(mailOptions);
        res.status(200).json({ success: true, message: 'Đã gửi mã OTP thành công' });
    } catch (error) {
        console.error("Lỗi gửi email:", error);
        res.status(500).json({ success: false, message: 'Không thể gửi email' });
    }
});

// [POST] 2. XÁC THỰC OTP & TẠO TÀI KHOẢN CHÍNH THỨC
router.post('/register', async (req, res) => {
    const { full_name, email, password_hash, otp } = req.body;
    const currentTime = new Date();

    try {
        const pool = await poolPromise;

        // Lấy OTP từ bảng tạm ra để đối chiếu
        const otpResult = await pool.request()
            .input('email', sql.VarChar, email)
            .query('SELECT otp_code, otp_expiry FROM dbo.otp_requests WHERE email = @email');

        if (otpResult.recordset.length === 0) {
            return res.status(400).json({ success: false, message: 'Không tìm thấy yêu cầu xác thực' });
        }

        const otpData = otpResult.recordset[0];

        if (otpData.otp_code !== otp) {
            return res.status(400).json({ success: false, message: 'Mã OTP không chính xác' });
        }

        if (currentTime > otpData.otp_expiry) {
            return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn' });
        }
        //MÃ HÓA MẬT KHẨU
        const saltRounds = 10;
        const hashedPassword = await bcrypt.hash(password_hash, saltRounds);

        // OTP CHÍNH XÁC -> Insert vào bảng users với is_verified = 1
        await pool.request()
            .input('full_name', sql.NVarChar, full_name)
            .input('email', sql.VarChar, email)
            .input('password', sql.VarChar, hashedPassword)
            .query(`
                INSERT INTO dbo.users (email, password_hash, full_name, is_verified) 
                VALUES (@email, @password, @full_name, 1)
            `);

        // Dọn dẹp: Xóa dòng OTP này trong bảng tạm cho sạch sẽ
        await pool.request()
            .input('email', sql.VarChar, email)
            .query('DELETE FROM dbo.otp_requests WHERE email = @email');

        res.status(201).json({ success: true, message: 'Đăng ký tài khoản thành công! 🎉' });
    } catch (error) {
        console.error(error);
        if (error.number === 2627) {
            return res.status(409).json({ success: false, message: 'Email này đã được sử dụng!' });
        }
        res.status(500).json({ success: false, message: 'Lỗi hệ thống khi tạo tài khoản' });
    }
});

// [POST] 3. ĐĂNG NHẬP
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const pool = await poolPromise;
        
        const result = await pool.request()
            .input('email', sql.VarChar, email)
            .query('SELECT * FROM dbo.users WHERE email = @email');

        const user = result.recordset[0];

        if (!user) {
            return res.status(401).json({ success: false, message: 'Email hoặc mật khẩu không chính xác.' });
        }

        // XÓA ĐOẠN SO SÁNH THÔ Ở ĐÂY RỒI NHÉ

        // CHỐT CHẶN BẢO MẬT: Kiểm tra xem đã xác thực email chưa
        if (user.is_verified === false || user.is_verified === 0) {
            return res.status(403).json({ success: false, message: 'Vui lòng xác thực email trước khi đăng nhập.' });
        }
        
        const isMatch = await bcrypt.compare(password, user.password_hash);
        
        if (!isMatch) {
            return res.status(401).json({ success: false, message: 'Email hoặc mật khẩu không chính xác.' });
        }

        res.status(200).json({ 
            success: true, 
            message: 'Đăng nhập thành công!',
            user: {
                id: user.user_id,
                email: user.email,
                name: user.full_name
            }
        });

    } catch (error) {
        console.error('Lỗi login:', error);
        res.status(500).json({ success: false, message: 'Lỗi máy chủ nội bộ.' });
    }
});

// [POST] 4. QUÊN MẬT KHẨU (Gửi mã OTP reset)
router.post('/forgot-password', async (req, res) => {
    const { email } = req.body;
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiryDate = new Date();
    expiryDate.setMinutes(expiryDate.getMinutes() + 5);

    try {
        const pool = await poolPromise;

        // 1. Kiểm tra xem email này có tồn tại trong hệ thống không
        const checkUser = await pool.request()
            .input('email', sql.VarChar, email)
            .query('SELECT user_id FROM dbo.users WHERE email = @email');
        
        if (checkUser.recordset.length === 0) {
            return res.status(404).json({ success: false, message: 'Email này chưa được đăng ký trong hệ thống.' });
        }

        // 2. Lưu OTP vào bảng tạm
        await pool.request()
            .input('email', sql.VarChar, email)
            .input('otp', sql.VarChar, otp)
            .input('expiry', sql.DateTime, expiryDate)
            .query(`
                MERGE dbo.otp_requests AS target
                USING (SELECT @email AS email) AS source
                ON (target.email = source.email)
                WHEN MATCHED THEN
                    UPDATE SET otp_code = @otp, otp_expiry = @expiry
                WHEN NOT MATCHED THEN
                    INSERT (email, otp_code, otp_expiry) VALUES (@email, @otp, @expiry);
            `);

        // 3. Gửi email ngầm (Fire-and-forget)
        transporter.sendMail({
            from: '"OmniBook" <omnibook001@gmail.com>',
            to: email,
            subject: 'Yêu cầu khôi phục mật khẩu OmniBook',
            text: `Chào bạn,\n\nMã OTP để khôi phục mật khẩu của bạn là: ${otp}\n\nMã này sẽ hết hạn trong 5 phút.`
        }).catch(err => console.error("Lỗi gửi email reset:", err));

        // Báo thành công luôn
        res.status(200).json({ success: true, message: 'Mã OTP khôi phục đã được gửi!' });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Lỗi hệ thống.' });
    }
});

// [POST] 4.5. KIỂM TRA OTP KHÔI PHỤC MẬT KHẨU (Chưa đổi mật khẩu)
router.post('/verify-reset-otp', async (req, res) => {
    const { email, otp } = req.body;
    const currentTime = new Date();

    try {
        const pool = await poolPromise;
        const otpResult = await pool.request()
            .input('email', sql.VarChar, email)
            .query('SELECT otp_code, otp_expiry FROM dbo.otp_requests WHERE email = @email');

        if (otpResult.recordset.length === 0) {
            return res.status(400).json({ success: false, message: 'Yêu cầu không tồn tại.' });
        }
        
        const otpData = otpResult.recordset[0];
        if (otpData.otp_code !== otp) {
            return res.status(400).json({ success: false, message: 'Mã OTP không chính xác.' });
        }
        if (currentTime > otpData.otp_expiry) {
            return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn.' });
        }

        // OTP Đúng -> Trả về thành công nhưng KHÔNG xóa OTP vội
        // (OTP sẽ được xóa ở API /reset-password cuối cùng)
        res.status(200).json({ success: true, message: 'OTP hợp lệ.' });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Lỗi hệ thống.' });
    }
});

// [POST] 5. ĐẶT LẠI MẬT KHẨU MỚI (Xác thực OTP + Đổi pass)
router.post('/reset-password', async (req, res) => {
    const { email, otp, new_password } = req.body;
    const currentTime = new Date();

    try {
        const pool = await poolPromise;

        // 1. Lấy OTP từ bảng tạm và lấy password_hash cũ từ bảng users ra cùng lúc
        const userResult = await pool.request()
            .input('email', sql.VarChar, email)
            .query(`
                SELECT u.password_hash, o.otp_code, o.otp_expiry 
                FROM dbo.users u
                LEFT JOIN dbo.otp_requests o ON u.email = o.email
                WHERE u.email = @email
            `);

        if (userResult.recordset.length === 0) {
            return res.status(44).json({ success: false, message: 'Không tìm thấy tài khoản.' });
        }

        const userData = userResult.recordset[0];

        // 2. Kiểm tra mã OTP trước
        if (!userData.otp_code || userData.otp_code !== otp) {
            return res.status(400).json({ success: false, message: 'Mã OTP không chính xác hoặc đã hết hạn.' });
        }

        if (currentTime > userData.otp_expiry) {
            return res.status(400).json({ success: false, message: 'Mã OTP đã hết hạn. Vui lòng xin lại mã mới.' });
        }

        // ==========================================================
        // BƯỚC KIỂM TRA: MẬT KHẨU MỚI KHÔNG ĐƯỢC TRÙNG MẬT KHẨU CŨ (MỚI)
        // ==========================================================
        const isSamePassword = await bcrypt.compare(new_password, userData.password_hash);
        if (isSamePassword) {
            return res.status(400).json({ 
                success: false, 
                message: 'Mật khẩu mới không được trùng với mật khẩu cũ gần nhất!' 
            });
        }

        // 3. Mọi thứ hợp lệ -> Tiến hành mã hóa mật khẩu mới
        const saltRounds = 10;
        const hashedNewPassword = await bcrypt.hash(new_password, saltRounds);

        // Cập nhật mật khẩu mới vào bảng users
        await pool.request()
            .input('email', sql.VarChar, email)
            .input('new_password', sql.VarChar, hashedNewPassword)
            .query('UPDATE dbo.users SET password_hash = @new_password WHERE email = @email');

        // Xóa OTP trong bảng tạm
        await pool.request().input('email', sql.VarChar, email).query('DELETE FROM dbo.otp_requests WHERE email = @email');

        res.status(200).json({ success: true, message: 'Đổi mật khẩu thành công!' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ success: false, message: 'Lỗi hệ thống.' });
    }
});
module.exports = router;