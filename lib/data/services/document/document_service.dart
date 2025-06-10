import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:tms_app/core/utils/api_response_helper.dart';
import 'package:tms_app/data/models/document/document_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/core/utils/shared_prefs.dart';

class DocumentService {
  final String apiUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  DocumentService(this.dio);

  Future<List<DocumentModel>> getAllDocuments() async {
    try {
      return await getPopularDocuments();
    } catch (e) {
      return [];
    }
  }

  Future<List<DocumentModel>> getPopularDocuments() async {
    try {
      final endpoint = '$apiUrl/general_documents/public?type=popular';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, DocumentModel.fromJson);
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<DocumentModel>> getNewDocuments() async {
    try {
      final endpoint = '$apiUrl/general_documents/public?type=new';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, DocumentModel.fromJson);
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<DocumentModel>> getDocumentsByCategory(int categoryId) async {
    try {
      final endpoint =
          '$apiUrl/general_documents/public?categoryId=$categoryId';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, DocumentModel.fromJson);
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<DocumentModel>> getRelatedDocuments(int categoryId) async {
    try {
      final endpoint = '$apiUrl/general_documents/public?categoryId=$categoryId';
      
      try {
        final response = await dio.get(
          endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {'Accept': 'application/json'},
          )
        );
        
        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
            response.data, DocumentModel.fromJson);
        } else {
          print('Lỗi khi lấy tài liệu liên quan: ${response.statusCode}');
          return [];
        }
      } on DioException catch (e) {
        print('DioException khi lấy tài liệu liên quan: ${e.message}');
        return [];
      }
    } catch (e) {
      print('Exception khi lấy tài liệu liên quan: $e');
      return [];
    }
  }

  Future<List<DocumentModel>> searchDocuments(String keyword) async {
    try {
      final endpoint = '$apiUrl/general_documents/public?keyword=$keyword';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          return ApiResponseHelper.processList(
              response.data, DocumentModel.fromJson);
        } else {
          return [];
        }
      } on DioException catch (e) {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<DocumentModel?> getDocumentDetail(int id) async {
    try {
      final endpoint = '$apiUrl/general_documents/$id';

      try {
        final response = await dio.get(endpoint,
            options: Options(
              validateStatus: (status) => true,
              headers: {'Accept': 'application/json'},
            ));

        if (response.statusCode == 200) {
          final responseData = response.data;

          Map<String, dynamic> documentData;

          if (responseData != null && responseData['data'] != null) {
            // Nếu API trả về cấu trúc {status, message, data}
            documentData = responseData['data'];
          } else if (responseData != null &&
              responseData is Map<String, dynamic>) {
            // Nếu API trả về đối tượng trực tiếp
            documentData = responseData;
          } else {
            return null;
          }

          return DocumentModel.fromJson(documentData);
        } else {
          return null;
        }
      } on DioException catch (e) {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<bool> incrementDownload(int documentId) async {
    try {
      final token = await _getToken();
      final endpoint = '$apiUrl/general_documents/$documentId/download';

      try {
        final response = await dio.post(
          endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        return response.statusCode == 200;
      } on DioException catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> incrementView(int documentId) async {
    try {
      final endpoint = '$apiUrl/general_documents/$documentId/increment-view';

      try {
        final response = await dio.put(
          endpoint,
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Accept': 'application/json',
            },
          ),
        );

        return response.statusCode == 200;
      } on DioException catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt') ?? '';
  }
  
  Future<bool> trackDocumentDownload(int documentId) async {
    try {
      final token = await _getToken();
      final endpoint = '$apiUrl/document-account/download';

      // Lấy accountId từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(SharedPrefs.KEY_USER_ID);
      
      // Chuyển userId từ string sang int
      final accountId = int.tryParse(userId ?? '');
      
      if (accountId == null) {
        print('Không tìm thấy accountId, không thể ghi nhận tải xuống');
        return false;
      }
      
      // Tạo ngày giờ hiện tại theo định dạng ISO
      final now = DateTime.now().toIso8601String();

      try {
        final response = await dio.post(
          endpoint,
          data: {
            'accountId': accountId,
            'generalDocumentId': documentId,
            'dateDownload': now
          },
          options: Options(
            validateStatus: (status) => true,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Đã ghi nhận tải xuống tài liệu thành công: $documentId');
          return true;
        } else {
          print('Lỗi khi ghi nhận tải xuống: ${response.statusCode}, ${response.data}');
          return false;
        }
      } on DioException catch (e) {
        print('DioException khi ghi nhận tải tài liệu: ${e.message}');
        return false;
      }
    } catch (e) {
      print('Exception khi ghi nhận tải tài liệu: $e');
      return false;
    }
  }
}
