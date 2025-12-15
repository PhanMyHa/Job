const mongoose = require('mongoose');
const Notification = require('./Notification');
const User = require('./User');

const applicationSchema = new mongoose.Schema({
  jobId: { type: String, required: true },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true },
  country: { type: String, required: true },
  message: { type: String, required: true },
  cvPath: { type: String },
  status: { type: String, default: 'Pending' },
  createdAt: { type: Date, default: Date.now },
});

applicationSchema.post('save', async function (doc) {
  const user = await User.findOne({ email: doc.email });
  if (user && user.receiveNotifications) {
    await Notification.create({
      userEmail: doc.email,
      title: 'Application Submitted',
      message: `Your application for job ID ${doc.jobId} has been submitted.`,
    });
  }
});

module.exports = mongoose.model('Application', applicationSchema);