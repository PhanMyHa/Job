require('dotenv').config();
const express = require('express');
const router = express.Router();
const Job = require('../models/Job');
const User = require('../models/User');
const axios = require('axios');
const multer = require('multer');
const path = require('path');
const { createWorker } = require('tesseract.js');

// Lấy danh sách công việc
router.get('/', async (req, res) => {
  const { title, location, jobType, salary, sort } = req.query;
  const query = {};

  // Tìm kiếm theo title 
  if (title) {
    const cleanTitle = title.trim(); 
    if (cleanTitle) {
      query.title = { $regex: cleanTitle, $options: 'i' }; 
    }
  }
  if (location) query.location = new RegExp(location.trim(), 'i');
  if (jobType) query.jobType = jobType;
  if (salary) query.salary = { $gte: parseInt(salary) };

  try {
    let jobs = Job.find(query);
    if (sort === 'recent') {
      jobs = jobs.sort({ createdAt: -1 });
    }
    const result = await jobs;
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
router.post('/', async (req, res) => {
  const { title, company, location, jobType, salary, requiredSkills, qualifications } = req.body;
  if (!title || !company || !location || !jobType || !salary) {
    return res.status(400).json({ message: 'Missing required fields' });
  }
  try {
    const job = new Job({
      title,
      company,
      location,
      jobType,
      salary,
      requiredSkills: requiredSkills || [],
      qualifications: qualifications || [],
    });
    await job.save();
    res.status(201).json(job);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});
// Lấy chi tiết công việc theo ID
router.get('/:id', async (req, res) => {
  try {
    const job = await Job.findById(req.params.id);
    if (job) {
      res.json(job);
    } else {
      res.status(404).json({ message: 'Job not found' });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Gợi ý công việc dựa trên học vấn, kỹ năng, kinh nghiệm
router.get('/suggestions/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const jobs = await Job.find().lean();

    const prompt = `
Hồ sơ người dùng:
- Tên: ${user.name}
- Kỹ năng: ${user.skills.join(', ')}
- Kinh nghiệm: ${user.experience.map(exp => exp.position).join(', ')}
- Học vấn: ${user.education.map(edu => edu.degree).join(', ')}

Danh sách công việc:
${jobs.map((job, i) => `${i + 1}. ${job.title} tại ${job.company} - Kỹ năng: ${job.requiredSkills.join(', ')} - Bằng cấp: ${job.qualifications.join(', ')}`).join('\n')}

Câu hỏi: Hãy gợi ý các công việc phù hợp nhất với hồ sơ trên, và chỉ trả về số thứ tự công việc (ví dụ: 1, 3, 5).
`;
    const geminiResponse = await axios.post(
      `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [
          {
            parts: [
              { text: prompt }
            ]
          }
        ],
        generationConfig: {
          maxOutputTokens: 100,
          temperature: 0.7,
        },
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    // Kiểm tra phản hồi từ Gemini API
    if (geminiResponse.status !== 200) {
      return res.status(500).json({ message: `Gemini API failed with status ${geminiResponse.status}` });
    }

    // Lấy câu trả lời từ Gemini API
    const content = geminiResponse.data.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!content) {
      return res.status(500).json({ message: 'No valid response from Gemini API' });
    }

    const indexes = content.match(/\d+/g)?.map(i => parseInt(i, 10)) || [];

    const suggestedJobs = indexes.map(i => jobs[i - 1]).filter(Boolean);

    if (suggestedJobs.length === 0) {
      return res.status(200).json([]);
    }
    res.json(suggestedJobs);

  } catch (err) {
    console.error('Error in /suggestions:', err);
    res.status(500).json({ message: err.message });
  }
});

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage: storage });
// =================
router.post('/upload-cv', upload.single('cv'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const worker = await createWorker();
    const { data: { text } } = await worker.recognize(req.file.path);
    await worker.terminate();

    res.status(200).json({ text: text.trim() });
  } catch (err) {
    console.error('Error in /upload-cv:', err);
    res.status(500).json({ message: err.message });
  }
});

// Kiểm tra định dạng file (chỉ cho phép ảnh)
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Chỉ hỗ trợ upload file ảnh (JPEG, PNG, GIF).'), false);
  }
};

module.exports = router;