const express = require('express');
const router = express.Router();

const { getMyOrders } = require('../controllers/orderController');

router.get('/getMyOrders', getMyOrders);

module.exports = router;