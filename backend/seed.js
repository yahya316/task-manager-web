const dotenv = require('dotenv');
dotenv.config();

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
const connectDB = require('./config/db');

const seedManager = async () => {
  try {
    await connectDB();

    const existingManager = await User.findOne({ role: 'manager' });
    if (existingManager) {
      console.log('Manager account already exists:');
      console.log(`  Email: ${existingManager.email}`);
      console.log(`  Name: ${existingManager.name}`);
      process.exit(0);
    }

    const manager = await User.create({
      name: 'Admin Manager',
      email: 'manager@taskmanager.com',
      password: 'manager123',
      role: 'manager',
      isActive: true,
    });

    console.log('✅ Manager account created successfully!');
    console.log(`  Name: ${manager.name}`);
    console.log(`  Email: ${manager.email}`);
    console.log(`  Password: manager123`);
    console.log(`  Role: ${manager.role}`);
    console.log('\n⚠️  Please change the default password after first login!');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error.message);
    process.exit(1);
  }
};

seedManager();
