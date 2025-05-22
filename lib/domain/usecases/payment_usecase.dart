import '../repositories/payment_repository.dart';
import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';

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
}
