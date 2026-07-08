declare module 'multer-storage-cloudinary' {
  import { StorageEngine } from 'multer';
  import { Cloudinary } from 'cloudinary';
  
  interface CloudinaryStorageOptions {
    cloudinary: any;
    params?: any;
  }
  
  export class CloudinaryStorage implements StorageEngine {
    constructor(options: CloudinaryStorageOptions);
    _handleFile(req: any, file: any, cb: any): void;
    _removeFile(req: any, file: any, cb: any): void;
  }
}
