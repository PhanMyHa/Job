require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const adminRoutes = require('./routes/admin');
const jobRoutes = require('./routes/jobs');
const applicationRoutes = require('./routes/applications');
const userRoutes = require('./routes/users');
const notificationRoutes = require('./routes/notifications');
const messageRoutes = require('./routes/messages');
const Message = require('./models/Message');const adminNotificationRoutes = require('./routes/admin-notification');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
  },
});

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
mongoose.set('strictQuery', true);

// MongoDB connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ MongoDB connected');
  server.listen(3000, () => {
    console.log('✅ Server running on port 3000');
  });
})
.catch((err) => {
  console.error('❌ MongoDB connection error:', err);
  process.exit(1);
});

// Routes
app.use('/api/admin', adminRoutes);
app.use('/api/jobs', jobRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/users', userRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/messages', messageRoutes);app.use('/api/admin-notifications', adminNotificationRoutes);


io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join', (userEmail) => {
    socket.join(userEmail);
  });

  // Gửi tin nhắn riêng 
  socket.on('message', async (data) => {
    const message = {
      sender: data.sender,
      receiver: data.receiver,
      content: data.content,
      timestamp: new Date(data.time),
    };
    await Message.create(message);
    io.to(data.receiver).emit('message', message);
    io.to(data.sender).emit('message', message);
  });

  // Gửi tin nhắn broadcast đến tất cả user
  socket.on('broadcast_message', async (data) => {
    const message = {
      sender: data.sender,
      receiver: 'ALL', 
      content: data.content,
      timestamp: new Date(data.time),
    };
    await Message.create(message);
    io.emit('receive_message', message);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});
