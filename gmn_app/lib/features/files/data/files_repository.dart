import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'models/file_model.dart';

class FilesRepository {
  final ApiClient _apiClient;

  FilesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<FileModel>> getFiles({FilesFilter? filter}) async {
    final response = await _apiClient.get(
      ApiConstants.files,
      queryParameters: filter?.toQueryParameters(),
    );

    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['data'] ?? []);
    return data.map((json) => FileModel.fromJson(json)).toList();
  }

  Future<FileModel> uploadFile({
    required File file,
    String? workOrderId,
    void Function(int, int)? onProgress,
  }) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      if (workOrderId != null) 'workOrderId': workOrderId,
    });

    final response = await _apiClient.uploadFile(
      ApiConstants.files,
      data: formData,
      onSendProgress: onProgress,
    );

    return FileModel.fromJson(response.data);
  }

  Future<FileModel> updateFile(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '${ApiConstants.files}/$id',
      data: data,
    );
    return FileModel.fromJson(response.data);
  }

  Future<void> deleteFile(String id) async {
    await _apiClient.delete('${ApiConstants.files}/$id');
  }

  String getFileUrl(String path) {
    // Remove /api from baseUrl and add /uploads
    final baseUrl = _apiClient.baseUrl.replaceAll('/api', '');
    return '$baseUrl$path';
  }
}
