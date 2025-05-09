const express = require('express');
const router = express.Router();
const User = require('../models/User');

router.get('/balance/:userId', async (req, res) => {
  const user = await User.findOne({ userId: req.params.userId });
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json({ balance: user.balance });
});

router.get('/history/:userId', async (req, res) => {
  const user = await User.findOne({ userId: req.params.userId });
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.json({ history: user.transactions });
});

router.post('/load', async (req, res) => {
  const { userId, amount } = req.body;
  let user = await User.findOne({ userId });

  if (!user) {
    user = new User({ userId, balance: amount });
  } else {
    user.balance += amount;
    user.transactions.push({ amount, type: 'load' });
  }

  await user.save();
  res.json({ success: true, newBalance: user.balance });
});

module.exports = router;