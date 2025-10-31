import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import cloudinary from "../config/cloudinary";

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "synctalk",
    resource_type: "auto"
  }
});

export const upload = multer({ storage });
