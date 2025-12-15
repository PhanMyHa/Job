const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');

// Lấy danh sách thông báo theo email
router.get('/:email', async (req, res) => {
  const notifications = await Notification.find({ userEmail: req.params.email }).sort({ createdAt: -1 });
  res.json(notifications);
});

// Tạo thông báo mới
router.post('/', async (req, res) => {
  const { userEmail, title, message } = req.body;

  if (!userEmail || !title || !message) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  try {
    const notification = new Notification({
      userEmail,
      title,
      message,
      createdAt: new Date(),
    });
    await notification.save();
    res.status(201).json(notification);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;