const dotenv = require('dotenv');
const connectDB = require('./config/db');

const Category = require('./models/Category');
const Food = require('./models/Food');
const Favorite = require('./models/Favorite');
const Basket = require('./models/Basket');

// Neu ban da tao model Order va muon xoa ca lich su don hang cu,
// bo comment 2 dong lien quan den Order ben duoi.
// const Order = require('./models/Order');

dotenv.config();

const seedData = async () => {
  try {
    await connectDB();

    console.log('Cleaning old seed data...');

    await Favorite.deleteMany({});
    await Basket.deleteMany({});
    await Food.deleteMany({});
    await Category.deleteMany({});

    // Neu muon reset luon lich su don hang cu, bo comment dong nay:
    // await Order.deleteMany({});

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
        title: 'Do uong',
        image: 'https://cdn-icons-png.flaticon.com/512/924/924514.png',
      },
      {
        title: 'Ga ran',
        image: 'https://cdn-icons-png.flaticon.com/512/1046/1046751.png',
      },
      {
        title: 'Com',
        image: 'https://cdn-icons-png.flaticon.com/512/3174/3174880.png',
      },
      {
        title: 'Mi va Pasta',
        image: 'https://cdn-icons-png.flaticon.com/512/3480/3480618.png',
      },
    ]);

    const burger = categories.find((c) => c.title === 'Burger');
    const pizza = categories.find((c) => c.title === 'Pizza');
    const drink = categories.find((c) => c.title === 'Do uong');
    const chicken = categories.find((c) => c.title === 'Ga ran');
    const rice = categories.find((c) => c.title === 'Com');
    const noodle = categories.find((c) => c.title === 'Mi va Pasta');

    await Food.insertMany([
      // =========================
      // Burger
      // =========================
      {
        title: 'Burger Bo Pho Mai',
        description:
          'Burger bo mem thom ket hop voi lop pho mai beo nhe, rau tuoi gion va sot dac biet. Mon nay phu hop cho bua trua nhanh gon nhung van du nang luong, vi beo man vua phai va de an voi hau het khau vi.',
        price: 45,
        image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
        category: burger._id,
      },
      {
        title: 'Burger Ga Gion',
        description:
          'Phan ga chien gion ben ngoai, mem va mong nuoc ben trong, ket hop cung rau xa lach, ca chua va lop sot nhe. Day la lua chon hop ly neu ban thich mon an gion, de an va khong qua nang bung.',
        price: 39,
        image: 'https://images.unsplash.com/photo-1571091718767-18b5b1457add',
        category: burger._id,
      },
      {
        title: 'Burger Bo Hai Lop',
        description:
          'Burger danh cho nguoi muon an no hon voi hai lop thit bo day, pho mai tan chay va sot dam vi. Huong vi man ngot can bang, phu hop khi ban can mot bua an chinh that chac bung.',
        price: 59,
        image: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
        category: burger._id,
      },
      {
        title: 'Burger Trung Sot Tieu',
        description:
          'Su ket hop giua thit bo, trung op la va sot tieu thom nong tao cam giac moi la hon so voi burger truyen thong. Mon nay co vi beo cua trung, mui thom cua tieu va do mem cua banh rat hai hoa.',
        price: 49,
        image: 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5',
        category: burger._id,
      },

      // =========================
      // Pizza
      // =========================
      {
        title: 'Pizza Xuc Xich Pho Mai',
        description:
          'Pizza de mong gion nhe, phu xuc xich cat lat, pho mai keo soi va sot ca chua dam vi. Mon nay de chia se voi ban be, co vi beo vua phai va mui thom dac trung cua pizza moi nuong.',
        price: 89,
        image: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
        category: pizza._id,
      },
      {
        title: 'Pizza Hai San',
        description:
          'Pizza hai san ket hop tom, muc, pho mai va sot ca chua thanh nhe. Huong vi tuoi, khong qua ngay, phu hop voi nguoi thich hai san nhung van muon mot mon an nhanh tien loi.',
        price: 99,
        image: 'https://images.unsplash.com/photo-1594007654729-407eedc4be65',
        category: pizza._id,
      },
      {
        title: 'Pizza Pho Mai Dac Biet',
        description:
          'Pizza danh cho tin do pho mai voi lop cheese day, beo thom va tan chay khi con nong. Vi mon nay don gian nhung hap dan, dac biet phu hop khi an kem nuoc ngot hoac tra trai cay.',
        price: 79,
        image: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3',
        category: pizza._id,
      },
      {
        title: 'Pizza Ga Nam',
        description:
          'Pizza ga nam co phan topping ga xe mem, nam thom va pho mai phu deu tren mat banh. Huong vi am, be tong nhe, thich hop cho nguoi muon mot mon pizza vua no vua khong qua cay.',
        price: 92,
        image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
        category: pizza._id,
      },

      // =========================
      // Do uong
      // =========================
      {
        title: 'Coca Cola Mat Lanh',
        description:
          'Coca Cola uong lanh giup can bang vi beo cua burger, ga ran va pizza. Do ngot va gas vua du tao cam giac san khoai, rat phu hop khi dung kem cac mon chien nuong.',
        price: 15,
        image: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97',
        category: drink._id,
      },
      {
        title: 'Nuoc Cam Tuoi',
        description:
          'Nuoc cam tuoi co vi chua ngot tu nhien, giup bua an tro nen nhe hon va bot ngay. Day la lua chon tot neu ban muon mot do uong co cam giac tuoi mat thay vi nuoc ngot co gas.',
        price: 25,
        image: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba',
        category: drink._id,
      },
      {
        title: 'Tra Sua Tran Chau',
        description:
          'Tra sua vi diu, co do beo nhe va tran chau dai mem. Mon nay phu hop cho buoi chieu hoac khi ban muon them mot mon ngot de ket thuc bua an theo cach de chiu hon.',
        price: 35,
        image: 'https://images.unsplash.com/photo-1558857563-b371033873b8',
        category: drink._id,
      },
      {
        title: 'Tra Dao Cam Sa',
        description:
          'Tra dao cam sa co mui thom tuoi, vi chua ngot thanh va hau vi nhe. Do uong nay hop voi nguoi khong thich qua beo, dac biet ngon khi dung lanh cung cac mon chien.',
        price: 32,
        image: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc',
        category: drink._id,
      },

      // =========================
      // Ga ran
      // =========================
      {
        title: 'Ga Ran Gion Cay',
        description:
          'Ga ran lop vo gion, ben trong mem va giu duoc do ngot tu nhien cua thit. Vi cay nhe giup mon an day mui hon ma khong qua gat, phu hop cho nguoi thich mon chien nong hoi.',
        price: 49,
        image: 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58',
        category: chicken._id,
      },
      {
        title: 'Canh Ga Sot Cay',
        description:
          'Canh ga chien vang sau do phu lop sot cay ngot, tao cam giac dam da va rat bat mieng. Mon nay phu hop de an vat, an chung voi ban be hoac dung kem nuoc ngot lanh.',
        price: 55,
        image: 'https://images.unsplash.com/photo-1527477396000-e27163b481c2',
        category: chicken._id,
      },
      {
        title: 'Ga Vien Chien Gion',
        description:
          'Ga vien nho gon, lop ngoai gion va phan nhan mem, de cham sot va phu hop cho ca tre em lan nguoi lon. Mon nay tien loi neu ban muon an nhe nhung van co vi thom cua ga chien.',
        price: 39,
        image: 'https://images.unsplash.com/photo-1562967916-eb82221dfb36',
        category: chicken._id,
      },
      {
        title: 'Combo Ga Ran Khoai Tay',
        description:
          'Combo gom ga ran gion va khoai tay chien, tao thanh mot phan an day du hon cho bua nhanh. Ga co vi dam, khoai tay beo bui, khi an kem sot se cho cam giac rat tron vi.',
        price: 69,
        image: 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb',
        category: chicken._id,
      },

      // =========================
      // Com
      // =========================
      {
        title: 'Com Ga Sot Dac Biet',
        description:
          'Com ga voi phan ga mem, sot dam vi va com nong deo vua phai. Mon nay phu hop cho bua trua hoac bua toi khi ban can mot phan an chac bung, de an va khong qua nhieu dau mo.',
        price: 45,
        image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b',
        category: rice._id,
      },
      {
        title: 'Com Bo Xao Hanh Tay',
        description:
          'Thit bo xao nhanh voi hanh tay giu duoc do mem va mui thom dac trung. Phan com nong ket hop cung nuoc sot man nhe tao cam giac vua mieng, phu hop voi nguoi thich mon com dam vi.',
        price: 55,
        image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
        category: rice._id,
      },
      {
        title: 'Com Chien Trung Rau Cu',
        description:
          'Com chien hat toi, ket hop trung, rau cu va gia vi nhe tao nen mon an quen thuoc nhung de an. Day la lua chon hop ly neu ban muon mot phan com nhanh, gon va it ngot hon cac mon sot.',
        price: 40,
        image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b',
        category: rice._id,
      },
      {
        title: 'Com Suon Nuong',
        description:
          'Suon duoc uop dam vi, nuong den khi ben ngoai hoi xem vang va ben trong van mem. An kem com nong va chut rau giup mon nay tro thanh lua chon rat phu hop cho mot bua chinh no lau.',
        price: 62,
        image: 'https://images.unsplash.com/photo-1544025162-d76694265947',
        category: rice._id,
      },

      // =========================
      // Mi va Pasta
      // =========================
      {
        title: 'Mi Y Sot Bo Bam',
        description:
          'Mi Y sot bo bam co vi ca chua chua nhe, thit bo bam dam da va soi mi mem vua. Mon nay hop voi nguoi muon doi vi khoi cac mon com, vua de an vua co cam giac sang hon mot bua nhanh thong thuong.',
        price: 58,
        image: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9',
        category: noodle._id,
      },
      {
        title: 'Mi Ga Sot Kem',
        description:
          'Mi ga sot kem co vi beo diu, thit ga mem va mui thom nhe cua sot. Mon nay khong qua cay, rat hop khi ban muon mot bua an am, mem va co hau vi beo nhe.',
        price: 54,
        image: 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a',
        category: noodle._id,
      },
      {
        title: 'Mi Xao Hai San',
        description:
          'Mi xao hai san co tom, muc va rau cu, duoc xao nhanh de giu do thom va do gion nhe. Vi mon nay kha dam da, phu hop cho nguoi thich hai san va muon mot phan an no nhung khong qua kho.',
        price: 65,
        image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
        category: noodle._id,
      },
    ]);

    console.log('Seed completed successfully.');
    console.log('Inserted categories:', categories.length);
    console.log('Inserted foods: 23');
    process.exit(0);
  } catch (error) {
    console.error('Seed failed:', error.message);
    process.exit(1);
  }
};

seedData();