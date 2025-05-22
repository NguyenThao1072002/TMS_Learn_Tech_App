import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:tms_app/data/services/payment_service.dart';
import 'package:tms_app/domain/repositories/payment_repository.dart';

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
}
