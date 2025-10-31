
import 'dotenv/config';
export const config = {
  port: Number(process.env.PORT || 4000),
  mongoUri: process.env.MONGO_URI || 'mongodb+srv://akshaypayya:payyadb@cluster0.ikwtotj.mongodb.net/?appName=Cluster0',
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || '52da45b3a7e4e1b60eda0958ac6c7e7faf9c5b638834eac07021c55499728b158345f250d1ed08b71623940fad080756037502850a17c08f684e601f83ef95b5',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'dev_refresh_secret_change_me',
    accessExpiresIn: process.env.ACCESS_EXPIRES_IN || '900s',
    refreshExpiresIn: process.env.REFRESH_EXPIRES_IN || '2592000s',
  },
  googleClientId: process.env.GOOGLE_CLIENT_ID,
  uploadDir: process.env.UPLOAD_DIR || 'uploads',
  openAiKey: process.env.OPENAI_API_KEY
};
