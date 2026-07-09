import mongoose from 'mongoose';
import { User } from './src/modules/users/user.model';
import { config } from './src/config/env';
import bcrypt from 'bcryptjs';

async function createAdmin() {
  try {
    await mongoose.connect(config.mongoUri);
    console.log('Connected to MongoDB');
    
    const adminEmail = 'admin@synctalk.com';
    let admin = await User.findOne({ email: adminEmail });
    if (!admin) {
      const passwordHash = await bcrypt.hash('admin123', 10);
      admin = new User({
        email: adminEmail,
        passwordHash,
        displayName: 'System Admin',
        role: 'admin',
      });
      await admin.save();
      console.log(`Created admin user: ${adminEmail} with password: admin123`);
    } else {
      admin.role = 'admin';
      await admin.save();
      console.log(`Admin user already exists: ${adminEmail}`);
    }
  } catch (error) {
    console.error('Error connecting to MongoDB', error);
  } finally {
    await mongoose.disconnect();
  }
}

createAdmin();
