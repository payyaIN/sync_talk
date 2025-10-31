import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sync_talk_mobile/core/utils/secure_token_store.dart';
import '../config/app_env.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileService {
  static Future<String?> uploadFile(
    String filePath,
    String conversationId,
  ) async {
    final dio = Dio();
    final token = await SecureTokenStore.read();

    final formData = FormData.fromMap({
      "conversationId": conversationId,
      "file": await MultipartFile.fromFile(filePath),
    });

    final response = await dio.post(
      "${AppEnv.apiBaseUrl}/messages/attachment",
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data["data"]["attachments"][0]["url"];
    }
    return null;
  }
}

class FileCache {
  /// Download a remote file to app cache and return the local path.
  static Future<String> downloadToCache(String url, {String? filename}) async {
    final dio = Dio();
    final dir = await getTemporaryDirectory();
    final name = filename ?? p.basename(Uri.parse(url).path);
    final savePath = p.join(dir.path, name);

    // Skip if already cached
    final f = File(savePath);
    if (await f.exists()) return savePath;

    await dio.download(url, savePath);
    return savePath;
  }
}
