import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import cloudinary from "../config/cloudinary";

// const storage = new CloudinaryStorage({
//   cloudinary,
//   params: {
//     folder: "synctalk",
//     resource_type: "auto"
//   }
// });
const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req: any, file: any) => {
    return {
      folder: "synctalk",
      resource_type: "auto" as const,
      public_id: `${Date.now()}-${file.originalname}`,
    };
  },
});

export const upload = multer({ storage });
