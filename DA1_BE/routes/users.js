const express = require('express');
const router = express.Router();
const User = require('../models/User');
const bcrypt = require('bcrypt');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, `avatar_${req.params.email}_${Date.now()}${path.extname(file.originalname)}`);
  },
});
const upload = multer({ storage: storage });

// Route đăng ký
router.post('/register', async (req, res) => {
  const { email, name, password, receiveNotifications } = req.body;

  if (!email || !name || !password) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields',
    });
  }

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists',
      });
    }

    // const hashedPassword = await bcrypt.hash(password, 10);
    // const user = new User({
    //   email,
    //   name,
    //   password: hashedPassword,
    //   receiveNotifications: receiveNotifications ?? true,
    //   education: [],
    //   skills: [],
    //   experience: [],
    //   avatar: '',
    // });

    await user.save();
    res.status(201).json({
      success: true,
      message: 'User registered successfully',
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message,
    });
  }
});

// Route đăng nhập
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields',
    });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid email or password',
      });
    }

    // const isMatch = await bcrypt.compare(password, user.password);
    // if (!isMatch) {
    //   return res.status(400).json({
    //     success: false,
    //     message: 'Invalid email or password',
    //   });
    // }

    res.status(200).json({
      success: true,
      message: 'Login successful',
      user: {
        email: user.email,
        name: user.name,
        receiveNotifications: user.receiveNotifications,
        education: user.education,
        skills: user.skills,
        experience: user.experience,
        avatar: user.avatar,
      },
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message,
    });
  }
});

// Route lấy tất cả users
router.get('/', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// Route lấy thông tin user
router.get('/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
});

// Route cập nhật thông tin user
router.put('/:email', async (req, res) => {
  try {
    const user = await User.findOneAndUpdate(
      { email: req.params.email },
      req.body,
      { new: true }
    );
    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ success: false, message: 'User not found' });
    }
  } catch (err) {
    res.status(400).json({ success: false, message: err.message });
  }
});

// Route upload avatar
router.post('/:email/avatar', upload.single('avatar'), async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    user.avatar = `/uploads/${req.file.filename}`;
    await user.save();
    res.json({ avatar: user.avatar });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;