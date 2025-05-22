import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:get_it/get_it.dart';

class PaymentService {
  final String baseUrl = Constants.BASE_URL;
  final Dio dio;

  PaymentService([Dio? dioInstance])
      : dio = dioInstance ?? GetIt.instance<Dio>();

  Future<ApiResponseWrapper<PaymentResponseModel>> createPaymentV2(
      PaymentRequestModel request) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final url = '$baseUrl/api/payments/v2';
    final response = await dio.post(
      url,
      data: request.toJson(),
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponseWrapper.fromJson(
        response.data,
        (data) => PaymentResponseModel.fromJson(data),
      );
    } else {
      throw Exception('Failed to create payment: ${response.data}');
    }
  }

  Future<Map<String, dynamic>> createPayment(
      Map<String, dynamic> paymentData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token not found. Please login again.");
    }

    final url = '$baseUrl/api/payment/create-order';
    final response = await dio.post(
      url,
      data: jsonEncode(paymentData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to create payment: ${response.data}');
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token not found. Please login again.");
    }

    final url = '$baseUrl/api/payment/$paymentId/status';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to get payment status: ${response.data}');
    }
  }

  Future<Map<String, dynamic>> getQueryPayment(String appTransId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null || token.isEmpty) {
      throw Exception("JWT token not found. Please login again.");
    }

    final url = '$baseUrl/api/payment/query?appTransId=$appTransId';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to get payment status: ${response.data}');
    }
  }
}
