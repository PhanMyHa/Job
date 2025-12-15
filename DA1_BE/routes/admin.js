const express = require('express');
const router = express.Router();
const Admin = require('../models/Admin');

// Route đăng ký admin
router.post('/register', async (req, res) => {
  const { adminId, name, password } = req.body;

  if (!adminId || !name || !password) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields',
    });
  }

  try {
    const existingAdmin = await Admin.findOne({ adminId });
    if (existingAdmin) {
      return res.status(400).json({
        success: false,
        message: 'Admin ID already exists',
      });
    }

    const admin = new Admin({
      adminId,
      name,
      password,
    });

    await admin.save();
    res.status(201).json({
      success: true,
      message: 'Admin registered successfully',
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message,
    });
  }
});

// Route đăng nhập admin
router.post('/login', async (req, res) => {
  const { adminId, password } = req.body;

  if (!adminId || !password) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields',
    });
  }

  try {
    const admin = await Admin.findOne({ adminId });
    if (!admin) {
      return res.status(400).json({
        success: false,
        message: 'Invalid admin ID or password',
      });
    }

    const isMatch = await admin.comparePassword(password);
    if (!isMatch) {
      return res.status(400).json({
        success: false,
        message: 'Invalid admin ID or password',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Admin login successful',
      admin: {
        adminId: admin.adminId,
        name: admin.name,
      },
    });
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message,
    });
  }
});

// Route lấy thông tin admin
router.get('/:adminId', async (req, res) => {
  try {
    const admin = await Admin.findOne({ adminId: req.params.adminId });
    if (admin) {
      res.json({
        adminId: admin.adminId,
        name: admin.name,
      });
    } else {
      res.status(404).json({ success: false, message: 'Admin not found' });
    }
  } catch (err) {
    res.status(400).json({
      success: false,
      message: err.message,
    });
  }
});

module.exports = router;