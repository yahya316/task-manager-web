const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();

const testConn = async () => {
    try {
        console.log('Connecting to:', process.env.MONGO_URI);
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✅ Connected!');
        const User = mongoose.model('User', new mongoose.Schema({ email: String }));
        const users = await User.find({});
        console.log('Users found:', users.length);
        users.forEach(u => console.log(' - ' + u.email));
        process.exit(0);
    } catch (err) {
        console.error('❌ Failed:', err.message);
        process.exit(1);
    }
};

testConn();
