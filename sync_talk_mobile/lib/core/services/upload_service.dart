import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sync_talk_mobile/core/services/api.dart' as ApiClient;

class UploadService {
  static Future<String?> uploadFile(String filePath, String roomId) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
      "roomId": roomId,
    });

    final res = await ApiClient.dio.post("/upload/file", data: formData);
    return res.data["url"];
  }
}
