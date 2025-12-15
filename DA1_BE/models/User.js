const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  password: { type: String, required: true },
  receiveNotifications: { type: Boolean, default: true },
  education: [{
    degree: { type: String, required: true },
    school: { type: String, required: true },
    startYear: { type: Number, required: true },
    endYear: { type: Number },
  }],
  skills: [{ type: String }],
  experience: [{
    position: { type: String, required: true },
    company: { type: String, required: true },
    startDate: { type: Date, required: true },
    endDate: { type: Date },
    description: { type: String },
  }],
  avatar: { type: String },
});

// // Hash password before saving
// userSchema.pre('save', async function (next) {
//   if (this.isModified('password')) {
//     this.password = await bcrypt.hash(this.password, 10);
//   }
//   next();
// });

// // Method to compare passwords
// userSchema.methods.comparePassword = async function (candidatePassword) {
//   return await bcrypt.compare(candidatePassword, this.password);
// };

module.exports = mongoose.model('User', userSchema);