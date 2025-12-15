const express = require('express');
const router = express.Router();
const AdminNotification = require('../models/AdminNotification');

// Lấy danh sách tất cả thông báo admin
router.get('/', async (req, res) => {
  try {
    const notifications = await AdminNotification.find().sort({ createdAt: -1 });
    res.json(notifications);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Tạo thông báo admin mới
router.post('/', async (req, res) => {
  const { title, message } = req.body;

  if (!title || !message) {
    return res.status(400).json({ success: false, message: 'Missing required fields' });
  }

  try {
    const notification = await AdminNotification.create({
      title,
      message,
      createdAt: new Date(),
    });

    // Gửi thông báo qua socket.io tới admin_room
    const io = req.app.get('socketio');
    io.to('admin_room').emit('receive_admin_notification', notification);

    res.status(201).json(notification);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;