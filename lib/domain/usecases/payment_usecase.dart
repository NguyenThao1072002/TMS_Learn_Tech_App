import '../repositories/payment_repository.dart';
import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:tms_app/data/models/payment/payment_gateway_request.dart';
import 'package:tms_app/data/models/payment/payment_gateway_response.dart';
import 'package:flutter/foundation.dart';

class PaymentUseCase {
  final PaymentRepository paymentRepository;

  PaymentUseCase(this.paymentRepository);

  Future<Map<String, dynamic>> createOrderUseCase(Map<String, dynamic> amount) {
    return paymentRepository.createZaloPayOrder(amount);
  }

  Future<Map<String, dynamic>> getQueryPaymentUseCase(String appTransId) {
    return paymentRepository.getQueryPayment(appTransId);
  }

  Future<ApiResponseWrapper<PaymentResponseModel>> savePayment(
      PaymentRequestModel request) {
    return paymentRepository.createPayment(request);
  }
  
  /// Process a successful payment from ZaloPay and deposit into wallet
  /// 
  /// [request] The payment gateway request with all transaction details
  Future<PaymentGatewayResponse> processPaymentGateway(PaymentGatewayRequest request) async {
    try {
      // Validate input
      if (request.accountId <= 0) {
        throw Exception('ID tài khoản không hợp lệ');
      }
      
      if (request.transactionId.isEmpty) {
        throw Exception('ID giao dịch không được để trống');
      }
      
      if (request.totalPayment <= 0) {
        throw Exception('Số tiền thanh toán phải lớn hơn 0');
      }
      
      debugPrint('UseCase: Processing payment gateway for transaction ${request.transactionId}');
      
      final response = await paymentRepository.processPaymentGateway(request);
      
      if (response.isSuccess) {
        debugPrint('UseCase: Payment gateway processed successfully');
      } else {
        debugPrint('UseCase: Payment gateway processing failed: ${response.message}');
      }
      
      return response;
    } catch (e) {
      debugPrint('UseCase: Error processing payment gateway: $e');
      rethrow;
    }
  }
  
  /// Helper method to create a wallet deposit request
  Future<PaymentGatewayResponse> depositToWallet({
    required String transactionId,
    required int accountId,
    required double amount,
    required int walletId,
    String paymentMethod = 'Zalo Pay',
  }) async {
    try {
      final request = PaymentGatewayRequest.createWalletDeposit(
        transactionId: transactionId,
        accountId: accountId,
        amount: amount,
        walletId: walletId,
        paymentMethod: paymentMethod,
      );
      
      return await processPaymentGateway(request);
    } catch (e) {
      debugPrint('UseCase: Error depositing to wallet: $e');
      rethrow;
    }
  }
}
