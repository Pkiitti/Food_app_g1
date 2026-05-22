const express = require('express');
const router = express.Router();
const { createFood, getAllFoods, getFoodsByCategory } = require('../controllers/foodController');
// Route để tạo một food mới
router.post('/createFood', createFood);

router.get('/getAllFoods', getAllFoods);

router.get('/getFoodsByCategory/:categoryId', getFoodsByCategory);

module.exports = router;