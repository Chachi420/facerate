import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';
import '../models/scan_result.dart';

class NoFaceException implements Exception {
  final String message;
  const NoFaceException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<ScanResult> analyzeFace(File imageFile, String userId, String mood, [String mode = 'honest']) async {
    final compressed = await _compressImage(imageFile);
    return _retryRequest(() => _doAnalyzeFace(compressed, userId, mood, mode));
  }

  Future<ScanResult> _doAnalyzeFace(File imageFile, String userId, String mood, String mode) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: 'face.jpg'),
      'user_id': userId,
      'mood': mood,
      'mode': mode,
    });

    final response = await _dio.post('/api/scan', data: formData);

    if (response.statusCode == 200) {
      return ScanResult.fromJson(response.data as Map<String, dynamic>);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      message: 'Unexpected status: ${response.statusCode}',
    );
  }

  Future<T> _retryRequest<T>(Future<T> Function() request) async {
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        return await request();
      } on DioException catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          throw _humanizeError(e);
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    throw Exception('Request failed after $maxAttempts attempts.');
  }

  Exception _humanizeError(DioException e) {
    debugPrint('=== DIO ERROR ===');
    debugPrint('Type: ${e.type}');
    debugPrint('Message: ${e.message}');
    debugPrint('Error: ${e.error}');
    debugPrint('Status: ${e.response?.statusCode}');
    debugPrint('Response: ${e.response?.data}');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('The analysis is taking too long. Please try again.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection. Please check your network and try again.');
    }
    final status = e.response?.statusCode;
    if (status == 429) {
      return Exception('Too many scans. Please wait a moment and try again.');
    }
    if (status == 400) {
      final data = e.response?.data;
      if (data is Map) {
        final detail = data['detail'];
        if (detail is Map && detail['error_type'] == 'no_face') {
          final msg = detail['message'] as String? ?? 'That\'s not a face! Please use a clear selfie.';
          return NoFaceException(msg);
        }
        if (detail is String) return Exception(detail);
      }
      return Exception('Invalid image. Please use a clear selfie.');
    }
    if (status != null && status >= 500) {
      return Exception('Our servers are busy. Please try again in a moment.');
    }
    return Exception('Something went wrong. Please try again.');
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return file;

    if (image.width > 800) {
      image = img.copyResize(image, width: 800);
    }

    final compressed = img.encodeJpg(image, quality: 80);
    if (compressed.length >= bytes.length) return file;

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressed);
    return tempFile;
  }
}
