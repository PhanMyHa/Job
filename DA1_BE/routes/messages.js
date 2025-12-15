const express = require('express');
const router = express.Router();
const Message = require('../models/Message');

router.get('/:user', async (req, res) => {
  const messages = await Message.find({
    $or: [
      { sender: req.params.user },
      { receiver: req.params.user },
    ],
  }).sort({ timestamp: 1 });
  res.json(messages);
});

module.exports = router;