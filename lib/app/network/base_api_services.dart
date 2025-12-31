import 'dart:io';

/// Abstract class for defining base API services.
abstract class BaseApiServices {
  Future<Map<String, dynamic>> get({required String url});
  Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>> put({
    required String url,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>> patch({
    required String url,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>> delete({
    required String url,
    Map<String, dynamic>? data,
  });
  Future<Map<String, dynamic>> multipartUpload({
    required String url,
    required List<File> files,
    String requestType = 'POST',
    String felid = 'image',
  });
}
