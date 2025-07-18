import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:tms_app/data/models/payment/payment_gateway_request.dart';
import 'package:tms_app/data/models/payment/payment_gateway_response.dart';
import 'package:tms_app/data/models/payment/payment_resquest_modal_wallet.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final String baseUrl = Constants.BASE_URL;
  final Dio dio;

  PaymentService([Dio? dioInstance])
      : dio = dioInstance ?? GetIt.instance<Dio>();

  /// Process a successful payment from ZaloPay and deposit into wallet
  /// 
  /// [request] The payment gateway request with transaction details
  Future<PaymentGatewayResponse> processPaymentGateway(
      PaymentGatewayRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null || token.isEmpty) {
        throw Exception("JWT token không tìm thấy. Vui lòng đăng nhập lại.");
      }
      
      debugPrint(
          'Processing payment gateway transaction: ${request.transactionId}');
      
      final url = '$baseUrl/api/payments/v2/payment-gateway';
      
      final response = await dio.post(
        url,
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      debugPrint('Payment gateway response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentGatewayResponse.fromJson(response.data);
      } else {
        throw Exception('Xử lý thanh toán thất bại: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error processing payment gateway: $e');
      throw Exception('Xử lý thanh toán thất bại: $e');
    }
  }

  Future<PaymentGatewayResponse> processPaymentGatewayMobile(
      PaymentRequestModelWallet request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      
      if (token == null || token.isEmpty) {
        throw Exception("JWT token không tìm thấy. Vui lòng đăng nhập lại.");
      }
      
      debugPrint(
          'Processing payment gateway transaction: ${request.transactionId}');
      
      final url = '$baseUrl/api/payments/v2/payment-gateway';
      
      final response = await dio.post(
        url,
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      debugPrint('Payment gateway response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentGatewayResponse.fromJson(response.data);
      } else {
        throw Exception('Xử lý thanh toán thất bại: ${response.data}');
      }
    } catch (e) {
      debugPrint('Error processing payment gateway: $e');
      throw Exception('Xử lý thanh toán thất bại: $e');
    }
  }

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

  Future<Map<String, dynamic>> createPaymentWalletMobile(
      Map<String, dynamic> paymentData) async {
    debugPrint('=== createPaymentWalletMobile START ===');
    debugPrint('Payment data: ${jsonEncode(paymentData)}');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    debugPrint('JWT token available: ${token != null && token.isNotEmpty}');

    if (token == null || token.isEmpty) {
      debugPrint('JWT token not found');
      throw Exception("JWT token not found. Please login again.");
    }

    final url = '$baseUrl/api/payment/create-order-mobile-to-up';
    debugPrint('Request URL: $url');

    try {
      debugPrint('Sending POST request to server...');
    final response = await dio.post(
      url,
      data: jsonEncode(paymentData),
    );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response data: ${jsonEncode(response.data)}');

    if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('=== createPaymentWalletMobile SUCCESS ===');
      return response.data;
    } else {
        debugPrint('Request failed with status: ${response.statusCode}');
        debugPrint('=== createPaymentWalletMobile FAILED ===');
      throw Exception('Failed to create payment: ${response.data}');
      }
    } catch (e) {
      debugPrint('Exception occurred: $e');
      debugPrint('=== createPaymentWalletMobile ERROR ===');
      rethrow;
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
