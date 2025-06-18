import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:tms_app/data/models/payment/payment_gateway_request.dart';
import 'package:tms_app/data/models/payment/payment_gateway_response.dart';
import 'package:tms_app/data/services/payment_service.dart';
import 'package:tms_app/domain/repositories/payment_repository.dart';
import 'package:tms_app/data/models/payment/payment_resquest_modal_wallet.dart';
import 'package:flutter/foundation.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  // Assuming you have a PaymentService that handles the actual API calls

  final PaymentService paymentService;

  PaymentRepositoryImpl({required this.paymentService});

  @override
  Future<void> cancelPayment(String paymentId) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> createZaloPayOrder(
      Map<String, dynamic> amount) async {
    return paymentService.createPayment(amount);
  }

  @override
  Future<Map<String, dynamic>> createZaloPayOrderMobile(
      Map<String, dynamic> amount) async {
    return paymentService.createPaymentWalletMobile(amount);
  }

  @override
  Future<bool> verifyPayment(String paymentId) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getQueryPayment(String appTransId) async {
    return paymentService.getQueryPayment(appTransId);
  }

  @override
  Future<ApiResponseWrapper<PaymentResponseModel>> createPayment(
      PaymentRequestModel request) async {
    return paymentService.createPaymentV2(request);
  }

  @override
  Future<PaymentGatewayResponse> processPaymentGateway(
      PaymentGatewayRequest request) async {
    try {
      debugPrint(
          'Repository: Processing payment gateway for transaction ${request.transactionId}');
      final response = await paymentService.processPaymentGateway(request);

      if (response.isSuccess) {
        debugPrint('Repository: Payment gateway process successful');
      } else {
        debugPrint(
            'Repository: Payment gateway process failed: ${response.message}');
      }

      return response;
    } catch (e) {
      debugPrint('Repository: Error processing payment gateway: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentGatewayResponse> processPaymentGatewayMobile(
      PaymentRequestModelWallet request) async {
    try {
      debugPrint(
          'Repository: Processing payment gateway for transaction ${request.transactionId}');
      final response =
          await paymentService.processPaymentGatewayMobile(request);

      if (response.isSuccess) {
        debugPrint('Repository: Payment gateway process successful');
      } else {
        debugPrint(
            'Repository: Payment gateway process failed: ${response.message}');
      }

      return response;
    } catch (e) {
      debugPrint('Repository: Error processing payment gateway: $e');
      rethrow;
    }
  }
}
