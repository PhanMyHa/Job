const express = require('express');
const router = express.Router();
const Application = require('../models/Application');
const Notification = require('../models/Notification');
const AdminNotification = require('../models/AdminNotification');
const Job = require('../models/Job');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

// Tạo ứng tuyển mới
router.post('/', upload.single('cv'), async (req, res) => {
  try {
    const { jobId, firstName, lastName, email, country, message } = req.body;

    const application = new Application({
      jobId,
      firstName,
      lastName,
      email,
      country,
      message,
      cvPath: req.file ? `/uploads/${req.file.filename}` : undefined,
      status: 'Delivered',
      createdAt: new Date(),
    });

    await application.save();

    const job = await Job.findById(jobId);
    const enrichedApplication = {
      ...application.toObject(),
      jobTitle: job ? job.title : 'Unknown Job',
      salary: job ? job.salary : 'N/A',
    };

    // Tạo thông báo cho user
    const userNotification = await Notification.create({
      userEmail: email,
      title: 'Application Submitted',
      message: `Your application for ${enrichedApplication.jobTitle} has been submitted.`,
      createdAt: new Date(),
    });

    // Tạo thông báo cho admin
    const adminNotification = await AdminNotification.create({
      title: 'New Application',
      message: `${firstName} ${lastName} applied for ${enrichedApplication.jobTitle}.`,
      createdAt: new Date(),
    });

    // Gửi thông báo qua socket.io
    const io = req.app.get('socketio');
    io.to(email).emit('receive_notification', userNotification);
    io.to('admin_room').emit('receive_admin_notification', adminNotification);

    res.status(201).json(enrichedApplication);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Lấy danh sách ứng tuyển theo email
router.get('/:email', async (req, res) => {
  try {
    const applications = await Application.find({ email: req.params.email });
    const enrichedApplications = await Promise.all(
      applications.map(async (app) => {
        const job = await Job.findById(app.jobId);
        return {
          ...app.toObject(),
          jobTitle: job ? job.title : 'Unknown Job',
          salary: job ? job.salary : 'N/A',
        };
      })
    );
    res.json(enrichedApplications);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Lấy tất cả ứng tuyển
router.get('/', async (req, res) => {
  try {
    const applications = await Application.find();
    const enrichedApplications = await Promise.all(
      applications.map(async (app) => {
        const job = await Job.findById(app.jobId);
        return {
          ...app.toObject(),
          jobTitle: job ? job.title : 'Unknown Job',
          salary: job ? job.salary : 'N/A',
        };
      })
    );
    res.json(enrichedApplications);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Phê duyệt ứng tuyển
router.post('/:applicationId/approve', async (req, res) => {
  try {
    const application = await Application.findById(req.params.applicationId);
    if (!application) {
      return res.status(404).json({ message: 'Application not found' });
    }
    application.status = 'Approved';
    await application.save();

    const job = await Job.findById(application.jobId);
    const jobTitle = job ? job.title : 'Unknown Job';

    // Tạo thông báo cho user
    const userNotification = await Notification.create({
      userEmail: application.email,
      title: 'Application Approved',
      message: `Your application for ${jobTitle} has been approved.`,
      createdAt: new Date(),
    });

    // Tạo thông báo cho admin
    const adminNotification = await AdminNotification.create({
      title: 'Application Approved',
      message: `Application by ${application.firstName} ${application.lastName} for ${jobTitle} has been approved.`,
      createdAt: new Date(),
    });

    // Gửi thông báo qua socket.io
    const io = req.app.get('socketio');
    io.to(application.email).emit('receive_notification', userNotification);
    io.to('admin_room').emit('receive_admin_notification', adminNotification);

    res.status(200).json({ message: 'Application approved', notification: adminNotification });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Từ chối ứng tuyển
router.post('/:applicationId/reject', async (req, res) => {
  try {
    const application = await Application.findById(req.params.applicationId);
    if (!application) {
      return res.status(404).json({ message: 'Application not found' });
    }
    application.status = 'Rejected';
    await application.save();

    const job = await Job.findById(application.jobId);
    const jobTitle = job ? job.title : 'Unknown Job';

    // Tạo thông báo cho user
    const userNotification = await Notification.create({
      userEmail: application.email,
      title: 'Application Rejected',
      message: `Your application for ${jobTitle} has been rejected.`,
      createdAt: new Date(),
    });

    // Tạo thông báo cho admin
    const adminNotification = await AdminNotification.create({
      title: 'Application Rejected',
      message: `Application by ${application.firstName} ${application.lastName} for ${jobTitle} has been rejected.`,
      createdAt: new Date(),
    });

    // Gửi thông báo qua socket.io
    const io = req.app.get('socketio');
    io.to(application.email).emit('receive_notification', userNotification);
    io.to('admin_room').emit('receive_admin_notification', adminNotification);

    res.status(200).json({ message: 'Application rejected', notification: adminNotification });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;