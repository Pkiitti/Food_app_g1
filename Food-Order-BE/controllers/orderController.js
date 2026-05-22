const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Order = require('../models/Order');

exports.getMyOrders = async (req, res) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({
      statusCode: 401,
      message: 'Token không tồn tại',
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const userId = decoded.userId;

    const userExists = await User.findById(userId);
    if (!userExists) {
      return res.status(400).json({
        statusCode: 400,
        message: 'Người dùng không tồn tại',
      });
    }

    const orders = await Order.find({ user: userId }).sort({ createdAt: -1 });

    return res.status(200).json({
      status: true,
      orders,
    });
  } catch (err) {
    console.error(err.message);

    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return res.status(401).json({
        statusCode: 401,
        message: 'Token không hợp lệ hoặc đã hết hạn',
      });
    }

    return res.status(500).json({
      statusCode: 500,
      message: 'Lỗi máy chủ',
    });
  }
};