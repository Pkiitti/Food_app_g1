const dotenv = require('dotenv');
const connectDB = require('./config/db');

const Category = require('./models/Category');
const Food = require('./models/Food');
const Favorite = require('./models/Favorite');
const Basket = require('./models/Basket');

dotenv.config();

const seedData = async () => {
  try {
    await connectDB();

    console.log('Cleaning old seed data...');

    await Favorite.deleteMany({});
    await Basket.deleteMany({});
    await Food.deleteMany({});
    await Category.deleteMany({});

    console.log('Old categories, foods, favorites, baskets removed.');

    const categories = await Category.insertMany([
      {
        title: 'Burger',
        image: 'https://cdn-icons-png.flaticon.com/512/3075/3075977.png',
      },
      {
        title: 'Pizza',
        image: 'https://cdn-icons-png.flaticon.com/512/1404/1404945.png',
      },
      {
        title: 'Drink',
        image: 'https://cdn-icons-png.flaticon.com/512/924/924514.png',
      },
      {
        title: 'Chicken',
        image: 'https://cdn-icons-png.flaticon.com/512/1046/1046751.png',
      },
      {
        title: 'Rice',
        image: 'https://cdn-icons-png.flaticon.com/512/3174/3174880.png',
      },
    ]);

    const burger = categories.find((c) => c.title === 'Burger');
    const pizza = categories.find((c) => c.title === 'Pizza');
    const drink = categories.find((c) => c.title === 'Drink');
    const chicken = categories.find((c) => c.title === 'Chicken');
    const rice = categories.find((c) => c.title === 'Rice');

    await Food.insertMany([
      {
        title: 'Cheese Burger',
        description: 'Beef burger with cheese and special sauce',
        price: 45000,
        image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
        category: burger._id,
      },
      {
        title: 'Chicken Burger',
        description: 'Crispy chicken burger with fresh vegetables',
        price: 39000,
        image: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add',
        category: burger._id,
      },
      {
        title: 'Double Beef Burger',
        description: 'Double beef burger with cheese and sauce',
        price: 59000,
        image: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
        category: burger._id,
      },
      {
        title: 'Pepperoni Pizza',
        description: 'Classic pepperoni pizza with melted cheese',
        price: 89000,
        image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
        category: pizza._id,
      },
      {
        title: 'Seafood Pizza',
        description: 'Seafood pizza with cheese and tomato sauce',
        price: 99000,
        image: 'https://images.unsplash.com/photo-1594007654729-407eedc4be65',
        category: pizza._id,
      },
      {
        title: 'Cheese Pizza',
        description: 'Cheese pizza with crispy crust',
        price: 79000,
        image: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3',
        category: pizza._id,
      },
      {
        title: 'Coca Cola',
        description: 'Cold Coca Cola drink',
        price: 15000,
        image: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97',
        category: drink._id,
      },
      {
        title: 'Orange Juice',
        description: 'Fresh orange juice',
        price: 25000,
        image: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba',
        category: drink._id,
      },
      {
        title: 'Milk Tea',
        description: 'Milk tea with black pearl',
        price: 35000,
        image: 'https://images.unsplash.com/photo-1558857563-b371033873b8',
        category: drink._id,
      },
      {
        title: 'Fried Chicken',
        description: 'Crispy fried chicken',
        price: 49000,
        image: 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58',
        category: chicken._id,
      },
      {
        title: 'Chicken Wings',
        description: 'Fried chicken wings with spicy sauce',
        price: 55000,
        image: 'https://images.unsplash.com/photo-1527477396000-e27163b481c2',
        category: chicken._id,
      },
      {
        title: 'Chicken Nuggets',
        description: 'Crispy chicken nuggets',
        price: 39000,
        image: 'https://images.unsplash.com/photo-1562967916-eb82221dfb36',
        category: chicken._id,
      },
      {
        title: 'Chicken Rice',
        description: 'Rice with chicken and special sauce',
        price: 45000,
        image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b',
        category: rice._id,
      },
      {
        title: 'Beef Rice',
        description: 'Rice with beef and onion',
        price: 55000,
        image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        category: rice._id,
      },
      {
        title: 'Fried Rice',
        description: 'Fried rice with egg and vegetables',
        price: 40000,
        image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b',
        category: rice._id,
      },
    ]);

    console.log('Seed completed successfully.');
    process.exit(0);
  } catch (error) {
    console.error('Seed failed:', error.message);
    process.exit(1);
  }
};

seedData();